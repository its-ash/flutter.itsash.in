import 'package:flutter/material.dart';

import 'package:theme/theme.dart';
import 'home/showcase_home_page.dart';
import 'theme_controller/theme_controller.dart';

void main() => runApp(ShowcaseRoot());

class ShowcaseRoot extends StatelessWidget {
  ShowcaseRoot({super.key});

  final _themeController = ThemeController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeControllerState>(
      valueListenable: _themeController,
      builder: (context, state, _) {
        final style = state.generated ?? AppThemeStyle.byId(state.styleId);
        return MaterialApp(
          title: 'Theme Showcase',
          debugShowCheckedModeBanner: false,
          theme: style.themeData(Brightness.light),
          darkTheme: style.themeData(Brightness.dark),
          themeMode: state.mode,
          home: ShowcaseHomePage(themeController: _themeController),
        );
      },
    );
  }
}
