import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';

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
  bool _showDelete = false;
  bool _showCheckIn = false;
  bool _isSelected = false;

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Booking"),
        content: const Text("Are you sure you want to delete this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(bookingListVM.notifier);
      final success = await notifier.deleteBooking(widget.booking.booking.id);
      ref.read(selectedBookingIdProvider.notifier).state = null;

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking deleted successfully."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleCheckIn(BuildContext context) async {
    final success = await ref
        .read(bookingListVM.notifier)
        .checkInBooking(int.parse(widget.booking.booking.id));
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Guest checked in successfully."),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedBookingIdProvider);
    _isSelected = selectedId == int.parse(widget.booking.booking.id);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          _showDelete = false;
          _showCheckIn = true;
          ref.read(selectedBookingIdProvider.notifier).state =
              int.parse(widget.booking.booking.id);
        });
      },
      onLongPress: () {
        setState(() {
          _showDelete = true;
          _showCheckIn = false;
          ref.read(selectedBookingIdProvider.notifier).state =
              int.parse(widget.booking.booking.id);
        });
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
              showDelete: false,
            ),
            childWhenDragging: _buildTile(
              context,
              color: Colors.grey[300]!,
              opacity: 0.5,
              showDelete: false,
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
              showDelete: _isSelected && _showDelete,
              opacity: _isHovered ? 0.85 : 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required Color color, double opacity = 1.0, bool showDelete = false}) {
    final booking = widget.booking.booking;
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
            if (showDelete)
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.white),
                padding: const EdgeInsets.only(right: 4),
                constraints: const BoxConstraints(),
                onPressed: () => _handleDelete(context),
              ),
            if (!showDelete &&
                _showCheckIn &&
                booking.statusID == 1 &&
                _isSelected)
              IconButton(
                icon: const Icon(Icons.login, size: 18, color: Colors.white),
                padding: const EdgeInsets.only(right: 4),
                constraints: const BoxConstraints(),
                onPressed: () => _handleCheckIn(context),
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
