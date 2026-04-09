import 'package:flutter/material.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import 'package:lotel_pms/app/api/utilities/booking_summary_card.utils.dart';
import 'package:lotel_pms/app/api/view_models/booking.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/payment_status_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_list.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';

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
    final currentDate = _dateOnly(selectedDate);
    final selectedView = ref.watch(selectedViewProvider);
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;

    // Fetch the raw lists from the VM
    final rawArrivals = ref.watch(
      bookingListByDateVM((propertyId, currentDate, 'Arrivals')),
    );

    final rawInHouse = ref.watch(
      bookingListByDateVM((propertyId, currentDate, 'InHouse')),
    );

    final rawDepartures = ref.watch(
      bookingListByDateVM((propertyId, currentDate, 'Departures')),
    );

    // Arrivals should ONLY be Status 1 (Confirmed/Pending Check-in)
    final arrivals = rawArrivals.where((b) => b.statusID == 1).toList();

    // InHouse should ONLY be Status 2 (Checked-In)
    // We combine the rawInHouse list and any rawArrivals that might have been checked in today
    final inHouseMap = <String, BookingVM>{};
    for (var b in [...rawInHouse, ...rawArrivals]) {
      if (b.statusID == 2) {
        inHouseMap[b.id] = b; // Use map to safely deduplicate by ID
      }
    }
    final inHouse = inHouseMap.values.toList();

    // 👉 NEW: Departures should ONLY show bookings that have not yet checked out.
    // Status 1 (Confirmed - for same day check-in/out) and Status 2 (Checked-In).
    // Once they check out (Status 3), they are removed from this list.
    final departures =
        rawDepartures.where((b) => b.statusID == 1 || b.statusID == 2).toList();

    final roomMapping = ref.watch(roomMappingProvider);
    final paymentStatusAsync = ref.watch(paymentStatusMappingProvider);
    final paymentStatusMapping = paymentStatusAsync.maybeWhen(
      data: (value) => Map<int, String>.from(value),
      orElse: () => <int, String>{},
    );

    // Keep only the selected list based on the chosen view
    final filtered = selectedView == 'Departures'
        ? departures
        : selectedView == 'InHouse'
            ? inHouse
            : arrivals;

    final List<Widget> rows = filtered
        .map(
          (booking) => _bookingRow(
            context,
            ref,
            booking,
            roomMapping,
            paymentStatusMapping,
          ),
        )
        .toList();

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
                    arrivals: arrivals.length, // Uses the filtered length
                    inHouse: inHouse.length, // Uses the filtered length
                    departures: departures.length, // Uses the filtered length
                    onTap: (category) {
                      ref.read(selectedViewProvider.notifier).state = category;
                    },
                  ),
                  const SizedBox(height: 16),
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

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Widget _bookingRow(
    BuildContext context,
    WidgetRef ref,
    BookingVM booking,
    Map<int, String> roomMapping,
    Map<int, String> paymentMapping,
  ) {
    return InkWell(
      onTap: () {
        ref.read(bookingIdProvider.notifier).state = int.parse(booking.id);
        ref.read(routerProvider).push('booking');
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '${booking.firstName} ${booking.lastName}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (booking.booking.specialRequest != null &&
                        booking.booking.specialRequest!.trim().isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Icon(
                          Icons.star, // Or Icons.speaker_notes
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                  ],
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
