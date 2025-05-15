import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/payment_status_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_list.vm.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

class BookingSearchView extends ConsumerStatefulWidget {
  const BookingSearchView({super.key});

  @override
  ConsumerState<BookingSearchView> createState() => _BookingSearchViewState();
}

class _BookingSearchViewState extends ConsumerState<BookingSearchView> {
  final TextEditingController searchController = TextEditingController();
  DateTime? checkInFrom;
  DateTime? checkOutTo;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    checkInFrom = DateTime(today.year, today.month, today.day);
    checkOutTo = DateTime(today.year, today.month, today.day);
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(bookingListVM);
    final roomMapping = ref.watch(roomMappingProvider);
    final paymentStatus = ref.watch(paymentStatusMappingProvider).maybeWhen(
          data: (value) => Map<int, String>.from(value),
          orElse: () => <int, String>{},
        );

    final query = searchController.text.toLowerCase();
    final filtered = allBookings.where((b) {
      final matchesQuery = query.isEmpty ||
          b.firstName.toLowerCase().contains(query) ||
          b.lastName.toLowerCase().contains(query) ||
          '${b.firstName} ${b.lastName}'.toLowerCase().contains(query) ||
          b.email?.toLowerCase().contains(query) == true ||
          b.phone?.contains(query) == true ||
          b.confirmationNumber.toString().contains(query);

      final matchesCheckIn =
          checkInFrom == null || !b.checkIn.isBefore(checkInFrom!);
      final matchesCheckOut =
          checkOutTo == null || !b.checkOut.isAfter(checkOutTo!);

      return matchesQuery && matchesCheckIn && matchesCheckOut;
    }).toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Material(
            elevation: 4,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDatePicker(
                      label: 'Check-In After',
                      date: checkInFrom,
                      onPicked: (date) => setState(() => checkInFrom = date),
                      onClear: () => setState(() => checkInFrom = null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _buildDatePicker(
                      label: 'Check-Out Before',
                      date: checkOutTo,
                      onPicked: (date) => setState(() => checkOutTo = date),
                      onClear: () => setState(() => checkOutTo = null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Name, email, phone, or confirmation #',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No bookings found'))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final booking = filtered[index];
                      return InkWell(
                        onTap: () {
                          ref.read(bookingIdProvider.notifier).state =
                              int.parse(booking.id);
                          ref.read(routerProvider).push('booking');
                        },
                        child: _bookingRow(
                          context,
                          ref,
                          booking.propertyID,
                          booking,
                          roomMapping,
                          paymentStatus,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required Function(DateTime) onPicked,
    required VoidCallback onClear,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: date != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date != null ? DateFormat('dd MMM yyyy').format(date) : 'Select date',
        ),
      ),
    );
  }

  Widget _bookingRow(
    BuildContext context,
    WidgetRef ref,
    int propertyId,
    BookingVM booking,
    Map<int, String> roomMapping,
    Map<int, String> paymentMapping,
  ) {
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
