import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/views/edit_booking.view.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';

final DateFormat _format = DateFormat('EEE, dd MMMM');

class BookingDetailsBar extends ConsumerWidget {
  final List<BookingVM> bookings;
  final Map<int, String> roomMapping;
  final Map<int, int> roomsCategoryMapping;
  final Map<int, String> categoryMapping;
  final Map<int, String> paymentStatusMapping;

  const BookingDetailsBar({
    super.key,
    required this.bookings,
    required this.roomMapping,
    required this.roomsCategoryMapping,
    required this.categoryMapping,
    required this.paymentStatusMapping,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedBookingIdProvider);
    final booking = bookings.firstWhereOrNull(
      (b) => int.parse(b.booking.id) == selectedId,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 80,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: booking == null
          ? const Center(
              child: Text(
                'Select a booking to see details.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(
                              '${booking.firstName} ${booking.lastName}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${booking.numberOfNights} nights',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Room: ${roomMapping[booking.roomID] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '(${_format.format(booking.checkIn)}) to (${_format.format(booking.checkOut)})',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Adults: ${booking.numberOfAdults}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Children: ${booking.numberOfChildren}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              paymentStatusMapping[booking.paymentStatusID] ??
                                  '',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Category: ${categoryMapping[roomsCategoryMapping[booking.roomID]] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'created: ${_format.format(booking.bookingDate)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'price: ${booking.rate}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'note: ${booking.note ?? ''}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ])
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditBookingDialog(context, booking, ref);
                    },
                  )
                ],
              ),
            ),
    );
  }

  void _showEditBookingDialog(
      BuildContext context, BookingVM booking, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Booking'),
          content: EditBookingForm(
            booking: booking,
            onSubmit: (bookingData) {
              return ref.read(bookingListVM.notifier).editBooking(
                    int.parse(booking.id),
                    bookingData,
                  );
            },
            ref: ref,
          ),
        );
      },
    );
  }
}
