import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'sections/app_demos_section.dart';
import 'sections/auth_section.dart';
import 'sections/booking_section.dart';
import 'sections/brand_section.dart';
import 'sections/buttons_section.dart';
import 'sections/commerce_section.dart';
import 'sections/display_section.dart';
import 'sections/dropdowns_chips_section.dart';
import 'sections/feedback_section.dart';
import 'sections/finance_section.dart';
import 'sections/fitness_section.dart';
import 'sections/home_section.dart';
import 'sections/inputs_section.dart';
import 'sections/layout_section.dart';
import 'sections/media_section.dart';
import 'sections/navigation_section.dart';
import 'sections/scroll_section.dart';
import 'sections/social_section.dart';

typedef ShowcaseSection = ({UiNavItem nav, Widget Function() build});

UiNavItem _nav(IconData icon, IconData selected, String label) =>
    UiNavItem(icon: icon, selectedIcon: selected, label: label);

final List<ShowcaseSection> showcaseSections = [
  (nav: _nav(Icons.home_outlined, Icons.home_rounded, 'Home'), build: HomeSection.new),
  (nav: _nav(Icons.palette_outlined, Icons.palette_rounded, 'Brand & mode'), build: BrandSection.new),
  (nav: _nav(Icons.smart_button_outlined, Icons.smart_button_rounded, 'Buttons & primitives'), build: ButtonsSection.new),
  (nav: _nav(Icons.edit_note_outlined, Icons.edit_note_rounded, 'Inputs & controls'), build: InputsSection.new),
  (nav: _nav(Icons.arrow_drop_down_circle_outlined, Icons.arrow_drop_down_circle_rounded, 'Dropdowns & chips'), build: DropdownsChipsSection.new),
  (nav: _nav(Icons.view_quilt_outlined, Icons.view_quilt_rounded, 'Layout & lists'), build: LayoutSection.new),
  (nav: _nav(Icons.swap_vert_rounded, Icons.swap_vert_circle_rounded, 'Scrolling & lazy load'), build: ScrollSection.new),
  (nav: _nav(Icons.perm_media_outlined, Icons.perm_media_rounded, 'Images & video'), build: MediaSection.new),
  (nav: _nav(Icons.explore_outlined, Icons.explore_rounded, 'Navigation'), build: NavigationSection.new),
  (nav: _nav(Icons.notifications_outlined, Icons.notifications_rounded, 'Feedback'), build: FeedbackSection.new),
  (nav: _nav(Icons.insert_chart_outlined, Icons.insert_chart_rounded, 'Data display & charts'), build: DisplaySection.new),
  (nav: _nav(Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Commerce'), build: CommerceSection.new),
  (nav: _nav(Icons.fitness_center_outlined, Icons.fitness_center_rounded, 'Fitness'), build: FitnessSection.new),
  (nav: _nav(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Finance'), build: FinanceSection.new),
  (nav: _nav(Icons.event_outlined, Icons.event_rounded, 'Booking'), build: BookingSection.new),
  (nav: _nav(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Social & chat'), build: SocialSection.new),
  (nav: _nav(Icons.lock_outline_rounded, Icons.lock_rounded, 'Auth & onboarding'), build: AuthSection.new),
  (nav: _nav(Icons.apps_outlined, Icons.apps_rounded, 'App demos'), build: AppDemosSection.new),
];

class ShowcaseHome extends StatefulWidget {
  const ShowcaseHome({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  late int _i = widget.initialIndex.clamp(0, showcaseSections.length - 1);

  void _select(int i) => setState(() => _i = i);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= UiBreakpoint.medium;
    final s = showcaseSections[_i];
    final nav = UiDrawer(
      items: [for (final s in showcaseSections) s.nav],
      selectedIndex: _i,
      onSelected: _select,
      header: const _DrawerHeader(),
    );
    final page = KeyedSubtree(key: ValueKey(_i), child: s.build());
    return Scaffold(
      appBar: UiAppBar(
        title: s.nav.label,
        showBack: false,
        leading: wide
            ? null
            : Builder(
                builder: (c) => Center(
                  child: UiIconButton(Icons.menu_rounded, tooltip: 'Menu', onPressed: () => Scaffold.of(c).openDrawer()),
                ),
              ),
        actions: const [Padding(padding: EdgeInsets.only(right: UiSpace.sm), child: UiThemeModeSwitch())],
      ),
      drawer: wide ? null : nav,
      body: wide
          ? Row(
              children: [
                SizedBox(width: 300, child: nav),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: page),
              ],
            )
          : page,
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(UiSpace.xxl, UiSpace.xl, UiSpace.lg, UiSpace.md),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: context.colors.primary, borderRadius: context.tokens.md),
              child: Padding(
                padding: const EdgeInsets.all(UiSpace.sm),
                child: Icon(Icons.auto_awesome_rounded, color: context.colors.onPrimary),
              ),
            ),
            const UiGap.md(),
            Expanded(child: Text('Ui Theme', style: context.text.titleLarge)),
          ],
        ),
      );
}
