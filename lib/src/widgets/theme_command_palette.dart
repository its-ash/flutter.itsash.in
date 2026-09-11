import 'package:flutter/material.dart';

class ThemeCommandPalette extends StatefulWidget {
  const ThemeCommandPalette({
    super.key,
    this.commands = const [],
    this.placeholder = 'Search commands...',
  });

  final List<ThemeCommand> commands;
  final String placeholder;

  static Future<ThemeCommand?> show(BuildContext context, {List<ThemeCommand> commands = const [], String placeholder = 'Search commands...'}) {
    return showDialog<ThemeCommand>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => ThemeCommandPalette(commands: commands, placeholder: placeholder),
    );
  }

  @override
  State<ThemeCommandPalette> createState() => _ThemeCommandPaletteState();
}

class _ThemeCommandPaletteState extends State<ThemeCommandPalette> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  int _sel = 0;
  List<ThemeCommand> _filtered = const [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.commands;
    _ctrl.addListener(_filter);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _filter() {
    final q = _ctrl.text.toLowerCase();
    _filtered = widget.commands.where((c) => c.label.toLowerCase().contains(q) || (c.tags?.any((t) => t.toLowerCase().contains(q)) ?? false)).toList();
    _sel = 0;
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _run(int i) {
    if (i < 0 || i >= _filtered.length) return;
    Navigator.pop(context, _filtered[i]);
  }

  double _cardRadius(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 16;
  }

  double _inputRadius(BuildContext context) {
    final border = Theme.of(context).inputDecorationTheme.border;
    if (border is OutlineInputBorder) return border.borderRadius.topLeft.x;
    return 10;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 400, vertical: 80),
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(_cardRadius(context)),
          boxShadow: [BoxShadow(color: scheme.shadow.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.pop(context)),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(_inputRadius(context))),
              ),
              onSubmitted: (_) => _run(_sel),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final c = _filtered[i];
                final selected = i == _sel;
                return ListTile(
                  dense: true,
                  leading: c.icon != null ? Icon(c.icon, size: 20, color: selected ? scheme.primary : scheme.onSurfaceVariant) : null,
                  title: Text(c.label, style: tt.bodyMedium?.copyWith(color: selected ? scheme.primary : scheme.onSurface, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                  subtitle: c.description != null ? Text(c.description!, style: tt.bodySmall) : null,
                  trailing: c.shortcut != null ? Text(c.shortcut!, style: tt.labelSmall?.copyWith(color: scheme.onSurfaceVariant)) : null,
                  tileColor: selected ? scheme.primaryContainer.withValues(alpha: 0.5) : null,
                  onTap: () => _run(i),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class ThemeCommand {
  const ThemeCommand({
    required this.id,
    required this.label,
    this.description,
    this.icon,
    this.shortcut,
    this.tags,
    this.run,
  });

  final String id;
  final String label;
  final String? description;
  final IconData? icon;
  final String? shortcut;
  final List<String>? tags;
  final VoidCallback? run;
}