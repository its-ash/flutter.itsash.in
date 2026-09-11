import 'package:flutter/material.dart';

import 'package:theme/theme.dart';
import '../showcase_tile.dart';

class ListsSection extends StatefulWidget {
  const ListsSection({super.key});

  @override
  State<ListsSection> createState() => _ListsSectionState();
}

class _ListsSectionState extends State<ListsSection> {
  var _draggableItems = const ['Design', 'Development', 'Testing', 'Launch'];

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      children: [
        ShowcaseTile(
          title: 'ThemeListTile',
          child: ThemeCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ThemeListTile(
                  leading: const Icon(Icons.person_outline),
                  title: 'Profile',
                  subtitle: 'View and edit your info',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ThemeListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: 'Notifications',
                  selected: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeExpansionTile',
          child: ThemeCard(
            margin: EdgeInsets.zero,
            child: ThemeExpansionTile(
              title: 'Shipping details',
              leading: const Icon(Icons.local_shipping_outlined),
              children: const [
                Padding(padding: EdgeInsets.all(16), child: Text('Delivered in 3-5 business days.')),
              ],
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeDataTable',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ThemeDataTable(
              columns: const [
                DataColumn(label: Text('Item')),
                DataColumn(label: Text('Qty')),
                DataColumn(label: Text('Price')),
              ],
              rows: const [
                DataRow(cells: [DataCell(Text('Running shoes')), DataCell(Text('1')), DataCell(Text('\$120'))]),
                DataRow(cells: [DataCell(Text('Socks')), DataCell(Text('3')), DataCell(Text('\$15'))]),
              ],
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeScrollbar',
          child: SizedBox(
            height: 100,
            child: ThemeScrollbar(
              child: ListView.builder(
                primary: true,
                itemCount: 20,
                itemBuilder: (_, i) => ListTile(dense: true, title: Text('Row $i')),
              ),
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeCarousel',
          child: Builder(
            builder: (context) {
              final scheme = Theme.of(context).colorScheme;
              return ThemeCarousel(
                itemExtent: 180,
                children: List.generate(
                  4,
                  (i) => Container(
                    color: scheme.primaryContainer,
                    alignment: Alignment.center,
                    child: Text('Item $i', style: TextStyle(color: scheme.onPrimaryContainer)),
                  ),
                ),
              );
            },
          ),
        ),
        ShowcaseTile(
          title: 'ThemeAccordion / ThemeAccordionList',
          child: ThemeAccordionList(
            items: [
              ThemeAccordionItem(
                title: const Text('Shipping'),
                leading: const Icon(Icons.local_shipping_outlined),
                children: const [
                  Padding(padding: EdgeInsets.all(16), child: Text('Delivered in 3-5 business days.')),
                ],
              ),
              ThemeAccordionItem(
                title: const Text('Returns'),
                leading: const Icon(Icons.assignment_return_outlined),
                children: const [
                  Padding(padding: EdgeInsets.all(16), child: Text('Free returns within 30 days.')),
                ],
              ),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeDraggableList<T>',
          description: 'Drag the handle to reorder',
          child: SizedBox(
            height: 220,
            child: ThemeDraggableList<String>(
              items: _draggableItems,
              onReorder: (items) => setState(() => _draggableItems = items),
              itemBuilder: (context, item, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Text(item),
              ),
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeTreeView<T>',
          child: ThemeTreeView<String>(
            nodes: [
              ThemeTreeNode(
                value: 'src',
                label: 'src',
                icon: Icons.folder_outlined,
                children: [
                  ThemeTreeNode(value: 'widgets', label: 'widgets', icon: Icons.folder_outlined, children: [
                    ThemeTreeNode(value: 'button.dart', label: 'button.dart', icon: Icons.description_outlined),
                  ]),
                  ThemeTreeNode(value: 'main.dart', label: 'main.dart', icon: Icons.description_outlined),
                ],
              ),
              ThemeTreeNode(value: 'pubspec.yaml', label: 'pubspec.yaml', icon: Icons.description_outlined),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeTimeline',
          child: ThemeTimeline(
            entries: const [
              ThemeTimelineEntry(title: 'Order placed', timestamp: '9:02 AM', status: ThemeStatus.info),
              ThemeTimelineEntry(title: 'Payment confirmed', timestamp: '9:04 AM', status: ThemeStatus.success),
              ThemeTimelineEntry(title: 'Payment failed retry', timestamp: '9:05 AM', status: ThemeStatus.error),
              ThemeTimelineEntry(title: 'Out for delivery', description: 'Arriving tomorrow', status: ThemeStatus.neutral),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeAvatarGroup',
          child: ThemeAvatarGroup(
            avatars: const [
              ThemeAvatarData(initials: 'AR'),
              ThemeAvatarData(initials: 'BK'),
              ThemeAvatarData(initials: 'CJ'),
              ThemeAvatarData(initials: 'DL'),
              ThemeAvatarData(initials: 'EM'),
            ],
            maxVisible: 3,
          ),
        ),
        ShowcaseTile(
          title: 'ThemePullToRefresh',
          description: 'Pull down to trigger onRefresh',
          child: SizedBox(
            height: 160,
            child: ThemePullToRefresh(
              onRefresh: () => Future.delayed(const Duration(seconds: 1)),
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (_, i) => ListTile(dense: true, title: Text('Item $i')),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
