import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';

enum _Kind { like, follow, mention, comment, order }

class _Note {
  _Note({required this.id, required this.kind, required this.actor, required this.avatar, required this.action, required this.time, this.thumbnail, this.unread = true});

  final String id;
  final _Kind kind;
  final String actor;
  final String? avatar;
  final String action;
  final DateTime time;
  final String? thumbnail;
  bool unread;
}

/// Pushed page with the user's notifications, split into tabs.
class PulseNotificationsPage extends StatefulWidget {
  const PulseNotificationsPage({super.key});

  @override
  State<PulseNotificationsPage> createState() => _PulseNotificationsPageState();
}

class _PulseNotificationsPageState extends State<PulseNotificationsPage> {
  List<_Note>? _notes;
  String _filter = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notes ??= _build(PulseScope.read(context).data);
  }

  List<_Note> _build(PulseData data) {
    final now = DateTime.now();
    final people = data.people.where((p) => p.id != 'u1').toList();
    Person who(int i) => people[i % people.length];
    final products = data.products;
    String? product(int i) => products.isEmpty ? null : products[i % products.length].image;
    DateTime ago({int minutes = 0, int hours = 0, int days = 0}) => now.subtract(Duration(minutes: minutes, hours: hours, days: days));

    return [
      _Note(id: 'n1', kind: _Kind.like, actor: who(0).name, avatar: who(0).avatar, action: 'liked your run photo', time: ago(minutes: 4), thumbnail: PulseAssets.content('run')),
      _Note(id: 'n2', kind: _Kind.mention, actor: who(1).name, avatar: who(1).avatar, action: 'mentioned you: "Join us for yoga on Sunday?"', time: ago(minutes: 26)),
      _Note(id: 'n3', kind: _Kind.order, actor: 'Pulse Shop', avatar: null, action: 'Your order #4821 has shipped', time: ago(hours: 2), thumbnail: product(2)),
      _Note(id: 'n4', kind: _Kind.follow, actor: who(2).name, avatar: who(2).avatar, action: 'started following you', time: ago(hours: 5), unread: false),
      _Note(id: 'n5', kind: _Kind.comment, actor: who(3).name, avatar: who(3).avatar, action: 'commented: "Great pace, keep going!"', time: ago(days: 1, hours: 1), thumbnail: PulseAssets.content('post1'), unread: false),
      _Note(id: 'n6', kind: _Kind.mention, actor: who(4).name, avatar: who(4).avatar, action: 'mentioned you in a post about the city trip', time: ago(days: 1, hours: 4), thumbnail: PulseAssets.content('trip'), unread: false),
      _Note(id: 'n7', kind: _Kind.order, actor: 'Pulse Shop', avatar: null, action: 'Your order #4790 was delivered', time: ago(days: 3), thumbnail: product(5), unread: false),
      _Note(id: 'n8', kind: _Kind.like, actor: who(1).name, avatar: who(1).avatar, action: 'liked your workout summary', time: ago(days: 3, hours: 6), thumbnail: PulseAssets.content('lift'), unread: false),
    ];
  }

  List<_Note> get _all => _notes ?? const [];
  int get _unread => _all.where((n) => n.unread).length;

  void _markRead(_Note n) {
    if (!n.unread) return;
    setState(() => n.unread = false);
    context.showToast('Marked as read', status: UiStatus.success);
  }

  void _markAllRead() {
    if (_unread == 0) {
      context.showToast('You are all caught up');
      return;
    }
    setState(() {
      for (final n in _all) {
        n.unread = false;
      }
    });
    context.showToast('All notifications marked as read', status: UiStatus.success);
  }

  void _remove(_Note n) {
    setState(() => _all.remove(n));
    context.showToast('Notification removed');
  }

  (IconData, Color) _badge(BuildContext context, _Kind k) => switch (k) {
        _Kind.like => (Icons.favorite_rounded, context.palette.sale),
        _Kind.follow => (Icons.person_add_rounded, context.colors.primary),
        _Kind.mention => (Icons.alternate_email_rounded, context.tone(UiStatus.info).color),
        _Kind.comment => (Icons.chat_bubble_rounded, context.colors.secondary),
        _Kind.order => (Icons.local_shipping_rounded, context.tone(UiStatus.success).color),
      };

  @override
  Widget build(BuildContext context) {
    final unread = _unread;
    return Scaffold(
      appBar: UiAppBar(
        title: 'Notifications',
        subtitle: unread == 0 ? 'All caught up' : '$unread unread',
        actions: [
          UiIconButton(Icons.done_all_rounded, tooltip: 'Mark all as read', variant: UiIconButtonVariant.plain, onPressed: _markAllRead),
          const UiGap.sm(),
        ],
      ),
      body: UiMaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.sm, UiSpace.lg, UiSpace.md),
              child: UiSegmented<String>(
                options: const ['All', 'Unread'],
                value: _filter,
                size: UiSize.sm,
                onChanged: (v) => setState(() => _filter = v),
              ),
            ),
            Expanded(
              child: UiTabView(
                tabs: const ['All', 'Mentions', 'Orders'],
                icons: const [Icons.notifications_rounded, Icons.alternate_email_rounded, Icons.receipt_long_rounded],
                children: [
                  _list(context, null),
                  _list(context, _Kind.mention),
                  _list(context, _Kind.order),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, _Kind? kind) {
    final items = [
      for (final n in _all)
        if ((kind == null || n.kind == kind) && (_filter == 'All' || n.unread)) n,
    ]..sort((a, b) => b.time.compareTo(a.time));

    if (items.isEmpty) {
      final unreadOnly = _filter == 'Unread';
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UiSpace.xl),
          child: UiEmptyState(
            icon: unreadOnly ? Icons.mark_email_read_rounded : Icons.notifications_off_outlined,
            title: unreadOnly ? 'No unread notifications' : 'Nothing here yet',
            message: unreadOnly ? 'You have read everything. Nice work!' : 'New activity will show up here.',
            actionLabel: unreadOnly ? 'Show all' : null,
            onAction: unreadOnly ? () => setState(() => _filter = 'All') : null,
          ),
        ),
      );
    }

    final children = <Widget>[];
    DateTime? lastDay;
    for (final n in items) {
      if (!UiFormat.sameDay(lastDay, n.time)) {
        lastDay = n.time;
        children.add(UiChatDateDivider(n.time));
      }
      children.add(_tile(context, n));
    }

    return ListView(padding: const EdgeInsets.only(bottom: UiSpace.xxl), children: children);
  }

  Widget _tile(BuildContext context, _Note n) {
    final (icon, color) = _badge(context, n.kind);
    final danger = context.tone(UiStatus.danger);
    final ok = context.tone(UiStatus.success);
    return Dismissible(
      key: ValueKey(n.id),
      background: _swipeBg(context, Icons.mark_email_read_rounded, 'Mark read', ok.container, ok.onContainer, Alignment.centerLeft),
      secondaryBackground: _swipeBg(context, Icons.delete_outline_rounded, 'Remove', danger.container, danger.onContainer, Alignment.centerRight),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          _markRead(n);
          return false;
        }
        return true;
      },
      onDismissed: (_) => _remove(n),
      child: UiNotificationTile(
        actor: n.actor,
        action: n.action,
        avatarUrl: n.avatar,
        time: n.time,
        unread: n.unread,
        icon: icon,
        iconColor: color,
        thumbnailUrl: n.thumbnail,
        trailing: n.kind == _Kind.follow ? _followButton(context, n) : null,
        onTap: () => _markRead(n),
      ),
    );
  }

  Widget? _followButton(BuildContext context, _Note n) {
    final store = PulseScope.of(context);
    final matches = store.data.people.where((p) => p.name == n.actor);
    if (matches.isEmpty) return null;
    final person = matches.first;
    final following = store.isFollowing(person);
    return UiButton(
      following ? 'Following' : 'Follow back',
      size: UiSize.sm,
      variant: following ? UiButtonVariant.outline : UiButtonVariant.primary,
      onPressed: () {
        PulseScope.read(context).setFollowing(person, !following);
        context.showToast(following ? 'Unfollowed ${person.name}' : 'You now follow ${person.name}', status: following ? UiStatus.neutral : UiStatus.success);
      },
    );
  }

  Widget _swipeBg(BuildContext context, IconData icon, String label, Color bg, Color fg, Alignment align) => Container(
        color: bg,
        alignment: align,
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.xl),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg),
            const UiGap.sm(),
            Text(label, style: context.text.labelLarge?.copyWith(color: fg)),
          ],
        ),
      );
}
