import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

class FeedbackSection extends StatefulWidget {
  const FeedbackSection({super.key});

  @override
  State<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  double _progress = 0.62;
  bool _banner = true;
  bool _shimmer = true;
  int _count = 7;

  Future<void> _confirm() async {
    final ok = await UiDialog.confirm(
      context,
      title: 'Delete item?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (mounted) context.showToast(ok ? 'Deleted' : 'Kept', status: ok ? UiStatus.danger : UiStatus.neutral);
  }

  Future<void> _input() async {
    final name = await UiDialog.input(
      context,
      title: 'Rename',
      message: 'Give the list a new name.',
      hint: 'Groceries',
      initialValue: 'My list',
      maxLength: 24,
      validator: (v) => v.trim().isEmpty ? 'Required' : null,
    );
    if (mounted && name != null) context.showToast('Renamed to $name', status: UiStatus.success);
  }

  Future<void> _actions() async {
    final i = await UiSheet.actions(
      context,
      title: 'Photo',
      actions: const [
        UiSheetAction('Share', icon: Icons.share_rounded),
        UiSheetAction('Edit', icon: Icons.edit_rounded, subtitle: 'Crop and filters'),
        UiSheetAction('Archive', icon: Icons.archive_rounded, enabled: false),
        UiSheetAction('Delete', icon: Icons.delete_rounded, destructive: true),
      ],
    );
    if (mounted && i != null) context.showSnack('Action $i', actionLabel: 'Undo', onAction: () {});
  }

  Future<void> _select() async {
    final size = await UiSheet.select<String>(
      context,
      title: 'Size',
      options: const ['XS', 'S', 'M', 'L', 'XL'],
      selected: 'M',
      icon: (_) => Icons.straighten_rounded,
    );
    if (mounted && size != null) context.showToast('Size $size');
  }

  Future<void> _overlay() async {
    final v = await UiLoader.overlay(context, Future.delayed(const Duration(seconds: 2), () => 42), message: 'Saving');
    if (mounted) context.showToast('Saved: $v', status: UiStatus.success);
  }

  @override
  Widget build(BuildContext context) => SectionPage(
        children: [
          DemoBlock(
            'Toast and snack',
            child: WrapRow(
              children: [
                for (final s in UiStatus.values)
                  UiButton.tonal(
                    'Toast ${s.name}',
                    size: UiSize.sm,
                    onPressed: () => context.showToast('Profile saved', title: s.name.toUpperCase(), status: s),
                  ),
                UiButton.outline(
                  'Snack',
                  size: UiSize.sm,
                  onPressed: () => context.showSnack('Item removed', actionLabel: 'Undo', onAction: () => context.showToast('Restored')),
                ),
                UiButton.ghost('Dismiss toast', size: UiSize.sm, onPressed: UiToast.dismiss),
              ],
            ),
          ),
          DemoBlock(
            'UiDialog',
            child: WrapRow(
              children: [
                UiButton.tonal('Confirm', size: UiSize.sm, onPressed: _confirm),
                UiButton.tonal(
                  'Alert',
                  size: UiSize.sm,
                  onPressed: () => UiDialog.alert(
                    context,
                    title: 'Card expires soon',
                    message: 'Update your card to keep your plan.',
                    status: UiStatus.warning,
                  ),
                ),
                UiButton.tonal('Input', size: UiSize.sm, onPressed: _input),
                UiButton.tonal('Success', size: UiSize.sm, onPressed: () => UiDialog.success(context, message: 'Payment complete')),
                UiButton.tonal(
                  'Custom',
                  size: UiSize.sm,
                  onPressed: () => UiDialog.show<void>(
                    context,
                    title: 'Rate us',
                    icon: Icons.star_rounded,
                    status: UiStatus.info,
                    child: const Center(child: UiRatingStars(4.5, size: 28)),
                    actions: [UiButton('Close', onPressed: () => Navigator.pop(context))],
                  ),
                ),
              ],
            ),
          ),
          DemoBlock(
            'UiSheet',
            child: WrapRow(
              children: [
                UiButton.tonal(
                  'Show sheet',
                  size: UiSize.sm,
                  onPressed: () => UiSheet.show<void>(
                    context,
                    title: 'Filters',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final f in ['Free shipping', 'On sale', 'In stock', 'Top rated'])
                          UiListTile(icon: Icons.filter_alt_rounded, title: f, dense: true),
                        const UiGap.md(),
                        UiButton('Apply', expand: true, onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                ),
                UiButton.tonal('Actions', size: UiSize.sm, onPressed: _actions),
                UiButton.tonal('Select', size: UiSize.sm, onPressed: _select),
                UiButton.tonal('Loader overlay', size: UiSize.sm, onPressed: _overlay),
              ],
            ),
          ),
          DemoBlock(
            'UiBanner',
            child: Column(
              children: [
                if (_banner)
                  UiBanner(
                    'Your card expires soon.',
                    title: 'Heads up',
                    status: UiStatus.warning,
                    actionLabel: 'Update',
                    onAction: () => toast(context, 'Update card'),
                    onClose: () => setState(() => _banner = false),
                  )
                else
                  UiButton.ghost('Show banner again', onPressed: () => setState(() => _banner = true)),
                for (final s in [UiStatus.info, UiStatus.success, UiStatus.danger, UiStatus.neutral]) ...[
                  const UiGap.sm(),
                  UiBanner('A ${s.name} message for the user.', status: s),
                ],
              ],
            ),
          ),
          DemoBlock(
            'UiEmptyState and UiErrorState',
            child: Column(
              children: [
                UiEmptyState(
                  title: 'No orders yet',
                  message: 'Your orders show here.',
                  icon: Icons.receipt_long_rounded,
                  actionLabel: 'Shop now',
                  onAction: () => toast(context, 'Shop'),
                ),
                const UiEmptyState(title: 'Compact empty', message: 'Nothing here', compact: true, status: UiStatus.info),
                UiErrorState(onRetry: () => toast(context, 'Retry'), compact: true),
              ],
            ),
          ),
          DemoBlock(
            'UiLoader',
            child: const WrapRow(children: [UiLoader(), UiLoader(message: 'Loading', size: 24)]),
          ),
          DemoBlock(
            'UiShimmer and UiSkeleton',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UiSwitchTile('Shimmer', value: _shimmer, onChanged: (v) => setState(() => _shimmer = v)),
                const UiGap.md(),
                UiShimmer(
                  enabled: _shimmer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UiSkeleton.box(height: 120),
                      const UiGap.sm(),
                      UiSkeleton.line(width: 180),
                      const UiGap.xs(),
                      UiSkeleton.line(width: 120, height: 10),
                      const UiGap.md(),
                      Row(children: [UiSkeleton.circle(), const UiGap.md(), Expanded(child: UiSkeleton.line())]),
                      const UiGap.md(),
                      UiSkeleton.listTile(avatar: true, lines: 2, trailing: true),
                      const UiGap.md(),
                      SizedBox(width: 220, child: UiSkeleton.card(imageHeight: 120, lines: 2)),
                    ],
                  ),
                ),
                const UiGap.md(),
                UiSkeleton.list(count: 3, avatar: true),
              ],
            ),
          ),
          DemoBlock(
            'UiProgressBar and UiProgressRing',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UiProgressBar(_progress, label: 'Storage', showPercent: true),
                const UiGap.md(),
                UiProgressBar(0.9, label: 'Quota', trailing: '9 of 10 GB', status: UiStatus.danger, height: 12),
                const UiGap.md(),
                UiSlider(value: _progress * 100, label: 'Value', onChanged: (v) => setState(() => _progress = v / 100)),
                const UiGap.md(),
                WrapRow(
                  children: [
                    UiProgressRing(_progress),
                    UiProgressRing(0.75, label: 'Goal', status: UiStatus.success),
                    UiProgressRing(0.3, size: 96, stroke: 10, status: UiStatus.warning),
                    const UiProgressRing(1, size: 56, showPercent: false, child: Icon(Icons.check_rounded)),
                  ],
                ),
              ],
            ),
          ),
          DemoBlock(
            'UiStatusDot, UiBadge, UiTooltip, UiStatusIcon',
            child: WrapRow(
              children: [
                const UiStatusDot(label: 'Online', pulse: true),
                const UiStatusDot(status: UiStatus.warning, label: 'Away'),
                const UiStatusDot(status: UiStatus.danger, label: 'Busy'),
                UiBadge(count: _count, child: const Icon(Icons.mail_outline_rounded)),
                const UiBadge(count: 120, child: Icon(Icons.notifications_rounded)),
                const UiBadge(dot: true, status: UiStatus.success, child: Icon(Icons.chat_bubble_outline_rounded)),
                UiButton.ghost('+1', size: UiSize.sm, onPressed: () => setState(() => _count++)),
                const UiTooltip('Copy link', child: Icon(Icons.link_rounded)),
                const UiTooltip('Tap to see', tap: true, child: Icon(Icons.info_outline_rounded)),
                for (final s in UiStatus.values) Icon(s.icon, color: context.tone(s).color),
              ],
            ),
          ),
        ],
      );
}
