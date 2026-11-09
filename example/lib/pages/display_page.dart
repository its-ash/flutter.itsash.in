import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  bool _selectedCard = false;
  bool _wifi = true;
  int _unread = 5;
  final _tags = ['Design', 'Flutter', 'Dart'];
  Person? _picked;
  double _download = 0.35;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return GalleryPage(
      children: [
        Demo(
          'Cards',
          child: UiResponsiveGrid(
            minItemWidth: 200,
            equalHeight: true,
            children: [
              UiCard(
                selected: _selectedCard,
                onTap: () => setState(() => _selectedCard = !_selectedCard),
                child: Text(_selectedCard ? 'Selected (tap again)' : 'Outlined, tap to select'),
              ),
              const UiCard(variant: UiCardVariant.filled, child: Text('Filled')),
              UiCard(
                variant: UiCardVariant.elevated,
                header: Text('Header', style: context.text.titleSmall),
                footer: Text('Footer', style: context.text.bodySmall),
                child: const Text('Elevated with header and footer'),
              ),
            ],
          ),
        ),
        Demo(
          'Stat cards',
          child: UiResponsiveGrid(
            minItemWidth: 180,
            children: [
              const UiStatCard(label: 'Revenue', value: r'$12.4k', delta: 8.2, deltaLabel: 'vs last week'),
              const UiStatCard(
                label: 'Costs',
                value: r'$3.1k',
                delta: 4.0,
                invertColors: true,
                icon: Icons.receipt_long_outlined,
                iconStatus: UiStatus.warning,
              ),
              UiStatCard(
                label: 'Unread',
                value: '$_unread',
                trend: UiTrend.neutral,
                icon: Icons.mail_outline_rounded,
                onTap: () => setState(() => _unread = 0),
                footer: Text('Tap to clear', style: context.text.bodySmall),
              ),
            ],
          ),
        ),
        Demo(
          'List group',
          child: UiListGroup(
            header: 'Settings',
            footer: 'Rows are interactive',
            children: [
              UiListTile(
                'Wi-Fi',
                icon: Icons.wifi_rounded,
                value: _wifi ? 'Home' : 'Off',
                chevron: true,
                onTap: () => setState(() => _wifi = !_wifi),
              ),
              UiListTile(
                'Notifications',
                subtitle: 'Badges, sounds and banners',
                icon: Icons.notifications_outlined,
                iconStatus: UiStatus.danger,
                trailing: UiCountBadge(_unread),
                onTap: () => setState(() => _unread++),
              ),
              const UiListTile('Storage', icon: Icons.storage_rounded, iconStatus: UiStatus.info, enabled: false),
              UiListTile(
                'Sign out',
                destructive: true,
                icon: Icons.logout_rounded,
                onTap: () => context.showToast('Signed out (not really)'),
              ),
            ],
          ),
        ),
        Demo(
          'Avatars and badges',
          child: UiColumn(
            children: [
              DemoWrap(
                children: [
                  UiAvatar(name: people[0].name, image: AssetImage(people[0].avatar), status: UiStatus.success),
                  UiAvatar(name: people[1].name, size: UiSize.lg, status: UiStatus.warning),
                  UiAvatar(name: people[2].name, shape: UiAvatarShape.rounded),
                  const UiAvatar(size: UiSize.sm),
                  UiAvatarGroup(
                    avatars: [for (final p in people) UiAvatar(name: p.name, image: AssetImage(p.avatar))],
                    max: 3,
                  ),
                ],
              ),
              DemoWrap(
                children: [
                  UiBadge(count: _unread, child: const Icon(Icons.notifications_rounded)),
                  const UiBadge(dot: true, child: Icon(Icons.chat_bubble_outline_rounded)),
                  UiBadge.standalone(count: 120),
                  const UiStatusPill('Online', status: UiStatus.success, pulse: true),
                  const UiStatusPill('Paid', status: UiStatus.info, icon: Icons.check_rounded),
                  const UiKbd('⌘K'),
                ],
              ),
              DemoWrap(
                children: [
                  for (final t in _tags)
                    UiTag(t, status: UiStatus.accent, onRemove: () => setState(() => _tags.remove(t))),
                  const UiTag('Neutral'),
                  const UiTag('Custom', color: Colors.purple, icon: Icons.star_rounded),
                ],
              ),
            ],
          ),
        ),
        Demo(
          'Table',
          subtitle: _picked == null ? 'Sort by a header, tap a row' : 'Tapped ${_picked!.name}',
          child: UiTable<Person>(
            striped: true,
            onRowTap: (p) => setState(() => _picked = p),
            columns: [
              UiTableColumn(
                'Name',
                builder: (context, p) => UiRow(
                  children: [
                    UiAvatar(name: p.name, image: AssetImage(p.avatar), size: UiSize.sm),
                    Flexible(child: Text(p.name, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                sortBy: (p) => p.name,
              ),
              UiTableColumn('Role', text: (p) => p.role, sortBy: (p) => p.role),
              UiTableColumn('City', text: (p) => p.city),
              UiTableColumn('Score', text: (p) => '${p.score}', sortBy: (p) => p.score, numeric: true, mono: true),
            ],
            rows: people,
          ),
        ),
        Demo(
          'Key values and code',
          child: UiColumn(
            children: [
              UiKeyValueList([
                const UiKeyValue('Order ID', 'A-10294', copyable: true, mono: true),
                const UiKeyValue('Status', 'Paid'),
                UiKeyValue.custom(
                  'Owner',
                  child: UiAvatar(name: people[3].name, size: UiSize.sm),
                ),
              ]),
              const UiCodeText('A1B2-C3D4', copyable: true),
              const UiCodeBlock('cd theme/example\nflutter pub get\nflutter run -d macos', title: 'Terminal'),
            ],
          ),
        ),
        Demo(
          'Timeline and accordion',
          child: UiColumn(
            gap: UiSpace.lg,
            children: [
              const UiTimeline(
                items: [
                  UiTimelineItem('Order placed', time: '09:41', status: UiStatus.success),
                  UiTimelineItem('Packed', time: '11:02', description: 'Warehouse B', status: UiStatus.info),
                  UiTimelineItem('Out for delivery', time: 'Pending', icon: Icons.local_shipping_outlined),
                ],
              ),
              UiAccordion(
                items: const [
                  UiAccordionItem('Shipping', Text('2-4 business days.'), icon: Icons.local_shipping_outlined),
                  UiAccordionItem('Returns', Text('Free returns within 30 days.'), subtitle: 'No questions asked'),
                  UiAccordionItem('Warranty', Text('Two years on all products.')),
                ],
                onChanged: (i, open) => context.showToast('Section $i ${open ? 'opened' : 'closed'}', replace: true),
              ),
            ],
          ),
        ),
        Demo(
          'Text helpers',
          child: UiColumn(
            children: [
              const UiExpandableText(
                'Long text gets cut to a few lines with a toggle. Lorem ipsum dolor sit amet, consectetur adipiscing '
                'elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, '
                'quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure '
                'dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                maxLines: 2,
              ),
              const UiHighlightText('Highlight every match of a term in this text', 'th'),
            ],
          ),
        ),
        Demo(
          'Files and countdown',
          child: UiColumn(
            children: [
              UiFileTile(
                name: 'holiday-video.mp4',
                size: 734003200,
                progress: _download,
                onTap: () => setState(() => _download = _download >= 1 ? 0 : (_download + 0.2).clamp(0, 1)),
                subtitle: 'Tap to advance',
              ),
              const UiFileTile(name: 'report.pdf', size: 248000),
              const UiFileTile(
                name: 'backup.zip',
                size: 1200000000,
                progress: 0.6,
                status: UiStatus.danger,
                subtitle: 'Failed',
              ),
              UiRow(
                gap: UiSpace.lg,
                children: [
                  const UiCountdown(period: Duration(seconds: 30), repeat: true),
                  Flexible(
                    child: Text(
                      '${UiFormat.bytes(1536)} · ${UiFormat.compact(12400)} · '
                      '${UiFormat.duration(const Duration(minutes: 4, seconds: 9))} · '
                      '${UiFormat.relativeTime(now.subtract(const Duration(hours: 3)))}',
                      style: context.text.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
