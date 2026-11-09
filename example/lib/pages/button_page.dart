import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});

  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  int _taps = 0;
  bool _saving = false;
  String _range = 'week';
  bool _bold = true;
  bool _italic = false;
  Set<String> _sizes = {'m'};
  Set<String> _days = {'mon', 'wed'};
  UiSize _size = UiSize.md;

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _saving = false);
    context.showToast('Saved', status: UiStatus.success);
  }

  void _tap(String what) {
    setState(() => _taps++);
    context.showToast('$what pressed ($_taps)', replace: true, duration: const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      children: [
        Demo(
          'Size',
          child: UiSegmentedControl<UiSize>(
            const [
              UiSegment(UiSize.sm, label: 'Small'),
              UiSegment(UiSize.md, label: 'Medium'),
              UiSegment(UiSize.lg, label: 'Large'),
            ],
            value: _size,
            onChanged: (v) => setState(() => _size = v),
          ),
        ),
        Demo(
          'Variants',
          subtitle: 'Tapped $_taps times',
          child: DemoWrap(
            children: [
              for (final v in UiButtonVariant.values)
                UiButton(v.name, variant: v, size: _size, onPressed: () => _tap(v.name)),
              UiButton('Disabled', size: _size, onPressed: null),
            ],
          ),
        ),
        Demo(
          'Icons, loading, status',
          child: DemoWrap(
            children: [
              UiButton(
                'Save',
                icon: Icons.save_outlined,
                size: _size,
                loading: _saving,
                onPressed: _saving ? null : _save,
              ),
              UiButton('Next', trailingIcon: Icons.arrow_forward_rounded, size: _size, onPressed: () => _tap('Next')),
              UiButton(
                'Approve',
                variant: UiButtonVariant.soft,
                status: UiStatus.success,
                icon: Icons.check_rounded,
                size: _size,
                onPressed: () => _tap('Approve'),
              ),
              UiButton(
                'Warn',
                variant: UiButtonVariant.outline,
                status: UiStatus.warning,
                size: _size,
                onPressed: () => _tap('Warn'),
              ),
            ],
          ),
        ),
        Demo(
          'Full width',
          child: UiButton('Continue', expand: true, size: _size, onPressed: () => _tap('Continue')),
        ),
        Demo(
          'Icon buttons',
          child: DemoWrap(
            children: [
              UiIconButton(
                Icons.notifications_outlined,
                tooltip: 'Inbox',
                badge: _taps,
                onPressed: () => _tap('Inbox'),
              ),
              UiIconButton(Icons.favorite_border_rounded, tooltip: 'Like', dot: true, onPressed: () => _tap('Like')),
              UiIconButton(
                Icons.add_rounded,
                tooltip: 'Add',
                variant: UiButtonVariant.primary,
                circular: true,
                onPressed: () => _tap('Add'),
              ),
              UiIconButton(
                Icons.delete_outline_rounded,
                tooltip: 'Delete',
                variant: UiButtonVariant.soft,
                status: UiStatus.danger,
                onPressed: () => _tap('Delete'),
              ),
              UiIconButton(Icons.refresh_rounded, tooltip: 'Refreshing', loading: true, onPressed: () {}),
              const UiIconButton(Icons.block_rounded, tooltip: 'Disabled', onPressed: null),
            ],
          ),
        ),
        Demo(
          'FAB',
          child: DemoWrap(
            children: [
              UiFab(Icons.add_rounded, tooltip: 'Create', onPressed: () => _tap('FAB')),
              UiFab(Icons.edit_rounded, label: 'Compose', onPressed: () => _tap('Compose')),
              UiFab(
                Icons.share_rounded,
                label: 'Share',
                variant: UiButtonVariant.secondary,
                onPressed: () => _tap('Share'),
              ),
            ],
          ),
        ),
        Demo(
          'Button bar',
          subtitle: 'Stacks with the primary action on top when narrow',
          child: UiButtonBar([
            UiButton('Cancel', variant: UiButtonVariant.outline, onPressed: () => _tap('Cancel')),
            UiButton('Save draft', variant: UiButtonVariant.secondary, onPressed: () => _tap('Save draft')),
            UiButton('Publish', onPressed: () => _tap('Publish')),
          ]),
        ),
        Demo(
          'Segmented control',
          child: UiSegmentedControl<String>(
            const [
              UiSegment('day', label: 'Day'),
              UiSegment('week', label: 'Week'),
              UiSegment('month', label: 'Month', icon: Icons.calendar_month_outlined),
            ],
            value: _range,
            expand: true,
            onChanged: (v) => setState(() => _range = v),
          ),
        ),
        Demo(
          'Toggles',
          child: UiColumn(
            children: [
              DemoWrap(
                children: [
                  UiToggleButton(
                    'Bold',
                    icon: Icons.format_bold_rounded,
                    selected: _bold,
                    onChanged: (v) => setState(() => _bold = v),
                  ),
                  UiToggleButton.icon(
                    Icons.format_italic_rounded,
                    tooltip: 'Italic',
                    selected: _italic,
                    onChanged: (v) => setState(() => _italic = v),
                  ),
                ],
              ),
              Text(
                'Preview text',
                style: context.text.bodyLarge!.copyWith(
                  fontWeight: _bold ? FontWeight.w700 : FontWeight.w400,
                  fontStyle: _italic ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              UiToggleGroup<String>(
                const [UiSegment('s', label: 'S'), UiSegment('m', label: 'M'), UiSegment('l', label: 'L')],
                selected: _sizes,
                onChanged: (s) => setState(() => _sizes = s),
              ),
              UiToggleGroup<String>(
                const [
                  UiSegment('mon', label: 'Mon'),
                  UiSegment('tue', label: 'Tue'),
                  UiSegment('wed', label: 'Wed'),
                  UiSegment('thu', label: 'Thu'),
                  UiSegment('fri', label: 'Fri'),
                ],
                selected: _days,
                multiple: true,
                onChanged: (s) => setState(() => _days = s),
              ),
            ],
          ),
        ),
        Demo(
          'Copy, social, hold',
          child: UiColumn(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DemoWrap(
                children: [
                  const UiCopyButton('sk_live_42'),
                  UiCopyButton(
                    'https://example.com/invite/42',
                    label: 'Copy link',
                    variant: UiButtonVariant.outline,
                    onCopied: () => context.showToast('Link copied'),
                  ),
                ],
              ),
              UiSocialButton('Google', icon: Icons.g_mobiledata_rounded, onPressed: () => _tap('Google')),
              UiSocialButton('Apple', icon: Icons.apple_rounded, onPressed: () => _tap('Apple')),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: UiHoldButton(
                  'Hold to delete',
                  icon: Icons.delete_rounded,
                  onConfirmed: () => context.showToast('Deleted', status: UiStatus.danger),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
