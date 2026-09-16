import 'package:flutter/material.dart';

class ThemeListTile extends StatelessWidget {
  const ThemeListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title, overflow: TextOverflow.ellipsis),
      subtitle: subtitle != null ? Text(subtitle!, overflow: TextOverflow.ellipsis) : null,
      trailing: trailing,
      onTap: onTap,
      selected: selected,
    );
  }
}
