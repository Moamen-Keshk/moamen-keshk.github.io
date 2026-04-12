import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/view_models/booking.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/payment_status_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_list.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/res/booking.service.dart';
import 'package:lotel_pms/main.dart';
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

final bookingSearchListProvider =
    FutureProvider.autoDispose<List<BookingVM>>((ref) async {
  final propertyId = ref.watch(selectedPropertyVM);
  if (propertyId == null || propertyId <= 0) {
    return const [];
  }

  final bookings = await BookingService().getBookingsForProperty(propertyId);
  return bookings.map((booking) => BookingVM(booking)).toList();
});

class BookingSearchView extends ConsumerStatefulWidget {
  const BookingSearchView({super.key});

  @override
  ConsumerState<BookingSearchView> createState() => _BookingSearchViewState();
}

class _BookingSearchViewState extends ConsumerState<BookingSearchView> {
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;
  String _query = '';
  DateTime? checkInFrom;
  DateTime? checkOutTo;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPropertyId = ref.watch(selectedPropertyVM);
    final allBookingsAsync = ref.watch(bookingSearchListProvider);
    final roomMapping = ref.watch(roomMappingProvider);
    final paymentStatus = ref.watch(paymentStatusMappingProvider).maybeWhen(
          data: (value) => Map<int, String>.from(value),
          orElse: () => <int, String>{},
        );

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
                      onChanged: _handleSearchChanged,
                      decoration: const InputDecoration(
                        hintText:
                            'Name, email, phone, room, invoice, or confirmation #',
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
            child: selectedPropertyId == null || selectedPropertyId <= 0
                ? const Center(child: Text('Select a property to search bookings'))
                : allBookingsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) =>
                        Center(child: Text('Failed to load bookings: $error')),
                    data: (allBookings) {
                      final filtered = _filterBookings(
                        allBookings,
                        roomMapping,
                        paymentStatus,
                      );

                      if (filtered.isEmpty) {
                        return const Center(child: Text('No bookings found'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final booking = filtered[index];
                          return _bookingRow(
                            context,
                            ref,
                            booking.propertyID,
                            booking,
                            roomMapping,
                            paymentStatus,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _query = value.trim().toLowerCase();
      });
    });
  }

  List<BookingVM> _filterBookings(
    List<BookingVM> bookings,
    Map<int, String> roomMapping,
    Map<int, String> paymentMapping,
  ) {
    final filtered = bookings.where((booking) {
      final matchesQuery = _query.isEmpty || _matchesQuery(
        booking,
        roomMapping,
        paymentMapping,
      );
      final matchesCheckIn = checkInFrom == null ||
          !_startOfDay(booking.checkIn).isBefore(_startOfDay(checkInFrom!));
      final matchesCheckOut = checkOutTo == null ||
          !_startOfDay(booking.checkOut).isAfter(_startOfDay(checkOutTo!));

      return matchesQuery && matchesCheckIn && matchesCheckOut;
    }).toList();

    filtered.sort((left, right) => right.checkIn.compareTo(left.checkIn));
    return filtered;
  }

  bool _matchesQuery(
    BookingVM booking,
    Map<int, String> roomMapping,
    Map<int, String> paymentMapping,
  ) {
    final roomNumber = roomMapping[booking.roomID] ?? '';
    final searchableFields = <String>[
      booking.id,
      booking.firstName,
      booking.lastName,
      '${booking.firstName} ${booking.lastName}',
      booking.email ?? '',
      booking.phone ?? '',
      booking.confirmationNumber.toString(),
      roomNumber,
      booking.invoiceNumber ?? '',
      booking.invoiceStatus ?? '',
      paymentMapping[booking.paymentStatusID] ?? '',
      booking.note ?? '',
      booking.specialRequest ?? '',
    ];

    return searchableFields
        .map((field) => field.toLowerCase())
        .any((field) => field.contains(_query));
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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
      // clipBehavior is needed so the InkWell ripple doesn't overflow the rounded corners
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Moved the onTap inside the Card's InkWell to make the whole card a proper button
        onTap: () {
          ref.read(bookingIdProvider.notifier).state = int.parse(booking.id);
          ref.read(routerProvider).push('booking');
        },
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
              const SizedBox(width: 8),
              // Added an arrow icon to clearly indicate it's a clickable link
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
