import 'dart:async';

import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

typedef _Country = ({String name, String code, String region});

const _countries = <_Country>[
  (name: 'Argentina', code: 'AR', region: 'South America'),
  (name: 'Australia', code: 'AU', region: 'Oceania'),
  (name: 'Brazil', code: 'BR', region: 'South America'),
  (name: 'Canada', code: 'CA', region: 'North America'),
  (name: 'Egypt', code: 'EG', region: 'Africa'),
  (name: 'France', code: 'FR', region: 'Europe'),
  (name: 'Germany', code: 'DE', region: 'Europe'),
  (name: 'India', code: 'IN', region: 'Asia'),
  (name: 'Italy', code: 'IT', region: 'Europe'),
  (name: 'Japan', code: 'JP', region: 'Asia'),
  (name: 'Kenya', code: 'KE', region: 'Africa'),
  (name: 'Mexico', code: 'MX', region: 'North America'),
  (name: 'Nigeria', code: 'NG', region: 'Africa'),
  (name: 'Norway', code: 'NO', region: 'Europe'),
  (name: 'Singapore', code: 'SG', region: 'Asia'),
  (name: 'Spain', code: 'ES', region: 'Europe'),
  (name: 'United Kingdom', code: 'GB', region: 'Europe'),
  (name: 'United States', code: 'US', region: 'North America'),
];

Future<List<_Country>> _remoteSearch(String q) async {
  await Future<void>.delayed(const Duration(milliseconds: 600));
  final lq = q.toLowerCase();
  return [for (final c in _countries) if (c.name.toLowerCase().contains(lq) || c.code.toLowerCase() == lq) c];
}

class DropdownsChipsSection extends StatefulWidget {
  const DropdownsChipsSection({super.key});

  @override
  State<DropdownsChipsSection> createState() => _DropdownsChipsSectionState();
}

class _DropdownsChipsSectionState extends State<DropdownsChipsSection> {
  String? _fruit = 'Apple';
  _Country? _country;
  _Country? _remote;
  List<_Country> _many = [_countries[5], _countries[7]];
  final _tags = <String>['Design', 'Flutter', 'Mobile'];
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    String name(_Country c) => c.name;
    return SectionPage(
      children: [
        DemoBlock(
          'UiDropdown',
          subtitle: 'Basic menu for short lists',
          child: UiDropdown<String>(
            label: 'Fruit',
            items: const ['Apple', 'Banana', 'Cherry', 'Mango'],
            value: _fruit,
            onChanged: (v) => setState(() => _fruit = v),
          ),
        ),
        DemoBlock(
          'UiSearchableDropdown',
          subtitle: 'Opens a sheet with a search box. Filters the list on the device.',
          child: UiSearchableDropdown<_Country>(
            label: 'Country',
            hint: 'Pick a country',
            prefixIcon: Icons.public_rounded,
            items: _countries,
            value: _country,
            itemLabel: name,
            itemSubtitle: (c) => c.region,
            clearable: true,
            isRequired: true,
            onChanged: (v) => setState(() => _country = v),
          ),
        ),
        DemoBlock(
          'UiSearchableDropdown with onSearch',
          subtitle: 'Async search with debounce and a 600 ms fake delay. Type 2+ letters.',
          child: UiSearchableDropdown<_Country>(
            label: 'Country (server)',
            onSearch: _remoteSearch,
            minChars: 2,
            value: _remote,
            itemLabel: name,
            itemSubtitle: (c) => c.code,
            onChanged: (v) => setState(() => _remote = v),
          ),
        ),
        DemoBlock(
          'UiMultiSelectDropdown',
          subtitle: 'Pick up to 4. Selected items show as chips.',
          child: UiMultiSelectDropdown<_Country>(
            label: 'Markets',
            items: _countries,
            values: _many,
            itemLabel: name,
            itemSubtitle: (c) => c.region,
            max: 4,
            onChanged: (v) => setState(() => _many = v),
          ),
        ),
        DemoBlock(
          'UiAutocomplete',
          subtitle: 'Suggestions show under the field as you type',
          child: UiAutocomplete<_Country>(
            label: 'Search countries',
            onSearch: _remoteSearch,
            itemLabel: name,
            itemSubtitle: (c) => c.region,
            onSelected: (c) => toast(context, 'Picked ${c.name}'),
          ),
        ),
        DemoBlock(
          'UiChip variants',
          child: UiChipGroup(
            children: [
              for (final v in UiChipVariant.values) UiChip(v.name, variant: v, onTap: () {}),
            ],
          ),
        ),
        DemoBlock(
          'UiChip with status, icon, avatar, count',
          child: UiChipGroup(
            children: [
              const UiChip('Paid', status: UiStatus.success, icon: Icons.check_circle_rounded),
              const UiChip('Overdue', status: UiStatus.danger, variant: UiChipVariant.soft),
              const UiChip('Pending', status: UiStatus.warning, variant: UiChipVariant.outline),
              UiChip('Ana Lee', avatar: UiAvatar(name: 'Ana Lee', imageUrl: pic('ana', 100, 100), size: 26), onTap: () {}),
              const UiChip('Inbox', icon: Icons.inbox_rounded, count: 12),
              const UiChip('Disabled', enabled: false),
              for (final s in UiSize.values) UiChip('Size ${s.name}', size: s, variant: UiChipVariant.filled),
            ],
          ),
        ),
        DemoBlock(
          'Input chips (onDeleted)',
          child: UiChipGroup(
            children: [
              for (final t in _tags) UiChip(t, onDeleted: () => setState(() => _tags.remove(t))),
              UiChip('Add', icon: Icons.add_rounded, variant: UiChipVariant.outline, onTap: () => setState(() => _tags.add('Tag ${_tags.length + 1}'))),
            ],
          ),
        ),
        DemoBlock(
          'Scrollable chip group',
          child: UiChipGroup(
            scrollable: true,
            children: [
              for (final f in const ['All', 'Unread', 'Starred', 'Sent', 'Drafts', 'Archive', 'Spam', 'Trash'])
                UiChip(f, selected: f == _filter, onTap: () => setState(() => _filter = f)),
            ],
          ),
        ),
      ],
    );
  }
}
