import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:theme/src/about/ui_developer_section.dart';
import 'package:theme/src/button/button.dart';
import 'package:theme/src/display/display.dart';
import 'package:theme/src/feedback/feedback.dart';
import 'package:theme/src/foundation/foundation.dart';

/// The latest GitHub release of an Ash Store app.
class UiRelease {
  const UiRelease({required this.version, required this.apkUrl});

  /// Version without the leading `v` (`1.2.3`).
  final String version;

  /// Direct link to the release APK.
  final String apkUrl;
}

/// Looks up the latest release of `<owner>/<storeId>` on GitHub and compares
/// versions. Used by [UiUpdateSection]; usable on its own.
abstract final class UiUpdater {
  /// `https://github.com/<owner>/<id>/releases/latest/download/<id>.apk`.
  static String latestApkUrl(String storeId, {String owner = 'its-ash'}) =>
      'https://github.com/$owner/$storeId/releases/latest/download/$storeId.apk';

  /// Fetches the latest release. Throws when offline or GitHub fails.
  static Future<UiRelease> latest(String storeId, {String owner = 'its-ash'}) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final req = await client.getUrl(Uri.parse('https://api.github.com/repos/$owner/$storeId/releases/latest'));
      req.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set(HttpHeaders.userAgentHeader, storeId);
      final res = await req.close().timeout(const Duration(seconds: 15));
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode == 404) throw const HttpException('No release published yet');
      if (res.statusCode != 200) throw HttpException('GitHub returned ${res.statusCode}');
      final json = jsonDecode(body) as Map<String, dynamic>;
      final tag = (json['tag_name'] as String? ?? '').replaceFirst(RegExp('^v'), '');
      var apk = latestApkUrl(storeId, owner: owner);
      for (final a in (json['assets'] as List? ?? const [])) {
        if (a is Map && a['name'] == '$storeId.apk' && a['browser_download_url'] is String) {
          apk = a['browser_download_url'] as String;
        }
      }
      return UiRelease(version: tag, apkUrl: apk);
    } finally {
      client.close(force: true);
    }
  }

  /// True when [latest] is a higher `x.y.z` than [current]. Build numbers
  /// (`+N`) and pre-release tags are ignored.
  static bool isNewer(String latest, String current) {
    List<int> parse(String v) => v
        .replaceFirst(RegExp('^v'), '')
        .split(RegExp('[+-]'))
        .first
        .split('.')
        .map((p) => int.tryParse(p) ?? 0)
        .toList();
    final a = parse(latest), b = parse(current);
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0, y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }
}

enum _Status { idle, checking, upToDate, available, failed }

/// The "Updates" group for an app's settings screen. Shows the installed
/// version, checks GitHub for a newer release when the screen opens, and
/// offers a button that downloads the new APK in the browser.
///
/// ```dart
/// const UiUpdateSection(storeId: 'linkdrop')
/// ```
///
/// Needs the `INTERNET` permission. For an offline app pass
/// `checkForUpdates: false`: the row then only opens the latest download.
class UiUpdateSection extends StatefulWidget {
  const UiUpdateSection({
    super.key,
    required this.storeId,
    this.owner = 'its-ash',
    this.checkForUpdates = true,
    this.header = 'Updates',
  });

  /// Store id = GitHub repo name = APK name (`<id>.apk`).
  final String storeId;

  /// GitHub owner of the repo.
  final String owner;

  /// Check GitHub when the section is shown. False for apps without internet.
  final bool checkForUpdates;

  /// Caption above the group.
  final String header;

  @override
  State<UiUpdateSection> createState() => _UiUpdateSectionState();
}

class _UiUpdateSectionState extends State<UiUpdateSection> {
  String? _version;
  late _Status _status = widget.checkForUpdates ? _Status.checking : _Status.idle;
  UiRelease? _latest;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (_) {}
    if (widget.checkForUpdates) await _check();
  }

  Future<void> _check() async {
    setState(() {
      _status = _Status.checking;
      _error = null;
    });
    try {
      final latest = await UiUpdater.latest(widget.storeId, owner: widget.owner);
      if (!mounted) return;
      final current = _version;
      setState(() {
        _latest = latest;
        _status = current != null && !UiUpdater.isNewer(latest.version, current) ? _Status.upToDate : _Status.available;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _Status.failed;
        _error = e is SocketException || e is TimeoutException
            ? 'No internet connection'
            : e is HttpException
            ? e.message
            : 'Something went wrong';
      });
    }
  }

  Future<void> _download() async {
    final url = _latest?.apkUrl ?? UiUpdater.latestApkUrl(widget.storeId, owner: widget.owner);
    final ok = await UiUrl.open(url);
    if (!mounted) return;
    context.showToast(
      ok ? 'Downloading the update. Open the file when it finishes to install it.' : 'Could not open the download link.',
      status: ok ? UiStatus.success : UiStatus.danger,
    );
  }

  @override
  Widget build(BuildContext context) {
    final version = _version;
    final latest = _latest;
    final Widget status = switch (_status) {
      _Status.idle => UiListTile(
        'Get the latest version',
        subtitle: 'Downloads the newest release in your browser',
        icon: Icons.system_update_rounded,
        chevron: true,
        onTap: _download,
      ),
      _Status.checking => const UiListTile(
        'Checking for updates…',
        icon: Icons.sync_rounded,
        trailing: UiSpinner(size: 18),
      ),
      _Status.upToDate => UiListTile(
        'You have the latest version',
        icon: Icons.check_circle_rounded,
        iconStatus: UiStatus.success,
        trailing: UiButton('Check', size: UiSize.sm, variant: UiButtonVariant.ghost, onPressed: _check),
      ),
      _Status.available => UiListTile(
        'Update available',
        subtitle: latest == null ? null : 'Version ${latest.version} is ready',
        icon: Icons.system_update_rounded,
        iconStatus: UiStatus.success,
        trailing: UiButton('Update', size: UiSize.sm, icon: Icons.download_rounded, onPressed: _download),
      ),
      _Status.failed => UiListTile(
        "Couldn't check for updates",
        subtitle: _error,
        icon: Icons.cloud_off_rounded,
        iconStatus: UiStatus.warning,
        trailing: UiButton('Retry', size: UiSize.sm, variant: UiButtonVariant.ghost, onPressed: _check),
      ),
    };
    return UiListGroup(
      header: widget.header,
      footer: widget.checkForUpdates
          ? 'Checks GitHub each time you open settings. Updates download in your browser; open the file to install.'
          : null,
      children: [
        UiListTile('Version', icon: Icons.tag_rounded, iconStatus: UiStatus.neutral, value: version ?? '…'),
        status,
      ],
    );
  }
}
