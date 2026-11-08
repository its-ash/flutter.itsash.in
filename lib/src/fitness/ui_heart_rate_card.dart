import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/display/ui_charts.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';

class UiHeartRateCard extends StatelessWidget {
  const UiHeartRateCard({
    super.key,
    required this.bpm,
    this.samples = const [],
    this.maxHeartRate = 190,
    this.zone,
    this.zoneStatus,
    this.title = 'Heart rate',
    this.onTap,
  });

  final int bpm;
  final List<double> samples;
  final int maxHeartRate;
  final String? zone;
  final UiStatus? zoneStatus;
  final String title;
  final VoidCallback? onTap;

  static (String, UiStatus) zoneFor(int bpm, int max) {
    final p = max <= 0 ? 0.0 : bpm / max;
    return switch (p) {
      < 0.5 => ('Resting', UiStatus.neutral),
      < 0.6 => ('Warm up', UiStatus.info),
      < 0.7 => ('Fat burn', UiStatus.success),
      < 0.8 => ('Cardio', UiStatus.warning),
      _ => ('Peak', UiStatus.danger),
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final v = bpm < 0 ? 0 : bpm;
    final auto = zoneFor(v, maxHeartRate);
    final status = zoneStatus ?? auto.$2;
    final label = zone ?? auto.$1;
    final tone = context.tone(status);
    final line = status == UiStatus.neutral ? cs.primary : tone.color;
    final data = [for (final s in samples) if (s.isFinite) s];

    return UiCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: cs.error, size: 20),
              const UiGap.sm(),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: UiSpace.xs),
                decoration: BoxDecoration(color: tone.container, borderRadius: context.tokens.full),
                child: Text(
                  label,
                  style: context.text.labelSmall?.copyWith(color: tone.onContainer, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const UiGap.md(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '$v', style: context.text.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                    TextSpan(
                      text: ' bpm',
                      style: context.text.labelLarge?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const UiGap.lg(),
              Expanded(
                child: Semantics(
                  label: data.length < 2
                      ? 'No heart rate history'
                      : 'Heart rate history, ${data.reduce(math.min).round()} to ${data.reduce(math.max).round()} bpm',
                  excludeSemantics: true,
                  child: data.length < 2 ? const SizedBox(height: 48) : UiSparkline(data, color: line, height: 48, strokeWidth: 2.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
