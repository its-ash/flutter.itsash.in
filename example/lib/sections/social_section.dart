import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

class SocialSection extends StatefulWidget {
  const SocialSection({super.key});

  @override
  State<SocialSection> createState() => _SocialSectionState();
}

class _SocialSectionState extends State<SocialSection> {
  bool _liked = false;
  int _likes = 12;
  String? _reaction = '❤️';
  final _sent = <String>[];

  static const _post =
      'Sunrise hike up the ridge this morning. The trail was empty, the air was cold, and the view at the top '
      'was worth every step. Already planning the next one. Who wants to join next weekend? Bring warm layers '
      'and lots of water.';

  Future<void> _follow(bool v) => Future<void>.delayed(const Duration(milliseconds: 600));

  @override
  Widget build(BuildContext context) {
    void tap() => toast(context, 'Tapped');
    return SectionPage(
      children: [
        DemoBlock(
          'UiChatBubble, UiChatDateDivider, UiTypingIndicator',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiChatDateDivider(ago(days: 1)),
              UiChatBubble(text: 'Hey! Are we still on for tonight?', isMe: false, time: ago(days: 1, hours: 1), isFirstInGroup: true),
              UiChatBubble(text: 'I can bring snacks 🍿', isMe: false, time: ago(days: 1, hours: 1), isLastInGroup: true),
              UiChatBubble(
                text: 'Yes! See you at 6',
                isMe: true,
                time: ago(days: 1),
                status: UiMessageStatus.read,
                isFirstInGroup: true,
                isLastInGroup: true,
                reply: (author: 'Ana', text: 'Are we still on for tonight?'),
              ),
              UiChatDateDivider(now, label: 'Today'),
              UiChatBubble(
                isMe: false,
                time: ago(minutes: 20),
                imageUrl: pic('chatimg', 800, 600),
                text: 'Look at this view',
                onImageTap: tap,
                isFirstInGroup: true,
                isLastInGroup: true,
              ),
              for (final s in UiMessageStatus.values)
                UiChatBubble(text: 'Status: ${s.name}', isMe: true, time: ago(minutes: 5), status: s, isLastInGroup: s == UiMessageStatus.values.last),
              for (final t in _sent) UiChatBubble(text: t, isMe: true, time: now, status: UiMessageStatus.sent, isLastInGroup: true),
              const Align(alignment: Alignment.centerLeft, child: UiTypingIndicator()),
            ],
          ),
        ),
        DemoBlock(
          'UiMessageTicks',
          child: WrapRow(children: [for (final s in UiMessageStatus.values) UiMessageTicks(s)]),
        ),
        DemoBlock(
          'UiMessageComposer',
          child: UiMessageComposer(
            onSend: (t) => setState(() => _sent.add(t)),
            onAttach: tap,
            onEmoji: tap,
            onCamera: tap,
            onMic: tap,
          ),
        ),
        DemoBlock(
          'UiReactionPicker',
          child: Align(
            alignment: Alignment.centerLeft,
            child: UiReactionPicker(selected: _reaction, onSelected: (e) => setState(() => _reaction = e == _reaction ? null : e)),
          ),
        ),
        DemoBlock(
          'UiConversationTile and UiUnreadBadge',
          child: Column(
            children: [
              UiConversationTile(
                name: 'Ana Lopez',
                message: 'Sounds good! See you there.',
                avatarUrl: pic('ana', 200, 200),
                time: ago(minutes: 4),
                unread: 3,
                online: true,
                pinned: true,
                onTap: tap,
              ),
              UiConversationTile(name: 'Sam Lee', message: '', time: ago(minutes: 30), typing: true, avatarUrl: pic('sam', 200, 200)),
              UiConversationTile(
                name: 'Design team',
                message: 'You: I pushed the new mockups to the shared folder',
                time: ago(hours: 5),
                status: UiMessageStatus.delivered,
                muted: true,
                unread: 120,
              ),
              UiConversationTile(name: 'Mia', message: 'Thanks!', time: ago(days: 3), selected: true, onLongPress: tap),
              const UiGap.sm(),
              const WrapRow(children: [UiUnreadBadge(5), UiUnreadBadge(120), UiUnreadBadge(7, muted: true), UiUnreadBadge(0)]),
            ],
          ),
        ),
        DemoBlock(
          'UiPostCard',
          child: Column(
            children: [
              UiPostCard(
                author: 'Ana Lopez',
                handle: 'ana',
                verified: true,
                avatarUrl: pic('ana', 200, 200),
                time: ago(hours: 2),
                text: _post,
                images: [for (var i = 0; i < 5; i++) pic('post$i', 800, 800)],
                likes: 1520,
                comments: 48,
                shares: 12,
                onLikeChanged: (_) {},
                onBookmarkChanged: (_) {},
                onComment: tap,
                onShare: tap,
                onMore: tap,
                onAuthorTap: tap,
                onImageTap: (i) => toast(context, 'Photo $i'),
              ),
              const UiGap.md(),
              UiPostCard(author: 'Sam Lee', time: ago(days: 1), text: 'Text only post. Short and sweet.', likes: 3, liked: true),
            ],
          ),
        ),
        DemoBlock(
          'UiLikeButton and UiVerifiedBadge',
          child: WrapRow(
            children: [
              UiLikeButton(
                liked: _liked,
                count: _likes,
                onChanged: (v) => setState(() {
                  _liked = v;
                  _likes += v ? 1 : -1;
                }),
              ),
              const UiLikeButton(liked: true, onChanged: null),
              const UiVerifiedBadge(size: 16),
              const UiVerifiedBadge(size: 24),
            ],
          ),
        ),
        DemoBlock(
          'UiCommentTile',
          child: Column(
            children: [
              UiCommentTile(
                name: 'Sam',
                text: 'Great shot! Which trail is this?',
                avatarUrl: pic('sam', 200, 200),
                time: ago(minutes: 40),
                likes: 4,
                onLikeChanged: (_) {},
                onReply: tap,
              ),
              UiCommentTile(name: 'Ana Lopez', verified: true, text: 'Ridge loop, north side!', time: ago(minutes: 30), level: 1, liked: true, likes: 2, onLikeChanged: (_) {}, onReply: tap),
              UiCommentTile(name: 'Leo', text: 'Saving this for later', time: ago(minutes: 10), level: 2, onReply: tap),
            ],
          ),
        ),
        DemoBlock(
          'UiProfileHeader and UiFollowButton',
          child: UiProfileHeader(
            name: 'Ana Lopez',
            handle: 'ana',
            verified: true,
            coverUrl: pic('cover', 1200, 400),
            avatarUrl: pic('ana', 300, 300),
            bio: 'Designer. Coffee. Trails. Based in Lisbon.',
            posts: 128,
            followers: 12400,
            following: 310,
            action: UiFollowButton(onChanged: _follow),
            onMessage: tap,
            onFollowersTap: tap,
          ),
        ),
        DemoBlock(
          'UiProfileHeader (no cover)',
          child: UiProfileHeader(name: 'Sam Lee', bio: 'Photographer', posts: 42, followers: null, action: UiButton.outline('Edit profile', size: UiSize.sm, onPressed: tap)),
        ),
        DemoBlock(
          'UiFollowButton',
          child: WrapRow(children: [UiFollowButton(onChanged: _follow), UiFollowButton(following: true, onChanged: _follow), UiFollowButton(size: UiSize.md, onChanged: _follow)]),
        ),
        DemoBlock(
          'UiStoryAvatar',
          child: WrapRow(
            children: [
              UiStoryAvatar(name: 'Ana', imageUrl: pic('ana', 200, 200), onTap: tap),
              UiStoryAvatar(name: 'Sam', imageUrl: pic('sam', 200, 200), seen: true, onTap: tap),
              UiStoryAvatar(name: 'Leo', imageUrl: pic('leo', 200, 200), live: true, onTap: tap),
              UiStoryAvatar(name: 'You', add: true, label: 'Your story', onTap: tap),
            ],
          ),
        ),
        DemoBlock(
          'UiStoryBar',
          child: UiStoryBar(
            padding: EdgeInsets.zero,
            myAvatarUrl: pic('me', 200, 200),
            onAdd: tap,
            onTap: (i) => toast(context, 'Story $i'),
            stories: [
              UiStory(name: 'Ana', imageUrl: pic('ana', 200, 200)),
              UiStory(name: 'Sam', imageUrl: pic('sam', 200, 200), seen: true),
              UiStory(name: 'Leo', imageUrl: pic('leo', 200, 200), live: true),
              const UiStory(name: 'Mia Torres'),
              UiStory(name: 'Kai', imageUrl: pic('kai', 200, 200)),
              UiStory(name: 'Zoe', imageUrl: pic('zoe', 200, 200), seen: true),
            ],
          ),
        ),
        DemoBlock(
          'UiNotificationTile',
          child: Column(
            children: [
              UiNotificationTile(
                actor: 'Ana',
                action: 'liked your post',
                avatarUrl: pic('ana', 200, 200),
                time: ago(minutes: 3),
                unread: true,
                icon: Icons.favorite_rounded,
                iconColor: context.palette.sale,
                thumbnailUrl: pic('post0', 200, 200),
              ),
              UiNotificationTile(
                actor: 'Sam Lee',
                action: 'started following you',
                avatarUrl: pic('sam', 200, 200),
                time: ago(hours: 1),
                icon: Icons.person_add_rounded,
                trailing: UiFollowButton(onChanged: _follow),
              ),
              UiNotificationTile(actor: 'Leo', action: 'commented: "So good!"', time: ago(days: 2), icon: Icons.chat_bubble_rounded),
            ],
          ),
        ),
        DemoBlock(
          'UiUserTile',
          child: Column(
            children: [
              UiUserTile(name: 'Sam Lee', subtitle: '@sam', verified: true, online: true, avatarUrl: pic('sam', 200, 200), trailing: UiFollowButton(onChanged: _follow), onTap: tap),
              UiUserTile(name: 'Mia Torres', subtitle: '@mia · 2 mutual friends', avatarUrl: pic('mia', 200, 200), onTap: tap),
            ],
          ),
        ),
      ],
    );
  }
}
