import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  double _minWidth = 140;
  Person? _selected;
  int _surfaceTaps = 0;

  void _openScaffold() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const _ScaffoldDemo()));
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      children: [
        Demo(
          'UiScaffold and UiBottomBar',
          subtitle: 'Opens a full page with a sticky bottom bar',
          child: UiButton('Open page', icon: Icons.open_in_new_rounded, onPressed: _openScaffold),
        ),
        UiSection(
          title: 'Section header',
          subtitle: 'With a trailing action',
          actionLabel: 'See all',
          onAction: () => context.showToast('See all tapped'),
          child: const Text('UiSection puts a UiSectionHeader above any child.'),
        ),
        Demo(
          'Dividers and gaps',
          child: UiColumn(
            children: [
              const UiDivider(),
              const UiDivider(label: 'or'),
              SizedBox(
                height: 32,
                child: UiRow(
                  children: [
                    const Text('Left'),
                    const UiDivider(vertical: true),
                    const Text('Middle'),
                    const UiGap(UiSpace.xl),
                    Flexible(
                      child: Text('after UiGap(24)', style: context.text.bodySmall, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Demo(
          'Responsive grid',
          subtitle: 'Min item width ${_minWidth.round()} px',
          child: UiColumn(
            children: [
              UiSlider(
                value: _minWidth,
                min: 80,
                max: 320,
                divisions: 12,
                label: 'minItemWidth',
                onChanged: (v) => setState(() => _minWidth = v),
              ),
              UiResponsiveGrid(
                minItemWidth: _minWidth,
                equalHeight: true,
                children: [
                  for (var i = 0; i < 6; i++)
                    UiSurface(
                      tone: UiStatus.values[i % UiStatus.values.length],
                      child: Text('Item ${i + 1}', style: context.text.labelLarge),
                    ),
                ],
              ),
            ],
          ),
        ),
        Demo(
          'Responsive layout',
          child: UiResponsiveLayout.builder(
            local: true,
            builder: (context, bp) =>
                UiSurface(tone: UiStatus.info, child: Text('This box is ${bp.name} (by its own width)')),
          ),
        ),
        Demo(
          'Split view',
          subtitle: 'Side by side when wide, one pane when narrow',
          child: SizedBox(
            height: 320,
            child: UiSurface(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: UiRadius.all(UiRadius.lg),
                child: UiSplitView(
                  breakpoint: UiBreakpoint.medium,
                  primaryWidth: 260,
                  primary: ListView(
                    primary: false,
                    children: [
                      for (final p in people)
                        UiListTile(
                          p.name,
                          subtitle: p.role,
                          leading: UiAvatar(name: p.name, image: AssetImage(p.avatar)),
                          selected: p == _selected,
                          onTap: () => setState(() => _selected = p),
                        ),
                    ],
                  ),
                  secondary: _selected == null
                      ? null
                      : _PersonDetail(_selected!, onClose: () => setState(() => _selected = null)),
                  placeholder: const UiEmptyState(
                    title: 'Pick someone',
                    icon: Icons.person_search_outlined,
                    compact: true,
                  ),
                  onCloseSecondary: () => setState(() => _selected = null),
                ),
              ),
            ),
          ),
        ),
        Demo(
          'Surfaces',
          child: DemoWrap(
            children: [
              const UiSurface(child: Text('Plain')),
              UiSurface(shadow: context.shadowMd, border: false, child: const Text('Shadow')),
              const UiSurface(tone: UiStatus.success, child: Text('Success tone')),
              UiSurface(onTap: () => setState(() => _surfaceTaps++), child: Text('Tappable ($_surfaceTaps)')),
            ],
          ),
        ),
      ],
    );
  }
}

class _PersonDetail extends StatelessWidget {
  const _PersonDetail(this.person, {required this.onClose});

  final Person person;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      padding: const EdgeInsets.all(UiSpace.lg),
      children: [
        UiRow(
          children: [
            UiAvatar(name: person.name, image: AssetImage(person.avatar), size: UiSize.lg),
            Expanded(
              child: Text(person.name, style: context.text.titleLarge, overflow: TextOverflow.ellipsis),
            ),
            UiIconButton(Icons.close_rounded, tooltip: 'Close', onPressed: onClose),
          ],
        ),
        const UiGap(UiSpace.lg),
        UiKeyValueList.map({'Role': person.role, 'City': person.city, 'Score': '${person.score}'}),
      ],
    );
  }
}

class _ScaffoldDemo extends StatefulWidget {
  const _ScaffoldDemo();

  @override
  State<_ScaffoldDemo> createState() => _ScaffoldDemoState();
}

class _ScaffoldDemoState extends State<_ScaffoldDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return UiScaffold(
      appBar: const UiAppBar(title: 'Edit profile', large: true),
      scrollable: true,
      maxWidth: 640,
      onRefresh: () => Future<void>.delayed(const Duration(seconds: 1)),
      bottomBar: UiBottomBar(
        children: [
          UiButton('Cancel', variant: UiButtonVariant.outline, onPressed: () => Navigator.pop(context)),
          UiButton('Save ($_count)', onPressed: () => setState(() => _count++)),
        ],
      ),
      body: UiColumn(
        gap: UiSpace.lg,
        children: [
          UiTextField(label: 'Name', initialValue: 'Ada Lovelace'),
          UiTextArea(label: 'About'),
          for (var i = 0; i < 6; i++) UiSurface(child: Text('Scroll content ${i + 1}')),
        ],
      ),
    );
  }
}
