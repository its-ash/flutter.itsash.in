import 'package:flutter/material.dart';

enum ThemePushNotificationStyle { basic, bigText, bigImage, inbox, media, progress }

class ThemePushNotification extends StatelessWidget {
  const ThemePushNotification({
    super.key,
    required this.title,
    this.body,
    this.style = ThemePushNotificationStyle.basic,
    this.imageProvider,
    this.lines = const [],
    this.progress,
    this.timestamp,
    this.appName = 'App',
    this.appIcon = const Icon(Icons.notifications, size: 14),
    this.onTap,
  });

  final String title;
  final String? body;
  final ThemePushNotificationStyle style;
  final ImageProvider? imageProvider;
  final List<String> lines;
  final double? progress;
  final String? timestamp;
  final String appName;
  final Widget appIcon;
  final VoidCallback? onTap;

  double _cardRadius(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cardRadius = _cardRadius(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [BoxShadow(color: scheme.shadow.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              appIcon,
              const SizedBox(width: 4),
              Text(appName, style: tt.labelSmall),
              const Spacer(),
              if (timestamp != null) Text(timestamp!, style: tt.labelSmall),
            ]),
            const SizedBox(height: 6),
            if (style == ThemePushNotificationStyle.bigImage && imageProvider != null)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: ClipRRect(
                borderRadius: BorderRadius.circular(cardRadius),
                child: Image(image: imageProvider!, width: double.infinity, height: 180, fit: BoxFit.cover),
              )),
            if (style == ThemePushNotificationStyle.media && imageProvider != null)
              Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(cardRadius), child: Image(image: imageProvider!, width: 64, height: 64, fit: BoxFit.cover)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  if (body != null) Text(body!, style: tt.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ])),
              ])
            else ...[
              Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              if (body != null) Text(body!, style: tt.bodySmall, maxLines: style == ThemePushNotificationStyle.bigText ? 6 : 2),
            ],
            if (style == ThemePushNotificationStyle.inbox && lines.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...lines.map((l) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text('• $l', style: tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis))),
            ],
            if (style == ThemePushNotificationStyle.progress && progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress, minHeight: 4, borderRadius: BorderRadius.circular(cardRadius.clamp(0, 2))),
            ],
          ]),
        ),
      ),
    );
  }
}