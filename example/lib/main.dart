import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'showcase_home.dart';

void main() => runApp(ShowcaseApp(controller: UiThemeController()));

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key, required this.controller});

  final UiThemeController controller;

  @override
  Widget build(BuildContext context) => UiApp(controller: controller, title: 'Ui Theme', home: const ShowcaseHome());
}
