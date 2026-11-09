import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Dot indicator for carousels and onboarding. The active dot stretches into
/// a short pill. Scales down to fit when there are many dots.
///
/// ```dart
/// UiPageDots(count: 4, index: page, onTap: (i) => controller.animateToPage(i, ...));
/// ```
class UiPageDots extends StatelessWidget {
  const UiPageDots({
    super.key,
    required this.count,
    required this.index,
    this.onTap,
    this.size = 8,
    this.activeWidth = 24,
  });

  final int count;

  /// Index of the active dot.
  final int index;

  /// Called with the tapped dot index. Null makes dots not tappable.
  final ValueChanged<int>? onTap;

  /// Diameter of each dot.
  final double size;

  /// Width of the active dot.
  final double activeWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = context.motion(UiMotion.normal);
    final onTap = this.onTap;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            Builder(
              builder: (context) {
                final active = i == index;
                Widget dot = AnimatedContainer(
                  duration: d,
                  curve: UiMotion.emphasized,
                  width: active ? activeWidth : size,
                  height: size,
                  margin: EdgeInsets.symmetric(horizontal: size / 2),
                  decoration: BoxDecoration(
                    color: active ? c.accent : c.borderStrong,
                    borderRadius: UiRadius.all(UiRadius.full),
                  ),
                );
                if (onTap == null) return dot;
                dot = GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: ((40 - size) / 2).clamp(0.0, 40.0)),
                    child: dot,
                  ),
                );
                return Semantics(button: true, selected: active, label: 'Page ${i + 1} of $count', child: dot);
              },
            ),
        ],
      ),
    );
  }
}
