import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

const bookingSlots = [
  TimeOfDay(hour: 9, minute: 0),
  TimeOfDay(hour: 9, minute: 30),
  TimeOfDay(hour: 10, minute: 0),
  TimeOfDay(hour: 11, minute: 30),
  TimeOfDay(hour: 13, minute: 0),
  TimeOfDay(hour: 14, minute: 30),
  TimeOfDay(hour: 15, minute: 0),
  TimeOfDay(hour: 17, minute: 30),
  TimeOfDay(hour: 18, minute: 0),
  TimeOfDay(hour: 19, minute: 30),
];

class BookingSection extends StatefulWidget {
  const BookingSection({super.key});

  @override
  State<BookingSection> createState() => _BookingSectionState();
}

class _BookingSectionState extends State<BookingSection> {
  late DateTime _day = DateTime(now.year, now.month, now.day);
  DateTime? _calDay;
  DateTimeRange? _range;
  TimeOfDay? _slot = const TimeOfDay(hour: 10, minute: 0);
  String? _strSlot;
  Set<UiSeat> _seats = const {(row: 2, col: 4)};
  int _service = 0;
  List<int> _guests = const [2, 0, 0];

  @override
  Widget build(BuildContext context) {
    void tap() => toast(context, 'Tapped');
    final today = DateTime(now.year, now.month, now.day);
    return SectionPage(
      children: [
        DemoBlock(
          'UiDateStrip',
          child: UiDateStrip(
            days: 14,
            selected: _day,
            padding: EdgeInsets.zero,
            markers: {today.add(const Duration(days: 2)), today.add(const Duration(days: 5))},
            onChanged: (d) => setState(() => _day = d),
          ),
        ),
        DemoBlock(
          'UiMonthCalendar (single)',
          child: UiMonthCalendar(
            selected: _calDay,
            firstDate: today,
            markers: {today.add(const Duration(days: 3))},
            onChanged: (d) => setState(() => _calDay = d),
          ),
        ),
        DemoBlock(
          'UiMonthCalendar (range)',
          child: UiMonthCalendar(
            mode: UiCalendarMode.range,
            range: _range,
            firstDate: today,
            onRangeChanged: (r) => setState(() => _range = r),
          ),
        ),
        DemoBlock(
          'UiTimeSlotGrid',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiTimeSlotGrid<TimeOfDay>(
                slots: bookingSlots,
                selected: _slot,
                unavailable: {bookingSlots[0], bookingSlots[6]},
                onChanged: (t) => setState(() => _slot = t),
              ),
              const UiGap.lg(),
              UiTimeSlotGrid<String>(
                slots: const ['10:00', '10:30', '11:00', '11:30'],
                selected: _strSlot,
                grouped: false,
                columns: 4,
                onChanged: (s) => setState(() => _strSlot = s),
              ),
              const UiGap.lg(),
              const UiTimeSlotGrid<String>(slots: [], emptyLabel: 'No slots on this day'),
            ],
          ),
        ),
        DemoBlock(
          'UiBookingCard',
          child: Column(
            children: [
              for (final (i, s) in UiBookingStatus.values.indexed) ...[
                UiBookingCard(
                  title: ['Haircut', 'Deep tissue massage', 'Dental check', 'Yoga class', 'Physio'][i % 5],
                  provider: ['Sam Lee', 'Mia Torres', 'Dr. Patel', 'Ana Ruiz', 'Leo Park'][i % 5],
                  providerRole: 'Specialist',
                  providerImage: pic('pro$i', 200, 200),
                  location: 'Studio ${i + 1}, Main St',
                  start: today.add(Duration(days: i, hours: 10 + i)),
                  duration: Duration(minutes: 30 + i * 15),
                  status: s,
                  onTap: tap,
                  onReschedule: tap,
                  onCancel: tap,
                ),
                const UiGap.sm(),
              ],
            ],
          ),
        ),
        DemoBlock(
          'UiTicketCard',
          child: UiTicketCard(
            onTap: tap,
            top: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Midnight Echoes', style: context.text.titleMedium),
                      Text('Concert · Row B · Seat 12', style: context.text.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.qr_code_2_rounded, size: 48),
              ],
            ),
            bottom: Row(
              children: [
                const Icon(Icons.door_front_door_rounded, size: 18),
                const UiGap.xs(),
                const Text('Gate 4'),
                const Spacer(),
                const Icon(Icons.schedule_rounded, size: 18),
                const UiGap.xs(),
                Text('19:30', style: context.text.titleSmall),
              ],
            ),
          ),
        ),
        DemoBlock(
          'UiSeatPicker',
          subtitle: _seats.isEmpty ? 'Pick up to 4 seats' : _seats.map(UiSeatPicker.seatName).join(', '),
          child: UiSeatPicker(
            rows: 8,
            columns: 10,
            aisleAfterColumns: const {4},
            unavailable: const {(row: 0, col: 3), (row: 1, col: 5), (row: 4, col: 4), (row: 4, col: 5)},
            hidden: const {(row: 7, col: 0), (row: 7, col: 9)},
            selected: _seats,
            maxSelection: 4,
            onChanged: (s) => setState(() => _seats = s),
          ),
        ),
        DemoBlock(
          'UiServiceTile',
          child: Column(
            children: [
              for (final (i, (name, mins, price, rating)) in const [
                ('Deep tissue massage', 60, '\$80', 4.8),
                ('Haircut and style', 45, '\$35', 4.6),
                ('Facial', 50, '\$65', 4.9),
              ].indexed) ...[
                UiServiceTile(
                  name: name,
                  subtitle: 'With a senior therapist',
                  image: pic('service$i', 300, 300),
                  duration: Duration(minutes: mins),
                  price: price,
                  rating: rating,
                  reviews: 120 + i * 37,
                  selected: _service == i,
                  onTap: () => setState(() => _service = i),
                  onBook: () => toast(context, 'Book $name'),
                ),
                const UiGap.sm(),
              ],
            ],
          ),
        ),
        DemoBlock(
          'UiGuestCounter',
          subtitle: 'Adults ${_guests.elementAtOrNull(0) ?? 0} · Children ${_guests.elementAtOrNull(1) ?? 0} · Infants ${_guests.elementAtOrNull(2) ?? 0}',
          child: UiGuestCounter(maxTotal: 8, onChanged: (c) => setState(() => _guests = c)),
        ),
      ],
    );
  }
}
