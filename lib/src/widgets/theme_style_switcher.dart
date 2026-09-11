import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';
import 'package:theme/src/theme_presets/app_theme_preset.dart';
import 'package:theme/src/theme_presets/app_theme_style.dart';

/// A visual theme-style picker. Renders a horizontal scrolling row of
/// preview cards — each painted from the style's own [ColorScheme] and
/// [AppShadowTheme] so the user sees a faithful miniature of the theme
/// before selecting it. Works in any app: pass [styles] (defaults to all
/// [AppThemeStyle.all]), the currently-selected [selectedId], and an
/// [onSelected] callback.
///
/// ```dart
/// ThemeStyleSwitcher(
///   selectedId: controller.value.styleId,
///   onSelected: controller.setStyle,
/// )
/// ```
class ThemeStyleSwitcher extends StatefulWidget {
  ThemeStyleSwitcher({
    super.key,
    List<AppThemeStyle>? styles,
    this.selectedId = 'material',
    this.onSelected,
    this.brightness = Brightness.light,
    this.cardWidth = 140,
    this.cardHeight = 96,
    this.spacing = 12,
    this.showLabels = true,
  }) : styles = styles ?? AppThemeStyle.all;

  final List<AppThemeStyle> styles;
  final String selectedId;
  final ValueChanged<String>? onSelected;
  final Brightness brightness;
  final double cardWidth;
  final double cardHeight;
  final double spacing;
  final bool showLabels;

  @override
  State<ThemeStyleSwitcher> createState() => _ThemeStyleSwitcherState();
}

class _ThemeStyleSwitcherState extends State<ThemeStyleSwitcher> {
  late final ScrollController _ctrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _labelHeight(BuildContext context) {
    if (!widget.showLabels) return 0;
    final painter = TextPainter(
      text: const TextSpan(
        text: 'Ag',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      strutStyle:
          const StrutStyle(fontSize: 12, height: 1.4, forceStrutHeight: true),
    )..layout();
    // A couple of extra px cushion — glyph metrics can round up slightly
    // past the strut height depending on platform font rendering.
    return 6 + painter.height + 2;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.cardHeight + _labelHeight(context) + 8,
      child: ListView.separated(
        controller: _ctrl,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemCount: widget.styles.length,
        separatorBuilder: (_, __) => SizedBox(width: widget.spacing),
        itemBuilder: (_, i) {
          final style = widget.styles[i];
          final selected = style.id == widget.selectedId;
          return GestureDetector(
            onTap: () => widget.onSelected?.call(style.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StylePreviewCard(
                  preset: style.preset(widget.brightness),
                  selected: selected,
                  width: widget.cardWidth,
                  height: widget.cardHeight,
                ),
                if (widget.showLabels) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: widget.cardWidth,
                    child: Text(
                      style.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StylePreviewCard extends StatelessWidget {
  const _StylePreviewCard({
    required this.preset,
    required this.selected,
    required this.width,
    required this.height,
  });

  final AppThemePreset preset;
  final bool selected;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = preset.colorScheme;
    final shadows = preset.shadows;
    final radius = preset.cardRadius.clamp(8, 20).toDouble();
    final borderWidth = selected ? 2.5 : 1.0;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color:
              selected ? scheme.primary : scheme.outline.withValues(alpha: 0.3),
          width: borderWidth,
        ),
        boxShadow: [
          shadows.shadowOne,
          if (selected) shadows.shadowTwo,
        ],
      ),
      padding: EdgeInsets.all(borderWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          (radius - borderWidth).clamp(0, radius),
        ),
        child: _StylePreview(preset: preset),
      ),
    );
  }
}

class _StylePreview extends StatelessWidget {
  const _StylePreview({required this.preset});

  final AppThemePreset preset;

  @override
  Widget build(BuildContext context) {
    final scheme = preset.colorScheme;
    final r = preset.cardRadius.clamp(4, 12).toDouble();
    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 5),
              Container(
                  width: 7,
                  height: 10,
                  decoration: BoxDecoration(
                      color: scheme.secondary,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 5),
              Container(
                  width: 7,
                  height: 10,
                  decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(2))),
              const Spacer(),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius:
                      BorderRadius.circular(preset.buttonRadius.clamp(2, 9)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius:
                        BorderRadius.circular(preset.buttonRadius.clamp(2, 7)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
