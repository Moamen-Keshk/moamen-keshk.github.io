import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/views/new_booking.view.dart';
import 'package:lotel_pms/app/api/views/new_block.view.dart';
import 'package:lotel_pms/app/api/widgets/calendar_header.dart';
import 'package:lotel_pms/app/api/widgets/rate_badge.widget.dart';
import 'package:lotel_pms/app/api/view_models/booking.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/block_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_online_list.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AvailableSlot extends ConsumerWidget {
  final int tabDay;
  final String tabRoom;
  final DateTime date;
  final bool showRates;
  final String categoryId;

  const AvailableSlot({
    super.key,
    required this.tabDay,
    required this.tabRoom,
    required this.date,
    required this.categoryId,
    this.showRates = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManageBookings =
        hasPmsPermission(ref, PmsPermission.manageBookings);
    final canManageRates = hasPmsPermission(ref, PmsPermission.manageRates);
    final isCompact = context.showCompactLayout;
    final slot = DragTarget<BookingVM>(
      onWillAcceptWithDetails: (details) {
        return canManageBookings &&
            details.data.roomID != int.tryParse(tabRoom);
      },
      onAcceptWithDetails: (details) async {
        if (!canManageBookings) return;
        int numberOfNights = details.data.numberOfNights;
        final checkInDate = DateTime(date.year, date.month, date.day);
        final checkOutDate = checkInDate.add(Duration(days: numberOfNights));

        if (await ref.read(bookingListVM.notifier).editBooking(
          int.parse(details.data.id),
          {
            'room_id': tabRoom,
            'check_in': checkInDate.toIso8601String(),
            'check_out': checkOutDate.toIso8601String(),
            'check_in_day': checkInDate.day,
            'check_in_month': checkInDate.month,
            'check_in_year': checkInDate.year,
            'check_out_day': checkOutDate.day,
            'check_out_month': checkOutDate.month,
            'check_out_year': checkOutDate.year,
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
          height: isCompact ? 36 : 35,
          width: isCompact
              ? CalendarHeader.compactDayColumnWidth
              : CalendarHeader.regularDayColumnWidth,
          child: Container(
            margin: EdgeInsets.all(isCompact ? 1.5 : 2),
            color: Colors.grey[200],
            child: showRates
                ? RateBadgeWidget(
                    roomId: tabRoom,
                    date: date,
                    categoryId: categoryId,
                  )
                : null,
          ),
        );
      },
    );

    return GestureDetector(
      onTap:
          !showRates && canManageBookings ? () => _onTap(context, ref) : null,
      onLongPress:
          (!showRates && canManageBookings) || (showRates && canManageRates)
              ? () => _onLongPress(context, ref)
              : null,
      child: isCompact
          ? slot
          : MouseRegion(
              onEnter: (_) {
                ref.read(highlightedDayVM.notifier).updateDay(tabDay);
                ref
                    .read(highlightedRoomVM.notifier)
                    .updateRoom(int.parse(tabRoom));
              },
              onExit: (_) {
                ref.read(highlightedDayVM.notifier).updateDay(0);
                ref.read(highlightedRoomVM.notifier).updateRoom(0);
              },
              child: slot,
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

    final existing =
        ref.read(roomOnlineIndexProvider)[roomOnlineCellKey(tabRoom, date)];

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
        } else if (!deleted && context.mounted) {
          final error = ref.read(roomOnlineListVM).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? 'Failed to remove custom rate.')),
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
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.showCompactLayout ? 320 : 720,
            ),
            child: BookingForm(
              tabDay: tabDay,
              tabRoom: tabRoom,
              onSubmit: (bookingData) async {
                return ref
                    .read(bookingListVM.notifier)
                    .addToBookings(bookingData);
              },
              ref: ref,
            ),
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
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.showCompactLayout ? 320 : 560,
            ),
            child: BlockForm(
              tabDay: tabDay,
              tabRoom: tabRoom,
              onSubmit: (blockData) async {
                return ref.read(blockListVM.notifier).addToBlocks(blockData);
              },
              ref: ref,
            ),
          ),
        );
      },
    );
  }
}
