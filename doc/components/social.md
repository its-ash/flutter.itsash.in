# Social

Kits for chat, feeds, profiles, stories, and notifications. All widgets use theme colors. They work in light and dark mode.

### UiSocialFormat
Formats counts and times. It does not use `intl`.

```dart
UiSocialFormat.count(1234);        // 1.2k
UiSocialFormat.relative(postTime); // now, 5m, 3h, 2d, Mar 4
UiSocialFormat.day(msgTime);       // Today, Yesterday, Mar 4, 2025
```
- `count(int)`: `999`, `1.2k`, `3.4M`, `1B`. Negative values show `0`.
- `relative(DateTime, {now})`, `date(DateTime, {now})`, `day(DateTime, {now})`.
- `clock(context, DateTime)`: local time, 12 h or 24 h from the device.
- `stamp(context, DateTime)`: clock time for today, else `day`.

### UiChatBubble
Shows one chat message. Corners change for message groups.

```dart
UiChatBubble(
  text: 'See you at 6',
  isMe: true,
  time: DateTime.now(),
  status: UiMessageStatus.read,
  isLastInGroup: true,
  reply: (author: 'Ana', text: 'When do we meet?'),
)
```
- `text`, `isMe`, `time`, `status` (shown only when `isMe`).
- `isFirstInGroup`, `isLastInGroup`: set the corners and the tail.
- `imageUrl`, `onImageTap`, `reply` (`({String author, String text})`).
- `onTap`, `onLongPress`, `maxWidthFactor` (default `0.78`).

### UiMessageStatus / UiMessageTicks
Enum `sending`, `sent`, `delivered`, `read`, `failed`. `UiMessageTicks(status, {color, readColor, size})` shows the matching tick icon.

### UiChatDateDivider
Shows a date pill between message days.

```dart
UiChatDateDivider(DateTime.now())   // Today
```
- `date`, `label` (replaces the automatic text).

### UiTypingIndicator
Shows three animated dots in a bubble. It stops when the device reduces motion.

```dart
const UiTypingIndicator()
```

### UiMessageComposer
Message input bar. The send button is enabled only when the text is not blank. It clears the text after send. Ctrl+Enter sends.

```dart
UiMessageComposer(
  onSend: (text) => chat.send(text),
  onAttach: pickFile,
  onEmoji: showEmoji,
  onCamera: openCamera,
)
```
- `onSend` (required, gets trimmed text), `controller`, `focusNode`, `hint`.
- `onAttach`, `onEmoji`, `onCamera`, `onMic` (shows a mic when the text is empty).
- `maxLines` (1 to 12), `maxLength` (default 4000), `enabled`, `autofocus`.
- Put it in `Scaffold.bottomNavigationBar` or at the bottom of a `Column`. It uses `SafeArea`.

### UiReactionPicker
Emoji reactions in a pill. Each emoji grows on hover and press.

```dart
UiReactionPicker(onSelected: (e) => react(e), selected: '❤️')
```
- `onSelected`, `reactions` (six defaults), `selected`, `size`.

### UiConversationTile
One row in a chat list.

```dart
UiConversationTile(
  name: 'Ana Lopez',
  message: 'Sounds good!',
  time: lastAt,
  unread: 3,
  online: true,
  pinned: true,
  onTap: open,
)
```
- `name`, `message`, `avatarUrl`, `time`, `unread`, `online`, `muted`, `pinned`.
- `typing` (shows "typing…"), `status` (ticks for your last message), `selected`, `onTap`, `onLongPress`.

### UiUnreadBadge
Pill with an unread count. Shows `99+` above 99. Hidden at 0.

```dart
UiUnreadBadge(5, muted: false)
```

### UiPostCard
Feed post card with author, text, photo grid, and actions.

```dart
UiPostCard(
  author: 'Ana Lopez',
  handle: 'ana',
  verified: true,
  time: postedAt,
  text: longText,
  images: [url1, url2, url3],
  likes: 1520,
  comments: 48,
  onLikeChanged: (v) => api.like(id, v),
  onBookmarkChanged: (v) => api.save(id, v),
  onComment: openComments,
  onShare: share,
  onMore: showMenu,
)
```
- Text longer than `maxLines` (default 4) shows "more".
- `images`: 1 to 4 show in a grid. More than 4 shows "+N" on the last cell. Double-tap a photo to like.
- `likes`, `comments`, `shares`, `liked`, `bookmarked`.
- `onLikeChanged`, `onBookmarkChanged` (shows the bookmark button), `onComment`, `onShare`, `onMore`, `onAuthorTap`, `onImageTap(int)`, `onTap`.

### UiLikeButton
Heart toggle with a bounce and a count.

```dart
UiLikeButton(liked: false, count: 12, onChanged: (v) {})
```
- `liked`, `count` (hidden when `null`), `onChanged` (disabled when `null`), `size`.

### UiVerifiedBadge
Blue check icon after a name.

```dart
const UiVerifiedBadge(size: 16)
```

### UiCommentTile
One comment with a reply action. Use `level` for nested replies.

```dart
UiCommentTile(
  name: 'Sam',
  text: 'Great shot!',
  time: at,
  likes: 4,
  level: 1,
  onLikeChanged: (v) {},
  onReply: reply,
)
```
- `name`, `text`, `avatarUrl`, `time`, `verified`, `likes`, `liked`.
- `level` (0 to 4, 40 px indent each), `onLikeChanged`, `onReply`, `onAuthorTap`, `onLongPress`.

### UiProfileHeader
Profile top area: cover, avatar, name, bio, and stats.

```dart
UiProfileHeader(
  name: 'Ana Lopez',
  handle: 'ana',
  verified: true,
  coverUrl: cover,
  avatarUrl: avatar,
  bio: 'Designer. Coffee. Trails.',
  posts: 128,
  followers: 12400,
  following: 310,
  action: UiFollowButton(onChanged: (v) => api.follow(id, v)),
  onMessage: openChat,
)
```
- Without `coverUrl` it shows the brand gradient.
- `posts`, `followers`, `following`: `null` hides the stat. Counts show as `12.4k`.
- `action` (any widget, for example `UiFollowButton` or `UiButton('Edit profile')`), `onMessage`.
- `onAvatarTap`, `onPostsTap`, `onFollowersTap`, `onFollowingTap`, `coverHeight` (140), `avatarSize` (92).

### UiFollowButton
Follow / Following toggle. It shows a spinner while `onChanged` runs. The state changes only when the future completes.

```dart
UiFollowButton(following: false, onChanged: (v) => api.follow(userId, v))
```
- `following`, `onChanged` (`Future<void> Function(bool)`), `followLabel`, `followingLabel`, `size` (`UiSize.sm`).

### UiStoryAvatar
Avatar with a story ring. Gradient ring when new, grey ring when seen.

```dart
UiStoryAvatar(name: 'Ana', imageUrl: url, seen: false, onTap: open)
```
- `name`, `imageUrl`, `seen`, `live` (red LIVE tag), `add` ("+" badge), `label`, `size` (64), `showLabel`, `onTap`.

### UiStoryBar / UiStory
Horizontal list of stories. "Your story" with "+" comes first when `onAdd` is set.

```dart
UiStoryBar(
  stories: const [UiStory(name: 'Ana', imageUrl: a), UiStory(name: 'Sam', seen: true)],
  myAvatarUrl: me,
  onAdd: createStory,
  onTap: (i) => openStory(i),
)
```
- `UiStory({name, imageUrl, seen, live})`.
- `stories`, `onTap(int)`, `onAdd`, `myName`, `myAvatarUrl`, `addLabel`, `size`, `padding`.

### UiNotificationTile
Activity row: "Ana liked your post".

```dart
UiNotificationTile(
  actor: 'Ana',
  action: 'liked your post',
  time: at,
  unread: true,
  icon: Icons.favorite_rounded,
  iconColor: context.palette.sale,
  thumbnailUrl: postThumb,
)
```
- `actor`, `action`, `avatarUrl`, `time`, `unread` (dot and tint).
- `icon`, `iconColor`: small badge on the avatar.
- `thumbnailUrl` or `trailing` (for example `UiFollowButton`). `trailing` wins.

### UiUserTile
Row for search results and member lists.

```dart
UiUserTile(name: 'Sam Lee', subtitle: '@sam', verified: true, trailing: UiFollowButton(onChanged: follow))
```
- `name`, `subtitle`, `avatarUrl`, `verified`, `online`, `trailing`, `avatarSize` (44), `onTap`.
