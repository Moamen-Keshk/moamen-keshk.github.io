import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
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
    final isCompact = context.showCompactLayout;
    final selectedId = ref.watch(selectedBookingIdProvider);
    final booking = bookings.firstWhereOrNull(
      (b) => int.parse(b.booking.id) == selectedId,
    );

    if (booking == null) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: isCompact ? null : 88,
      margin: EdgeInsets.only(right: isCompact ? 74 : 0),
      padding: EdgeInsets.all(isCompact ? 6 : 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 2 : 2),
        child: isCompact
            ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: _CompactStatusChip(
                                          icon: Icons.payments_outlined,
                                          label: paymentStatusMapping[
                                                  booking.paymentStatusID] ??
                                              'N/A',
                                        ),
                                      ),
                                      const Spacer(),
                                      _CompactStatusChip(
                                        icon: Icons.attach_money_outlined,
                                        label: '${booking.rate}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (canManageBookings)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: IconButton.filledTonal(
                                  visualDensity: VisualDensity.compact,
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFEAF2FF),
                                    foregroundColor: const Color(0xFF2D6CDF),
                                  ),
                                  onPressed: () {
                                    _showEditBookingDialog(context, booking, ref);
                                  },
                                  icon: const Icon(Icons.edit_outlined, size: 16),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _CompactInfoRow(
                                icon: Icons.email_outlined,
                                child: _EllipsisTooltipText(
                                  booking.email ?? 'N/A',
                                  style: const TextStyle(fontSize: 11.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _CompactInfoRow(
                                icon: Icons.phone_outlined,
                                child: Text(
                                  booking.phone ?? 'N/A',
                                  style: const TextStyle(fontSize: 11.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _CompactInfoRow(
                                icon: Icons.event_outlined,
                                child: Text(
                                  _format.format(booking.bookingDate),
                                  style: const TextStyle(fontSize: 11.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _CompactInfoRow(
                                icon: Icons.info_outline,
                                child: Text(
                                  booking.booking.statusID == 2
                                      ? 'Checked in'
                                      : booking.booking.statusID == 1
                                          ? 'Reserved'
                                          : booking.booking.statusID == 3
                                              ? 'Checked out'
                                              : booking.booking.statusID == 4
                                                  ? 'Cancelled'
                                                  : 'Unknown',
                                  style: const TextStyle(fontSize: 11.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
            : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              flex: 3,
                              child: _EllipsisTooltipText(
                                'Special request: ${booking.specialRequest?.trim().isNotEmpty == true ? booking.specialRequest!.trim() : 'N/A'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            if (canManageBookings)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: IconButton.filledTonal(
                                  visualDensity: VisualDensity.compact,
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFEAF2FF),
                                    foregroundColor: const Color(0xFF2D6CDF),
                                  ),
                                  onPressed: () {
                                    _showEditBookingDialog(context, booking, ref);
                                  },
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                ),
                              ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                paymentStatusMapping[booking.paymentStatusID] ??
                                    '',
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
                            if (canManageBookings) const SizedBox(width: 56),
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
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.showCompactLayout ? 320 : 560,
            ),
            child: EditBookingForm(
              booking: booking,
              onSubmit: (bookingData) {
                return ref.read(bookingListVM.notifier).editBooking(
                      int.parse(booking.id),
                      bookingData,
                    );
              },
              ref: ref,
            ),
          ),
        );
      },
    );
  }
}

class _CompactInfoRow extends StatelessWidget {
  final IconData icon;
  final Widget child;

  const _CompactInfoRow({
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Expanded(child: child),
      ],
    );
  }
}

class _CompactStatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CompactStatusChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2D6CDF)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label.trim().isEmpty ? 'N/A' : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF244B9A),
              ),
            ),
          ),
        ],
      ),
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
