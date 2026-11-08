# Foundation

Import one file. It gives you the theme and all components.

```dart
import 'package:theme/theme.dart';
```

### UiTheme
Makes a complete Material 3 `ThemeData` for light or dark mode from one brand.

```dart
MaterialApp(
  theme: UiTheme.light(UiBrand.commerce),
  darkTheme: UiTheme.dark(UiBrand.commerce),
);
```
- `UiTheme.light([UiBrand brand = UiBrand.neutral])`
- `UiTheme.dark([UiBrand brand = UiBrand.neutral])`
- `UiTheme.build(UiBrand brand, Brightness brightness)`

The theme sets: filled inputs with no border and a primary focus ring, pill tab indicators, stadium chips, rounded cards with a hairline border, floating snackbars, bottom sheets with a drag handle, rounded dialogs, and pill navigation indicators.

### UiBrand
One preset per app type. Each preset sets a seed color, a heading font, a body font (Google Fonts), a radius scale, and a color-scheme variant.

| Preset | Seed | Fonts | Radius |
|---|---|---|---|
| `neutral` | Indigo | Plus Jakarta Sans / Inter | 1.0 |
| `commerce` | Orange-red | Outfit / Inter | 1.0 |
| `fitness` | Lime | Sora / Inter | 1.2 |
| `finance` | Teal | Manrope | 0.85 |
| `health` | Sky | Nunito | 1.2 |
| `food` | Amber | Poppins / Inter | 1.1 |
| `travel` | Blue | DM Sans | 1.0 |
| `social` | Pink | Poppins / Inter | 1.3 |
| `education` | Violet | Lexend | 1.0 |
| `productivity` | Slate | Plus Jakarta Sans / Inter | 0.75 |
| `luxury` | Bronze | Playfair Display / Lato | 0.5 |

Make your own brand:
```dart
final brand = UiBrand.neutral.copyWith(id: 'acme', name: 'Acme', seed: const Color(0xFF00897B), radiusScale: 1.4);
```
- `UiBrand.values`, `UiBrand.byId(String id)`.

### Context shortcuts
```dart
context.colors   // ColorScheme
context.text     // TextTheme
context.palette  // UiColors (success, warning, info, rating, sale, gradient, shimmer)
context.tokens   // UiTokens (radius)
context.isDark
context.isCompact / isMedium / isExpanded
context.tone(UiStatus.success) // (color, onColor, container, onContainer)
```

### Tokens
- `UiSpace`: `xxs 2`, `xs 4`, `sm 8`, `md 12`, `lg 16`, `xl 20`, `xxl 24`, `xxxl 32`, `huge 48`, `page`, `card`.
- `UiTokens` (theme extension, scaled by brand): `context.tokens.xs / sm / md / lg / xl / full` are `BorderRadius` values. `controlHeight` is 52.
- `UiDuration`: `fast 150ms`, `normal 250ms`, `slow 400ms`. `UiCurve.standard`, `UiCurve.emphasized`.
- `UiBreakpoint`: `compact 600`, `medium 840`, `expanded 1200`.
- `UiSize { sm, md, lg }`, `UiStatus { neutral, info, success, warning, danger }`.

### UiColors
A theme extension with semantic colors that the Material `ColorScheme` does not have: `success`, `warning`, `info` (each with `on`, `container`, `onContainer`), `rating`, `sale`, `shimmerBase`, `shimmerHighlight`, `gradient`.

### UiGap
A square spacer.
```dart
const UiGap.md()
```
`UiGap(double)`, `.xs`, `.sm`, `.md`, `.lg`, `.xl`, `.xxl`.

The basic widgets that used to be listed here as primitives now have their own pages: [button.md](button.md) (`UiButton`, `UiIconButton`), [card.md](card.md) (`UiCard`), [image.md](image.md) (`UiImage`, `UiAvatar`), and [display.md](display.md) (`UiTag`, `UiRatingStars`).

## Formatting

All widgets use these two helpers. Do not add a formatter in a slice. The helpers do not use the `intl` package.

### UiFormat
Formats dates, times, durations, and numbers.
```dart
UiFormat.date(d)                     // 12 Mar 2026
UiFormat.day(d)                      // Fri, 14 Mar
UiFormat.day(d, year: true)          // Fri, 14 Mar 2026
UiFormat.shortDate(d)                // 14 Mar (adds the year if it is not this year)
UiFormat.monthYear(d)                // March 2026
UiFormat.time(t)                     // 9:05 AM (t is TimeOfDay or DateTime)
UiFormat.time(t, h24: true)          // 09:05
UiFormat.dateTime(d)                 // 12 Mar 2026, 9:05 AM
UiFormat.dateTime(d, weekday: true)  // Fri, 14 Mar, 9:05 AM
UiFormat.range(r)                    // 12 Mar – 15 Mar 2026
UiFormat.relative(d)                 // now, 5m, 3h, 2d, then shortDate
UiFormat.relativeDay(d)              // Today, Yesterday, Tomorrow, then day
UiFormat.duration(d)                 // 04:05 or 1:04:05
UiFormat.minutes(d)                  // 45 min, 1h, 1h 30m
UiFormat.number(12345.6, decimals: 1) // 12,345.6
UiFormat.compact(1234)               // 1.2k (also M, B, T)
UiFormat.count(1299)                 // 1.2k (rounds down, never below 0)
UiFormat.percent(4.25)               // +4.3%
UiFormat.masked('4111 1111 1111 1234') // •••• 1234
```
- Date helpers: `dateOnly`, `sameDay`, `daysInMonth`, `daysUntil`, `weekday`.
- Lists: `weekdays`, `months`, `monthsLong`, `mask`.
- `number(v, {decimals = 0, trimZeros = false, group = ',', point = '.'})`. `trimZeros` removes trailing zeros. Null, NaN, and infinity become 0.
- `compact(v, {floor = false})`. Use `floor: true` to round down.

### UiMoney
Formats money. Commerce, finance, and booking widgets use it. Set the global values one time at app start.
```dart
UiMoney.symbol = '₹';
UiMoney.format(1299.5);                                           // ₹1,299.50
UiMoney.format(1200, compact: true);                              // ₹1.2k
UiMoney.format(42, sign: true);                                   // +₹42.00
UiMoney.format(9, symbol: '€', position: UiSymbolPosition.after); // 9.00 €
UiMoney.spoken(12.5);                                             // 12.50 rupees
UiMoney.discountPercent(129, 159);                                // 19
```
- Global values: `symbol` ('\$'), `decimals` (2), `position` (`UiSymbolPosition.before`), `groupSeparator` (','), `decimalSeparator` ('.'), `names` (symbol to spoken name).
- `format(amount, {symbol, decimals, position, compact, trimZeros, sign})`. `compact` applies from 1000. `trimZeros` removes ".00" only. `sign` adds "+" to a positive value.
- `safe(v)` changes null, NaN, and infinity to 0.
- A widget `symbol` param that is null uses `UiMoney.symbol`.
