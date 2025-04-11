import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/views/new_booking.view.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<int, int> roomsCategoryMapping = {};

class AvailableSlot extends StatelessWidget {
  final int tabDay;
  final String tabRoom;
  final WidgetRef ref;

  const AvailableSlot({
    super.key,
    required this.tabDay,
    required this.tabRoom,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBookingDialog(context),
      child: MouseRegion(
        onEnter: (_) {
          ref.read(highlightedDayVM.notifier).updateDay(tabDay);
          ref.read(highlightedRoomVM.notifier).updateRoom(int.parse(tabRoom));
        },
        onExit: (_) {
          ref.read(highlightedDayVM.notifier).updateDay(0);
          ref.read(highlightedRoomVM.notifier).updateRoom(0);
        },
        child: DragTarget<BookingVM>(
          onWillAcceptWithDetails: (details) {
            return roomsCategoryMapping[details.data.roomID] ==
                roomsCategoryMapping[int.parse(tabRoom)];
          },
          onAcceptWithDetails: (details) async {
            int numberOfNights = details.data.numberOfNights;
            int checkInYear = details.data.checkInYear;
            int checkInMonth = details.data.checkInMonth;

            if (await ref.read(bookingListVM.notifier).editBooking(
              int.parse(details.data.id),
              {
                'room_id': tabRoom,
                'chech_in': DateTime(checkInYear, checkInMonth, tabDay)
                    .toIso8601String(),
                'chech_out':
                    DateTime(checkInYear, checkInMonth, tabDay + numberOfNights)
                        .toIso8601String(),
                'check_in_day': tabDay,
                'check_out_day': tabDay + numberOfNights
              },
            )) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking edited successfully.')),
                );
              }
            }
          },
          builder: (context, candidateData, rejectedData) {
            return SizedBox(
              height: 35,
              width: 93.9,
              child: Container(
                color: candidateData.isNotEmpty
                    ? Colors.green[200]
                    : Colors.grey[200],
                margin: const EdgeInsets.all(2),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Booking'),
          content: BookingForm(
            tabDay: tabDay,
            tabRoom: tabRoom,
            onSubmit: (bookingData) async {
              return ref
                  .read(bookingListVM.notifier)
                  .addToBookings(bookingData);
            },
            ref: ref,
          ),
        );
      },
    );
  }
}
