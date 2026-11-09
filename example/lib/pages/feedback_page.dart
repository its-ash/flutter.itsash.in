import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _popover = UiPopoverController();
  final _menuKey = GlobalKey();
  bool _alert = true;
  bool _offline = false;
  double _progress = 0.3;
  bool _loading = false;
  String _last = 'Nothing yet';
  int _state = 0;

  @override
  void dispose() {
    _popover.dispose();
    super.dispose();
  }

  void _result(Object? value) {
    if (mounted) setState(() => _last = '$value');
  }

  Future<void> _overlay() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      children: [
        UiBanner(
          "You're offline. Changes will sync later.",
          visible: _offline,
          status: UiStatus.warning,
          actionLabel: 'Retry',
          onAction: () => setState(() => _offline = false),
          onDismiss: () => setState(() => _offline = false),
        ),
        Demo(
          'Alerts and banner',
          child: UiColumn(
            children: [
              if (_alert)
                UiAlert(
                  'Your trial ends in 3 days.',
                  title: 'Heads up',
                  status: UiStatus.warning,
                  onClose: () => setState(() => _alert = false),
                ),
              UiAlert(
                'Payment received.',
                status: UiStatus.success,
                action: TextButton(
                  onPressed: () => setState(() => _alert = true),
                  child: const Text('Show warning again'),
                ),
              ),
              const UiAlert('Could not reach the server.', status: UiStatus.danger, title: 'Error'),
              UiSwitch(_offline, label: 'Offline banner', onChanged: (v) => setState(() => _offline = v)),
            ],
          ),
        ),
        Demo(
          'Toasts and snackbar',
          child: DemoWrap(
            children: [
              for (final s in [UiStatus.neutral, UiStatus.success, UiStatus.warning, UiStatus.danger])
                UiButton(
                  s.name,
                  variant: UiButtonVariant.outline,
                  status: s == UiStatus.neutral ? null : s,
                  onPressed: () => UiToast.show(context, 'A ${s.name} toast', title: 'Toast', status: s),
                ),
              UiButton(
                'With undo',
                variant: UiButtonVariant.secondary,
                onPressed: () => context.showToast(
                  'Message archived',
                  actionLabel: 'Undo',
                  onAction: () => context.showToast('Restored', status: UiStatus.success),
                  position: UiToastPosition.bottom,
                ),
              ),
              UiButton(
                'Snackbar',
                variant: UiButtonVariant.secondary,
                onPressed: () =>
                    context.showSnack('Archived', action: 'Undo', onAction: () {}, status: UiStatus.success),
              ),
              UiButton('Dismiss all', variant: UiButtonVariant.ghost, onPressed: UiToast.dismissAll),
            ],
          ),
        ),
        Demo(
          'Dialogs and sheets',
          subtitle: 'Last result: $_last',
          child: DemoWrap(
            children: [
              UiButton(
                'Confirm',
                onPressed: () async => _result(
                  await UiDialog.confirm(
                    context,
                    title: 'Delete note?',
                    message: 'This cannot be undone.',
                    destructive: true,
                  ),
                ),
              ),
              UiButton(
                'Alert',
                variant: UiButtonVariant.soft,
                onPressed: () async {
                  await UiDialog.alert(
                    context,
                    title: 'Update ready',
                    message: 'Restart to apply it.',
                    status: UiStatus.success,
                  );
                  _result('alert closed');
                },
              ),
              UiButton(
                'Prompt',
                variant: UiButtonVariant.soft,
                onPressed: () async => _result(
                  await UiDialog.prompt(
                    context,
                    title: 'Rename',
                    label: 'Name',
                    initialValue: 'Untitled',
                    validator: (v) => v.trim().isEmpty ? 'Enter a name' : null,
                  ),
                ),
              ),
              UiButton(
                'Custom dialog',
                variant: UiButtonVariant.outline,
                onPressed: () async => _result(
                  await UiDialog.show<String>(
                    context,
                    title: 'Unsaved changes',
                    message: 'Save before leaving?',
                    icon: Icons.save_outlined,
                    actions: const [
                      UiDialogAction('Discard', value: 'discard', destructive: true),
                      UiDialogAction('Save', value: 'save', primary: true),
                    ],
                  ),
                ),
              ),
              UiButton(
                'Sheet',
                variant: UiButtonVariant.outline,
                onPressed: () async => _result(
                  await UiSheet.show<String>(
                    context,
                    title: 'Filters',
                    subtitle: 'Pick one and apply',
                    child: const _SheetBody(),
                  ),
                ),
              ),
              UiButton(
                'Action sheet',
                variant: UiButtonVariant.outline,
                onPressed: () async => _result(
                  await UiActionSheet.show<String>(
                    context,
                    title: 'Photo',
                    actions: const [
                      UiSheetAction('Share', value: 'share', icon: Icons.ios_share_rounded),
                      UiSheetAction(
                        'Duplicate',
                        value: 'duplicate',
                        icon: Icons.copy_rounded,
                        subtitle: 'Makes a copy',
                      ),
                      UiSheetAction('Delete', value: 'delete', icon: Icons.delete_outline_rounded, destructive: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Demo(
          'Menus, popover, tooltip',
          child: DemoWrap(
            children: [
              UiButton(
                'Open menu',
                key: _menuKey,
                trailingIcon: Icons.expand_more_rounded,
                variant: UiButtonVariant.secondary,
                onPressed: () async => _result(
                  await UiMenu.show<String>(
                    context,
                    anchorKey: _menuKey,
                    items: const [
                      UiMenuItem('edit', 'Edit', icon: Icons.edit_outlined, shortcut: '⌘E'),
                      UiMenuItem('copy', 'Copy', icon: Icons.copy_rounded, shortcut: '⌘C'),
                      UiMenuItem.divider(),
                      UiMenuItem('delete', 'Delete', icon: Icons.delete_outline_rounded, destructive: true),
                    ],
                  ),
                ),
              ),
              UiMenuButton<String>(
                items: const [UiMenuItem('rename', 'Rename'), UiMenuItem('archive', 'Archive')],
                onSelected: _result,
              ),
              UiPopover(
                controller: _popover,
                openOnTap: false,
                popover: (context) => UiColumn(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Popover', style: context.text.titleSmall),
                    const Text('Anchored to the button. Tap outside to close.'),
                    UiButton('Close', size: UiSize.sm, onPressed: _popover.hide),
                  ],
                ),
                child: UiButton('Popover', variant: UiButtonVariant.outline, onPressed: _popover.toggle),
              ),
              const UiTooltip('Tooltips use the inverse surface', child: Icon(Icons.info_outline_rounded)),
            ],
          ),
        ),
        Demo(
          'Progress',
          child: UiColumn(
            children: [
              UiProgressBar(_progress, label: 'Uploading', showPercent: true),
              const UiProgressBar(null, status: UiStatus.success),
              UiRow(
                gap: UiSpace.lg,
                children: [
                  UiProgressRing(_progress, showPercent: true, size: 64),
                  const UiProgressRing(null),
                  const UiSpinner(),
                  const Spacer(),
                  UiButton(
                    '+10%',
                    size: UiSize.sm,
                    variant: UiButtonVariant.soft,
                    onPressed: () => setState(() => _progress = _progress >= 1 ? 0 : (_progress + 0.1).clamp(0, 1)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Demo(
          'Skeletons',
          child: UiShimmer(
            child: UiColumn(
              children: const [
                UiRow(
                  children: [
                    UiSkeleton.circle(size: 48),
                    Expanded(child: UiSkeleton.text(lines: 2)),
                  ],
                ),
                UiSkeleton.box(height: 100),
                UiSkeletonList(count: 2),
              ],
            ),
          ),
        ),
        Demo(
          'States',
          child: UiColumn(
            children: [
              UiSegmentedControl<int>(
                const [UiSegment(0, label: 'Empty'), UiSegment(1, label: 'Error'), UiSegment(2, label: 'Success')],
                value: _state,
                expand: true,
                onChanged: (v) => setState(() => _state = v),
              ),
              UiSurface(
                child: switch (_state) {
                  0 => UiEmptyState(
                    title: 'No notes yet',
                    message: 'Tap the button to write one.',
                    compact: true,
                    action: UiButton('New note', icon: Icons.add_rounded, onPressed: () => setState(() => _state = 2)),
                  ),
                  1 => UiErrorState(
                    message: 'Check your connection.',
                    compact: true,
                    onRetry: () => setState(() => _state = 2),
                  ),
                  _ => UiSuccessState(
                    title: 'All done',
                    message: 'We emailed your receipt.',
                    compact: true,
                    action: UiButton(
                      'Reset',
                      variant: UiButtonVariant.ghost,
                      onPressed: () => setState(() => _state = 0),
                    ),
                  ),
                },
              ),
            ],
          ),
        ),
        Demo(
          'Loading overlay',
          child: UiLoadingOverlay(
            loading: _loading,
            message: 'Saving…',
            child: UiSurface(
              child: UiColumn(
                children: [
                  const Text('The overlay blocks this card for 2 seconds.'),
                  UiButton('Save', onPressed: _loading ? null : _overlay),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetBody extends StatefulWidget {
  const _SheetBody();

  @override
  State<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends State<_SheetBody> {
  String _sort = 'new';

  @override
  Widget build(BuildContext context) {
    return UiColumn(
      children: [
        UiRadioGroup<String>(
          value: _sort,
          options: const [UiChoice('new', 'Newest'), UiChoice('pop', 'Most popular'), UiChoice('price', 'Price')],
          onChanged: (v) => setState(() => _sort = v),
        ),
        UiButton('Apply', expand: true, onPressed: () => Navigator.pop(context, _sort)),
      ],
    );
  }
}
