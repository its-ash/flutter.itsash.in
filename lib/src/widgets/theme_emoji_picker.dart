import 'package:flutter/material.dart';

/// A minimal grid-based emoji picker. Pass your own [emojis] list (this
/// package doesn't bundle an emoji dataset) — group them by category
/// upstream and pass one [ThemeEmojiPicker] per category/tab if needed.
class ThemeEmojiPicker extends StatelessWidget {
  const ThemeEmojiPicker({
    super.key,
    required this.emojis,
    this.onSelected,
    this.crossAxisCount = 8,
    this.emojiSize = 24,
  });

  final List<String> emojis;
  final ValueChanged<String>? onSelected;
  final int crossAxisCount;
  final double emojiSize;

  static Future<String?> show(BuildContext context, {required List<String> emojis}) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: ThemeEmojiPicker(
          emojis: emojis,
          onSelected: (emoji) => Navigator.pop(context, emoji),
        ),
      ),
    );
  }

  double _buttonRadius(BuildContext context) {
    final shape = Theme.of(context).filledButtonTheme.style?.shape?.resolve({});
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: emojis.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
      itemBuilder: (context, index) {
        final emoji = emojis[index];
        return InkWell(
          borderRadius: BorderRadius.circular(_buttonRadius(context)),
          onTap: () => onSelected?.call(emoji),
          child: Center(child: Text(emoji, style: TextStyle(fontSize: emojiSize))),
        );
      },
    );
  }
}
