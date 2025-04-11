import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';

class BookingTile extends StatefulWidget {
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
  State<BookingTile> createState() => _BookingTileState();
}

class _BookingTileState extends State<BookingTile> {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        widget.tabController.animateTo(widget.tabIndex);
        _focusNode.requestFocus();
      },
      child: Draggable<BookingVM>(
        data: widget.booking,
        feedback: _buildTile(context, Colors.blue[300]!, opacity: 1.0),
        childWhenDragging: _buildTile(context, Colors.grey[300]!, opacity: 0.5),
        child: Focus(
          focusNode: _focusNode,
          child: _buildTile(
            context,
            _isFocused
                ? Colors.brown[300]!
                : widget.booking.paymentStatusID == 1
                    ? Colors.blue[300]!
                    : Colors.red[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, Color color, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        height: 35,
        width: 93.9 * widget.tabSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            "${widget.booking.firstName} ${widget.booking.lastName}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
