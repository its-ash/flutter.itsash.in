import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../demos/demo_route.dart';
import '../widgets/demo_block.dart';

class LayoutSection extends StatefulWidget {
  const LayoutSection({super.key});

  @override
  State<LayoutSection> createState() => _LayoutSectionState();
}

class _LayoutSectionState extends State<LayoutSection> {
  bool _dark = false;
  bool _alerts = true;
  bool _shipping = true;

  Widget _tile(BuildContext context, int i) => UiCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: UiImage(pic('grid$i', 400, 400))),
            Padding(
              padding: const EdgeInsets.all(UiSpace.sm),
              child: Text('Item ${i + 1}', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    void tap() => toast(context, 'Tapped');
    final cs = context.colors;
    return SectionPage(
      children: [
        DemoBlock(
          'UiScaffold',
          subtitle: 'Full pages with app bar, scroll, sticky bottom bar, pull to refresh',
          child: WrapRow(
            children: [
              UiButton.tonal('Open page', icon: Icons.open_in_new_rounded, onPressed: () => pushPage(context, const ScaffoldDemoPage())),
              UiButton.tonal(
                'Open large title',
                icon: Icons.title_rounded,
                onPressed: () => pushPage(context, const ScaffoldDemoPage(large: true)),
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiAppBar and UiBackButton',
          child: ClipRRect(
            borderRadius: context.tokens.md,
            child: Column(
              children: [
                UiAppBar(
                  title: 'Orders',
                  subtitle: '12 active',
                  leading: const Center(child: UiBackButton()),
                  actions: [UiIconButton(Icons.search_rounded, onPressed: tap)],
                  backgroundColor: cs.surfaceContainer,
                ),
                UiAppBar(title: 'Centered', centerTitle: true, showBack: false, backgroundColor: cs.surfaceContainerHigh),
              ],
            ),
          ),
        ),
        DemoBlock(
          'UiStickyBottomBar',
          child: ClipRRect(
            borderRadius: context.tokens.md,
            child: UiStickyBottomBar(child: UiButton('Book now', expand: true, onPressed: tap)),
          ),
        ),
        DemoBlock(
          'UiMaxWidth',
          subtitle: 'Child is limited to 360 px on wide screens',
          child: ColoredBox(
            color: cs.surfaceContainerHighest,
            child: UiMaxWidth(
              maxWidth: 360,
              child: Container(height: 48, color: cs.primaryContainer, alignment: Alignment.center, child: const Text('360 max')),
            ),
          ),
        ),
        DemoBlock(
          'UiSection',
          child: UiSection(
            title: 'Popular',
            subtitle: 'Picked for you',
            onSeeAll: tap,
            margin: EdgeInsets.zero,
            child: UiHorizontalList(
              padding: EdgeInsets.zero,
              children: [
                for (var i = 0; i < 8; i++)
                  SizedBox(width: 120, child: UiImage(pic('pop$i', 300, 300), aspectRatio: 1, radius: context.tokens.md)),
              ],
            ),
          ),
        ),
        const DemoBlock('UiDividerText', child: Column(children: [UiDividerText(), UiDividerText(text: 'or continue with')])),
        DemoBlock(
          'UiListTile',
          child: Column(
            children: [
              UiListTile(icon: Icons.person_rounded, title: 'Profile', subtitle: 'Name, photo, bio', onTap: tap),
              UiListTile(
                leading: UiAvatar(name: 'Ana Lee', imageUrl: pic('ana', 200, 200)),
                title: 'Ana Lee',
                subtitle: 'A very long subtitle that should be cut with an ellipsis on small screens',
                trailing: const UiTag('Admin', status: UiStatus.info),
              ),
              UiListTile(icon: Icons.star_rounded, iconColor: context.palette.rating, title: 'Selected', selected: true, onTap: tap),
              UiListTile(icon: Icons.block_rounded, title: 'Disabled', enabled: false, onTap: tap),
              UiListTile(icon: Icons.delete_rounded, title: 'Delete account', destructive: true, dense: true, onTap: tap),
            ],
          ),
        ),
        DemoBlock(
          'UiListGroup and UiSettingsTile',
          child: Column(
            children: [
              UiListGroup(
                header: 'Account',
                footer: 'Changes sync across devices.',
                children: [
                  UiSettingsTile.nav(icon: Icons.lock_rounded, title: 'Privacy', onTap: tap),
                  UiSettingsTile.nav(icon: Icons.credit_card_rounded, title: 'Payments', value: 'Visa 4242', onTap: tap),
                  UiSettingsTile.value(icon: Icons.language_rounded, title: 'Language', value: 'English', onTap: tap),
                ],
              ),
              UiListGroup(
                header: 'Preferences',
                children: [
                  UiSettingsTile.toggle(
                    icon: Icons.notifications_rounded,
                    title: 'Alerts',
                    subtitle: 'Orders and offers',
                    checked: _alerts,
                    onChanged: (v) => setState(() => _alerts = v),
                  ),
                  UiSettingsTile.toggle(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark preview',
                    checked: _dark,
                    onChanged: (v) => setState(() => _dark = v),
                  ),
                  UiSettingsTile.action(icon: Icons.logout_rounded, title: 'Sign out', onTap: tap),
                ],
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiResponsiveGrid',
          subtitle: 'Columns from minItemWidth',
          child: UiResponsiveGrid(
            minItemWidth: 140,
            childAspectRatio: 0.85,
            children: [for (var i = 0; i < 6; i++) _tile(context, i)],
          ),
        ),
        DemoBlock(
          'UiResponsiveGrid.builder',
          child: UiResponsiveGrid.builder(
            itemCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            maxColumns: 4,
            childAspectRatio: 1,
            itemBuilder: (c, i) => _tile(c, i + 10),
          ),
        ),
        DemoBlock(
          'UiSliverGrid',
          child: SizedBox(
            height: 280,
            child: CustomScrollView(
              slivers: [
                UiSliverGrid(itemCount: 12, minItemWidth: 120, mainAxisExtent: 130, itemBuilder: (c, i) => _tile(c, i + 20)),
              ],
            ),
          ),
        ),
        DemoBlock(
          'UiHorizontalList.builder',
          child: UiHorizontalList.builder(
            height: 150,
            itemCount: 10,
            itemExtent: 130,
            padding: EdgeInsets.zero,
            itemBuilder: (c, i) => _tile(c, i + 40),
          ),
        ),
        DemoBlock(
          'UiResponsive',
          child: UiResponsive(
            compact: const UiBanner('Compact layout', status: UiStatus.info),
            medium: const UiBanner('Medium layout', status: UiStatus.success),
            expanded: const UiBanner('Expanded layout', status: UiStatus.warning),
          ),
        ),
        DemoBlock(
          'UiExpandableCard',
          child: Column(
            children: [
              const UiExpandableCard(
                title: 'Shipping',
                subtitle: 'Free over \$50',
                icon: Icons.local_shipping_rounded,
                initiallyExpanded: true,
                child: Text('Orders ship in 1 to 2 business days. Express shipping is available at checkout.'),
              ),
              const UiGap.sm(),
              UiExpandableCard(
                title: 'Controlled',
                icon: Icons.tune_rounded,
                expanded: _shipping,
                onChanged: (v) => setState(() => _shipping = v),
                child: const Text('The parent holds the open state.'),
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiAccordion',
          child: UiAccordion(
            initialIndex: 0,
            items: [
              UiAccordionItem.text(title: 'Returns', body: 'Return any item within 30 days for a full refund.', icon: Icons.undo_rounded),
              UiAccordionItem.text(title: 'Warranty', subtitle: '2 years', body: 'All products have a 2 year warranty.'),
              UiAccordionItem(
                title: 'Contact',
                icon: Icons.support_agent_rounded,
                child: UiButton.outline('Chat with us', icon: Icons.chat_rounded, onPressed: tap),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScaffoldDemoPage extends StatelessWidget {
  const ScaffoldDemoPage({super.key, this.large = false});

  final bool large;

  @override
  Widget build(BuildContext context) => UiScaffold(
        title: large ? 'Large title' : 'Cart',
        subtitle: large ? null : '3 items',
        large: large,
        onRefresh: () => Future<void>.delayed(const Duration(seconds: 1)),
        actions: [UiIconButton(Icons.more_horiz_rounded, onPressed: () {})],
        bottomBar: UiButton('Checkout', expand: true, icon: Icons.lock_rounded, onPressed: () => Navigator.maybePop(context)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < 12; i++)
              UiListTile(
                leading: UiImage(pic('cart$i', 200, 200), width: 48, height: 48, radius: context.tokens.sm),
                title: 'Product ${i + 1}',
                subtitle: 'Pull down to refresh',
                trailing: Text('\$${(i + 1) * 12}.00', style: context.text.titleSmall),
              ),
          ],
        ),
      );
}
