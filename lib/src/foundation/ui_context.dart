import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_colors.dart';

extension UiContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  UiColors get palette => Theme.of(this).extension<UiColors>() ?? UiColors.from(colors);
  UiTokens get tokens => Theme.of(this).extension<UiTokens>() ?? const UiTokens();
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Size get screen => MediaQuery.sizeOf(this);
  bool get isCompact => screen.width < UiBreakpoint.compact;
  bool get isMedium => screen.width >= UiBreakpoint.compact && screen.width < UiBreakpoint.expanded;
  bool get isExpanded => screen.width >= UiBreakpoint.expanded;
  UiTone tone(UiStatus status) => palette.tone(status, colors);
}

class UiGap extends StatelessWidget {
  const UiGap(this.size, {super.key});

  const UiGap.xs({super.key}) : size = UiSpace.xs;
  const UiGap.sm({super.key}) : size = UiSpace.sm;
  const UiGap.md({super.key}) : size = UiSpace.md;
  const UiGap.lg({super.key}) : size = UiSpace.lg;
  const UiGap.xl({super.key}) : size = UiSpace.xl;
  const UiGap.xxl({super.key}) : size = UiSpace.xxl;

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}
