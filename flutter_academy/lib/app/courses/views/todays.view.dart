import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:flutter_academy/app/courses/utilities/booking_summary_card.utils.dart';
import 'package:flutter_academy/app/courses/utilities/status_card.utils.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/payment_status_list.vm.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedViewProvider = StateProvider<String>((ref) => 'Arrivals');

final roomMappingProvider = Provider<Map<int, String>>((ref) {
  final rooms = ref.watch(roomListVM);
  return {
    for (var room in rooms)
      if (int.tryParse(room.id) != null)
        int.parse(room.id): room.roomNumber.toString()
  };
});

final paymentStatusMappingProvider =
    FutureProvider<Map<int, String>>((ref) async {
  return await PaymentStatusListVM().paymentStatusMapping();
});

class TodaysView extends ConsumerWidget {
  const TodaysView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedView = ref.watch(selectedViewProvider);
    final bookings = ref.watch(bookingListByDateVM(selectedDate));
    final roomMapping = ref.watch(roomMappingProvider);
    final paymentStatusAsync = ref.watch(paymentStatusMappingProvider);
    final paymentStatusMapping = paymentStatusAsync.maybeWhen(
      data: (value) => Map<int, String>.from(value),
      orElse: () => <int, String>{},
    );

    final arrivals =
        bookings.where((b) => isSameDay(b.checkIn, selectedDate)).toList();
    final departures =
        bookings.where((b) => isSameDay(b.checkOut, selectedDate)).toList();
    final inHouse = bookings
        .where((b) =>
            b.checkIn.isBefore(selectedDate) &&
            b.checkOut.isAfter(selectedDate))
        .toList();

    final readyRoomIDs = bookings
        .where((b1) => isSameDay(b1.checkIn, selectedDate))
        .where((b1) => !bookings.any(
              (b2) =>
                  b2.roomID == b1.roomID &&
                  b2 != b1 &&
                  isSameDay(b2.checkOut, selectedDate),
            ))
        .map((b) => b.roomID)
        .toSet();

    final toCleanRoomIDs = bookings
        .where((b1) => isSameDay(b1.checkOut, selectedDate))
        .expand((b1) => bookings.where((b2) =>
            b2.roomID == b1.roomID &&
            b2 != b1 &&
            isSameDay(b2.checkIn, selectedDate)))
        .map((b) => b.roomID)
        .toSet();

    List<Widget> rows;
    if (selectedView == 'Ready') {
      final rooms = readyRoomIDs
          .map((id) => roomMapping[id] ?? 'Room $id')
          .toList()
        ..sort();
      rows = [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: rooms.map((room) => Chip(label: Text(room))).toList(),
          ),
        )
      ];
    } else if (selectedView == 'ToClean') {
      final rooms = toCleanRoomIDs
          .map((id) => roomMapping[id] ?? 'Room $id')
          .toList()
        ..sort();
      rows = [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: rooms.map((room) => Chip(label: Text(room))).toList(),
          ),
        )
      ];
    } else {
      final filtered = selectedView == 'Departures'
          ? departures
          : selectedView == 'InHouse'
              ? inHouse
              : arrivals;
      rows = filtered
          .map((booking) =>
              _bookingRow(context, booking, roomMapping, paymentStatusMapping))
          .toList();
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DatePicker(selectedDate),
                  const SizedBox(height: 8),
                  BookingSummaryCards(
                    arrivals: arrivals.length,
                    inHouse: inHouse.length,
                    departures: departures.length,
                    onTap: (category) => ref
                        .read(selectedViewProvider.notifier)
                        .state = category,
                  ),
                  const SizedBox(height: 8),
                  StatusCards(
                    readyRoomIDs: readyRoomIDs,
                    toCleanRoomIDs: toCleanRoomIDs,
                    roomMapping: roomMapping,
                    selectedGroup: selectedView,
                    onTap: (group) =>
                        ref.read(selectedViewProvider.notifier).state = group!,
                  ),
                  const Divider(height: 24),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(rows),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _bookingRow(BuildContext context, BookingVM booking,
      Map<int, String> roomMapping, Map<int, String> paymentMapping) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '${booking.firstName} ${booking.lastName}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Room: ${roomMapping[booking.roomID] ?? 'N/A'}',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${booking.numberOfNights} night(s)',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                paymentMapping[booking.paymentStatusID] ?? 'Unknown',
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePicker extends ConsumerWidget {
  final DateTime selectedDate;
  const _DatePicker(this.selectedDate);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () {
            ref.read(selectedDateProvider.notifier).state =
                selectedDate.subtract(const Duration(days: 1));
          },
        ),
        Text(
          DateFormat('dd MMM yyyy').format(selectedDate),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () {
            ref.read(selectedDateProvider.notifier).state =
                selectedDate.add(const Duration(days: 1));
          },
        ),
      ],
    );
  }
}
