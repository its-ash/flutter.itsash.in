import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';
import 'chat_page.dart';
import 'profile_view_page.dart';

/// Social tab: a feed of posts and a list of conversations.
/// The shell provides the Scaffold and app bar.
class PulseSocialTab extends StatelessWidget {
  const PulseSocialTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: UiSpace.sm),
      child: UiTabView(
        tabs: ['Feed', 'Messages'],
        icons: [Icons.dynamic_feed_rounded, Icons.chat_bubble_outline_rounded],
        spacing: UiSpace.xs,
        children: [_Feed(), _Messages()],
      ),
    );
  }
}

void _openProfile(BuildContext context, Person p) => pulsePush(context, PulseProfileViewPage(person: p));

// ---------------------------------------------------------------- Feed

class _Feed extends StatelessWidget {
  const _Feed();

  /// The "Who to follow" block goes after this many posts.
  static const _followAfter = 2;

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    final posts = store.data.posts;
    final others = [for (final p in store.data.people) if (p != store.me) p];
    final showFollow = posts.length >= _followAfter;
    final count = 1 + posts.length + (showFollow ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.only(top: UiSpace.sm, bottom: UiSpace.xxl),
      itemCount: count,
      itemBuilder: (context, i) {
        if (i == 0) return _stories(context, store, others);
        var index = i - 1;
        if (showFollow && index == _followAfter) return _WhoToFollow(people: others);
        if (showFollow && index > _followAfter) index -= 1;
        final post = posts[index];
        return UiMaxWidth(
          maxWidth: 720,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.md),
            child: post.video == null ? _imagePost(context, store, post) : _VideoPost(post: post),
          ),
        );
      },
    );
  }

  Widget _stories(BuildContext context, PulseStore store, List<Person> others) => Padding(
        padding: const EdgeInsets.only(bottom: UiSpace.md),
        child: UiStoryBar(
          myAvatarUrl: store.me.avatar,
          onAdd: () => context.showToast('Stories are coming soon'),
          onTap: (i) => _openProfile(context, others[i]),
          stories: [
            for (final (i, p) in others.indexed) UiStory(name: p.name.split(' ').first, imageUrl: p.avatar, seen: i >= 3, live: i == 1),
          ],
        ),
      );

  Widget _imagePost(BuildContext context, PulseStore store, Post post) {
    final liked = store.isLiked(post);
    return UiPostCard(
      author: post.author.name,
      handle: post.author.handle,
      verified: post.author.verified,
      avatarUrl: post.author.avatar,
      time: post.time,
      text: post.text,
      images: post.images,
      likes: post.likes + (liked ? 1 : 0),
      comments: post.comments,
      liked: liked,
      onLikeChanged: (v) => PulseScope.read(context).setLiked(post, v),
      onBookmarkChanged: (v) => context.showToast(v ? 'Saved to bookmarks' : 'Removed from bookmarks'),
      onComment: () => context.showToast('Comments are coming soon'),
      onShare: () => context.showToast('Link copied'),
      onAuthorTap: () => _openProfile(context, post.author),
      onImageTap: (i) => UiImageViewer.open(context, post.images, initialIndex: i),
    );
  }
}

class _VideoPost extends StatelessWidget {
  const _VideoPost({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    final liked = store.isLiked(post);
    final a = post.author;
    final muted = context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant);

    return UiCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => _openProfile(context, a),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(UiSpace.md, UiSpace.md, UiSpace.md, UiSpace.sm),
              child: Row(
                children: [
                  UiAvatar(name: a.name, imageUrl: a.avatar, size: 42),
                  const UiGap.sm(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(a.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            if (a.verified) ...[const UiGap.xs(), const UiVerifiedBadge()],
                          ],
                        ),
                        Text('@${a.handle} · ${UiFormat.relative(post.time)}', style: muted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(UiSpace.md, 0, UiSpace.md, UiSpace.sm),
              child: Text(post.text, style: context.text.bodyMedium),
            ),
          UiVideoPlayer(
            post.video!,
            poster: PulseAssets.heroes[post.id.hashCode % PulseAssets.heroes.length],
            aspectRatio: 16 / 9,
            radius: BorderRadius.zero,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: UiSpace.xs),
            child: Row(
              children: [
                UiLikeButton(
                  liked: liked,
                  count: post.likes + (liked ? 1 : 0),
                  onChanged: (v) => PulseScope.read(context).setLiked(post, v),
                ),
                const UiGap.sm(),
                Icon(Icons.chat_bubble_outline_rounded, size: 20, color: context.colors.onSurfaceVariant),
                const UiGap.xs(),
                Text(UiFormat.compact(post.comments), style: muted),
                const Spacer(),
                UiIconButton(
                  Icons.share_outlined,
                  tooltip: 'Share',
                  variant: UiIconButtonVariant.plain,
                  onPressed: () => context.showToast('Link copied'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhoToFollow extends StatelessWidget {
  const _WhoToFollow({required this.people});

  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    return UiMaxWidth(
      maxWidth: 720,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.md),
        child: UiCard(
          padding: const EdgeInsets.symmetric(vertical: UiSpace.sm),
          child: UiSection(
            title: 'Who to follow',
            subtitle: 'People with similar interests',
            headerPadding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
            spacing: UiSpace.xs,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (final p in people.take(4))
                  UiUserTile(
                    name: p.name,
                    subtitle: '@${p.handle}',
                    verified: p.verified,
                    avatarUrl: p.avatar,
                    onTap: () => _openProfile(context, p),
                    trailing: UiFollowButton(
                      following: store.isFollowing(p),
                      onChanged: (on) async {
                        await Future<void>.delayed(const Duration(milliseconds: 400));
                        if (context.mounted) PulseScope.read(context).setFollowing(p, on);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Messages

class _Messages extends StatefulWidget {
  const _Messages();

  @override
  State<_Messages> createState() => _MessagesState();
}

class _MessagesState extends State<_Messages> {
  static const _last = [
    ('Want to go on Saturday morning?', 2, 3),
    ('That class was so hard, but fun!', 35, 1),
    ('Sent you the playlist', 90, 0),
    ('Thanks for the tip about the shoes', 300, 0),
    ('See you at the gym tomorrow', 1500, 0),
    ('Happy birthday!', 4000, 0),
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    final now = DateTime.now();
    final others = [for (final p in store.data.people) if (p != store.me) p];
    final q = _query.trim().toLowerCase();
    final rows = [
      for (final (i, p) in others.indexed)
        if (q.isEmpty || p.name.toLowerCase().contains(q) || p.handle.toLowerCase().contains(q)) (i, p),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.sm, UiSpace.lg, UiSpace.xs),
          child: UiSearchField(hint: 'Search messages', onChanged: (v) => setState(() => _query = v)),
        ),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    'No conversations match "$_query".',
                    style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: UiSpace.xxl),
                  itemCount: rows.length,
                  itemBuilder: (context, n) {
                    final (i, p) = rows[n];
                    final last = _last[i % _last.length];
                    return UiMaxWidth(
                      maxWidth: 720,
                      child: UiConversationTile(
                        name: p.name,
                        avatarUrl: p.avatar,
                        message: last.$3 == 0 && i.isOdd ? 'You: ${last.$1}' : last.$1,
                        time: now.subtract(Duration(minutes: last.$2)),
                        unread: last.$3,
                        online: i < 2,
                        pinned: i == 0,
                        status: last.$3 == 0 && i.isOdd ? UiMessageStatus.read : null,
                        onTap: () => pulsePush(context, PulseChatPage(person: p)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
