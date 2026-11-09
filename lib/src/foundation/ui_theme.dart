import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/ui_colors.dart';
import 'package:theme/src/foundation/ui_tokens.dart';
import 'package:theme/src/foundation/ui_typography.dart';

/// Builds the two [ThemeData]s of the design system.
///
/// ```dart
/// MaterialApp(theme: UiTheme.light(), darkTheme: UiTheme.dark());
/// ```
/// Or use `UiApp`, which does this for you.
abstract final class UiTheme {
  static ThemeData light({Color? accent, String? fontFamily}) =>
      fromColors(UiColors.light(accent: accent), fontFamily: fontFamily);

  static ThemeData dark({Color? accent, String? fontFamily}) =>
      fromColors(UiColors.dark(accent: accent), fontFamily: fontFamily);

  /// Builds a full Material 3 theme from a palette. Every built-in Material
  /// widget is styled, so plain `ElevatedButton`, `TextField`, `Switch` etc.
  /// match the `Ui*` components.
  static ThemeData fromColors(UiColors c, {String? fontFamily}) {
    final dark = c.isDark;
    final text = UiTypography.textTheme(text: c.text, muted: c.textMuted, fontFamily: fontFamily);
    final label = text.labelLarge!;

    final scheme = ColorScheme(
      brightness: c.brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      primaryContainer: c.accentSoft,
      onPrimaryContainer: c.onAccentSoft,
      secondary: c.text,
      onSecondary: c.background,
      secondaryContainer: c.surfaceMuted,
      onSecondaryContainer: c.text,
      tertiary: c.info,
      onTertiary: c.onInfo,
      tertiaryContainer: c.infoSoft,
      onTertiaryContainer: c.onInfoSoft,
      error: c.danger,
      onError: c.onDanger,
      errorContainer: c.dangerSoft,
      onErrorContainer: c.onDangerSoft,
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.textMuted,
      surfaceDim: c.background,
      surfaceBright: c.surfaceRaised,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surfaceMuted,
      surfaceContainerHighest: c.surfaceMuted,
      outline: c.borderStrong,
      outlineVariant: c.border,
      inverseSurface: c.surfaceInverse,
      onInverseSurface: c.onSurfaceInverse,
      inversePrimary: dark ? UiColors.defaultAccentLight : UiColors.defaultAccentDark,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );

    final r = UiRadius.all;
    final controlShape = RoundedRectangleBorder(borderRadius: r(UiRadius.md));
    const controlSize = Size(64, 44);
    const controlPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 10);
    final disabledFill = c.surfaceMuted;

    OutlineInputBorder inputBorder(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: r(UiRadius.md),
          borderSide: BorderSide(color: color, width: width),
        );

    final overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: c.brightness,
      systemNavigationBarColor: c.background,
      systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: text,
      primaryTextTheme: text,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      cardColor: c.surface,
      dividerColor: c.border,
      hintColor: c.textSubtle,
      disabledColor: c.textDisabled,
      focusColor: c.accent.withValues(alpha: 0.12),
      hoverColor: c.text.withValues(alpha: 0.04),
      highlightColor: Colors.transparent,
      splashColor: c.text.withValues(alpha: 0.06),
      splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      extensions: [c],
      iconTheme: IconThemeData(color: c.text, size: 22),
      primaryIconTheme: IconThemeData(color: c.onAccent, size: 22),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: c.background,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: UiSpace.page,
        toolbarHeight: 60,
        systemOverlayStyle: overlay,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: c.text, size: 22),
        actionsIconTheme: IconThemeData(color: c.text, size: 22),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.lg), side: BorderSide(color: c.border)),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: c.surfaceMuted,
        hoverColor: Colors.transparent,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        hintStyle: text.bodyMedium!.copyWith(color: c.textSubtle),
        labelStyle: text.bodyMedium!.copyWith(color: c.textMuted),
        floatingLabelStyle: text.bodyMedium!.copyWith(color: c.accent, fontWeight: FontWeight.w600),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall!.copyWith(color: c.danger),
        prefixIconColor: c.textSubtle,
        suffixIconColor: c.textSubtle,
        border: inputBorder(Colors.transparent),
        enabledBorder: inputBorder(Colors.transparent),
        disabledBorder: inputBorder(Colors.transparent),
        focusedBorder: inputBorder(c.accent, 1.5),
        errorBorder: inputBorder(c.danger),
        focusedErrorBorder: inputBorder(c.danger, 1.5),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accent,
        selectionColor: c.accent.withValues(alpha: 0.25),
        selectionHandleColor: c.accent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: disabledFill,
          disabledForegroundColor: c.textDisabled,
          minimumSize: controlSize,
          padding: controlPadding,
          shape: controlShape,
          textStyle: label,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: disabledFill,
          disabledForegroundColor: c.textDisabled,
          minimumSize: controlSize,
          padding: controlPadding,
          shape: controlShape,
          textStyle: label,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          disabledForegroundColor: c.textDisabled,
          minimumSize: controlSize,
          padding: controlPadding,
          shape: controlShape,
          textStyle: label,
          side: BorderSide(color: c.borderStrong),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          disabledForegroundColor: c.textDisabled,
          minimumSize: const Size(48, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: controlShape,
          textStyle: label,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.text,
          disabledForegroundColor: c.textDisabled,
          minimumSize: const Size(40, 40),
          shape: controlShape,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 4,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.lg)),
        extendedTextStyle: label,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.surface,
          foregroundColor: c.textMuted,
          selectedBackgroundColor: c.accentSoft,
          selectedForegroundColor: c.onAccentSoft,
          side: BorderSide(color: c.border),
          shape: controlShape,
          textStyle: label,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceMuted,
        selectedColor: c.accentSoft,
        disabledColor: c.surfaceMuted,
        checkmarkColor: c.onAccentSoft,
        deleteIconColor: c.textMuted,
        labelStyle: text.labelMedium!.copyWith(color: c.text),
        secondaryLabelStyle: text.labelMedium!.copyWith(color: c.onAccentSoft),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.full)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        showCheckmark: false,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: r(6)),
        side: WidgetStateBorderSide.resolveWith(
          (s) => BorderSide(
            color: s.contains(WidgetState.selected) ? c.accent : c.borderStrong,
            width: 1.5,
          ),
        ),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? (s.contains(WidgetState.selected) ? c.textDisabled : Colors.transparent)
              : s.contains(WidgetState.selected)
                  ? c.accent
                  : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(c.onAccent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? c.textDisabled
              : s.contains(WidgetState.selected)
                  ? c.accent
                  : c.borderStrong,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onAccent : (dark ? c.textMuted : Colors.white),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? c.surfaceMuted
              : s.contains(WidgetState.selected)
                  ? c.accent
                  : (dark ? c.borderStrong : c.border),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbIcon: const WidgetStatePropertyAll(null),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.accent,
        inactiveTrackColor: c.surfaceMuted,
        thumbColor: c.accent,
        overlayColor: c.accent.withValues(alpha: 0.12),
        valueIndicatorColor: c.surfaceInverse,
        valueIndicatorTextStyle: text.labelMedium!.copyWith(color: c.onSurfaceInverse),
        trackHeight: 6,
        // Opt into the 2024 look (Flutter asks callers to set this to false).
        // ignore: deprecated_member_use
        year2023: false,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.surfaceMuted,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 6,
        borderRadius: r(UiRadius.full),
        // ignore: deprecated_member_use
        year2023: false,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textMuted,
        textColor: c.text,
        titleTextStyle: text.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: text.bodySmall,
        leadingAndTrailingTextStyle: text.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
        minVerticalPadding: 10,
        horizontalTitleGap: 14,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.md)),
        selectedColor: c.onAccentSoft,
        selectedTileColor: c.accentSoft,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.xl)),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium!.copyWith(color: c.textMuted),
        barrierColor: c.scrim,
        insetPadding: const EdgeInsets.symmetric(horizontal: UiSpace.xl, vertical: UiSpace.xl),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceRaised,
        modalBackgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        modalBarrierColor: c.scrim,
        showDragHandle: true,
        dragHandleColor: c.borderStrong,
        dragHandleSize: const Size(36, 4),
        shape: RoundedRectangleBorder(borderRadius: UiRadius.top(UiRadius.xl)),
        clipBehavior: Clip.antiAlias,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surfaceInverse,
        contentTextStyle: text.bodyMedium!.copyWith(color: c.onSurfaceInverse),
        actionTextColor: dark ? UiColors.defaultAccentLight : UiColors.defaultAccentDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.md)),
        insetPadding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.lg),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: c.surfaceInverse, borderRadius: r(UiRadius.sm)),
        textStyle: text.labelMedium!.copyWith(color: c.onSurfaceInverse),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        waitDuration: const Duration(milliseconds: 400),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: dark ? 0.6 : 0.12),
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.md), side: BorderSide(color: c.border)),
        textStyle: text.bodyMedium,
        labelTextStyle: WidgetStatePropertyAll(text.bodyMedium),
        menuPadding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surfaceRaised),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(8),
          shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: dark ? 0.6 : 0.12)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: r(UiRadius.md), side: BorderSide(color: c.border)),
          ),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: UiSpace.xs)),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: text.bodyMedium,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surfaceRaised),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: r(UiRadius.md), side: BorderSide(color: c.border)),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: c.accentSoft,
        indicatorShape: RoundedRectangleBorder(borderRadius: r(UiRadius.full)),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(size: 22, color: s.contains(WidgetState.selected) ? c.onAccentSoft : c.textMuted),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelSmall!.copyWith(
            letterSpacing: 0,
            color: s.contains(WidgetState.selected) ? c.text : c.textMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.accentSoft,
        indicatorShape: RoundedRectangleBorder(borderRadius: r(UiRadius.full)),
        selectedIconTheme: IconThemeData(color: c.onAccentSoft, size: 22),
        unselectedIconTheme: IconThemeData(color: c.textMuted, size: 22),
        selectedLabelTextStyle: text.labelMedium!.copyWith(color: c.text),
        unselectedLabelTextStyle: text.labelMedium!.copyWith(color: c.textMuted),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.accentSoft,
        indicatorShape: RoundedRectangleBorder(borderRadius: r(UiRadius.md)),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        scrimColor: c.scrim,
        shape: const RoundedRectangleBorder(),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.text,
        unselectedLabelColor: c.textMuted,
        labelStyle: label,
        unselectedLabelStyle: label.copyWith(fontWeight: FontWeight.w500),
        indicatorColor: c.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: c.border,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        tabAlignment: TabAlignment.start,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: c.danger,
        textColor: c.onDanger,
        textStyle: text.labelSmall!.copyWith(letterSpacing: 0),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(c.surfaceMuted),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: r(UiRadius.full))),
        hintStyle: WidgetStatePropertyAll(text.bodyMedium!.copyWith(color: c.textSubtle)),
        textStyle: WidgetStatePropertyAll(text.bodyMedium),
        constraints: const BoxConstraints(minHeight: 44),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: c.surfaceRaised,
        headerForegroundColor: c.text,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.xl)),
        dayShape: const WidgetStatePropertyAll(CircleBorder()),
        todayBorder: BorderSide(color: c.accent),
        rangeSelectionBackgroundColor: c.accentSoft,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: c.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.xl)),
        dialBackgroundColor: c.surfaceMuted,
        hourMinuteColor: c.surfaceMuted,
        dayPeriodColor: c.accentSoft,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: c.textMuted,
        collapsedIconColor: c.textMuted,
        textColor: c.text,
        collapsedTextColor: c.text,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(c.borderStrong),
        radius: const Radius.circular(UiRadius.full),
        thickness: const WidgetStatePropertyAll(4),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
