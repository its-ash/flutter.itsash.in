import 'package:flutter/material.dart';

class ThemeSplitPanel extends StatefulWidget {
  const ThemeSplitPanel({
    super.key,
    required this.first,
    required this.second,
    this.axis = Axis.horizontal,
    this.initialRatio = 0.5,
    this.minRatio = 0.15,
    this.maxRatio = 0.85,
    this.onRatioChanged,
    this.dividerThickness = 8,
  });

  final Widget first;
  final Widget second;
  final Axis axis;
  final double initialRatio;
  final double minRatio;
  final double maxRatio;
  final ValueChanged<double>? onRatioChanged;
  final double dividerThickness;

  @override
  State<ThemeSplitPanel> createState() => _ThemeSplitPanelState();
}

class _ThemeSplitPanelState extends State<ThemeSplitPanel> {
  late double _ratio = widget.initialRatio;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final horizontal = widget.axis == Axis.horizontal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = horizontal ? constraints.maxWidth : constraints.maxHeight;

        void updateRatio(double delta) {
          setState(() {
            _ratio = (_ratio + delta / extent).clamp(widget.minRatio, widget.maxRatio);
          });
          widget.onRatioChanged?.call(_ratio);
        }

        final divider = MouseRegion(
          cursor: horizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow,
          child: GestureDetector(
            onPanUpdate: (details) => updateRatio(horizontal ? details.delta.dx : details.delta.dy),
            child: Container(
              width: horizontal ? widget.dividerThickness : null,
              height: horizontal ? null : widget.dividerThickness,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: Container(
                width: horizontal ? 2 : 32,
                height: horizontal ? 32 : 2,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        );

        final children = [
          SizedBox(
            width: horizontal ? extent * _ratio - widget.dividerThickness / 2 : null,
            height: horizontal ? null : extent * _ratio - widget.dividerThickness / 2,
            child: widget.first,
          ),
          divider,
          Expanded(child: widget.second),
        ];

        return horizontal
            ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children)
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
      },
    );
  }
}
