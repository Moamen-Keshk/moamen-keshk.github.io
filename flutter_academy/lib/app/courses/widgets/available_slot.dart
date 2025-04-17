import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/widgets/rate_input.widget.dart';
import 'package:flutter_academy/infrastructure/courses/model/room_rate.model.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_rate_list.vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/views/new_booking.view.dart';
import 'package:flutter_academy/app/courses/widgets/rate_badge.widget.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';

Map<int, int> roomsCategoryMapping = {};

class AvailableSlot extends StatelessWidget {
  final int tabDay;
  final String tabRoom;
  final WidgetRef ref;
  final DateTime date;
  final bool showRates;

  const AvailableSlot({
    super.key,
    required this.tabDay,
    required this.tabRoom,
    required this.ref,
    required this.date,
    this.showRates = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      onLongPress: () => _onLongPress(context),
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
                'check_in': DateTime(checkInYear, checkInMonth, tabDay)
                    .toIso8601String(),
                'check_out':
                    DateTime(checkInYear, checkInMonth, tabDay + numberOfNights)
                        .toIso8601String(),
                'check_in_day': tabDay,
                'check_out_day': tabDay + numberOfNights,
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
            final isHovered = candidateData.isNotEmpty;

            return SizedBox(
              height: 35,
              width: 93.9,
              child: Container(
                margin: const EdgeInsets.all(2),
                color: isHovered
                    ? Colors.green[200]
                    : showRates
                        ? Colors.transparent
                        : Colors.grey[200],
                child: showRates
                    ? RateBadgeWidget(roomId: tabRoom, date: date)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (showRates) {
      final roomRateVMs = ref.read(roomRateListVM);
      final existing = roomRateVMs.firstWhereOrNull(
        (vm) {
          final r = vm.roomRate;
          return r.roomId == tabRoom &&
              r.date.year == date.year &&
              r.date.month == date.month &&
              r.date.day == date.day;
        },
      );

      final editedPrice = await showDialog<double>(
        context: context,
        builder: (_) => RateInputDialog(
          initialPrice: existing?.roomRate.price,
          date: date,
        ),
      );

      if (editedPrice != null) {
        final propertyId = ref.read(selectedPropertyVM);
        if (propertyId == null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No property selected')),
          );
          return;
        }

        final categoryId = roomsCategoryMapping[int.parse(tabRoom)]?.toString();
        if (categoryId == null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room category not found')),
          );
          return;
        }

        final newRate = RoomRate(
          id: existing?.id ?? '',
          roomId: tabRoom,
          propertyId: propertyId!,
          date: date,
          price: editedPrice,
          categoryId: categoryId!, // ✅ Required
        );

        final success =
            await ref.read(roomRateListVM.notifier).upsertRoomRate(newRate);

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rate saved: \$${editedPrice.toStringAsFixed(2)}'),
            ),
          );
        }
      }
    } else {
      _showBookingDialog(context);
    }
  }

  void _onLongPress(BuildContext context) async {
    if (!showRates) return;

    final existing = ref.read(roomRateListVM).firstWhereOrNull(
      (vm) {
        final r = vm.roomRate;
        return r.roomId == tabRoom &&
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day;
      },
    );

    if (existing != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Rate Override'),
          content: Text(
            'Remove custom rate of \$${existing.roomRate.price.toStringAsFixed(2)} for ${DateFormat.yMMMd().format(date)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final deleted =
            await ref.read(roomRateListVM.notifier).deleteRoomRate(existing.id);

        if (deleted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Custom rate removed')),
          );
        }
      }
    }
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
