import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiSheetAction {
  const UiSheetAction(this.label, {this.icon, this.subtitle, this.destructive = false, this.enabled = true});

  final String label;
  final IconData? icon;
  final String? subtitle;
  final bool destructive;
  final bool enabled;
}

abstract final class UiSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool scrollable = true,
    bool dismissible = true,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.lg),
  }) =>
      showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: dismissible,
        enableDrag: dismissible,
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9, maxWidth: 640),
        builder: (_) => _SheetBody(title: title, scrollable: scrollable, padding: padding, child: child),
      );

  static Future<int?> actions(
    BuildContext context, {
    required List<UiSheetAction> actions,
    String? title,
  }) {
    if (actions.isEmpty) return Future.value();
    return show<int>(
      context,
      title: title,
      padding: const EdgeInsets.only(bottom: UiSpace.sm),
      child: Builder(
        builder: (c) {
          final cs = c.colors;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, a) in actions.indexed)
                ListTile(
                  enabled: a.enabled,
                  contentPadding: const EdgeInsets.symmetric(horizontal: UiSpace.xxl),
                  leading: a.icon == null ? null : Icon(a.icon, color: a.destructive ? cs.error : cs.onSurfaceVariant),
                  title: Text(
                    a.label,
                    style: c.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: a.destructive ? cs.error : null),
                  ),
                  subtitle: a.subtitle == null ? null : Text(a.subtitle!),
                  onTap: () => Navigator.pop(c, i),
                ),
            ],
          );
        },
      ),
    );
  }

  static Future<T?> select<T>(
    BuildContext context, {
    required List<T> options,
    String Function(T value)? label,
    T? selected,
    String? title,
    IconData Function(T value)? icon,
  }) {
    if (options.isEmpty) return Future.value();
    final name = label ?? (T v) => '$v';
    return show<T>(
      context,
      title: title,
      padding: const EdgeInsets.only(bottom: UiSpace.sm),
      child: Builder(
        builder: (c) {
          final cs = c.colors;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final o in options)
                ListTile(
                  selected: o == selected,
                  contentPadding: const EdgeInsets.symmetric(horizontal: UiSpace.xxl),
                  leading: icon == null ? null : Icon(icon(o)),
                  title: Text(name(o), style: c.text.bodyLarge?.copyWith(fontWeight: o == selected ? FontWeight.w700 : FontWeight.w500)),
                  trailing: o == selected ? Icon(Icons.check_rounded, color: cs.primary) : null,
                  onTap: () => Navigator.pop(c, o),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.title, required this.scrollable, required this.padding, required this.child});

  final String? title;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(UiSpace.xxl, 0, UiSpace.xxl, UiSpace.md),
                child: Semantics(
                  header: true,
                  child: Text(title!, style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
            Flexible(child: scrollable ? SingleChildScrollView(child: body) : body),
          ],
        ),
      ),
    );
  }
}
