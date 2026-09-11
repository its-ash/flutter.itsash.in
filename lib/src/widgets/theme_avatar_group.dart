import 'package:flutter/material.dart';

import 'package:theme/src/typography/app_typography.dart';
import 'package:theme/src/shadows/app_shadow_theme.dart';
import 'package:theme/src/widgets/profile_avatar.dart';

class ThemeAvatarData {
  const ThemeAvatarData({this.imageUrl, this.initials, this.backgroundColor});

  final String? imageUrl;
  final String? initials;
  final Color? backgroundColor;
}

class ThemeAvatarGroup extends StatelessWidget {
  const ThemeAvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 4,
    this.radius = 18,
  });

  final List<ThemeAvatarData> avatars;
  final int maxVisible;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shadows = Theme.of(context).extension<AppShadowTheme>() ?? const AppShadowTheme();
    final visible = avatars.take(maxVisible).toList();
    final overflow = avatars.length - visible.length;
    final step = radius * 1.2;
    final itemCount = visible.length + (overflow > 0 ? 1 : 0);

    return SizedBox(
      width: step * (itemCount - 1) + radius * 2,
      height: radius * 2,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: step * i,
              child: _RingedAvatar(
                radius: radius,
                ringColor: scheme.surface,
                child: ProfileAvatar(
                  radius: radius,
                  imageUrl: visible[i].imageUrl,
                  initials: visible[i].initials,
                  backgroundColor: visible[i].backgroundColor,
                ),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: step * visible.length,
              child: _RingedAvatar(
                radius: radius,
                ringColor: scheme.surface,
                child: Container(
                  decoration: shadows.borderWidth > 0
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: shadows.borderColor ?? scheme.outline,
                            width: shadows.borderWidth * 0.5,
                          ),
                        )
                      : null,
                  child: CircleAvatar(
                    radius: radius,
                    backgroundColor: scheme.surfaceContainerHighest,
                    child: Text(
                      '+$overflow',
                      style: AppTypography.labelLarge.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RingedAvatar extends StatelessWidget {
  const _RingedAvatar({required this.radius, required this.ringColor, required this.child});

  final double radius;
  final Color ringColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(shape: BoxShape.circle, color: ringColor),
      child: child,
    );
  }
}
