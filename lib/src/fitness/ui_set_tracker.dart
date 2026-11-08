import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';

typedef UiSetEntry = ({double? weight, int? reps, bool done});

class UiSetTracker extends StatefulWidget {
  const UiSetTracker({
    super.key,
    this.initial = const [],
    this.previous = const [],
    this.onChanged,
    this.unit = 'kg',
    this.maxSets = 20,
    this.addLabel = 'Add set',
  });

  final List<UiSetEntry> initial;
  final List<String> previous;
  final ValueChanged<List<UiSetEntry>>? onChanged;
  final String unit;
  final int maxSets;
  final String addLabel;

  @override
  State<UiSetTracker> createState() => _UiSetTrackerState();
}

class _Row {
  _Row(this.id, UiSetEntry e)
      : w = TextEditingController(text: e.weight == null || !e.weight!.isFinite || e.weight! < 0 ? '' : UiFormat.number(e.weight, decimals: 2, trimZeros: true, group: '')),
        r = TextEditingController(text: e.reps == null || e.reps! < 0 ? '' : '${e.reps}'),
        done = e.done;

  final int id;
  final TextEditingController w;
  final TextEditingController r;
  bool done;

  UiSetEntry get entry => (
        weight: double.tryParse(w.text.replaceAll(',', '.')),
        reps: int.tryParse(r.text),
        done: done,
      );

  void dispose() {
    w.dispose();
    r.dispose();
  }
}

class _UiSetTrackerState extends State<UiSetTracker> {
  static final _weightFmt = TextInputFormatter.withFunction(
    (o, n) => RegExp(r'^\d{0,4}([.,]\d{0,2})?$').hasMatch(n.text) ? n : o,
  );
  static final _repsFmt = TextInputFormatter.withFunction((o, n) => RegExp(r'^\d{0,3}$').hasMatch(n.text) ? n : o);

  final List<_Row> _rows = [];
  var _next = 0;

  int get _max => widget.maxSets < 1 ? 1 : widget.maxSets;

  @override
  void initState() {
    super.initState();
    final seed = widget.initial.isEmpty ? const <UiSetEntry>[(weight: null, reps: null, done: false)] : widget.initial;
    for (final e in seed.take(_max)) {
      _rows.add(_Row(_next++, e));
    }
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _emit() => widget.onChanged?.call([for (final r in _rows) r.entry]);

  void _add() {
    if (_rows.length >= _max) return;
    final last = _rows.isEmpty ? null : _rows.last.entry;
    setState(() => _rows.add(_Row(_next++, (weight: last?.weight, reps: last?.reps, done: false))));
    _emit();
  }

  void _remove(_Row r) {
    if (_rows.length <= 1) return;
    setState(() => _rows.remove(r));
    WidgetsBinding.instance.addPostFrameCallback((_) => r.dispose());
    _emit();
  }

  void _toggle(_Row r) {
    HapticFeedback.selectionClick();
    setState(() => r.done = !r.done);
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final head = context.text.labelSmall?.copyWith(
      color: cs.onSurfaceVariant,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );

    Widget cell(int flex, Widget child) => Expanded(flex: flex, child: Center(child: child));

    InputDecoration deco(bool done) => InputDecoration(
          isDense: true,
          filled: true,
          fillColor: done ? Colors.transparent : cs.surfaceContainerHighest,
          hintText: '–',
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: UiSpace.xs),
          border: OutlineInputBorder(borderRadius: context.tokens.sm, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: context.tokens.sm, borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: context.tokens.sm, borderSide: BorderSide(color: cs.primary, width: 1.5)),
        );

    Widget field(TextEditingController c, bool decimal, bool done, String label) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
          child: Semantics(
            label: label,
            child: TextField(
              controller: c,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(decimal: decimal),
              inputFormatters: [decimal ? _weightFmt : _repsFmt],
              style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              decoration: deco(done),
              onChanged: (_) => _emit(),
            ),
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: UiSpace.sm),
          child: Row(
            children: [
              cell(2, Text('SET', style: head)),
              cell(4, Text('PREVIOUS', style: head)),
              cell(3, Text(widget.unit.toUpperCase(), style: head)),
              cell(3, Text('REPS', style: head)),
              cell(2, Icon(Icons.check_rounded, size: 16, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
        for (var i = 0; i < _rows.length; i++)
          Dismissible(
            key: ValueKey(_rows[i].id),
            direction: _rows.length > 1 ? DismissDirection.endToStart : DismissDirection.none,
            onDismissed: (_) => _remove(_rows[i]),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: UiSpace.lg),
              decoration: BoxDecoration(color: cs.errorContainer, borderRadius: context.tokens.sm),
              child: Icon(Icons.delete_outline_rounded, color: cs.onErrorContainer),
            ),
            child: AnimatedContainer(
              duration: UiDuration.fast,
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
              decoration: BoxDecoration(
                color: _rows[i].done ? context.palette.successContainer.withValues(alpha: 0.6) : Colors.transparent,
                borderRadius: context.tokens.sm,
              ),
              child: Row(
                children: [
                  cell(2, Text('${i + 1}', style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
                  cell(
                    4,
                    Text(
                      i < widget.previous.length && widget.previous[i].trim().isNotEmpty ? widget.previous[i] : '–',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  cell(3, field(_rows[i].w, true, _rows[i].done, 'Weight, set ${i + 1}')),
                  cell(3, field(_rows[i].r, false, _rows[i].done, 'Reps, set ${i + 1}')),
                  cell(
                    2,
                    Semantics(
                      checked: _rows[i].done,
                      label: 'Set ${i + 1} done',
                      child: InkResponse(
                        onTap: () => _toggle(_rows[i]),
                        radius: 20,
                        child: AnimatedContainer(
                          duration: UiDuration.fast,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _rows[i].done ? context.palette.success : cs.surfaceContainerHighest,
                            borderRadius: context.tokens.xs,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: _rows[i].done ? context.palette.onSuccess : cs.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const UiGap.sm(),
        UiButton.tonal(
          widget.addLabel,
          icon: Icons.add_rounded,
          size: UiSize.sm,
          expand: true,
          onPressed: _rows.length < _max ? _add : null,
        ),
      ],
    );
  }
}
