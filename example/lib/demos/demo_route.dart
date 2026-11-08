import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

ThemeData brandTheme(UiBrand brand, Brightness b) => b == Brightness.dark ? UiTheme.dark(brand) : UiTheme.light(brand);

class BrandScope extends StatelessWidget {
  const BrandScope({super.key, required this.brand, required this.child});

  final UiBrand brand;
  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(data: brandTheme(brand, Theme.of(context).brightness), child: child);
}

Future<T?> pushBranded<T>(BuildContext context, UiBrand brand, Widget page) => Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (_) => BrandScope(brand: brand, child: page)),
    );

Future<T?> pushPage<T>(BuildContext context, Widget page, {bool fullscreen = false}) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page, fullscreenDialog: fullscreen));
