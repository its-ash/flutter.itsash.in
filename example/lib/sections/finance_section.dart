import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

const spendItems = [
  UiSpendItem('Rent', 1200, icon: Icons.home_rounded),
  UiSpendItem('Food', 420, icon: Icons.restaurant_rounded),
  UiSpendItem('Transport', 160, icon: Icons.directions_bus_rounded),
  UiSpendItem('Shopping', 240, icon: Icons.shopping_bag_rounded),
  UiSpendItem('Fun', 95, icon: Icons.celebration_rounded),
];

const contacts = [
  UiContactItem(name: 'Ana Silva', id: 'ana'),
  UiContactItem(name: 'Bruno Costa', id: 'bruno'),
  UiContactItem(name: 'Carla Dias', id: 'carla'),
  UiContactItem(name: 'Diego Reis', id: 'diego'),
  UiContactItem(name: 'Eva Lima', id: 'eva'),
  UiContactItem(name: 'Filipe Rocha', id: 'filipe'),
];

class FinanceSection extends StatefulWidget {
  const FinanceSection({super.key});

  @override
  State<FinanceSection> createState() => _FinanceSectionState();
}

class _FinanceSectionState extends State<FinanceSection> {
  bool _masked = false;
  int? _contact;
  int _card = 0;
  num _amount = 0;
  bool _paid = false;

  @override
  Widget build(BuildContext context) {
    void tap() => toast(context, 'Tapped');
    final actions = [
      UiQuickAction(icon: Icons.send_rounded, label: 'Send', onTap: tap),
      UiQuickAction(icon: Icons.call_received_rounded, label: 'Request', onTap: tap),
      UiQuickAction(icon: Icons.add_rounded, label: 'Top up', onTap: tap),
      UiQuickAction(icon: Icons.receipt_long_rounded, label: 'Bills', onTap: tap, badge: '2'),
    ];
    return SectionPage(
      children: [
        const DemoBlock(
          'UiAmount',
          child: WrapRow(
            children: [
              UiAmount(-42.5),
              UiAmount(1250.75),
              UiAmount(1250000, compact: true),
              UiAmount(980, masked: true),
              UiAmount(-12, negativeAsDanger: true),
              UiAmount(64.99, signed: false, colored: false, strike: true),
              UiAmount(3480.42, splitDecimals: true, signed: false, colored: false),
              UiAmount(99, symbol: '€'),
            ],
          ),
        ),
        DemoBlock(
          'UiBalanceCard',
          child: UiBalanceCard(
            balance: 12480.32,
            change: 2.4,
            changeLabel: 'vs last month',
            accountNumber: '1234567890',
            masked: _masked,
            onMaskChanged: (v) => setState(() => _masked = v),
            actions: actions.take(3).toList(),
          ),
        ),
        DemoBlock(
          'UiPaymentCardView',
          child: UiHorizontalList(
            padding: EdgeInsets.zero,
            children: [
              for (final (i, s) in UiPaymentCardStyle.values.indexed)
                UiPaymentCardView(
                  number: '424242424242${4240 + i}',
                  holder: 'Jane Doe',
                  expiry: '08/2${8 + i % 2}',
                  brand: i.isEven ? 'VISA' : 'MASTERCARD',
                  style: s,
                  selected: _card == i,
                  masked: i != 1,
                  width: 280,
                  onTap: () => setState(() => _card = i),
                ),
            ],
          ),
        ),
        DemoBlock(
          'UiTransactionTile and UiTransactionGroup',
          child: Column(
            children: [
              UiTransactionGroup(
                date: now,
                trailing: '−\$54.20',
                children: [
                  UiTransactionTile(title: 'Spotify', subtitle: 'Subscription', amount: -9.99, date: now, icon: Icons.music_note_rounded, onTap: tap),
                  UiTransactionTile(title: 'Salary', amount: 4200, date: ago(hours: 3), icon: Icons.work_rounded, color: context.palette.success),
                  UiTransactionTile(
                    title: 'Coffee Lab',
                    amount: -4.2,
                    date: ago(hours: 5),
                    imageUrl: pic('coffee', 200, 200),
                    status: UiTransactionStatus.pending,
                  ),
                ],
              ),
              const UiGap.md(),
              UiTransactionGroup(
                date: ago(days: 1),
                children: [
                  UiTransactionTile(
                    title: 'Uber',
                    amount: -18.5,
                    date: ago(days: 1),
                    icon: Icons.local_taxi_rounded,
                    status: UiTransactionStatus.failed,
                  ),
                  UiTransactionTile(title: 'Refund · Store', amount: 39, date: ago(days: 1), icon: Icons.undo_rounded, status: UiTransactionStatus.completed),
                ],
              ),
              const UiGap.md(),
              UiTransactionGroup(
                title: 'Older',
                card: false,
                children: [UiTransactionTile(title: 'Gym', amount: -45, date: ago(days: 9), icon: Icons.fitness_center_rounded, symbol: '€')],
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiQuickActions',
          child: Column(
            children: [
              UiQuickActions(actions: actions),
              const UiGap.lg(),
              UiQuickActions(
                columns: 4,
                actions: [
                  ...actions,
                  UiQuickAction(icon: Icons.savings_rounded, label: 'Save', onTap: tap),
                  UiQuickAction(icon: Icons.qr_code_scanner_rounded, label: 'Scan', onTap: tap),
                  UiQuickAction(icon: Icons.currency_exchange_rounded, label: 'Exchange', onTap: tap),
                  UiQuickAction(icon: Icons.more_horiz_rounded, label: 'More', onTap: tap),
                ],
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiBudgetBar',
          child: Column(
            children: [
              const UiBudgetBar(category: 'Food', spent: 320, limit: 500, icon: Icons.restaurant_rounded),
              const UiGap.sm(),
              const UiBudgetBar(category: 'Shopping', spent: 430, limit: 500, icon: Icons.shopping_bag_rounded),
              const UiGap.sm(),
              UiBudgetBar(category: 'Travel', spent: 640, limit: 500, icon: Icons.flight_rounded, onTap: tap),
              const UiGap.sm(),
              const UiBudgetBar(category: 'No card', spent: 80, limit: 200, card: false),
            ],
          ),
        ),
        const DemoBlock(
          'UiSpendingBreakdown',
          child: Column(
            children: [
              UiSpendingBreakdown(items: spendItems, centerLabel: 'This month'),
              UiGap.lg(),
              UiSpendingBreakdown(items: [], emptyLabel: 'No spending yet', size: 120),
            ],
          ),
        ),
        DemoBlock(
          'UiCurrencyInput',
          subtitle: 'Amount: $_amount',
          child: UiCurrencyInput(max: 5000, hint: 'Available: \$5,000', onChanged: (v) => setState(() => _amount = v)),
        ),
        DemoBlock(
          'UiContactAvatarRow',
          child: UiContactAvatarRow(
            contacts: contacts,
            selectedIndex: _contact,
            padding: EdgeInsets.zero,
            onTap: (c) => setState(() => _contact = contacts.indexOf(c)),
            onAdd: tap,
          ),
        ),
        DemoBlock(
          'UiBillTile',
          child: Column(
            children: [
              UiBillTile(
                title: 'Electricity',
                amount: 84.2,
                due: ahead(days: 2),
                icon: Icons.bolt_rounded,
                paid: _paid,
                onPay: () => setState(() => _paid = true),
              ),
              const UiGap.sm(),
              UiBillTile(title: 'Internet', amount: 39.99, due: ago(days: 1), icon: Icons.wifi_rounded, onPay: tap),
              const UiGap.sm(),
              UiBillTile(title: 'Water', amount: 21.5, due: ahead(days: 12), icon: Icons.water_drop_rounded, paid: true),
            ],
          ),
        ),
      ],
    );
  }
}
