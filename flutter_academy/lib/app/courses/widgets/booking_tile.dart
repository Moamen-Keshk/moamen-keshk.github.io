import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';
import 'package:flutter_academy/main.dart';

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
    _isSelected = selectedId == int.parse(widget.booking.booking.id);

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
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Tooltip(
          message: _generateRatesTooltip(widget.booking),
          padding: const EdgeInsets.all(8),
          preferBelow: false,
          verticalOffset: 40,
          child: Draggable<BookingVM>(
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
              opacity: _isHovered ? 0.85 : 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required Color color, double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        height: 35,
        width: 93.9 * widget.tabSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "${widget.booking.firstName} ${widget.booking.lastName}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
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
