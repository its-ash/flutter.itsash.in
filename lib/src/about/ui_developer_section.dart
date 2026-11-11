import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:theme/src/display/display.dart';

/// Who made the apps. Shown by [UiDeveloperSection].
abstract final class UiDeveloper {
  static const name = 'Ashvini Jangid';
  static const website = 'https://itsash.github.io';

  /// [website] without the scheme, for display.
  static const websiteLabel = 'itsash.github.io';
}

/// The "Developer" group at the bottom of every app's settings screen:
/// "Developed by Ashvini Jangid" and a link to the portfolio.
///
/// ```dart
/// const UiDeveloperSection()
/// ```
class UiDeveloperSection extends StatelessWidget {
  const UiDeveloperSection({super.key, this.header = 'Developer'});

  /// Caption above the group.
  final String header;

  @override
  Widget build(BuildContext context) {
    return UiListGroup(
      header: header,
      children: [
        const UiListTile('Developed by', icon: Icons.person_rounded, value: UiDeveloper.name),
        UiListTile(
          'Portfolio',
          subtitle: UiDeveloper.websiteLabel,
          icon: Icons.language_rounded,
          trailing: const Icon(Icons.open_in_new_rounded, size: 18),
          onTap: () => UiUrl.open(UiDeveloper.website),
        ),
      ],
    );
  }
}

/// Opens links outside the app.
abstract final class UiUrl {
  /// Opens [url] in the browser or the app that handles it. False on failure.
  static Future<bool> open(String url) async {
    try {
      return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
