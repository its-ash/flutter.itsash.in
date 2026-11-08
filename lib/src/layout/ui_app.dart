import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_brand.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/foundation/ui_theme.dart';

typedef UiThemeState = ({ThemeMode mode, UiBrand brand});

class UiThemeController extends ValueNotifier<UiThemeState> {
  UiThemeController({ThemeMode mode = ThemeMode.system, UiBrand brand = UiBrand.neutral})
      : super((mode: mode, brand: brand));

  ThemeMode get mode => value.mode;
  UiBrand get brand => value.brand;

  void setMode(ThemeMode mode) => value = (mode: mode, brand: brand);

  void setBrand(UiBrand brand) => value = (mode: mode, brand: brand);

  void toggleMode([Brightness? current]) {
    final dark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => (current ?? WidgetsBinding.instance.platformDispatcher.platformBrightness) == Brightness.dark,
    };
    setMode(dark ? ThemeMode.light : ThemeMode.dark);
  }
}

class UiThemeScope extends InheritedNotifier<UiThemeController> {
  const UiThemeScope({super.key, required UiThemeController controller, required super.child})
      : super(notifier: controller);

  static UiThemeController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UiThemeScope>()?.notifier;
}

class UiApp extends StatelessWidget {
  const UiApp({
    super.key,
    this.title = '',
    this.brand = UiBrand.neutral,
    this.themeMode = ThemeMode.system,
    this.controller,
    this.home,
    this.routes = const {},
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorKey,
    this.navigatorObservers = const [],
    this.scaffoldMessengerKey,
    this.locale,
    this.supportedLocales = const [Locale('en', 'US')],
    this.localizationsDelegates,
    this.builder,
    this.debugShowCheckedModeBanner = false,
  }) : routerConfig = null;

  const UiApp.router({
    super.key,
    required RouterConfig<Object> this.routerConfig,
    this.title = '',
    this.brand = UiBrand.neutral,
    this.themeMode = ThemeMode.system,
    this.controller,
    this.scaffoldMessengerKey,
    this.locale,
    this.supportedLocales = const [Locale('en', 'US')],
    this.localizationsDelegates,
    this.builder,
    this.debugShowCheckedModeBanner = false,
  })  : home = null,
        routes = const {},
        initialRoute = null,
        onGenerateRoute = null,
        onUnknownRoute = null,
        navigatorKey = null,
        navigatorObservers = const [];

  final String title;
  final UiBrand brand;
  final ThemeMode themeMode;
  final UiThemeController? controller;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final Locale? locale;
  final Iterable<Locale> supportedLocales;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final TransitionBuilder? builder;
  final bool debugShowCheckedModeBanner;
  final RouterConfig<Object>? routerConfig;

  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static ScaffoldMessengerState? get messenger => messengerKey.currentState;

  static final _cache = <(UiBrand, Brightness), ThemeData>{};

  static ThemeData themeFor(UiBrand brand, Brightness brightness) {
    if (_cache.length > 24) _cache.clear();
    return _cache.putIfAbsent((brand, brightness), () => UiTheme.build(brand, brightness));
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return c == null ? _app(brand, themeMode) : ValueListenableBuilder(valueListenable: c, builder: (_, v, _) => _app(v.brand, v.mode));
  }

  Widget _app(UiBrand b, ThemeMode mode) {
    final light = themeFor(b, Brightness.light);
    final dark = themeFor(b, Brightness.dark);
    final c = controller;
    Widget wrap(BuildContext ctx, Widget? child) {
      final w = builder?.call(ctx, child) ?? child ?? const SizedBox.shrink();
      return c == null ? w : UiThemeScope(controller: c, child: w);
    }

    final messenger = scaffoldMessengerKey ?? messengerKey;
    final router = routerConfig;
    if (router != null) {
      return MaterialApp.router(
        routerConfig: router,
        title: title,
        theme: light,
        darkTheme: dark,
        themeMode: mode,
        scaffoldMessengerKey: messenger,
        locale: locale,
        supportedLocales: supportedLocales,
        localizationsDelegates: localizationsDelegates,
        builder: wrap,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      );
    }
    return MaterialApp(
      title: title,
      theme: light,
      darkTheme: dark,
      themeMode: mode,
      home: home,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
      navigatorKey: navigatorKey,
      navigatorObservers: navigatorObservers,
      scaffoldMessengerKey: messenger,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      builder: wrap,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
    );
  }
}

class UiThemeModeSwitch extends StatelessWidget {
  const UiThemeModeSwitch({super.key, this.controller, this.showLabels = false});

  final UiThemeController? controller;
  final bool showLabels;

  static const _modes = [
    (ThemeMode.light, Icons.light_mode_rounded, 'Light'),
    (ThemeMode.system, Icons.brightness_auto_rounded, 'System'),
    (ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = controller ?? UiThemeScope.maybeOf(context);
    if (c == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: [
          for (final (m, i, l) in _modes)
            ButtonSegment(value: m, icon: Icon(i, size: 18), label: showLabels ? Text(l) : null, tooltip: l),
        ],
        selected: {c.mode},
        onSelectionChanged: (s) => c.setMode(s.first),
      ),
    );
  }
}

class UiBrandPicker extends StatelessWidget {
  const UiBrandPicker({
    super.key,
    this.controller,
    this.brands = UiBrand.values,
    this.size = 40,
    this.showLabels = true,
    this.padding = UiSpace.page,
  });

  final UiThemeController? controller;
  final List<UiBrand> brands;
  final double size;
  final bool showLabels;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = controller ?? UiThemeScope.maybeOf(context);
    if (c == null || brands.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final itemW = size + UiSpace.xxl;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => SizedBox(
        height: size + 8 + (showLabels ? UiSpace.xxl : 0),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: padding,
          itemCount: brands.length,
          separatorBuilder: (_, _) => const UiGap.xs(),
          itemBuilder: (context, i) {
            final b = brands[i];
            final sel = c.brand.id == b.id;
            final onSeed = ThemeData.estimateBrightnessForColor(b.seed) == Brightness.dark ? Colors.white : Colors.black;
            return Semantics(
              button: true,
              selected: sel,
              label: b.name,
              child: InkWell(
                onTap: () => c.setBrand(b),
                borderRadius: context.tokens.md,
                child: SizedBox(
                  width: itemW,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: UiDuration.normal,
                        curve: UiCurve.standard,
                        width: size + 8,
                        height: size + 8,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: sel ? cs.onSurface : Colors.transparent, width: 2),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: b.seed, shape: BoxShape.circle),
                          child: sel ? Icon(Icons.check_rounded, size: size * 0.5, color: onSeed) : null,
                        ),
                      ),
                      if (showLabels)
                        Padding(
                          padding: const EdgeInsets.only(top: UiSpace.xs),
                          child: Text(
                            b.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelSmall?.copyWith(
                              color: sel ? cs.onSurface : cs.onSurfaceVariant,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
