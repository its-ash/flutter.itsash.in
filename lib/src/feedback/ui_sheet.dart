import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Modal bottom sheet with a header, scrollable body and sticky action footer.
///
/// ```dart
/// final saved = await UiSheet.show<bool>(context, title: 'Filters', child: const FiltersForm());
/// ```
abstract final class UiSheet {
  /// Shows [child] in a bottom sheet. Close it with `Navigator.pop(context, value)`.
  ///
  /// The sheet moves above the keyboard. [actions] (usually buttons) stay
  /// pinned at the bottom while the body scrolls.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    String? subtitle,
    List<Widget> actions = const [],
    bool scrollable = true,
    bool expand = false,
    bool isDismissible = true,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(UiSpace.xl, 0, UiSpace.xl, UiSpace.lg),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      sheetAnimationStyle: AnimationStyle(
        duration: context.motion(UiMotion.slow),
        reverseDuration: context.motion(UiMotion.normal),
      ),
      builder: (ctx) => PopScope(
        canPop: isDismissible,
        child: _SheetBody(
          title: title,
          subtitle: subtitle,
          actions: actions,
          scrollable: scrollable,
          expand: expand,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.scrollable,
    required this.expand,
    required this.padding,
    required this.child,
  });

  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final bool scrollable;
  final bool expand;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final media = MediaQuery.of(context);
    final hasHeader = title != null || subtitle != null;

    final body = scrollable
        ? SingleChildScrollView(padding: padding, child: child)
        : Padding(padding: padding, child: child);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: expand ? double.infinity : media.size.height * 0.9),
        child: Column(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(UiSpace.xl, 0, UiSpace.xl, UiSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) Semantics(header: true, child: Text(title!, style: t.titleLarge)),
                    if (subtitle != null) ...[
                      if (title != null) const SizedBox(height: UiSpace.xs),
                      Text(subtitle!, style: t.bodyMedium?.copyWith(color: c.textMuted)),
                    ],
                  ],
                ),
              ),
            Flexible(fit: expand ? FlexFit.tight : FlexFit.loose, child: body),
            if (actions.isNotEmpty)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.surfaceRaised,
                  border: Border(top: BorderSide(color: c.border)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(UiSpace.xl, UiSpace.md, UiSpace.xl, UiSpace.md),
                    child: _ActionsBar(actions: actions),
                  ),
                ),
              )
            else
              const SafeArea(top: false, child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

/// Buttons in a row when they fit, stacked full width (last on top) when not.
class _ActionsBar extends StatelessWidget {
  const _ActionsBar({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (actions.length <= 2 && constraints.maxWidth >= 280) {
          return Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: UiSpace.sm),
                Expanded(child: actions[i]),
              ],
            ],
          );
        }
        final stacked = actions.reversed.toList();
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < stacked.length; i++) ...[if (i > 0) const SizedBox(height: UiSpace.sm), stacked[i]],
          ],
        );
      },
    );
  }
}

/// One row of a [UiActionSheet].
class UiSheetAction<T> {
  const UiSheetAction(
    this.label, {
    required this.value,
    this.icon,
    this.subtitle,
    this.destructive = false,
    this.enabled = true,
  });

  final String label;

  /// Returned from [UiActionSheet.show] when tapped.
  final T value;
  final IconData? icon;
  final String? subtitle;

  /// Danger color, for delete-like actions.
  final bool destructive;
  final bool enabled;
}

/// Bottom sheet with a list of actions and a Cancel button.
///
/// ```dart
/// final v = await UiActionSheet.show<String>(context, actions: [
///   const UiSheetAction('Share', value: 'share', icon: Icons.ios_share_rounded),
///   const UiSheetAction('Delete', value: 'delete', icon: Icons.delete_outline_rounded, destructive: true),
/// ]);
/// ```
abstract final class UiActionSheet {
  /// Returns the chosen action's value, or null when cancelled.
  static Future<T?> show<T>(
    BuildContext context, {
    required List<UiSheetAction<T>> actions,
    String? title,
    String? message,
    String cancelLabel = 'Cancel',
    bool showCancel = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      sheetAnimationStyle: AnimationStyle(
        duration: context.motion(UiMotion.slow),
        reverseDuration: context.motion(UiMotion.normal),
      ),
      builder: (ctx) => _ActionSheetBody<T>(
        title: title,
        message: message,
        actions: actions,
        cancelLabel: showCancel ? cancelLabel : null,
      ),
    );
  }
}

class _ActionSheetBody<T> extends StatelessWidget {
  const _ActionSheetBody({
    required this.title,
    required this.message,
    required this.actions,
    required this.cancelLabel,
  });

  final String? title;
  final String? message;
  final List<UiSheetAction<T>> actions;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final hasHeader = title != null || message != null;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(UiSpace.xl, 0, UiSpace.xl, UiSpace.md),
                child: Column(
                  children: [
                    if (title != null) Text(title!, textAlign: TextAlign.center, style: t.titleSmall),
                    if (message != null) ...[
                      if (title != null) const SizedBox(height: UiSpace.xxs),
                      Text(message!, textAlign: TextAlign.center, style: t.bodySmall),
                    ],
                  ],
                ),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
                children: [for (final a in actions) _ActionRow<T>(action: a)],
              ),
            ),
            if (cancelLabel != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.sm, UiSpace.lg, UiSpace.lg),
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: c.border)),
                  child: Text(cancelLabel!),
                ),
              )
            else
              const SizedBox(height: UiSpace.lg),
          ],
        ),
      ),
    );
  }
}

class _ActionRow<T> extends StatelessWidget {
  const _ActionRow({required this.action});

  final UiSheetAction<T> action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final enabled = action.enabled;
    final fg = !enabled
        ? c.textDisabled
        : action.destructive
        ? c.danger
        : c.text;
    final iconColor = !enabled
        ? c.textDisabled
        : action.destructive
        ? c.danger
        : c.textMuted;
    return InkWell(
      borderRadius: UiRadius.all(UiRadius.md),
      onTap: enabled ? () => Navigator.of(context).pop(action.value) : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.sm),
          child: Row(
            children: [
              if (action.icon != null) ...[
                Icon(action.icon, size: 22, color: iconColor),
                const SizedBox(width: UiSpace.lg),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyLarge?.copyWith(color: fg, fontWeight: FontWeight.w500),
                    ),
                    if (action.subtitle != null)
                      Text(
                        action.subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall?.copyWith(color: enabled ? c.textMuted : c.textDisabled),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
