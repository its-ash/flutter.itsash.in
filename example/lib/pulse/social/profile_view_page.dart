import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';
import 'chat_page.dart';

/// Public profile of another Pulse member: header, follow, message, and photo grid.
class PulseProfileViewPage extends StatelessWidget {
  const PulseProfileViewPage({super.key, required this.person});

  final Person person;

  /// Stable fake counts so the numbers do not change between visits.
  int get _seed => person.handle.codeUnits.fold(7, (a, b) => (a * 31 + b) % 9973);

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    final posts = [for (final p in store.data.posts) if (p.author == person) p];
    final photos = [for (final p in posts) ...p.images];
    final following = store.isFollowing(person);
    final isMe = person == store.me;
    final followers = 800 + _seed * 3 + (following ? 1 : 0);

    return Scaffold(
      appBar: UiAppBar(title: person.name, subtitle: '@${person.handle}'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: UiSpace.xxl),
        children: [
          UiMaxWidth(
            maxWidth: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UiProfileHeader(
                  name: person.name,
                  handle: person.handle,
                  verified: person.verified,
                  avatarUrl: person.avatar,
                  coverUrl: PulseAssets.content('trip'),
                  bio: person.bio,
                  posts: posts.length,
                  followers: followers,
                  following: 120 + _seed % 300,
                  onAvatarTap: () => UiImageViewer.open(context, [person.avatar]),
                  action: isMe
                      ? null
                      : UiFollowButton(
                          following: following,
                          onChanged: (on) async {
                            await Future<void>.delayed(const Duration(milliseconds: 400));
                            if (!context.mounted) return;
                            PulseScope.read(context).setFollowing(person, on);
                            context.showToast(on ? 'You follow ${person.name}' : 'Unfollowed ${person.name}');
                          },
                        ),
                  onMessage: isMe ? null : () => pulsePush(context, PulseChatPage(person: person)),
                ),
                const UiGap.lg(),
                Padding(
                  padding: UiSpace.page,
                  child: Text('Photos', style: context.text.titleMedium),
                ),
                const UiGap.sm(),
                if (photos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(UiSpace.xl),
                    child: Text(
                      'No photos yet.',
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                  )
                else
                  Padding(
                    padding: UiSpace.page,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: photos.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: UiSpace.xs,
                        crossAxisSpacing: UiSpace.xs,
                      ),
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () => UiImageViewer.open(context, photos, initialIndex: i),
                        child: UiLazyImage(photos[i], radius: context.tokens.sm, semanticLabel: 'Photo ${i + 1}'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
