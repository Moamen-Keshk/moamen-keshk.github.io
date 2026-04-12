import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/view_models/booking.vm.dart';
import 'package:lotel_pms/app/api/views/edit_booking.view.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';

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
    final canManageBookings =
        hasPmsPermission(ref, PmsPermission.manageBookings);
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
              padding: const EdgeInsets.all(3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '${booking.firstName} ${booking.lastName}',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: _EllipsisTooltipText(
                          booking.email ?? 'N/A',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          booking.phone ?? 'N/A',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${booking.numberOfNights} nights',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Room: ${roomMapping[booking.roomID] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '(${_format.format(booking.checkIn)}) to (${_format.format(booking.checkOut)})',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          paymentStatusMapping[booking.paymentStatusID] ?? '',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Category: ${categoryMapping[roomsCategoryMapping[booking.roomID]] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'created: ${_format.format(booking.bookingDate)}',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Adults: ${booking.numberOfAdults}',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Children: ${booking.numberOfChildren}',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Price: ${booking.rate}',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _EllipsisTooltipText(
                          'Note: ${booking.note ?? ''}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      if (canManageBookings)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditBookingDialog(context, booking, ref);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _showEditBookingDialog(
    BuildContext context,
    BookingVM booking,
    WidgetRef ref,
  ) {
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

/// Single-line text with ellipsis.
/// Tooltip is shown ONLY if the text is actually truncated (overflowing).
class _EllipsisTooltipText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const _EllipsisTooltipText(
    this.text, {
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final value = text.trim();
    final message = value.isEmpty ? 'N/A' : value;

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveStyle = style ?? DefaultTextStyle.of(context).style;

        final span = TextSpan(
          text: message,
          style: effectiveStyle,
        );

        final painter = TextPainter(
          text: span,
          maxLines: 1,
          textDirection: Directionality.of(context),
          ellipsis: '…',
        );

        painter.layout(maxWidth: constraints.maxWidth);

        final isOverflowing = painter.didExceedMaxLines;

        final textWidget = Text(
          message,
          style: effectiveStyle,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        );

        if (!isOverflowing) return textWidget;

        return Tooltip(
          message: message,
          waitDuration: const Duration(milliseconds: 350),
          showDuration: const Duration(seconds: 6),
          child: textWidget,
        );
      },
    );
  }
}
