# Finance

Import: `package:theme/theme.dart`. All widgets use the theme colors. They work in light mode and dark mode.

### UiAmount
Money text with a sign and color. Positive values use the success color and "+".
```dart
UiAmount(-42.5)
UiAmount(1250000, compact: true)
UiAmount(980, masked: true)
```
Params: `value`, `symbol` '$', `decimals` 2, `compact`, `masked`, `signed` true, `colored` true, `negativeAsDanger` false, `strike`, `splitDecimals`, `style`.

### UiBalanceCard
Gradient card with balance, eye button to hide it, change %, masked account number, and actions.
```dart
UiBalanceCard(
  balance: 12480.32,
  change: 2.4,
  changeLabel: 'vs last month',
  accountNumber: '1234567890',
  actions: [UiQuickAction(icon: Icons.send, label: 'Send', onTap: () {})],
)
```
Params: `balance`, `label`, `symbol`, `change`, `changeLabel`, `accountNumber`, `masked`, `onMaskChanged`, `actions`, `gradient`, `trailing`, `onTap`.

### UiPaymentCardView
Credit card view with a 1.586 ratio.
```dart
UiPaymentCardView(number: '4242424242424242', holder: 'Jane Doe', expiry: '08/28', brand: 'VISA')
```
Params: `number`, `holder`, `expiry`, `brand`, `style` (`UiPaymentCardStyle.primary|secondary|tertiary|dark`), `gradient`, `masked` true, `selected`, `onTap`, `width`.

### UiTransactionTile
Transaction row with a category icon, title, date, amount, and status tag.
```dart
UiTransactionTile(title: 'Spotify', amount: -9.99, date: DateTime.now(), icon: Icons.music_note)
```
Params: `title`, `amount`, `subtitle`, `date`, `icon`, `imageUrl`, `color`, `status` (`UiTransactionStatus.completed|pending|failed`), `symbol`, `onTap`.

### UiTransactionGroup
Date header and a list of tiles in one card.
```dart
UiTransactionGroup(date: DateTime.now(), trailing: '−\$54.20', children: [tileA, tileB])
```
Params: `children`, `title` (or `date` → Today, Yesterday, date), `trailing`, `card` true.

### UiQuickActions
Round icon buttons with labels. Up to 5 fill a row; more scroll; `columns` makes a grid.
```dart
UiQuickActions(actions: [
  UiQuickAction(icon: Icons.send, label: 'Send', onTap: () {}),
  UiQuickAction(icon: Icons.add, label: 'Top up', onTap: () {}),
])
```
Params: `actions` (`UiQuickAction(icon, label, onTap, badge)`), `columns`, `size` 56, `background`, `foreground`, `labelColor`.

### UiBudgetBar
Budget for one category. The color changes to warning at 80% and to danger above 100%.
```dart
UiBudgetBar(category: 'Food', spent: 420, limit: 500, icon: Icons.restaurant)
```
Params: `category`, `spent`, `limit`, `icon`, `color`, `symbol`, `warnAt` 0.8, `card` true, `onTap`.

### UiSpendingBreakdown
Donut chart with legend rows and percents. Shows `emptyLabel` when the total is zero.
```dart
UiSpendingBreakdown(items: const [UiSpendItem('Food', 420), UiSpendItem('Rent', 1200)])
```
Params: `items` (`UiSpendItem(label, value, {color, icon})`), `symbol`, `centerLabel`, `emptyLabel`, `size` 180, `stroke` 22, `legend` true.

### UiCurrencyInput
Large amount display and a number keypad. Long-press delete to clear.
```dart
UiCurrencyInput(max: 5000, hint: 'Available: \$5,000', onChanged: (v) {})
```
Params: `initial`, `symbol`, `decimals` 2, `max`, `onChanged`, `hint`, `maxLabel`, `keypad` true. The input rejects extra dots, extra decimals, more than 9 integer digits, and values above `max`.

### UiContactAvatarRow
Horizontal row of recent contacts with first names.
```dart
UiContactAvatarRow(contacts: const [UiContactItem(name: 'Ana Silva')], onTap: (c) {}, onAdd: () {})
```
Params: `contacts` (`UiContactItem(name, imageUrl, id)`), `onTap`, `onAdd`, `addLabel`, `selectedIndex`, `size` 56, `padding`.

### UiBillTile
Bill with amount, due label, and Pay button.
```dart
UiBillTile(title: 'Electricity', amount: 84.2, due: DateTime.now().add(const Duration(days: 2)), onPay: () {})
```
Params: `title`, `amount`, `due`, `icon`, `color`, `paid`, `symbol`, `payLabel`, `onPay`, `onTap`, `now`.

### UiFinanceFormat
Helpers: `money(v, symbol:, decimals:, compact:, sign:)`, `compact(v)`, `group(digits)`, `maskNumber(s)`, `percent(v)`, `date(d)`, `relativeDay(d)`, `daysUntil(d)`.
