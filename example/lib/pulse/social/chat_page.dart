import 'dart:async';

import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';
import 'profile_view_page.dart';

class _Msg {
  _Msg(this.text, {required this.isMe, required this.time, this.status, this.image});

  final String text;
  final bool isMe;
  final DateTime time;
  final String? image;
  UiMessageStatus? status;
  String? reaction;
}

/// One-to-one chat with a Pulse member. Sending a message shows a typing
/// indicator, then an automatic reply.
class PulseChatPage extends StatefulWidget {
  const PulseChatPage({super.key, required this.person});

  final Person person;

  @override
  State<PulseChatPage> createState() => _PulseChatPageState();
}

class _PulseChatPageState extends State<PulseChatPage> {
  static const _replies = [
    'Sounds great!',
    'Ha, love that.',
    'Sure, what time works for you?',
    'Let me check and get back to you.',
    'Yes! Count me in.',
    'Nice, see you then.',
  ];

  late final List<_Msg> _messages = _seed();
  final _timers = <Timer>[];
  bool _typing = false;
  int _replyIndex = 0;

  String get _first => widget.person.name.split(' ').first;

  List<_Msg> _seed() {
    final now = DateTime.now();
    final y = now.subtract(const Duration(days: 1));
    DateTime at(DateTime d, int h, int m) => DateTime(d.year, d.month, d.day, h, m);
    const read = UiMessageStatus.read;
    return [
      _Msg('Hey! Did you see the new trail map?', isMe: false, time: at(y, 18, 2)),
      _Msg('Not yet. Is it the one along the river?', isMe: true, time: at(y, 18, 5), status: read),
      _Msg('Yes, about 8 km. Mostly flat.', isMe: false, time: at(y, 18, 7)),
      _Msg('Perfect for a weekend run', isMe: false, time: at(y, 18, 7)),
      _Msg('Here is the view from the end point', isMe: false, time: now.subtract(const Duration(minutes: 42)), image: PulseAssets.content('trip')),
      _Msg('Wow, that looks amazing', isMe: true, time: now.subtract(const Duration(minutes: 40)), status: read),
      _Msg('Want to go on Saturday morning?', isMe: true, time: now.subtract(const Duration(minutes: 39)), status: read),
    ];
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  void _after(Duration d, VoidCallback fn) => _timers.add(Timer(d, () {
        if (mounted) setState(fn);
      }));

  void _send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    final msg = _Msg(t, isMe: true, time: DateTime.now(), status: UiMessageStatus.sending);
    setState(() => _messages.add(msg));
    _after(const Duration(milliseconds: 400), () {
      msg.status = UiMessageStatus.delivered;
      _typing = true;
    });
    _after(const Duration(milliseconds: 1900), () {
      _typing = false;
      for (final m in _messages) {
        if (m.isMe) m.status = UiMessageStatus.read;
      }
      _messages.add(_Msg(_replies[_replyIndex++ % _replies.length], isMe: false, time: DateTime.now()));
    });
  }

  Future<void> _react(_Msg m) async {
    final picked = await UiSheet.show<String>(
      context,
      title: 'React',
      scrollable: false,
      child: Center(
        child: UiReactionPicker(
          selected: m.reaction,
          onSelected: (e) => Navigator.of(context).pop(e),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => m.reaction = picked == m.reaction ? null : picked);
  }

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Builds rows oldest-first (dividers + bubbles), then the list shows them reversed.
  List<Widget> _rows(BuildContext context) {
    final rows = <Widget>[];
    final now = DateTime.now();
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      final prev = i > 0 ? _messages[i - 1] : null;
      final next = i < _messages.length - 1 ? _messages[i + 1] : null;
      final newDay = prev == null || !_sameDay(prev.time, m.time);
      if (newDay) {
        rows.add(UiChatDateDivider(m.time, label: _sameDay(m.time, now) ? 'Today' : null));
      }
      final first = newDay || prev.isMe != m.isMe;
      final last = next == null || next.isMe != m.isMe || !_sameDay(next.time, m.time);
      rows.add(_bubble(context, m, first, last));
    }
    if (_typing) {
      rows.add(const Padding(
        padding: EdgeInsets.only(top: UiSpace.xs),
        child: Align(alignment: Alignment.centerLeft, child: UiTypingIndicator()),
      ));
    }
    return rows;
  }

  Widget _bubble(BuildContext context, _Msg m, bool first, bool last) {
    final bubble = UiChatBubble(
      text: m.text,
      isMe: m.isMe,
      time: m.time,
      status: m.isMe ? m.status : null,
      imageUrl: m.image,
      isFirstInGroup: first,
      isLastInGroup: last,
      onLongPress: () => _react(m),
      onImageTap: m.image == null ? null : () => UiImageViewer.open(context, [m.image!]),
    );
    if (m.reaction == null) return bubble;
    return Column(
      crossAxisAlignment: m.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        bubble,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
          child: GestureDetector(
            onTap: () => setState(() => m.reaction = null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: UiSpace.xxs),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHigh,
                borderRadius: context.tokens.full,
              ),
              child: Text(m.reaction!, style: context.text.bodyMedium),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.person;
    final rows = _rows(context).reversed.toList();
    return Scaffold(
      appBar: UiAppBar(
        title: p.name,
        subtitle: _typing ? 'typing...' : 'online',
        actions: [
          UiIconButton(
            Icons.call_outlined,
            tooltip: 'Call',
            variant: UiIconButtonVariant.plain,
            onPressed: () => context.showToast('Calling $_first...'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: UiSpace.md, left: UiSpace.xs),
            child: UiAvatar(
              name: p.name,
              imageUrl: p.avatar,
              size: 36,
              status: UiStatus.success,
              onTap: () => pulsePush(context, PulseProfileViewPage(person: p)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: UiSpace.md),
                itemCount: rows.length,
                itemBuilder: (_, i) => rows[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(UiSpace.sm),
              child: UiMessageComposer(
                hint: 'Message $_first',
                onSend: _send,
                onAttach: () => context.showToast('Attachments are not part of the demo'),
                onCamera: () => context.showToast('Camera is not part of the demo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
