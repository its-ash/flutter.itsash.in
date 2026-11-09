import 'package:flutter/material.dart';

import 'package:theme/src/display/ui_format.dart';
import 'package:theme/src/display/ui_list.dart';
import 'package:theme/src/foundation/foundation.dart';

/// File category, picked from the file extension.
enum UiFileKind {
  image,
  video,
  audio,
  pdf,
  archive,
  document,
  code,
  apk,
  generic;

  static const _ext = <UiFileKind, Set<String>>{
    UiFileKind.image: {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'bmp', 'svg', 'tif', 'tiff', 'avif', 'raw'},
    UiFileKind.video: {'mp4', 'mov', 'mkv', 'avi', 'webm', 'm4v', '3gp', 'flv', 'wmv'},
    UiFileKind.audio: {'mp3', 'wav', 'm4a', 'aac', 'flac', 'ogg', 'opus', 'wma', 'amr'},
    UiFileKind.pdf: {'pdf'},
    UiFileKind.archive: {'zip', 'rar', '7z', 'tar', 'gz', 'tgz', 'bz2', 'xz', 'iso', 'dmg'},
    UiFileKind.document: {
      'doc', 'docx', 'txt', 'rtf', 'odt', 'md', 'pages', 'xls', 'xlsx', 'csv', 'ods', 'numbers', 'ppt', 'pptx', //
      'key', 'odp', 'epub',
    },
    UiFileKind.code: {
      'dart', 'js', 'ts', 'jsx', 'tsx', 'py', 'java', 'kt', 'swift', 'c', 'cpp', 'h', 'rs', 'go', 'rb', 'php', //
      'html', 'css', 'json', 'yaml', 'yml', 'xml', 'sh', 'sql', 'toml',
    },
    UiFileKind.apk: {'apk', 'aab', 'xapk', 'apks', 'ipa'},
  };

  /// Kind of a file name or path: `"IMG_01.HEIC"` → [image].
  static UiFileKind fromName(String name) {
    final base = name.split(RegExp(r'[/\\]')).last;
    final dot = base.lastIndexOf('.');
    if (dot <= 0 || dot == base.length - 1) return generic;
    final ext = base.substring(dot + 1).toLowerCase();
    for (final e in _ext.entries) {
      if (e.value.contains(ext)) return e.key;
    }
    return generic;
  }

  IconData get icon => switch (this) {
    UiFileKind.image => Icons.image_rounded,
    UiFileKind.video => Icons.movie_rounded,
    UiFileKind.audio => Icons.music_note_rounded,
    UiFileKind.pdf => Icons.picture_as_pdf_rounded,
    UiFileKind.archive => Icons.folder_zip_rounded,
    UiFileKind.document => Icons.description_rounded,
    UiFileKind.code => Icons.code_rounded,
    UiFileKind.apk => Icons.android_rounded,
    UiFileKind.generic => Icons.insert_drive_file_rounded,
  };

  /// Tint from the palette (null = neutral).
  Color? colorOf(UiColors c) => switch (this) {
    UiFileKind.image => c.chartColor(5),
    UiFileKind.video => c.chartColor(6),
    UiFileKind.audio => c.chartColor(1),
    UiFileKind.pdf => c.danger,
    UiFileKind.archive => c.warning,
    UiFileKind.document => c.info,
    UiFileKind.code => c.chartColor(7),
    UiFileKind.apk => c.success,
    UiFileKind.generic => null,
  };
}

/// A file row: type icon, name, size and optional progress. For downloaders,
/// file transfer, recovery and scanner apps.
///
/// ```dart
/// UiFileTile(name: 'report.pdf', size: 2400000, progress: 0.4)
/// ```
class UiFileTile extends StatelessWidget {
  const UiFileTile({
    super.key,
    required this.name,
    this.size,
    this.subtitle,
    this.progress,
    this.status,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  final String name;

  /// Size in bytes, shown as KB / MB / GB.
  final int? size;

  /// Extra meta text, e.g. a date or "Paused".
  final String? subtitle;

  /// 0..1 shows a progress bar. Null hides it.
  final double? progress;

  /// Colors the progress bar and meta text (e.g. danger for failed).
  final UiStatus? status;

  /// Overrides the icon picked from the extension.
  final IconData? icon;

  /// Replaces the icon box (e.g. an image thumbnail).
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final kind = UiFileKind.fromName(name);
    final tint = kind.colorOf(colors);
    final tone = status == null ? null : colors.tone(status!);
    final p = progress?.clamp(0.0, 1.0);

    final meta = <String>[
      if (size != null)
        p != null && p < 1
            ? '${UiFormat.bytes((size! * p).round())} of ${UiFormat.bytes(size!)}'
            : UiFormat.bytes(size!),
      ?subtitle,
    ].join('  ·  ');
    final metaColor = tone == null || status == UiStatus.neutral ? colors.textMuted : tone.color;

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
      child: Row(
        children: [
          leading ?? UiIconBox(icon ?? kind.icon, size: 40, color: tint, status: UiStatus.neutral),
          const SizedBox(width: UiSpace.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500, height: 1.3),
                ),
                if (meta.isNotEmpty || p != null)
                  Padding(
                    padding: const EdgeInsets.only(top: UiSpace.xxs),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(color: metaColor),
                          ),
                        ),
                        if (p != null)
                          Text(
                            '${(p * 100).round()}%',
                            style: text.bodySmall?.copyWith(
                              color: colors.textMuted,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                      ],
                    ),
                  ),
                if (p != null)
                  Padding(
                    padding: const EdgeInsets.only(top: UiSpace.sm),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: p),
                      duration: context.motion(UiMotion.normal),
                      curve: UiMotion.standard,
                      builder: (context, v, _) => ClipRRect(
                        borderRadius: UiRadius.all(UiRadius.full),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 4,
                          color: tone == null || status == UiStatus.neutral ? colors.accent : tone.color,
                          backgroundColor: colors.surfaceMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: UiSpace.sm), trailing!],
        ],
      ),
    );

    final interactive = onTap != null || onLongPress != null;
    return Semantics(
      button: interactive,
      selected: selected,
      label: name,
      child: Material(
        type: selected ? MaterialType.canvas : MaterialType.transparency,
        color: selected ? colors.accentSoft : null,
        child: InkWell(onTap: onTap, onLongPress: onLongPress, child: row),
      ),
    );
  }
}
