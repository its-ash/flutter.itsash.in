import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// One step of [UiSteps]. Plain strings work too.
///
/// ```dart
/// const UiStep('Payment', description: 'Card or UPI');
/// ```
@immutable
class UiStep {
  const UiStep(this.title, {this.description, this.icon});

  final String title;
  final String? description;

  /// Shown in the circle instead of the step number (until done).
  final IconData? icon;
}

enum _StepState { done, active, todo }

/// Step indicator for multi-step flows: numbered circles, a check on done
/// steps, and connecting lines that fill as you progress.
///
/// Each entry of [steps] is a `String` or a [UiStep]. Steps before [current]
/// are done. Use `direction: Axis.vertical` to show descriptions in a list.
///
/// ```dart
/// UiSteps(steps: const ['Cart', 'Address', 'Pay'], current: 1);
/// ```
class UiSteps extends StatelessWidget {
  const UiSteps({super.key, required this.steps, required this.current, this.direction = Axis.horizontal, this.onTap});

  /// `String` or [UiStep] entries.
  final List<Object> steps;

  /// Index of the active step. Use `steps.length` to mark all done.
  final int current;
  final Axis direction;

  /// Called with the tapped step index. Null makes steps not tappable.
  final ValueChanged<int>? onTap;

  _StepState _state(int i) => i < current
      ? _StepState.done
      : i == current
      ? _StepState.active
      : _StepState.todo;

  @override
  Widget build(BuildContext context) {
    final list = [for (final s in steps) s is UiStep ? s : UiStep(s.toString())];
    return direction == Axis.horizontal ? _horizontal(context, list) : _vertical(context, list);
  }

  Widget _tappable(BuildContext context, int i, int n, UiStep step, Widget child) {
    final state = _state(i);
    final status = switch (state) {
      _StepState.done => 'completed',
      _StepState.active => 'current',
      _StepState.todo => 'not started',
    };
    final onTap = this.onTap;
    return Semantics(
      container: true,
      button: onTap != null,
      selected: state == _StepState.active,
      label: 'Step ${i + 1} of $n, ${step.title}, $status',
      excludeSemantics: true,
      onTap: onTap == null ? null : () => onTap(i),
      child: onTap == null
          ? child
          : InkWell(onTap: () => onTap(i), borderRadius: UiRadius.all(UiRadius.sm), child: child),
    );
  }

  Widget _horizontal(BuildContext context, List<UiStep> list) {
    final c = context.colors;
    final t = context.text;
    final n = list.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < n; i++)
          Expanded(
            child: _tappable(
              context,
              i,
              n,
              list[i],
              Padding(
                padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
                child: Column(
                  children: [
                    SizedBox(
                      height: _StepDot.size,
                      child: Row(
                        children: [
                          Expanded(child: i == 0 ? const SizedBox.shrink() : _Line(active: i <= current)),
                          _StepDot(state: _state(i), number: i + 1, icon: list[i].icon),
                          Expanded(child: i == n - 1 ? const SizedBox.shrink() : _Line(active: i < current)),
                        ],
                      ),
                    ),
                    const SizedBox(height: UiSpace.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
                      child: Text(
                        list[i].title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.labelMedium!.copyWith(color: _state(i) == _StepState.todo ? c.textMuted : c.text),
                      ),
                    ),
                    if (list[i].description != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(UiSpace.xs, UiSpace.xxs, UiSpace.xs, 0),
                        child: Text(
                          list[i].description!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall!.copyWith(color: c.textSubtle),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _vertical(BuildContext context, List<UiStep> list) {
    final c = context.colors;
    final t = context.text;
    final n = list.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < n; i++)
          _tappable(
            context,
            i,
            n,
            list[i],
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      _StepDot(state: _state(i), number: i + 1, icon: list[i].icon),
                      if (i < n - 1)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
                            child: _Line(active: i < current, vertical: true),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: UiSpace.md),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: UiSpace.xs, bottom: i < n - 1 ? UiSpace.xl : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            list[i].title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.titleSmall!.copyWith(color: _state(i) == _StepState.todo ? c.textMuted : c.text),
                          ),
                          if (list[i].description != null) ...[
                            const SizedBox(height: UiSpace.xxs),
                            Text(list[i].description!, style: t.bodySmall),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.state, required this.number, this.icon});

  static const double size = 28;

  final _StepState state;
  final int number;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color fill, Color border, Color fg) = switch (state) {
      _StepState.done => (c.accent, c.accent, c.onAccent),
      _StepState.active => (c.accentSoft, c.accent, c.onAccentSoft),
      _StepState.todo => (c.surface, c.borderStrong, c.textSubtle),
    };
    final Widget child;
    if (state == _StepState.done) {
      child = Icon(Icons.check_rounded, size: 16, color: fg);
    } else if (icon != null) {
      child = Icon(icon, size: 16, color: fg);
    } else {
      child = Text(
        '$number',
        style: context.text.labelMedium!.copyWith(color: fg, fontWeight: FontWeight.w700, letterSpacing: 0),
      );
    }
    return AnimatedContainer(
      duration: context.motion(UiMotion.normal),
      curve: UiMotion.standard,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: state == _StepState.active ? 1.5 : 1),
      ),
      child: MediaQuery.withNoTextScaling(child: child),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.active, this.vertical = false});

  final bool active;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: AnimatedContainer(
        duration: context.motion(UiMotion.normal),
        curve: UiMotion.standard,
        width: vertical ? 2 : double.infinity,
        height: vertical ? double.infinity : 2,
        margin: vertical ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: UiSpace.xs),
        decoration: BoxDecoration(color: active ? c.accent : c.border, borderRadius: UiRadius.all(UiRadius.full)),
      ),
    );
  }
}
