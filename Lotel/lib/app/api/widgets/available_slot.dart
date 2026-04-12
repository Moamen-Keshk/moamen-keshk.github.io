import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/views/new_booking.view.dart';
import 'package:lotel_pms/app/api/views/new_block.view.dart';
import 'package:lotel_pms/app/api/widgets/rate_badge.widget.dart';
import 'package:lotel_pms/app/api/view_models/booking.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/block_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_online_list.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Map<int, int> roomsCategoryMapping = {};

class AvailableSlot extends ConsumerWidget {
  final int tabDay;
  final String tabRoom;
  final DateTime date;
  final bool showRates;

  const AvailableSlot({
    super.key,
    required this.tabDay,
    required this.tabRoom,
    required this.date,
    this.showRates = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManageBookings =
        hasPmsPermission(ref, PmsPermission.manageBookings);
    final canManageRates = hasPmsPermission(ref, PmsPermission.manageRates);

    return GestureDetector(
      onTap: canManageBookings ? () => _onTap(context, ref) : null,
      onLongPress: (!showRates && canManageBookings) ||
              (showRates && canManageRates)
          ? () => _onLongPress(context, ref)
          : null,
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
            return canManageBookings &&
                roomsCategoryMapping[details.data.roomID] ==
                roomsCategoryMapping[int.parse(tabRoom)];
          },
          onAcceptWithDetails: (details) async {
            if (!canManageBookings) return;
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
            return SizedBox(
              height: 35,
              width: 93.9,
              child: Container(
                margin: const EdgeInsets.all(2),
                color: Colors.grey[200], // Static background color
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

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    if (showRates) return;
    _showBookingDialog(context, ref);
  }

  Future<void> _onLongPress(BuildContext context, WidgetRef ref) async {
    if (!showRates) {
      _showBlockDialog(context, ref);
      return;
    }

    final existing = ref.read(roomOnlineListVM).firstWhereOrNull(
          (vm) =>
              vm.roomOnline.roomId == tabRoom &&
              DateUtils.isSameDay(vm.roomOnline.date, date),
        );

    if (existing != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Rate Override'),
          content: Text(
            'Remove custom rate of \$${existing.roomOnline.price.toStringAsFixed(2)} for ${DateFormat.yMMMd().format(date)}?',
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
        final deleted = await ref
            .read(roomOnlineListVM.notifier)
            .deleteRoomOnline(existing.id);

        if (deleted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Custom rate removed')),
          );
        }
      }
    }
  }

  void _showBookingDialog(BuildContext context, WidgetRef ref) {
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

  void _showBlockDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Block'),
          content: BlockForm(
            tabDay: tabDay,
            tabRoom: tabRoom,
            onSubmit: (blockData) async {
              return ref.read(blockListVM.notifier).addToBlocks(blockData);
            },
            ref: ref,
          ),
        );
      },
    );
  }
}
