import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_avatar.dart';

class UiContactItem {
  const UiContactItem({required this.name, this.imageUrl, this.id});

  final String name;
  final String? imageUrl;
  final String? id;
}

class UiContactAvatarRow extends StatelessWidget {
  const UiContactAvatarRow({
    super.key,
    required this.contacts,
    this.onTap,
    this.onAdd,
    this.addLabel = 'New',
    this.selectedIndex,
    this.size = 56,
    this.padding = UiSpace.page,
  });

  final List<UiContactItem> contacts;
  final ValueChanged<UiContactItem>? onTap;
  final VoidCallback? onAdd;
  final String addLabel;
  final int? selectedIndex;
  final double size;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final hasAdd = onAdd != null;
    if (contacts.isEmpty && !hasAdd) return const SizedBox.shrink();
    final cs = context.colors;
    final dim = size.clamp(36.0, 96.0);
    final label = context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600);

    Widget cell({required Widget avatar, required String name, VoidCallback? tap, bool selected = false}) => Semantics(
          button: tap != null,
          selected: selected,
          label: name,
          child: ExcludeSemantics(
            child: InkWell(
              onTap: tap,
              borderRadius: context.tokens.md,
              child: SizedBox(
                width: dim + 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const UiGap.xs(),
                    avatar,
                    const UiGap.sm(),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: selected ? label?.copyWith(color: cs.primary, fontWeight: FontWeight.w800) : label,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

    final count = contacts.length + (hasAdd ? 1 : 0);
    return SizedBox(
      height: dim + 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: count,
        separatorBuilder: (_, _) => const UiGap.xs(),
        itemBuilder: (_, i) {
          if (hasAdd && i == 0) {
            return cell(
              name: addLabel,
              tap: onAdd,
              avatar: Container(
                width: dim,
                height: dim,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outlineVariant, width: 1.5),
                ),
                child: Icon(Icons.add_rounded, color: cs.primary, size: dim * 0.45),
              ),
            );
          }
          final idx = hasAdd ? i - 1 : i;
          final c = contacts[idx];
          final first = c.name.trim().split(RegExp(r'\s+')).first;
          final sel = selectedIndex == idx;
          return cell(
            name: first.isEmpty ? c.name : first,
            selected: sel,
            tap: onTap == null ? null : () => onTap!(c),
            avatar: UiAvatar(name: c.name, imageUrl: c.imageUrl, size: dim, ring: sel),
          );
        },
      ),
    );
  }
}
