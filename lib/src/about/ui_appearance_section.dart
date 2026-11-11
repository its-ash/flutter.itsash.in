import 'package:flutter/material.dart';

import 'package:theme/src/button/button.dart';
import 'package:theme/src/display/display.dart';
import 'package:theme/src/foundation/foundation.dart';

/// The "Appearance" group of a settings screen: Light / Dark / Auto (system).
/// Changes the nearest [UiThemeController] and saves the choice
/// ([UiAppearance]), so it is restored the next time the app starts.
///
/// ```dart
/// const UiAppearanceSection()
/// ```
class UiAppearanceSection extends StatelessWidget {
  const UiAppearanceSection({super.key, this.header = 'Appearance'});

  final String header;

  @override
  Widget build(BuildContext context) {
    final controller = UiThemeController.of(context);
    if (controller == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => UiListGroup(
        header: header,
        children: [
          UiListTile(
            'Theme',
            icon: Icons.brightness_6_rounded,
            trailing: SizedBox(
              width: 220,
              child: UiSegmentedControl<ThemeMode>(
                const [
                  UiSegment(ThemeMode.light, label: 'Light'),
                  UiSegment(ThemeMode.dark, label: 'Dark'),
                  UiSegment(ThemeMode.system, label: 'Auto'),
                ],
                value: controller.mode,
                size: UiSize.sm,
                onChanged: (m) {
                  controller.mode = m;
                  UiAppearance.save(m);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
