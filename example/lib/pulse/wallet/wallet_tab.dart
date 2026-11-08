import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';
import 'transfer_page.dart';

/// Wallet tab: balance, cards, budgets, bills, and a paged transaction history.
class PulseWalletTab extends StatefulWidget {
  const PulseWalletTab({super.key});

  @override
  State<PulseWalletTab> createState() => _PulseWalletTabState();
}

class _PulseWalletTabState extends State<PulseWalletTab> {
  late final PulseData _data = PulseScope.read(context).data;
  late final _txns = UiPagingController<Txn>(
    pageSize: 20,
    fetch: (page, size) => _data.fetchTransactions(page, size),
  );
  final _scroll = ScrollController();
  bool _masked = false;
  final Set<String> _paidBills = {};

  @override
  void dispose() {
    _txns.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _soon(String what) => context.showToast('$what is coming soon', status: UiStatus.info);

  void _send([Person? to]) => pulsePush(context, PulseTransferPage(to: to));

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    return UiScrollToTop(
      controller: _scroll,
      child: UiInfiniteList<Txn>(
        controller: _txns,
        scrollController: _scroll,
        padding: const EdgeInsets.only(bottom: UiSpace.xxl),
        header: _header(store),
        endBuilder: (_) => Padding(
          padding: const EdgeInsets.all(UiSpace.lg),
          child: Center(child: Text('No older transactions', style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant))),
        ),
        itemBuilder: (context, t, i) {
          final items = _txns.items;
          final newDay = i == 0 || !UiFormat.sameDay(items[i - 1].date, t.date);
          final tile = Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
            child: UiTransactionTile(
              title: t.title,
              subtitle: t.category,
              amount: t.amount,
              date: t.date,
              icon: t.icon,
              color: t.amount > 0 ? context.palette.success : null,
              status: t.pending ? UiTransactionStatus.pending : UiTransactionStatus.completed,
              onTap: () => _showTxn(t),
            ),
          );
          if (!newDay) return tile;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.lg, UiSpace.lg, UiSpace.xs),
                child: Text(
                  UiFormat.relativeDay(t.date),
                  style: context.text.labelLarge?.copyWith(color: context.colors.onSurfaceVariant, fontWeight: FontWeight.w700),
                ),
              ),
              tile,
            ],
          );
        },
      ),
    );
  }

  Widget _header(PulseStore store) {
    final now = DateTime.now();
    final bills = [
      ('Power & Light', 84.20, now.add(const Duration(days: 2)), Icons.bolt_rounded),
      ('Home internet', 39.99, now.add(const Duration(days: 5)), Icons.wifi_rounded),
      ('Streamly', 15.99, now.add(const Duration(days: 9)), Icons.live_tv_rounded),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.lg, UiSpace.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UiBalanceCard(
            balance: store.balance,
            change: 3.2,
            changeLabel: 'vs last month',
            accountNumber: '4021558890',
            masked: _masked,
            onMaskChanged: (v) => setState(() => _masked = v),
          ),
          const UiGap.lg(),
          UiQuickActions(
            actions: [
              UiQuickAction(icon: Icons.send_rounded, label: 'Send', onTap: _send),
              UiQuickAction(icon: Icons.call_received_rounded, label: 'Request', onTap: () => _soon('Request money')),
              UiQuickAction(icon: Icons.add_rounded, label: 'Top up', onTap: () => _soon('Top up')),
              UiQuickAction(icon: Icons.receipt_long_rounded, label: 'Pay bills', onTap: () => _soon('Bill pay'), badge: '${bills.length - _paidBills.length}'),
            ],
          ),
          const UiGap.xl(),
          UiSection(
            title: 'Your card',
            child: Center(
              child: UiPaymentCardView(
                number: '4242424242428841',
                holder: store.me.name,
                expiry: '09/29',
                brand: 'VISA',
                width: 340,
                onTap: () => _soon('Card settings'),
              ),
            ),
          ),
          const UiSection(
            title: 'Spending this month',
            child: UiSpendingBreakdown(
              centerLabel: 'This month',
              items: [
                UiSpendItem('Groceries', 412.40, icon: Icons.local_grocery_store_rounded),
                UiSpendItem('Bills', 238.10, icon: Icons.bolt_rounded),
                UiSpendItem('Shopping', 196.75, icon: Icons.shopping_bag_rounded),
                UiSpendItem('Food & drink', 88.30, icon: Icons.local_cafe_rounded),
                UiSpendItem('Transport', 64.50, icon: Icons.directions_subway_rounded),
              ],
            ),
          ),
          const UiSection(
            title: 'Budgets',
            child: Column(
              children: [
                UiBudgetBar(category: 'Groceries', spent: 412.40, limit: 500, icon: Icons.local_grocery_store_rounded),
                UiGap.sm(),
                UiBudgetBar(category: 'Shopping', spent: 196.75, limit: 150, icon: Icons.shopping_bag_rounded),
                UiGap.sm(),
                UiBudgetBar(category: 'Food & drink', spent: 88.30, limit: 200, icon: Icons.local_cafe_rounded),
              ],
            ),
          ),
          UiSection(
            title: 'Upcoming bills',
            child: Column(
              children: [
                for (final (i, b) in bills.indexed) ...[
                  if (i > 0) const UiGap.sm(),
                  UiBillTile(
                    title: b.$1,
                    amount: b.$2,
                    due: b.$3,
                    icon: b.$4,
                    paid: _paidBills.contains(b.$1),
                    onPay: () => _payBill(b.$1, b.$2),
                  ),
                ],
              ],
            ),
          ),
          UiSection(
            title: 'Send again',
            child: UiContactAvatarRow(
              padding: EdgeInsets.zero,
              contacts: [
                for (final p in store.data.people)
                  if (p != store.me) UiContactItem(name: p.name, imageUrl: p.avatar, id: p.id),
              ],
              onTap: (c) => _send(store.data.person(c.id!)),
              onAdd: _send,
            ),
          ),
          Text('Transactions', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Future<void> _payBill(String title, double amount) async {
    final store = PulseScope.read(context);
    if (amount > store.balance) {
      context.showToast('Not enough money to pay $title', status: UiStatus.danger);
      return;
    }
    final ok = await UiDialog.confirm(context, title: 'Pay $title?', message: 'We will take ${money(amount)} from your balance.', confirmLabel: 'Pay now');
    if (!ok || !mounted) return;
    await UiLoader.overlay(context, Future<void>.delayed(const Duration(milliseconds: 800)), message: 'Paying...');
    if (!mounted) return;
    store.pay(amount);
    setState(() => _paidBills.add(title));
    context.showToast('$title paid', status: UiStatus.success);
  }

  void _showTxn(Txn t) {
    final out = t.amount < 0;
    UiSheet.show<void>(
      context,
      title: t.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: UiAmount(t.amount, style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w800))),
          const UiGap.lg(),
          UiKeyValueList(
            divided: true,
            [
              UiKeyValue('Type', out ? 'Money out' : 'Money in', icon: out ? Icons.north_east_rounded : Icons.south_west_rounded),
              UiKeyValue('Category', t.category, icon: t.icon),
              UiKeyValue('Date', UiFormat.dateTime(t.date), icon: Icons.event_rounded),
              UiKeyValue(
                'Status',
                t.pending ? 'Pending' : 'Completed',
                icon: Icons.info_outline_rounded,
                valueColor: t.pending ? context.tone(UiStatus.warning).color : context.palette.success,
              ),
              UiKeyValue('Reference', t.id.toUpperCase().padLeft(8, '0'), icon: Icons.tag_rounded),
            ],
            total: ('Amount', money(t.amount, sign: true)),
          ),
          const UiGap.xl(),
          Builder(
            builder: (sheet) => UiButton.outline(
              'Report a problem',
              icon: Icons.flag_outlined,
              expand: true,
              onPressed: () {
                Navigator.pop(sheet);
                context.showToast('Thanks, our team will look into it', status: UiStatus.info);
              },
            ),
          ),
        ],
      ),
    );
  }
}
