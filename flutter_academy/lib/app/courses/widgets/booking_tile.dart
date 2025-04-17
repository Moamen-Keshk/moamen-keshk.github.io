import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';

final selectedBookingIdProvider = StateProvider<String?>((ref) => null);

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
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedBookingIdProvider);
    final isSelected = selectedId == widget.booking.booking.id;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        widget.tabController.animateTo(widget.tabIndex);
        _focusNode.requestFocus();
        ref.read(selectedBookingIdProvider.notifier).state =
            isSelected ? null : widget.booking.booking.id;
      },
      child: Draggable<BookingVM>(
        data: widget.booking,
        feedback: _buildTile(context,
            color: Colors.blue[300]!, opacity: 1.0, showDelete: false),
        childWhenDragging: _buildTile(context,
            color: Colors.grey[300]!, opacity: 0.5, showDelete: false),
        child: Focus(
          focusNode: _focusNode,
          child: _buildTile(
            context,
            color: _isFocused
                ? Colors.brown[300]!
                : widget.booking.paymentStatusID == 1
                    ? Colors.blue[300]!
                    : Colors.red[300]!,
            showDelete: isSelected,
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required Color color, double opacity = 1.0, bool showDelete = false}) {
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
          ],
        ),
      ),
    );
  }
}
