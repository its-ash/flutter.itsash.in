import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'pages/button_page.dart';
import 'pages/chart_page.dart';
import 'pages/display_page.dart';
import 'pages/feedback_page.dart';
import 'pages/foundation_page.dart';
import 'pages/input_page.dart';
import 'pages/layout_page.dart';
import 'pages/media_page.dart';
import 'pages/navigation_page.dart';
import 'pages/scroll_page.dart';
import 'pages/selection_page.dart';

void main() => runApp(const GalleryApp());

/// The design system's default accent (indigo).
final Color defaultAccent = UiColors.light().accent;

/// Accent choices for the theme settings sheet. The first one is the default.
final galleryAccents = <Color>[
  defaultAccent,
  Colors.teal,
  Colors.pink,
  Colors.orange,
  Colors.green,
  Colors.deepPurple,
  Colors.blue,
  Colors.red,
];

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key, this.controller});

  /// External theme controller (tests use it to force a mode). Not disposed.
  final UiThemeController? controller;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  UiThemeController? _own;

  UiThemeController get _controller => widget.controller ?? (_own ??= UiThemeController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      UiApp(title: 'Theme gallery', controller: _controller, home: const GalleryHome());
}

class _Destination {
  const _Destination(this.item, this.page);
  final UiNavItem item;
  final Widget page;
}

const _destinations = [
  _Destination(UiNavItem(Icons.palette_outlined, 'Foundation', selectedIcon: Icons.palette), FoundationPage()),
  _Destination(UiNavItem(Icons.smart_button_outlined, 'Buttons', selectedIcon: Icons.smart_button), ButtonPage()),
  _Destination(UiNavItem(Icons.insights_outlined, 'Charts', selectedIcon: Icons.insights), ChartPage()),
  _Destination(UiNavItem(Icons.dashboard_outlined, 'Display', selectedIcon: Icons.dashboard), DisplayPage()),
  _Destination(
    UiNavItem(Icons.notifications_outlined, 'Feedback', selectedIcon: Icons.notifications, dot: true),
    FeedbackPage(),
  ),
  _Destination(UiNavItem(Icons.edit_note_outlined, 'Inputs', selectedIcon: Icons.edit_note), InputPage()),
  _Destination(UiNavItem(Icons.view_quilt_outlined, 'Layout', selectedIcon: Icons.view_quilt), LayoutPage()),
  _Destination(UiNavItem(Icons.photo_library_outlined, 'Media', selectedIcon: Icons.photo_library), MediaPage()),
  _Destination(UiNavItem(Icons.explore_outlined, 'Navigation', selectedIcon: Icons.explore), NavigationPage()),
  _Destination(
    UiNavItem(Icons.view_stream_outlined, 'Scroll', selectedIcon: Icons.view_stream, badge: 3),
    ScrollPage(),
  ),
  _Destination(UiNavItem(Icons.check_box_outlined, 'Selection', selectedIcon: Icons.check_box), SelectionPage()),
];

/// Gallery shell. Desktop widths use [UiShell] (sidebar). Narrower widths use
/// a [UiDrawer]: 11 destinations do not fit a bottom nav or a rail.
class GalleryHome extends StatefulWidget {
  const GalleryHome({super.key});

  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  final _contentKey = GlobalKey();
  int _index = 0;

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final items = [for (final d in _destinations) d.item];
    final content = KeyedSubtree(
      key: _contentKey,
      child: IndexedStack(index: _index, children: [for (final d in _destinations) d.page]),
    );
    final appBar = UiAppBar(
      title: _destinations[_index].item.label,
      subtitle: 'theme v2 gallery',
      border: true,
      actions: const [_ThemeActions()],
    );
    if (context.breakpoint == UiBreakpoint.large) {
      return UiShell(
        items: items,
        index: _index,
        onChanged: _select,
        appBar: appBar,
        body: content,
        sidebarCollapsible: true,
        header: Text('Theme gallery', style: context.text.titleLarge),
        footer: const UiStatusPill('v2', status: UiStatus.accent),
      );
    }
    return Scaffold(
      appBar: appBar,
      drawer: UiDrawer(
        items: items,
        index: _index,
        onChanged: _select,
        header: Text('Theme gallery', style: context.text.titleLarge),
      ),
      body: content,
    );
  }
}

class _ThemeActions extends StatelessWidget {
  const _ThemeActions();

  @override
  Widget build(BuildContext context) {
    final theme = UiThemeController.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UiIconButton(
          context.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          tooltip: 'Toggle dark mode',
          onPressed: theme == null ? null : () => theme.toggle(context),
        ),
        UiIconButton(
          Icons.tune_rounded,
          tooltip: 'Theme settings',
          onPressed: theme == null ? null : () => _openSettings(context, theme),
        ),
        const SizedBox(width: UiSpace.sm),
      ],
    );
  }

  static Future<void> _openSettings(BuildContext context, UiThemeController theme) {
    return UiSheet.show<void>(
      context,
      title: 'Appearance',
      subtitle: 'Mode and accent apply to the whole app',
      child: ListenableBuilder(
        listenable: theme,
        builder: (context, _) => UiColumn(
          gap: UiSpace.lg,
          children: [
            UiSegmentedControl<ThemeMode>(
              const [
                UiSegment(ThemeMode.system, label: 'System', icon: Icons.brightness_auto_outlined),
                UiSegment(ThemeMode.light, label: 'Light', icon: Icons.light_mode_outlined),
                UiSegment(ThemeMode.dark, label: 'Dark', icon: Icons.dark_mode_outlined),
              ],
              value: theme.mode,
              expand: true,
              onChanged: (m) => theme.mode = m,
            ),
            Text('Accent', style: context.text.titleSmall),
            UiColorPicker(
              value: theme.accent ?? defaultAccent,
              colors: galleryAccents,
              labels: const ['Indigo', 'Teal', 'Pink', 'Orange', 'Green', 'Purple', 'Blue', 'Red'],
              onChanged: (c) => theme.accent = c == defaultAccent ? null : c,
            ),
          ],
        ),
      ),
      actions: [UiButton('Done', expand: true, onPressed: () => Navigator.pop(context))],
    );
  }
}
