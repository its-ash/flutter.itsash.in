import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';

/// Send money to a contact. Checks the balance, asks to confirm, then pays.
class PulseTransferPage extends StatefulWidget {
  const PulseTransferPage({super.key, this.to});

  final Person? to;

  @override
  State<PulseTransferPage> createState() => _PulseTransferPageState();
}

class _PulseTransferPageState extends State<PulseTransferPage> {
  static const _quick = [10.0, 25.0, 50.0, 100.0, 250.0];

  late Person? _to = widget.to;
  double _amount = 0;

  /// Changes when a quick amount is picked, so the keypad starts from that value.
  int _inputVersion = 0;
  final _note = TextEditingController();
  bool _favorite = false;
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _pickQuick(double v) => setState(() {
        _amount = v;
        _inputVersion++;
        _error = null;
      });

  Future<void> _send() async {
    final store = PulseScope.read(context);
    final to = _to;
    if (to == null) {
      setState(() => _error = 'Choose who you want to pay.');
      return;
    }
    if (_amount <= 0) {
      setState(() => _error = 'Enter an amount to send.');
      return;
    }
    if (_amount > store.balance) {
      setState(() => _error = 'You only have ${money(store.balance)}. Lower the amount or top up first.');
      return;
    }
    setState(() => _error = null);
    final ok = await UiDialog.confirm(
      context,
      title: 'Send ${money(_amount)}?',
      message: 'To ${to.name} (@${to.handle}). You cannot undo this payment.',
      confirmLabel: 'Send now',
      icon: Icons.send_rounded,
    );
    if (!ok || !mounted) return;
    setState(() => _sending = true);
    await UiLoader.overlay(context, Future<void>.delayed(const Duration(seconds: 1)), message: 'Sending money...');
    if (!mounted) return;
    store.pay(_amount);
    context.showToast(
      '${money(_amount)} sent to ${to.name.split(' ').first}${_favorite ? ' and saved as favorite' : ''}',
      title: 'Payment sent',
      status: UiStatus.success,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    final people = [for (final p in store.data.people) if (p != store.me) p];
    final to = _to;
    final error = _error;
    return Scaffold(
      appBar: const UiAppBar(title: 'Send money'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(UiSpace.lg),
          children: [
            UiSearchableDropdown<Person>(
              label: 'Send to',
              hint: 'Choose a contact',
              searchHint: 'Search by name or handle',
              sheetTitle: 'Choose a contact',
              prefixIcon: Icons.person_search_rounded,
              items: people,
              value: to,
              itemLabel: (p) => p.name,
              itemSubtitle: (p) => '@${p.handle}',
              itemIcon: (p) => p.verified ? Icons.verified_rounded : Icons.person_rounded,
              isRequired: true,
              onChanged: (p) => setState(() {
                _to = p;
                _error = null;
              }),
            ),
            if (to != null) ...[
              const UiGap.md(),
              Row(
                children: [
                  UiAvatar(name: to.name, imageUrl: to.avatar, size: 44),
                  const UiGap.md(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(to.name, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          to.bio,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const UiGap.xl(),
            UiCurrencyInput(
              key: ValueKey(_inputVersion),
              initial: _amount == 0 ? null : _amount,
              max: 10000,
              hint: 'Available: ${money(store.balance)}',
              onChanged: (v) => setState(() {
                _amount = v;
                _error = null;
              }),
            ),
            const UiGap.lg(),
            Text('Quick amounts', style: context.text.labelLarge?.copyWith(color: context.colors.onSurfaceVariant)),
            const UiGap.sm(),
            UiChipGroup(
              scrollable: true,
              children: [
                for (final v in _quick)
                  UiChip(
                    money(v),
                    selected: _amount == v,
                    onTap: () => _pickQuick(v),
                  ),
              ],
            ),
            const UiGap.xl(),
            UiTextField.multiline(
              'Note',
              hint: 'What is it for? (optional)',
              controller: _note,
              maxLength: 140,
              minLines: 2,
              maxLines: 4,
            ),
            const UiGap.sm(),
            UiSwitchTile(
              'Save as favorite',
              subtitle: 'Show this contact first next time',
              leading: Icons.star_outline_rounded,
              value: _favorite,
              onChanged: (v) => setState(() => _favorite = v),
            ),
            if (error != null) ...[
              const UiGap.md(),
              UiBanner(
                error,
                title: 'Cannot send yet',
                status: UiStatus.danger,
                onClose: () => setState(() => _error = null),
              ),
            ],
            const UiGap.xl(),
            UiButton(
              _amount > 0 ? 'Send ${money(_amount)}' : 'Send',
              icon: Icons.send_rounded,
              expand: true,
              loading: _sending,
              onPressed: _sending ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
