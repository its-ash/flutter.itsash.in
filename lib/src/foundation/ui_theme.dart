import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_brand.dart';
import 'package:theme/src/foundation/ui_colors.dart';

abstract final class UiTheme {
  static ThemeData light([UiBrand brand = UiBrand.neutral]) => build(brand, Brightness.light);

  static ThemeData dark([UiBrand brand = UiBrand.neutral]) => build(brand, Brightness.dark);

  static ThemeData build(UiBrand brand, Brightness brightness) {
    final cs = ColorScheme.fromSeed(
      seedColor: brand.seed,
      brightness: brightness,
      dynamicSchemeVariant: brand.variant,
    );
    final t = UiTokens.scaled(brand.radiusScale);
    final text = _textTheme(brand, cs);
    final dark = brightness == Brightness.dark;

    RoundedRectangleBorder shape(BorderRadius r, [BorderSide side = BorderSide.none]) =>
        RoundedRectangleBorder(borderRadius: r, side: side);
    final controlSize = Size(64, t.controlHeight);
    final btnPad = const EdgeInsets.symmetric(horizontal: UiSpace.xl);
    final label = text.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 15);
    OutlineInputBorder border(Color c, [double w = 1]) =>
        OutlineInputBorder(borderRadius: t.md, borderSide: BorderSide(color: c, width: w));
    final inputs = InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest.withValues(alpha: dark ? 0.6 : 0.7),
      contentPadding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.lg),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(cs.primary, 1.6),
      errorBorder: border(cs.error),
      focusedErrorBorder: border(cs.error, 1.6),
      disabledBorder: border(Colors.transparent),
      hintStyle: text.bodyLarge?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
      labelStyle: text.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
      floatingLabelStyle: text.bodyMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
      prefixIconColor: cs.onSurfaceVariant,
      suffixIconColor: cs.onSurfaceVariant,
      errorMaxLines: 2,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      textTheme: text,
      primaryTextTheme: text,
      scaffoldBackgroundColor: cs.surface,
      canvasColor: cs.surface,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      extensions: [t, UiColors.from(cs)],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
        titleSpacing: UiSpace.lg,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: shape(t.lg, BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: controlSize, padding: btnPad, textStyle: label, shape: shape(t.md)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: controlSize,
          padding: btnPad,
          textStyle: label,
          shape: shape(t.md),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: controlSize,
          padding: btnPad,
          textStyle: label,
          shape: shape(t.md),
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: label, shape: shape(t.md), padding: const EdgeInsets.symmetric(horizontal: UiSpace.md)),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(shape: shape(t.md))),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: shape(t.lg),
        extendedTextStyle: label,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: shape(t.full),
          side: BorderSide(color: cs.outlineVariant),
          selectedBackgroundColor: cs.primary,
          selectedForegroundColor: cs.onPrimary,
          textStyle: label?.copyWith(fontSize: 14),
        ),
      ),
      inputDecorationTheme: inputs,
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: inputs,
        menuStyle: MenuStyle(shape: WidgetStatePropertyAll(shape(t.md))),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: cs.primary,
        selectionColor: cs.primary.withValues(alpha: 0.25),
        selectionHandleColor: cs.primary,
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHigh),
        shape: WidgetStatePropertyAll(shape(t.full)),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: UiSpace.lg)),
        constraints: BoxConstraints(minHeight: t.controlHeight),
        hintStyle: WidgetStatePropertyAll(text.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
      ),
      tabBarTheme: TabBarThemeData(
        indicator: BoxDecoration(color: cs.primary, borderRadius: t.full),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        dividerHeight: 0,
        labelColor: cs.onPrimary,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle: label?.copyWith(fontSize: 14),
        unselectedLabelStyle: label?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
        splashBorderRadius: t.full,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        labelPadding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
        tabAlignment: TabAlignment.fill,
      ),
      chipTheme: ChipThemeData(
        shape: shape(t.full),
        side: BorderSide.none,
        backgroundColor: cs.surfaceContainerHigh,
        selectedColor: cs.primary,
        secondarySelectedColor: cs.primary,
        disabledColor: cs.surfaceContainerHighest,
        labelStyle: text.labelLarge?.copyWith(color: cs.onSurface),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: cs.onPrimary),
        checkmarkColor: cs.onPrimary,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: UiSpace.sm),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cs.primaryContainer,
        indicatorShape: shape(t.full),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelMedium?.copyWith(
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? cs.onSurface : cs.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? cs.onPrimaryContainer : cs.onSurfaceVariant),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cs.surfaceContainerLow,
        indicatorColor: cs.primaryContainer,
        indicatorShape: shape(t.full),
        labelType: NavigationRailLabelType.all,
        selectedLabelTextStyle: text.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: cs.surfaceContainerLow,
        indicatorColor: cs.primaryContainer,
        indicatorShape: shape(t.full),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(t.radiusXl)),
        ),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(color: cs.surfaceContainer, elevation: 0),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: cs.surfaceContainerLow,
        showDragHandle: true,
        dragHandleColor: cs.outlineVariant,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(t.radiusXl))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: shape(t.xl),
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
        contentTextStyle: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: cs.onInverseSurface),
        actionTextColor: cs.inversePrimary,
        shape: shape(t.md),
        elevation: 2,
      ),
      listTileTheme: ListTileThemeData(
        shape: shape(t.md),
        contentPadding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
        iconColor: cs.onSurfaceVariant,
        titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
        subtitleTextStyle: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        minVerticalPadding: UiSpace.md,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: shape(t.md),
        collapsedShape: shape(t.md),
        tilePadding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
        childrenPadding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.lg),
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant.withValues(alpha: 0.6), thickness: 1, space: 1),
      checkboxTheme: CheckboxThemeData(
        shape: shape(BorderRadius.circular(6)),
        side: BorderSide(color: cs.outline, width: 1.6),
      ),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? cs.primary : cs.outline)),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? const Icon(Icons.check_rounded) : null),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.surfaceContainerHighest,
        thumbColor: cs.primary,
        overlayColor: cs.primary.withValues(alpha: 0.12),
        valueIndicatorColor: cs.inverseSurface,
        valueIndicatorTextStyle: text.labelMedium?.copyWith(color: cs.onInverseSurface),
        showValueIndicator: ShowValueIndicator.onDrag,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.surfaceContainerHighest,
        circularTrackColor: cs.surfaceContainerHighest,
        linearMinHeight: 6,
        borderRadius: t.full,
        strokeCap: StrokeCap.round,
      ),
      badgeTheme: BadgeThemeData(backgroundColor: cs.error, textColor: cs.onError, textStyle: text.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: cs.inverseSurface, borderRadius: t.sm),
        textStyle: text.labelMedium?.copyWith(color: cs.onInverseSurface),
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.sm),
        waitDuration: const Duration(milliseconds: 400),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: shape(t.md),
        textStyle: text.bodyMedium,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(cs.surfaceContainer),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(shape(t.md)),
          elevation: const WidgetStatePropertyAll(3),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: shape(t.xl),
        headerBackgroundColor: cs.primary,
        headerForegroundColor: cs.onPrimary,
        dayShape: const WidgetStatePropertyAll(CircleBorder()),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: cs.surfaceContainerLow,
        shape: shape(t.xl),
        hourMinuteShape: shape(t.md),
        dayPeriodShape: shape(t.md),
      ),
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(8),
        thickness: const WidgetStatePropertyAll(6),
        thumbColor: WidgetStatePropertyAll(cs.onSurfaceVariant.withValues(alpha: 0.4)),
      ),
      iconTheme: IconThemeData(color: cs.onSurface, size: 24),
    );
  }

  static TextTheme _textTheme(UiBrand brand, ColorScheme cs) {
    final base = (cs.brightness == Brightness.dark ? Typography.material2021().white : Typography.material2021().black)
        .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface);
    TextTheme body;
    TextStyle Function(TextStyle?) heading;
    try {
      body = GoogleFonts.getTextTheme(brand.bodyFont, base);
      heading = (s) => GoogleFonts.getFont(brand.headingFont, textStyle: s);
    } catch (_) {
      body = base;
      heading = (s) => s ?? const TextStyle();
    }
    TextStyle h(TextStyle? s, FontWeight w, [double ls = -0.5]) => heading(s).copyWith(fontWeight: w, letterSpacing: ls);
    return body.copyWith(
      displayLarge: h(body.displayLarge, FontWeight.w800, -1.5),
      displayMedium: h(body.displayMedium, FontWeight.w800, -1),
      displaySmall: h(body.displaySmall, FontWeight.w700, -0.8),
      headlineLarge: h(body.headlineLarge, FontWeight.w700),
      headlineMedium: h(body.headlineMedium, FontWeight.w700),
      headlineSmall: h(body.headlineSmall, FontWeight.w700, -0.3),
      titleLarge: h(body.titleLarge, FontWeight.w700, -0.2),
      titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: body.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
