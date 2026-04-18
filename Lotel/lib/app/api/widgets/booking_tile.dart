import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/calendar_header.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/view_models/booking.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/main.dart';

class BookingTile extends ConsumerStatefulWidget {
  final int tabIndex;
  final TabController tabController;
  final int tabSize;
  final BookingVM booking;

  const BookingTile({
    super.key,
    required this.tabIndex,
    required this.tabController,
    required this.tabSize,
    required this.booking,
  });

  @override
  ConsumerState<BookingTile> createState() => _BookingTileState();
}

class _BookingTileState extends ConsumerState<BookingTile> {
  bool _isHovered = false;
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedBookingIdProvider);
    final canManageBookings =
        hasPmsPermission(ref, PmsPermission.manageBookings);
    final isCompact = context.showCompactLayout;
    _isSelected = selectedId == int.parse(widget.booking.booking.id);

    final tile = canManageBookings
        ? Draggable<BookingVM>(
            data: widget.booking,
            feedback: _buildTile(
              context,
              color: Colors.blue[300]!,
              opacity: 1.0,
            ),
            childWhenDragging: _buildTile(
              context,
              color: Colors.grey[300]!,
              opacity: 0.5,
            ),
            child: _buildTile(
              context,
              color: _isSelected
                  ? Colors.indigo[400]!
                  : widget.booking.booking.statusID == 2
                      ? Colors.brown[200]!
                      : widget.booking.booking.statusID == 1
                          ? Colors.blue[300]!
                          : widget.booking.paymentStatusID == 3
                              ? Colors.red[300]!
                              : Colors.blue[300]!,
              opacity: isCompact ? 1.0 : (_isHovered ? 0.85 : 1.0),
            ),
          )
        : _buildTile(
            context,
            color: _isSelected
                ? Colors.indigo[400]!
                : widget.booking.booking.statusID == 2
                    ? Colors.brown[200]!
                    : widget.booking.booking.statusID == 1
                        ? Colors.blue[300]!
                        : widget.booking.paymentStatusID == 3
                            ? Colors.red[300]!
                            : Colors.blue[300]!,
            opacity: isCompact ? 1.0 : (_isHovered ? 0.85 : 1.0),
          );

    final interactiveTile = isCompact
        ? tile
        : MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: Tooltip(
              message: _generateRatesTooltip(widget.booking),
              padding: const EdgeInsets.all(8),
              preferBelow: false,
              verticalOffset: 40,
              child: tile,
            ),
          );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        ref.read(selectedBookingIdProvider.notifier).state =
            int.parse(widget.booking.booking.id);
      },
      onDoubleTap: () {
        ref.read(selectedBookingIdProvider.notifier).state =
            int.parse(widget.booking.booking.id);
        ref.read(bookingIdProvider.notifier).state =
            int.parse(widget.booking.booking.id);
        ref.read(routerProvider).push('booking');
      },
      child: interactiveTile,
    );
  }

  Widget _buildTile(BuildContext context,
      {required Color color, double opacity = 1.0}) {
    final isCompact = context.showCompactLayout;
    // Check if there is a special request
    final hasSpecialRequest = widget.booking.booking.specialRequest != null &&
        widget.booking.booking.specialRequest!.trim().isNotEmpty;

    return Opacity(
      opacity: opacity,
      child: Container(
        height: isCompact ? 36 : 35,
        width: (isCompact
                ? CalendarHeader.compactDayColumnWidth
                : CalendarHeader.regularDayColumnWidth) *
            widget.tabSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      "${widget.booking.firstName} ${widget.booking.lastName}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isCompact ? 10 : 13,
                      ),
                      maxLines: isCompact ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasSpecialRequest)
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.star, // Or Icons.speaker_notes
                        color: Colors.amberAccent,
                        size: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateRatesTooltip(BookingVM booking) {
    if (booking.bookingRates.isEmpty) return "No rates available.";

    return booking.bookingRates
        .map((r) =>
            "${r.rateDate.year}-${r.rateDate.month.toString().padLeft(2, '0')}-${r.rateDate.day.toString().padLeft(2, '0')}: \$${r.nightlyRate.toStringAsFixed(2)}")
        .join("\n");
  }
}
