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
    final regular = label.copyWith(fontWeight: FontWeight.w400);
    // Buttons: 36 high, radius 8, 32/8 padding (Figma "button").
    final controlShape = RoundedRectangleBorder(borderRadius: r(UiRadius.md));
    const controlSize = Size(64, 36);
    const controlPadding = EdgeInsets.symmetric(horizontal: 32, vertical: 8);
    final disabledFill = c.gray(2);
    final pill = RoundedRectangleBorder(borderRadius: r(UiRadius.full));

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
      focusColor: c.accent.withValues(alpha: 0.2),
      hoverColor: c.surfaceMuted,
      highlightColor: Colors.transparent,
      splashColor: c.surfaceMuted,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      extensions: [c],
      iconTheme: IconThemeData(color: c.text, size: 20),
      primaryIconTheme: IconThemeData(color: c.onAccent, size: 20),
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
        toolbarHeight: 56,
        systemOverlayStyle: overlay,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: c.text, size: 20),
        actionsIconTheme: IconThemeData(color: c.text, size: 20),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.lg)),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      // Fields: Overlay fill, no border at rest, 1 px Primary when focused,
      // red when invalid (Figma "field").
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: c.surfaceMuted,
        hoverColor: Colors.transparent,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        hintStyle: text.bodyMedium!.copyWith(color: c.textSubtle),
        labelStyle: text.bodyMedium!.copyWith(color: c.textSubtle),
        floatingLabelStyle: text.labelSmall!.copyWith(color: c.textSubtle, fontWeight: FontWeight.w400),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall!.copyWith(color: c.danger),
        prefixIconColor: c.textSubtle,
        suffixIconColor: c.textSubtle,
        border: inputBorder(Colors.transparent),
        enabledBorder: inputBorder(Colors.transparent),
        disabledBorder: inputBorder(Colors.transparent),
        focusedBorder: inputBorder(c.accent),
        errorBorder: inputBorder(c.danger),
        focusedErrorBorder: inputBorder(c.danger),
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
      // Ghost button: 1 px gray-4 outline, regular label.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.gray(7),
          disabledForegroundColor: c.gray(3),
          minimumSize: controlSize,
          padding: controlPadding,
          shape: controlShape,
          textStyle: regular,
        ).copyWith(
          side: WidgetStateProperty.resolveWith(
            (s) => BorderSide(color: s.contains(WidgetState.disabled) ? c.gray(3) : c.borderStrong),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          disabledForegroundColor: c.textDisabled,
          minimumSize: const Size(48, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: controlShape,
          textStyle: regular,
        ),
      ),
      // Icon controls are round (Figma "control", type=icon).
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.text,
          disabledForegroundColor: c.textDisabled,
          minimumSize: const Size(36, 36),
          iconSize: 20,
          shape: const CircleBorder(),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 4,
        highlightElevation: 2,
        shape: pill,
        extendedTextStyle: label,
      ),
      // Segmented control: gray-2 pill track, the selected segment is a
      // Primary pill with a bold label.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.surface,
          foregroundColor: c.gray(7),
          selectedBackgroundColor: c.accent,
          selectedForegroundColor: c.onAccent,
          side: BorderSide.none,
          shape: pill,
          textStyle: regular,
        ),
      ),
      // Chips are "controls": 28 high pills, Overlay fill, Primary when selected.
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceMuted,
        selectedColor: c.accent,
        disabledColor: c.surfaceMuted,
        checkmarkColor: c.onAccent,
        deleteIconColor: c.textMuted,
        labelStyle: regular.copyWith(color: c.gray(7)),
        secondaryLabelStyle: label.copyWith(color: c.onAccent),
        side: BorderSide.none,
        shape: pill,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        showCheckmark: false,
      ),
      // Checkbox: 20 px, radius 4, gray-2 fill with gray-4 outline; Primary when on.
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.xs)),
        side: WidgetStateBorderSide.resolveWith(
          (s) => s.contains(WidgetState.selected) ? BorderSide.none : BorderSide(color: c.borderStrong),
        ),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? (s.contains(WidgetState.selected) ? c.textDisabled : c.gray(2))
              : s.contains(WidgetState.selected)
                  ? c.accent
                  : c.gray(2),
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
        backgroundColor: WidgetStatePropertyAll(c.gray(2)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onAccent : (dark ? c.gray(6) : Colors.white),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? c.gray(2)
              : s.contains(WidgetState.selected)
                  ? c.accent
                  : c.gray(3),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbIcon: const WidgetStatePropertyAll(null),
      ),
      // Slider: 2 px gray-3 track, filled with the foreground color, 16 px
      // round thumb with a level 1 shadow (Figma "basic slider").
      sliderTheme: SliderThemeData(
        activeTrackColor: c.text,
        inactiveTrackColor: c.gray(3),
        thumbColor: c.text,
        overlayColor: c.surfaceMuted,
        valueIndicatorColor: c.surfaceInverse,
        valueIndicatorTextStyle: text.labelMedium!.copyWith(color: c.onSurfaceInverse),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 3, pressedElevation: 4),
        trackShape: const RectangularSliderTrackShape(),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        tickMarkShape: SliderTickMarkShape.noTickMark,
        showValueIndicator: ShowValueIndicator.onlyForDiscrete,
      ),
      // Progress bar: 2 px, foreground fill on a gray-3 track.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.text,
        linearTrackColor: c.gray(3),
        circularTrackColor: Colors.transparent,
        linearMinHeight: 2,
        borderRadius: BorderRadius.zero,
        // ignore: deprecated_member_use
        year2023: true,
      ),
      // List rows (Figma "menu item list"): 36 high, regular title, Overlay on
      // hover, solid Primary when selected.
      listTileTheme: ListTileThemeData(
        iconColor: c.textMuted,
        textColor: c.text,
        titleTextStyle: text.bodyMedium,
        subtitleTextStyle: text.bodySmall!.copyWith(color: c.textSubtle),
        leadingAndTrailingTextStyle: text.bodyMedium!.copyWith(color: c.textSubtle),
        contentPadding: const EdgeInsets.symmetric(horizontal: UiSpace.page),
        minVerticalPadding: 6,
        minTileHeight: 36,
        horizontalTitleGap: 12,
        minLeadingWidth: 16,
        dense: true,
        visualDensity: VisualDensity.standard,
        shape: const RoundedRectangleBorder(),
        selectedColor: c.onAccent,
        selectedTileColor: c.accent,
      ),
      // Dialog: gray-2, radius 12, level 3 shadow, H3 title, gray-6 text.
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.lg)),
        titleTextStyle: text.headlineSmall,
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
        dragHandleColor: c.gray(4),
        dragHandleSize: const Size(36, 4),
        shape: RoundedRectangleBorder(borderRadius: UiRadius.top(UiRadius.xl)),
        clipBehavior: Clip.antiAlias,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surfaceInverse,
        contentTextStyle: text.bodyMedium!.copyWith(color: c.onSurfaceInverse),
        actionTextColor: c.accent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.md)),
        insetPadding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.lg),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: c.surfaceInverse, borderRadius: r(UiRadius.sm)),
        textStyle: text.bodySmall!.copyWith(color: c.onSurfaceInverse),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        waitDuration: const Duration(milliseconds: 400),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: dark ? 0.6 : 0.15),
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.lg)),
        textStyle: text.bodyMedium,
        labelTextStyle: WidgetStatePropertyAll(text.bodyMedium),
        menuPadding: const EdgeInsets.symmetric(vertical: UiSpace.sm),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surfaceRaised),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(8),
          shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: dark ? 0.6 : 0.15)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: r(UiRadius.lg))),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: UiSpace.sm)),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: text.bodyMedium,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surfaceRaised),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: r(UiRadius.lg))),
        ),
      ),
      // Bottom navigation: on the page background, no pill; the selected
      // item is Primary, the rest gray-5.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 60,
        indicatorColor: Colors.transparent,
        indicatorShape: pill,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(size: 22, color: s.contains(WidgetState.selected) ? c.accent : c.textSubtle),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelSmall!.copyWith(
            fontWeight: FontWeight.w400,
            color: s.contains(WidgetState.selected) ? c.accent : c.textSubtle,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.background,
        indicatorColor: c.surfaceMuted,
        indicatorShape: pill,
        selectedIconTheme: IconThemeData(color: c.accent, size: 22),
        unselectedIconTheme: IconThemeData(color: c.textSubtle, size: 22),
        selectedLabelTextStyle: text.bodySmall!.copyWith(color: c.accent),
        unselectedLabelTextStyle: text.bodySmall!.copyWith(color: c.textSubtle),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.accent,
        indicatorShape: RoundedRectangleBorder(borderRadius: r(UiRadius.md)),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        scrimColor: c.scrim,
        shape: const RoundedRectangleBorder(),
      ),
      // Tabs: regular labels, active = foreground with a 1 px bar, rest gray-5
      // over a gray-3 rule.
      tabBarTheme: TabBarThemeData(
        labelColor: c.text,
        unselectedLabelColor: c.textSubtle,
        labelStyle: regular,
        unselectedLabelStyle: regular,
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: c.text, width: 1)),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: c.gray(3),
        dividerHeight: 1,
        labelPadding: const EdgeInsets.only(right: UiSpace.lg),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        tabAlignment: TabAlignment.start,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: c.danger,
        textColor: c.onDanger,
        textStyle: text.labelSmall!.copyWith(fontWeight: FontWeight.w400),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(c.surfaceMuted),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: r(UiRadius.md))),
        hintStyle: WidgetStatePropertyAll(text.bodyMedium!.copyWith(color: c.textSubtle)),
        textStyle: WidgetStatePropertyAll(text.bodyMedium),
        constraints: const BoxConstraints(minHeight: 36),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: c.surfaceRaised,
        headerForegroundColor: c.text,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.lg)),
        dayShape: const WidgetStatePropertyAll(CircleBorder()),
        todayBorder: BorderSide(color: c.accent),
        rangeSelectionBackgroundColor: c.accentSoft,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: c.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: r(UiRadius.lg)),
        dialBackgroundColor: c.surfaceMuted,
        hourMinuteColor: c.surfaceMuted,
        dayPeriodColor: c.accentSoft,
      ),
      // Accordion: gray-6 title when closed, foreground when open, Overlay
      // rules above and below.
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: c.text,
        collapsedIconColor: c.textMuted,
        textColor: c.text,
        collapsedTextColor: c.textMuted,
        shape: Border(top: BorderSide(color: c.border), bottom: BorderSide(color: c.border)),
        collapsedShape: Border(top: BorderSide(color: c.border)),
        tilePadding: const EdgeInsets.symmetric(horizontal: UiSpace.page),
        childrenPadding: const EdgeInsets.fromLTRB(UiSpace.page, 0, UiSpace.page, UiSpace.lg),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(c.gray(4)),
        radius: const Radius.circular(UiRadius.full),
        thickness: const WidgetStatePropertyAll(4),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
