import 'package:flutter/material.dart';

class ThemeSearchableDropdown<T> extends StatefulWidget {
  const ThemeSearchableDropdown({
    super.key,
    required this.items,
    this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.itemLabel = _defaultLabel,
    this.itemLeading,
    this.maxHeight = 320,
    this.enabled = true,
  });

  final List<T> items;
  final String? label;
  final String? hint;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String Function(T) itemLabel;
  final Widget Function(T)? itemLeading;
  final double maxHeight;
  final bool enabled;

  static String _defaultLabel(dynamic v) => v.toString();

  @override
  State<ThemeSearchableDropdown<T>> createState() => _ThemeSearchableDropdownState<T>();
}

class _ThemeSearchableDropdownState<T> extends State<ThemeSearchableDropdown<T>> {
  final LayerLink _link = LayerLink();
  final TextEditingController _searchCtrl = TextEditingController();
  OverlayEntry? _entry;
  List<T> _filtered = const [];
  bool _open = false;

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openMenu() {
    if (!widget.enabled) return;
    _filtered = widget.items;
    _open = true;
    _entry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _close() {
    _open = false;
    _entry?.remove();
    _entry = null;
    _searchCtrl.clear();
    if (mounted) setState(() {});
  }

  void _filter(String q) {
    _filtered = widget.items.where((i) => widget.itemLabel(i).toLowerCase().contains(q.toLowerCase())).toList();
    _entry?.markNeedsBuild();
  }

  double _cardRadius(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }

  double _inputRadius(BuildContext context) {
    final border = Theme.of(context).inputDecorationTheme.border;
    if (border is OutlineInputBorder) return border.borderRadius.topLeft.x;
    return 10;
  }

  Widget _buildOverlay(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(children: [
      GestureDetector(behavior: HitTestBehavior.opaque, onTap: _close, child: const SizedBox.expand()),
      Positioned(
        width: _link.leaderSize?.width ?? 220,
        child: CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 6),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(_cardRadius(context)),
            color: scheme.surface,
            child: ConstrainedConstraints(
              maxHeight: widget.maxHeight,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    onChanged: _filter,
                    decoration: InputDecoration(
                      hintText: widget.hint ?? 'Search...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(_inputRadius(context))),
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      final selected = item == widget.value;
                      return ListTile(
                        dense: true,
                        leading: widget.itemLeading?.call(item),
                        title: Text(widget.itemLabel(item)),
                        trailing: selected ? Icon(Icons.check, size: 18, color: scheme.primary) : null,
                        onTap: () {
                          widget.onChanged?.call(item);
                          _close();
                        },
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _open ? _close : _openMenu,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.value != null ? widget.itemLabel(widget.value as T) : (widget.hint ?? 'Select...'),
            suffixIcon: Icon(_open ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            enabled: widget.enabled,
          ),
          child: SizedBox(height: 22, child: widget.value != null
              ? Align(alignment: Alignment.centerLeft, child: Text(widget.itemLabel(widget.value as T), style: TextStyle(color: scheme.onSurface)))
              : null),
        ),
      ),
    );
  }
}

class ConstrainedConstraints extends StatelessWidget {
  const ConstrainedConstraints({super.key, required this.maxHeight, required this.child});
  final double maxHeight;
  final Widget child;
  @override
  Widget build(BuildContext context) => ConstrainedBox(constraints: BoxConstraints(maxHeight: maxHeight), child: child);
}