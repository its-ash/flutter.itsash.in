# Booking

Import: `package:theme/theme.dart`. All widgets use the theme colors. They work in light mode and dark mode.

### UiDateStrip
Horizontal list of days with weekday and day number. Past days are off by default.
```dart
UiDateStrip(days: 14, selected: day, markers: {DateTime(2026, 11, 10)}, onChanged: (d) {})
```
Params: `start` (today), `days` 14 (1–366), `selected`, `onChanged`, `disablePast` true, `markers`, `isEnabled`, `padding`.

### UiMonthCalendar
Month grid with previous and next buttons. Single day or range selection.
```dart
UiMonthCalendar(selected: day, firstDate: DateTime.now(), onChanged: (d) {})
UiMonthCalendar(mode: UiCalendarMode.range, onRangeChanged: (r) {})
```
Params: `mode` (`single|range`), `selected`, `range`, `onChanged`, `onRangeChanged`, `firstDate`, `lastDate`, `initialMonth`, `markers`, `firstWeekday` Monday, `isEnabled`, `onMonthChanged`.

### UiTimeSlotGrid
Time slots as pills. `TimeOfDay` slots group into Morning, Afternoon, and Evening.
```dart
UiTimeSlotGrid(
  slots: const [TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 14, minute: 30)],
  unavailable: const {TimeOfDay(hour: 9, minute: 0)},
  onChanged: (t) {},
)
UiTimeSlotGrid(slots: const ['10:00', '10:30'], onChanged: (s) {})
```
Params: `slots` (`List<T>`), `selected`, `unavailable`, `onChanged`, `labelOf`, `grouped` true, `use24h` false, `columns` 3, `sections`, `emptyLabel`.

### UiBookingCard
Appointment card with provider, date and time, location, status, and actions.
```dart
UiBookingCard(
  title: 'Haircut',
  provider: 'Sam Lee',
  start: DateTime(2026, 11, 12, 10),
  duration: const Duration(minutes: 45),
  status: UiBookingStatus.confirmed,
  onReschedule: () {},
  onCancel: () {},
)
```
Params: `title`, `start`, `duration`, `provider`, `providerRole`, `providerImage`, `location`, `status` (`upcoming|confirmed|pending|completed|cancelled`), `onTap`, `onReschedule`, `onCancel`, labels, `use24h`. Actions do not show for completed or cancelled bookings.

### UiTicketCard
Ticket shape with side cutouts and a dashed line between the top and bottom sections.
```dart
UiTicketCard(top: const Text('Concert · Row B'), bottom: const Text('Gate 4 · 19:30'))
```
Params: `top`, `bottom`, `notch` 12, `color`, `foreground`, `padding`, `onTap`.

### UiSeatPicker
Seat grid with aisles, taken seats, max selection, and legend.
```dart
UiSeatPicker(
  rows: 8,
  columns: 10,
  aisleAfterColumns: const {4},
  unavailable: const {(row: 0, col: 3)},
  maxSelection: 4,
  onChanged: (seats) {},
)
```
Params: `rows`, `columns` (max 60), `selected`, `unavailable`, `hidden`, `aisleAfterColumns`, `aisleAfterRows`, `maxSelection` 8, `onChanged`, `screenLabel` 'Screen' (null hides), `legend`, `labels`, `seatSize` 28.
Type: `UiSeat = ({int row, int col})`. `UiSeatPicker.seatName(seat)` gives "B4".

### UiServiceTile
Service row with image, duration, rating, price, and Book button.
```dart
UiServiceTile(name: 'Deep tissue massage', duration: const Duration(minutes: 60), price: '\$80', rating: 4.8, onBook: () {})
```
Params: `name`, `image`, `subtitle`, `duration`, `price`, `rating`, `reviews`, `onBook`, `onTap`, `bookLabel`, `selected`.

### UiGuestCounter
Rows with − n + steppers. Default rows: adults (min 1), children, infants (max 5).
```dart
UiGuestCounter(maxTotal: 8, onChanged: (counts) {})
```
Params: `types` (`UiGuestType(label, {subtitle, min, max, initial})`), `maxTotal`, `onChanged` (`List<int>` in type order).

Dates and times use `UiFormat`. Refer to [foundation.md](foundation.md#formatting).
