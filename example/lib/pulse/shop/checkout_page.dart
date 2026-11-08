import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';
import 'cart_page.dart';

const _countries = [
  'Australia', 'Brazil', 'Canada', 'Denmark', 'France', 'Germany', 'India', 'Ireland', 'Italy', 'Japan', //
  'Mexico', 'Netherlands', 'New Zealand', 'Norway', 'Portugal', 'Singapore', 'South Africa', 'Spain', 'Sweden',
  'United Kingdom', 'United States',
];

const _payments = [
  (UiPaymentBrand.visa, 'Visa', '4242424242424242', 'Expires 08/28'),
  (UiPaymentBrand.mastercard, 'Mastercard', '5555444433331111', 'Expires 02/27'),
  (UiPaymentBrand.paypal, 'PayPal', null, 'ana.lee@mail.com'),
  (UiPaymentBrand.applePay, 'Apple Pay', null, 'Pay with Face ID'),
  (UiPaymentBrand.cod, 'Cash on delivery', null, 'Pay when it arrives'),
];

/// Checkout in three steps: address, payment, review. Then a success screen.
class PulseCheckoutPage extends StatefulWidget {
  const PulseCheckoutPage({super.key});

  @override
  State<PulseCheckoutPage> createState() => _PulseCheckoutPageState();
}

class _PulseCheckoutPageState extends State<PulseCheckoutPage> {
  int _step = 0; // 0 address, 1 payment, 2 review
  int _address = 0; // 0 home, 1 work, 2 new
  int _payment = 0;
  bool _placing = false;
  bool _done = false;
  String _orderId = '';
  double _paid = 0;

  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _zip = TextEditingController();
  String? _country = 'Portugal';

  @override
  void dispose() {
    for (final c in [_name, _phone, _street, _city, _zip]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  List<(String, List<String>, String)> _saved(PulseStore store) => [
        ('Home', ['12 Rua Augusta', 'Lisbon 1100-053', 'Portugal'], '+351 912 345 678'),
        ('Work', ['Av. da Liberdade 110, Floor 4', 'Lisbon 1250-146', 'Portugal'], '+351 213 456 789'),
      ];

  List<String> _addressLines(PulseStore store) => _address < 2
      ? _saved(store)[_address].$2
      : [_street.text.trim(), '${_city.text.trim()} ${_zip.text.trim()}', _country ?? ''];

  void _next() {
    if (_step == 0 && _address == 2 && !(_form.currentState?.validate() ?? false)) {
      context.showToast('Please fill in the address', status: UiStatus.warning);
      return;
    }
    setState(() => _step++);
  }

  void _back() => _step == 0 ? Navigator.of(context).pop() : setState(() => _step--);

  Future<void> _place(PulseTotals t) async {
    setState(() => _placing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final store = PulseScope.read(context);
    store.pay(t.total);
    store.clearCart();
    pulseCoupon.value = null;
    setState(() {
      _placing = false;
      _done = true;
      _paid = t.total;
      _orderId = 'PL-${DateTime.now().millisecondsSinceEpoch % 100000}';
    });
  }

  /// Close checkout and cart and go back to where the cart was opened from.
  void _backToShop() => Navigator.of(context)
    ..pop()
    ..pop();

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    if (_done) return _success();
    final t = PulseTotals(store, pulseCoupon.value);
    return PopScope(
      canPop: _step == 0 && !_placing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_placing) _back();
      },
      child: Scaffold(
        appBar: UiAppBar(title: 'Checkout', subtitle: '${t.items} items · ${money(t.total)}'),
        body: UiMaxWidth(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.md, UiSpace.lg, UiSpace.sm),
                child: UiCheckoutSteps(current: _step + 1, onStepTap: (i) => i == 0 ? Navigator.of(context).pop() : setState(() => _step = i - 1)),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: UiDuration.normal,
                  child: ListView(
                    key: ValueKey(_step),
                    padding: const EdgeInsets.all(UiSpace.lg),
                    children: switch (_step) {
                      0 => _addressStep(store),
                      1 => _paymentStep(store),
                      _ => _reviewStep(store, t),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(UiSpace.lg),
            child: Row(
              children: [
                Expanded(child: UiButton.outline('Back', expand: true, onPressed: _placing ? null : _back)),
                const UiGap.md(),
                Expanded(
                  flex: 2,
                  child: _step < 2
                      ? UiButton('Continue', expand: true, trailingIcon: Icons.arrow_forward_rounded, onPressed: _next)
                      : UiButton(
                          'Place order · ${money(t.total)}',
                          expand: true,
                          icon: Icons.lock_rounded,
                          loading: _placing,
                          onPressed: t.items == 0 || _placing ? null : () => _place(t),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _addressStep(PulseStore store) => [
        Text('Ship to', style: context.text.titleMedium),
        const UiGap.md(),
        for (final (i, a) in _saved(store).indexed) ...[
          UiAddressCard(
            name: store.me.name,
            label: a.$1,
            lines: a.$2,
            phone: a.$3,
            icon: i == 0 ? Icons.home_outlined : Icons.work_outline_rounded,
            isDefault: i == 0,
            selected: _address == i,
            onTap: () => setState(() => _address = i),
            onEdit: () => setState(() => _address = 2),
          ),
          const UiGap.sm(),
        ],
        UiAddressCard(
          name: 'New address',
          label: 'Other',
          lines: const ['Ship somewhere else'],
          icon: Icons.add_location_alt_outlined,
          selected: _address == 2,
          onTap: () => setState(() => _address = 2),
        ),
        if (_address == 2) ...[
          const UiGap.lg(),
          Form(
            key: _form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UiTextField.name(controller: _name, validator: _required, isRequired: true),
                const UiGap.md(),
                UiTextField.phone(
                  controller: _phone,
                  isRequired: true,
                  validator: (v) => (v ?? '').replaceAll(RegExp(r'\D'), '').length < 7 ? 'Enter a valid phone number' : null,
                ),
                const UiGap.md(),
                UiSearchableDropdown<String>(
                  label: 'Country',
                  items: _countries,
                  value: _country,
                  prefixIcon: Icons.public_rounded,
                  searchHint: 'Search countries',
                  isRequired: true,
                  validator: (v) => v == null ? 'Select a country' : null,
                  onChanged: (v) => setState(() => _country = v),
                ),
                const UiGap.md(),
                UiTextField('Street address', controller: _street, prefixIcon: Icons.signpost_outlined, validator: _required, isRequired: true),
                const UiGap.md(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: UiTextField('City', controller: _city, validator: _required, isRequired: true, textCapitalization: TextCapitalization.words),
                    ),
                    const UiGap.md(),
                    Expanded(
                      flex: 2,
                      child: UiTextField(
                        'ZIP code',
                        controller: _zip,
                        isRequired: true,
                        keyboardType: TextInputType.text,
                        validator: (v) => (v ?? '').trim().length < 4 ? 'Too short' : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ];

  List<Widget> _paymentStep(PulseStore store) {
    final sel = _payments[_payment];
    return [
      if (sel.$3 != null) ...[
        Center(
          child: UiPaymentCardView(
            number: sel.$3!,
            holder: store.me.name,
            expiry: sel.$4.replaceFirst('Expires ', ''),
            brand: sel.$2,
            style: _payment == 0 ? UiPaymentCardStyle.primary : UiPaymentCardStyle.dark,
            width: 340,
          ),
        ),
        const UiGap.xl(),
      ],
      Text('Payment method', style: context.text.titleMedium),
      const UiGap.md(),
      for (final (i, m) in _payments.indexed) ...[
        UiPaymentMethodTile(
          brand: m.$1,
          title: m.$2,
          number: m.$3,
          subtitle: m.$4,
          selected: _payment == i,
          onTap: () => setState(() => _payment = i),
        ),
        const UiGap.sm(),
      ],
      const UiGap.md(),
      Text(
        'Your card details are encrypted. We never store the full number.',
        style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
      ),
    ];
  }

  List<Widget> _reviewStep(PulseStore store, PulseTotals t) {
    final pay = _payments[_payment];
    final name = _address == 2 ? _name.text.trim() : store.me.name;
    return [
      UiSection(
        title: 'Items',
        margin: const EdgeInsets.only(bottom: UiSpace.lg),
        child: UiCard(
          variant: UiCardVariant.outlined,
          child: UiKeyValueList(
            [for (final e in store.cart.entries) UiKeyValue('${e.value} x ${e.key.title}', money(e.key.price * e.value))],
            divided: true,
          ),
        ),
      ),
      UiSection(
        title: 'Delivery',
        trailing: UiButton.ghost('Change', size: UiSize.sm, onPressed: () => setState(() => _step = 0)),
        margin: const EdgeInsets.only(bottom: UiSpace.lg),
        child: UiCard(
          variant: UiCardVariant.outlined,
          child: UiKeyValueList([
            UiKeyValue('Name', name, icon: Icons.person_outline_rounded),
            UiKeyValue('Address', _addressLines(store).where((l) => l.trim().isNotEmpty).join(', '), icon: Icons.place_outlined),
            UiKeyValue('Arrives', UiFormat.date(DateTime.now().add(const Duration(days: 3))), icon: Icons.local_shipping_outlined),
            UiKeyValue('Payment', pay.$3 == null ? pay.$2 : '${pay.$2} •••• ${pay.$3!.substring(pay.$3!.length - 4)}', icon: Icons.credit_card_rounded),
          ]),
        ),
      ),
      UiSection(
        title: 'Total',
        margin: const EdgeInsets.only(bottom: UiSpace.lg),
        child: UiCard(
          variant: UiCardVariant.outlined,
          child: UiKeyValueList(
            [
              UiKeyValue('Subtotal', money(t.subtotal)),
              if (t.discount > 0) UiKeyValue('Promo SAVE10', money(-t.discount), valueColor: context.palette.success),
              UiKeyValue('Shipping', t.shipping == 0 ? 'Free' : money(t.shipping)),
              UiKeyValue('Tax', money(t.tax)),
            ],
            total: ('Total', money(t.total)),
          ),
        ),
      ),
      const UiTrustBadges(),
    ];
  }

  Widget _success() => Scaffold(
        appBar: UiAppBar(title: 'Order placed', showBack: false),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UiSpace.xl),
            child: UiMaxWidth(
              maxWidth: 480,
              child: Column(
                children: [
                  UiEmptyState(
                    title: 'Thank you for your order!',
                    message: 'Order $_orderId is confirmed. We charged ${money(_paid)} and sent the receipt to your email.',
                    icon: Icons.check_rounded,
                    status: UiStatus.success,
                    actionLabel: 'Back to shop',
                    onAction: _backToShop,
                  ),
                  const UiGap.lg(),
                  const UiTrustBadges(),
                ],
              ),
            ),
          ),
        ),
      );
}
