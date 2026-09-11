import 'package:flutter/material.dart';

import 'package:theme/theme.dart';
import '../showcase_tile.dart';
import '../../theme_controller/theme_controller.dart';

class ThemeStylesSection extends StatelessWidget {
  const ThemeStylesSection({super.key, required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return ShowcasePage(
      children: [
        ValueListenableBuilder<ThemeControllerState>(
          valueListenable: controller,
          builder: (context, state, _) {
            return ShowcaseTile(
              title: 'ThemeCustomizer',
              description: 'Any theme + any color + any font, all independently — pick a color and/or font here, or a style below, in any order',
              child: ThemeCustomizer(
                seedColor: state.customization?.seedColor ?? Theme.of(context).colorScheme.primary,
                pairing: state.customization?.pairing,
                headingFont: state.customization?.headingFont,
                bodyFont: state.customization?.bodyFont,
                onChanged: controller.setGenerated,
              ),
            );
          },
        ),
        ValueListenableBuilder<ThemeControllerState>(
          valueListenable: controller,
          builder: (context, state, _) {
            return ShowcaseTile(
              title: 'ThemeStyleSwitcher',
              description: 'Tap any card to switch the base style — your color/font pick above carries over',
              child: ThemeStyleSwitcher(
                selectedId: state.styleId,
                brightness: brightness,
                onSelected: controller.setStyle,
              ),
            );
          },
        ),
        ShowcaseTile(
          title: 'All styles',
          description: '${AppThemeStyle.all.length} styles, each with light & dark variants',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final style in AppThemeStyle.all)
                Builder(
                  builder: (context) {
                    final scheme = style.preset(brightness).colorScheme;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(style.preset(brightness).cardRadius),
                      ),
                      child: Text(
                        style.name,
                        style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}