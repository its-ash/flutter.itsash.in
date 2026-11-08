import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

class DisplaySection extends StatefulWidget {
  const DisplaySection({super.key});

  @override
  State<DisplaySection> createState() => _DisplaySectionState();
}

class _DisplaySectionState extends State<DisplaySection> {
  int? _bar = 3;

  static const _week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _desc =
      'This jacket uses recycled nylon with a water-repellent finish. It packs into its own pocket, '
      'so you can take it on any trip. The hood adjusts with one hand, and the cuffs keep wind out. '
      'Machine wash cold and hang dry. Imported. Fits true to size; choose one size up for layers.';

  @override
  Widget build(BuildContext context) {
    final photos = [for (var i = 0; i < 6; i++) pic('gallery$i', 900, 700)];
    return SectionPage(
      children: [
        DemoBlock(
          'UiStatCard and UiDelta',
          child: LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 720 ? 3 : 2;
              final w = (c.maxWidth - (cols - 1) * UiSpace.sm) / cols;
              return WrapRow(
                children: [
                  SizedBox(
                    width: w,
                    child: const UiStatCard(
                      label: 'Revenue',
                      value: '\$12.4k',
                      icon: Icons.payments_rounded,
                      delta: 8.2,
                      sparkline: [3, 5, 4, 7, 9, 8, 12],
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: const UiStatCard(
                      label: 'Expenses',
                      value: '\$3.1k',
                      icon: Icons.receipt_rounded,
                      delta: -4.1,
                      invertDelta: true,
                      caption: 'vs last month',
                      status: UiStatus.warning,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: UiStatCard(
                      label: 'Users',
                      value: '48,210',
                      icon: Icons.people_alt_rounded,
                      delta: 0,
                      sparkline: const [1, 2, 2, 3, 5, 4, 6],
                      onTap: () => toast(context, 'Users'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const DemoBlock(
          'UiDelta',
          child: WrapRow(children: [UiDelta(12.5), UiDelta(-3.5), UiDelta(-3.5, invert: true), UiDelta(4, solid: true), UiDelta(2, suffix: ' pts')]),
        ),
        DemoBlock(
          'UiKeyValue and UiKeyValueList',
          child: UiCard(
            child: Column(
              children: [
                UiKeyValueList.fromMap(
                  const {'Subtotal': '\$240.00', 'Shipping': 'Free', 'Tax': '\$19.20'},
                  total: ('Total', '\$259.20'),
                ),
                const Divider(height: UiSpace.xxl),
                UiKeyValueList(
                  [
                    const UiKeyValue('Order', '#A1042', icon: Icons.tag_rounded),
                    UiKeyValue('Status', 'Shipped', valueColor: context.palette.success, icon: Icons.local_shipping_rounded),
                    UiKeyValue('Tracking', '1Z999AA10123456784', onTap: () => toast(context, 'Copied'), trailing: const Icon(Icons.copy_rounded, size: 16)),
                    const UiKeyValue('Paid', '\$259.20', emphasis: true),
                  ],
                  divided: true,
                ),
              ],
            ),
          ),
        ),
        const DemoBlock(
          'UiTimeline',
          child: UiTimeline([
            UiTimelineItem('Ordered', time: '09:12', subtitle: 'We got your order', done: true),
            UiTimelineItem('Packed', time: '11:40', done: true, icon: Icons.inventory_2_rounded),
            UiTimelineItem('Shipped', subtitle: 'In transit to Lisbon', current: true, status: UiStatus.info),
            UiTimelineItem('Delivered', content: Text('Expected Friday')),
          ]),
        ),
        const DemoBlock('UiSparkline', child: Row(children: [
          Expanded(child: UiSparkline([4, 6, 5, 9, 12, 10, 14])),
          UiGap.lg(),
          Expanded(child: UiSparkline([9, 7, 8, 5, 4, 6, 3], fill: false, smooth: false)),
          UiGap.lg(),
          Expanded(child: UiSparkline([])),
        ])),
        DemoBlock(
          'UiLineChart',
          child: UiLineChart(
            const [12, 18, 9, 22, 30, 26, 34],
            labels: _week,
            format: (v) => '\$${v.round()}k',
          ),
        ),
        const DemoBlock('UiLineChart (empty)', child: UiLineChart([], height: 120, emptyText: 'No data yet')),
        DemoBlock(
          'UiBarChart',
          subtitle: _bar == null ? 'Tap a bar' : 'Selected: ${_week[_bar!]}',
          child: UiBarChart(
            const [5, 8, 3, 10, 7, 12, 6],
            labels: _week,
            highlight: _bar,
            showValues: true,
            onSelect: (i) => setState(() => _bar = i),
          ),
        ),
        const DemoBlock(
          'UiDonutChart',
          child: Center(
            child: UiDonutChart(
              [UiChartSegment('Rent', 900), UiChartSegment('Food', 420), UiChartSegment('Travel', 260), UiChartSegment('Fun', 140)],
              centerText: '\$1.7k',
              centerLabel: 'Spent',
            ),
          ),
        ),
        const DemoBlock(
          'UiProgressSegments',
          child: Column(
            children: [
              UiProgressSegments(
                [UiChartSegment('Photos', 42), UiChartSegment('Apps', 28), UiChartSegment('Mail', 10), UiChartSegment('Free', 20)],
                legend: true,
              ),
              UiGap.lg(),
              UiProgressSegments.steps(total: 5, done: 2),
            ],
          ),
        ),
        DemoBlock(
          'UiCarousel',
          child: Column(
            children: [
              UiCarousel.images(photos.take(4).toList(), autoplay: true, height: 200, onTap: (i) => UiImageViewer.open(context, photos, initialIndex: i)),
              const UiGap.md(),
              UiCarousel(
                height: 120,
                viewportFraction: 0.8,
                children: [
                  for (final s in UiStatus.values)
                    UiCard(
                      variant: UiCardVariant.tonal,
                      child: Center(child: Text('Card ${s.name}', style: context.text.titleMedium)),
                    ),
                ],
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiImageGrid and UiImageViewer',
          subtitle: 'Tap a photo to open the viewer',
          child: Column(
            children: [
              UiImageGrid(photos, height: 240),
              const UiGap.sm(),
              Row(
                children: [
                  for (final n in [1, 2, 3]) ...[
                    Expanded(child: UiImageGrid(photos.take(n).toList(), height: 120)),
                    if (n < 3) const UiGap.sm(),
                  ],
                ],
              ),
            ],
          ),
        ),
        const DemoBlock('UiExpandableText', child: UiExpandableText(_desc, maxLines: 2)),
        DemoBlock(
          'UiCountdown',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UiCountdown(target: ahead(days: 2, hours: 5), showDays: true),
              const UiGap.md(),
              const UiCountdown(duration: Duration(minutes: 5), size: UiSize.sm, status: UiStatus.danger),
              const UiGap.md(),
              const UiCountdown(duration: Duration(hours: 1, minutes: 12), size: UiSize.lg, labels: false),
            ],
          ),
        ),
        DemoBlock(
          'UiInfoTile',
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: UiInfoTile(icon: Icons.local_fire_department_rounded, title: 'Calories', value: '540', status: UiStatus.danger)),
                  const UiGap.sm(),
                  Expanded(child: UiInfoTile(icon: Icons.timer_rounded, title: 'Time', value: '42 min', onTap: () => toast(context, 'Time'))),
                  const UiGap.sm(),
                  const Expanded(child: UiInfoTile(icon: Icons.straighten_rounded, title: 'Distance', value: '6.2 km', status: UiStatus.info)),
                ],
              ),
              const UiGap.sm(),
              const UiInfoTile(icon: Icons.bed_rounded, title: 'Sleep', value: '7 h 40 min', horizontal: true, status: UiStatus.success),
            ],
          ),
        ),
        const DemoBlock(
          'UiFeatureList',
          child: UiFeatureList(['Free delivery', '24/7 support', 'Cancel any time'], excluded: ['Priority booking', 'Family plan']),
        ),
        const DemoBlock(
          'UiChipList',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UiChipList(['Vegan', 'Gluten free', 'Spicy', 'Organic', 'Local'], max: 3),
              UiGap.sm(),
              UiChipList(['Wi-Fi', 'Parking', 'Pool'], status: UiStatus.success, icon: Icons.check_rounded),
            ],
          ),
        ),
        DemoBlock(
          'UiAvatarGroup',
          child: WrapRow(
            children: [
              UiAvatarGroup(
                names: const ['Ana Lee', 'Bo Chen', 'Cy Ray', 'Di Fox', 'Ed Moe'],
                images: [pic('a1', 200, 200), null, pic('a3', 200, 200), null, pic('a5', 200, 200)],
                total: 24,
                onTap: () => toast(context, '24 members'),
              ),
              const UiAvatarGroup(names: ['Ana Lee', 'Bo Chen'], size: 28),
            ],
          ),
        ),
        DemoBlock(
          'UiQuoteCard',
          child: UiQuoteCard(
            'Best gym in town. The coaches know my name and the classes are never too full.',
            author: 'Sam K',
            subtitle: 'Member since 2023',
            avatarUrl: pic('samk', 200, 200),
            rating: 5,
          ),
        ),
      ],
    );
  }
}
