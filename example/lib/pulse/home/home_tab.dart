import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';

/// Home dashboard tab. The shell provides the Scaffold and app bar.
class PulseHomeTab extends StatefulWidget {
  const PulseHomeTab({super.key});

  @override
  State<PulseHomeTab> createState() => _PulseHomeTabState();
}

class _PulseHomeTabState extends State<PulseHomeTab> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<double> _steps = const [6200, 8400, 7100, 10250, 9300, 12100, 8640];
  int _selectedDay = 6;
  bool _showBanner = true;

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _steps = [..._steps.skip(1), 7000 + (DateTime.now().second * 97) % 5000]);
    context.showToast('Dashboard updated', status: UiStatus.success);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    final first = store.me.name.split(' ').first;
    final today = _steps.last;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: UiSpace.lg),
        child: UiMaxWidth(
          maxWidth: 960,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context, first),
              const UiGap.md(),
              Padding(
                padding: UiSpace.page,
                child: UiMarquee(
                  'Weekend sale: up to 40% off running gear  •  New yoga classes every Monday  •  Free delivery on orders over \$50',
                  style: context.text.labelLarge?.copyWith(color: context.colors.primary),
                ),
              ),
              const UiGap.md(),
              UiCarousel.images(
                PulseAssets.heroes,
                height: 190,
                autoplay: true,
                onTap: (i) => UiImageViewer.open(context, PulseAssets.heroes, initialIndex: i),
              ),
              const UiGap.xl(),
              if (_showBanner)
                Padding(
                  padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.xl),
                  child: UiBanner(
                    'You are 1,360 steps away from your daily goal. A short walk will do it.',
                    title: 'Almost there',
                    status: UiStatus.info,
                    icon: Icons.directions_walk_rounded,
                    actionLabel: 'Start walk',
                    onAction: () => context.showToast('Walk started. Have fun!', status: UiStatus.success),
                    onClose: () => setState(() => _showBanner = false),
                  ),
                ),
              Padding(padding: UiSpace.page, child: _stats(context, store, today)),
              const UiGap.xxl(),
              Padding(
                padding: UiSpace.page,
                child: UiSection(
                  title: 'Quick actions',
                  child: UiQuickActions(
                    columns: 4,
                    actions: [
                      UiQuickAction(icon: Icons.play_arrow_rounded, label: 'Workout', onTap: () => _toast('Opening workouts')),
                      UiQuickAction(icon: Icons.send_rounded, label: 'Send', onTap: () => _toast('Send money')),
                      UiQuickAction(
                        icon: Icons.shopping_bag_rounded,
                        label: 'Cart',
                        badge: store.cartCount > 0 ? '${store.cartCount}' : null,
                        onTap: () => _toast('${store.cartCount} items in your cart'),
                      ),
                      UiQuickAction(icon: Icons.qr_code_scanner_rounded, label: 'Scan', onTap: () => _toast('Scanner is not ready yet')),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: UiSpace.page,
                child: UiSection(
                  title: 'Weekly activity',
                  subtitle: 'Steps per day. Tap a bar for details.',
                  child: UiLazyBuilder(
                    placeholderHeight: 200,
                    builder: (_) => UiBarChart(
                      _steps,
                      labels: _days,
                      height: 200,
                      highlight: _selectedDay,
                      format: (v) => UiFormat.compact(v),
                      onSelect: (i) {
                        setState(() => _selectedDay = i);
                        _toast('${_days[i]}: ${UiFormat.number(_steps[i])} steps');
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: UiSpace.page,
                child: UiSection(
                  title: 'Continue watching',
                  child: UiVideoThumbnail(
                    image: PulseAssets.content('post2'),
                    title: 'Morning flow: 12 minute stretch',
                    duration: const Duration(minutes: 12, seconds: 4),
                    onTap: () => pulsePush(context, const _PulseVideoPage()),
                  ),
                ),
              ),
              UiSection(
                title: 'Featured products',
                headerPadding: UiSpace.page,
                onSeeAll: () => _toast('Open the Shop tab to see all products'),
                child: UiHorizontalList(
                  itemExtent: 170,
                  children: [
                    for (final p in store.data.products.take(8))
                      UiProductCard(
                        title: p.title,
                        subtitle: p.brand,
                        price: p.price,
                        compareAt: p.compareAt,
                        rating: p.rating,
                        reviewCount: p.reviews,
                        imageUrl: p.image,
                        inStock: p.stock > 0,
                        isFavorite: store.isWished(p),
                        onFavoriteChanged: (_) => PulseScope.read(context).toggleWish(p),
                        onAdd: () {
                          PulseScope.read(context).addToCart(p);
                          _toast('${p.title} added to cart');
                        },
                      ),
                  ],
                ),
              ),
              Padding(
                padding: UiSpace.page,
                child: UiSection(
                  title: 'Today',
                  margin: EdgeInsets.zero,
                  child: UiTimeline(const [
                    UiTimelineItem('Morning run', subtitle: '5.2 km in 28 min', time: '7:00 AM', done: true, icon: Icons.directions_run_rounded),
                    UiTimelineItem('Order shipped', subtitle: 'Trail shoes are on the way', time: '10:15 AM', done: true, icon: Icons.local_shipping_rounded),
                    UiTimelineItem('Yoga class', subtitle: 'Studio B with Dee', time: '6:30 PM', current: true, icon: Icons.self_improvement_rounded),
                    UiTimelineItem('Rent payment', subtitle: 'Due tonight', time: '11:59 PM', status: UiStatus.warning, icon: Icons.home_rounded),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String message) => context.showToast(message);

  Widget _header(BuildContext context, String first) {
    final store = PulseScope.of(context);
    return Padding(
      padding: UiSpace.page,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(UiFormat.day(DateTime.now()), style: context.text.labelLarge?.copyWith(color: context.colors.onSurfaceVariant)),
                const UiGap.xs(),
                Text('${_greeting()}, $first', style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          UiAvatar(name: store.me.name, imageUrl: store.me.avatar, size: 48),
        ],
      ),
    );
  }

  Widget _stats(BuildContext context, PulseStore store, double today) => UiResponsiveGrid(
        minItemWidth: 200,
        maxColumns: 4,
        children: [
          UiStatCard(
            label: 'Steps',
            value: UiFormat.number(today),
            icon: Icons.directions_walk_rounded,
            delta: (today - _steps[_steps.length - 2]) / _steps[_steps.length - 2] * 100,
            caption: 'Goal 10,000',
            sparkline: _steps,
          ),
          const UiStatCard(
            label: 'Calories',
            value: '1,840 kcal',
            icon: Icons.local_fire_department_rounded,
            delta: 6.5,
            caption: 'vs. yesterday',
            sparkline: [1500, 1720, 1610, 1900, 1780, 1730, 1840],
          ),
          UiStatCard(
            label: 'Balance',
            value: money(store.balance),
            icon: Icons.account_balance_wallet_rounded,
            delta: -2.1,
            caption: 'This month',
            sparkline: const [5200, 5100, 5050, 4990, 4930, 4870, 4820],
          ),
          UiStatCard(
            label: 'Cart',
            value: '${store.cartCount} items',
            icon: Icons.shopping_cart_rounded,
            caption: money(store.subtotal),
            status: store.cartCount > 0 ? UiStatus.info : null,
          ),
        ],
      );
}

class _PulseVideoPage extends StatelessWidget {
  const _PulseVideoPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const UiAppBar(title: 'Morning flow'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(UiSpace.lg),
          child: UiMaxWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UiVideoPlayer(PulseAssets.butterfly, autoplay: true, loop: true, radius: context.tokens.lg),
                const UiGap.lg(),
                Text('Morning flow: 12 minute stretch', style: context.text.titleLarge),
                const UiGap.sm(),
                Text(
                  'A slow and easy routine to wake up your body. Follow along, breathe deeply, and stop if anything hurts.',
                  style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
}
