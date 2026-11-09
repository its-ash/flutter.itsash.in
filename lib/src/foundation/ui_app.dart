import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_theme.dart';

/// Holds the app's theme mode (system / light / dark) and optional accent.
///
/// ```dart
/// final theme = UiThemeController();
/// UiApp(controller: theme, home: const HomePage());
/// // anywhere below:
/// UiThemeController.of(context)?.toggle(context);
/// ```
class UiThemeController extends ChangeNotifier {
  UiThemeController({ThemeMode mode = ThemeMode.system, Color? accent})
      : _mode = mode,
        _accent = accent;

  ThemeMode _mode;
  Color? _accent;

  ThemeMode get mode => _mode;
  Color? get accent => _accent;

  set mode(ThemeMode value) {
    if (value == _mode) return;
    _mode = value;
    notifyListeners();
  }

  set accent(Color? value) {
    if (value == _accent) return;
    _accent = value;
    notifyListeners();
  }

  /// Switches between light and dark, based on what is shown now.
  void toggle(BuildContext context) {
    mode = Theme.of(context).brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
  }

  /// The nearest controller provided by a [UiApp], if any.
  static UiThemeController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UiThemeScope>()?.notifier;
}

class _UiThemeScope extends InheritedNotifier<UiThemeController> {
  const _UiThemeScope({required UiThemeController controller, required super.child})
      : super(notifier: controller);
}

/// `MaterialApp` with the design system's light and dark themes applied.
///
/// ```dart
/// void main() => runApp(const UiApp(title: 'Notes', home: NotesPage()));
/// ```
/// Use [UiApp.router] with `go_router` or any `RouterConfig`.
class UiApp extends StatefulWidget {
  const UiApp({
    super.key,
    this.title = '',
    required Widget this.home,
    this.controller,
    this.themeMode,
    this.accent,
    this.fontFamily,
    this.routes = const {},
    this.onGenerateRoute,
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.navigatorObservers = const [],
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const [Locale('en', 'US')],
    this.builder,
    this.debugShowCheckedModeBanner = false,
  }) : routerConfig = null;

  const UiApp.router({
    super.key,
    this.title = '',
    required RouterConfig<Object> this.routerConfig,
    this.controller,
    this.themeMode,
    this.accent,
    this.fontFamily,
    this.scaffoldMessengerKey,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const [Locale('en', 'US')],
    this.builder,
    this.debugShowCheckedModeBanner = false,
  })  : home = null,
        routes = const {},
        onGenerateRoute = null,
        navigatorKey = null,
        navigatorObservers = const [];

  final String title;
  final Widget? home;
  final RouterConfig<Object>? routerConfig;

  /// Lets widgets below change mode/accent at runtime. Overrides
  /// [themeMode] and [accent] when given.
  final UiThemeController? controller;

  /// Fixed theme mode when no [controller] is given. Defaults to system.
  final ThemeMode? themeMode;

  /// Brand color. Defaults to the design system's indigo.
  final Color? accent;

  /// Bundled font family. Defaults to Inter via Google Fonts.
  final String? fontFamily;

  final Map<String, WidgetBuilder> routes;
  final RouteFactory? onGenerateRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final List<NavigatorObserver> navigatorObservers;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;
  final TransitionBuilder? builder;
  final bool debugShowCheckedModeBanner;

  @override
  State<UiApp> createState() => _UiAppState();
}

class _UiAppState extends State<UiApp> {
  UiThemeController? _own;

  UiThemeController get _controller =>
      widget.controller ?? (_own ??= UiThemeController(mode: widget.themeMode ?? ThemeMode.system, accent: widget.accent));

  @override
  void didUpdateWidget(UiApp old) {
    super.didUpdateWidget(old);
    final own = _own;
    if (widget.controller == null && own != null) {
      own
        ..mode = widget.themeMode ?? ThemeMode.system
        ..accent = widget.accent;
    }
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return _UiThemeScope(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final light = UiTheme.light(accent: controller.accent, fontFamily: widget.fontFamily);
          final dark = UiTheme.dark(accent: controller.accent, fontFamily: widget.fontFamily);
          final w = widget;
          if (w.routerConfig != null) {
            return MaterialApp.router(
              title: w.title,
              theme: light,
              darkTheme: dark,
              themeMode: controller.mode,
              routerConfig: w.routerConfig,
              scaffoldMessengerKey: w.scaffoldMessengerKey,
              locale: w.locale,
              localizationsDelegates: w.localizationsDelegates,
              supportedLocales: w.supportedLocales,
              builder: w.builder,
              debugShowCheckedModeBanner: w.debugShowCheckedModeBanner,
            );
          }
          return MaterialApp(
            title: w.title,
            theme: light,
            darkTheme: dark,
            themeMode: controller.mode,
            home: w.home,
            routes: w.routes,
            onGenerateRoute: w.onGenerateRoute,
            navigatorKey: w.navigatorKey,
            scaffoldMessengerKey: w.scaffoldMessengerKey,
            navigatorObservers: w.navigatorObservers,
            locale: w.locale,
            localizationsDelegates: w.localizationsDelegates,
            supportedLocales: w.supportedLocales,
            builder: w.builder,
            debugShowCheckedModeBanner: w.debugShowCheckedModeBanner,
          );
        },
      ),
    );
  }
}
