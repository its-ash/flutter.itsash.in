import 'package:flutter/material.dart';

import 'package:theme/src/components/theme_button.dart';
import 'package:theme/src/components/theme_card.dart';
import 'package:theme/src/typography/app_typography.dart';

class ThemeOnboardingStep {
  const ThemeOnboardingStep({required this.key, required this.title, required this.description});

  final GlobalKey key;
  final String title;
  final String description;
}

class ThemeOnboardingTour {
  ThemeOnboardingTour._();

  static void show(BuildContext context, {required List<ThemeOnboardingStep> steps}) {
    if (steps.isEmpty) return;
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _OnboardingOverlay(steps: steps, onFinished: () => entry.remove()),
    );
    overlay.insert(entry);
  }
}

class _OnboardingOverlay extends StatefulWidget {
  const _OnboardingOverlay({required this.steps, required this.onFinished});

  final List<ThemeOnboardingStep> steps;
  final VoidCallback onFinished;

  @override
  State<_OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<_OnboardingOverlay> {
  int _index = 0;

  Rect? _targetRect() {
    final box = widget.steps[_index].key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return null;
    final origin = box.localToGlobal(Offset.zero);
    return (origin & box.size).inflate(8);
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final target = _targetRect();
    final screen = MediaQuery.sizeOf(context);
    final isLast = _index == widget.steps.length - 1;

    final showBelow = target == null || target.bottom + 160 < screen.height;
    final cardTop = target == null
        ? screen.height / 2 - 80
        : (showBelow ? target.bottom + 12 : target.top - 172);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _SpotlightPainter(
              rect: target,
              barrierColor: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
        Positioned.fill(child: GestureDetector(onTap: () {})),
        Positioned(
          top: cardTop.clamp(16, screen.height - 172),
          left: 24,
          right: 24,
          child: ThemeCard(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(step.title, style: AppTypography.titleMedium),
                  const SizedBox(height: 6),
                  Text(step.description, style: AppTypography.bodyMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ThemeButton(
                        label: 'Skip',
                        variant: ThemeButtonVariant.text,
                        onPressed: widget.onFinished,
                      ),
                      const Spacer(),
                      ThemeButton(
                        label: isLast ? 'Done' : 'Next',
                        onPressed: () {
                          if (isLast) {
                            widget.onFinished();
                          } else {
                            setState(() => _index++);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.rect, required this.barrierColor});

  final Rect? rect;
  final Color barrierColor;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    if (rect == null) {
      canvas.drawPath(full, Paint()..color = barrierColor);
      return;
    }
    final cutout = Path()..addRRect(RRect.fromRectAndRadius(rect!, const Radius.circular(12)));
    final combined = Path.combine(PathOperation.difference, full, cutout);
    canvas.drawPath(combined, Paint()..color = barrierColor);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.rect != rect || oldDelegate.barrierColor != barrierColor;
}
