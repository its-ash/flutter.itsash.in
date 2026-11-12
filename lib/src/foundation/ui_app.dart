import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:theme/src/foundation/ui_theme.dart';

/// In-app text size, applied on top of the phone's own font size setting.
enum UiTextSize {
  small(0.9, 'S'),
  normal(1.0, 'M'),
  large(1.15, 'L'),
  extraLarge(1.3, 'XL');

  const UiTextSize(this.factor, this.label);

  /// Multiplies the system text scale.
  final double factor;

  /// Short label for the settings control.
  final String label;
}

/// Holds the app's theme mode (light / dark / system), text size and optional
/// accent. Apps start in light mode at normal size; the user's saved choices
/// (see [UiAppearance]) win.
///
/// ```dart
/// final theme = UiThemeController();
/// UiApp(controller: theme, home: const HomePage());
/// // anywhere below:
/// UiThemeController.of(context)?.toggle(context);
/// ```
class UiThemeController extends ChangeNotifier {
  UiThemeController({ThemeMode mode = ThemeMode.light, Color? accent, UiTextSize textSize = UiTextSize.normal})
      : _mode = mode,
        _accent = accent,
        _textSize = textSize;

  ThemeMode _mode;
  Color? _accent;
  UiTextSize _textSize;

  ThemeMode get mode => _mode;
  Color? get accent => _accent;
  UiTextSize get textSize => _textSize;

  set textSize(UiTextSize value) {
    if (value == _textSize) return;
    _textSize = value;
    notifyListeners();
  }

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

/// The saved appearance choices (theme mode and text size), kept in
/// `SharedPreferences`. [UiApp] restores them on start; `UiAppearanceSection`
/// saves them. Nothing saved means light, normal size.
abstract final class UiAppearance {
  static const key = 'ui_theme_mode';
  static const textSizeKey = 'ui_text_size';

  /// The saved text size, or null if none was saved.
  static Future<UiTextSize?> loadTextSize() async {
    try {
      final name = (await SharedPreferences.getInstance()).getString(textSizeKey);
      for (final s in UiTextSize.values) {
        if (s.name == name) return s;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> saveTextSize(UiTextSize size) async {
    try {
      await (await SharedPreferences.getInstance()).setString(textSizeKey, size.name);
    } catch (_) {}
  }

  /// The saved mode, or null if none was saved (or storage is unavailable).
  static Future<ThemeMode?> load() async {
    try {
      final name = (await SharedPreferences.getInstance()).getString(key);
      for (final m in ThemeMode.values) {
        if (m.name == name) return m;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> save(ThemeMode mode) async {
    try {
      await (await SharedPreferences.getInstance()).setString(key, mode.name);
    } catch (_) {}
  }
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

  /// Fixed theme mode when no [controller] is given. Defaults to light. A
  /// mode saved by the user ([UiAppearance]) overrides it.
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
      widget.controller ?? (_own ??= UiThemeController(mode: widget.themeMode ?? ThemeMode.light, accent: widget.accent));

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final saved = await UiAppearance.load();
    if (saved != null && mounted) _controller.mode = saved;
    final size = await UiAppearance.loadTextSize();
    if (size != null && mounted) _controller.textSize = size;
  }

  /// Applies the in-app text size on top of the system one, then the app's own builder.
  Widget _build(BuildContext context, Widget? child, UiTextSize size) {
    Widget? out = child;
    if (size != UiTextSize.normal && out != null) {
      final mq = MediaQuery.of(context);
      out = MediaQuery(data: mq.copyWith(textScaler: _TimesTextScaler(mq.textScaler, size.factor)), child: out);
    }
    final b = widget.builder;
    return b == null ? (out ?? const SizedBox.shrink()) : b(context, out);
  }

  @override
  void didUpdateWidget(UiApp old) {
    super.didUpdateWidget(old);
    final own = _own;
    if (widget.controller == null && own != null) {
      own
        ..mode = widget.themeMode ?? ThemeMode.light
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
          final size = controller.textSize;
          Widget builder(BuildContext c, Widget? child) => _build(c, child, size);
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
              builder: builder,
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
            builder: builder,
            debugShowCheckedModeBanner: w.debugShowCheckedModeBanner,
          );
        },
      ),
    );
  }
}

/// The system [TextScaler] times a fixed factor (keeps Android's non-linear scaling).
class _TimesTextScaler extends TextScaler {
  const _TimesTextScaler(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor * factor;

  @override
  bool operator ==(Object other) => other is _TimesTextScaler && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
