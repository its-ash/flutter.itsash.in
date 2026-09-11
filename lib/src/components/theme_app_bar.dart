import 'package:flutter/material.dart';

class ThemeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ThemeAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
    this.leadingWidth,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle;
  final bool automaticallyImplyLeading;
  final double? leadingWidth;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null ? Text(title!) : null,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leadingWidth: leadingWidth,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
