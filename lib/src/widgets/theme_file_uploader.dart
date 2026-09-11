import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:theme/src/typography/app_typography.dart';
import 'package:theme/src/components/theme_button.dart';

class ThemeFileUploader extends StatefulWidget {
  const ThemeFileUploader({
    super.key,
    this.onFilesPicked,
    this.allowMultiple = false,
    this.type = FileType.any,
    this.allowedExtensions,
    this.label = 'Choose file',
    this.hint = 'or drag and drop',
  });

  final ValueChanged<List<PlatformFile>>? onFilesPicked;
  final bool allowMultiple;
  final FileType type;
  final List<String>? allowedExtensions;
  final String label;
  final String hint;

  @override
  State<ThemeFileUploader> createState() => _ThemeFileUploaderState();
}

class _ThemeFileUploaderState extends State<ThemeFileUploader> {
  final List<PlatformFile> _files = [];
  bool _picking = false;

  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final List<PlatformFile> result;
      if (widget.allowMultiple) {
        result = await FilePicker.pickFiles(
          type: widget.type,
          allowedExtensions: widget.allowedExtensions,
        );
      } else {
        final file = await FilePicker.pickFile(
          type: widget.type,
          allowedExtensions: widget.allowedExtensions,
        );
        result = file == null ? [] : [file];
      }
      if (result.isNotEmpty && mounted) {
        setState(() {
          if (widget.allowMultiple) {
            _files.addAll(result);
          } else {
            _files
              ..clear()
              ..addAll(result);
          }
        });
        widget.onFilesPicked?.call(_files);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _remove(PlatformFile file) {
    setState(() => _files.remove(file));
    widget.onFilesPicked?.call(_files);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DottedBorderBox(
          onTap: _picking ? null : _pick,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined, size: 32, color: scheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                ThemeButton(
                  label: widget.label,
                  variant: ThemeButtonVariant.outlined,
                  onPressed: _picking ? null : _pick,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.hint,
                  style: AppTypography.bodyMedium.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_files.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final file in _files)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.insert_drive_file_outlined, color: scheme.onSurface.withValues(alpha: 0.7)),
              title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => _remove(file),
              ),
            ),
        ],
      ],
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  double _cardRadius(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = _cardRadius(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: scheme.outline, style: BorderStyle.solid),
        ),
        child: child,
      ),
    );
  }
}
