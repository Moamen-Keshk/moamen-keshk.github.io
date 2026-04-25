import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/booking_status.vm.dart';
import 'package:lotel_pms/app/api/widgets/calendar_header.dart';
import 'package:lotel_pms/app/api/view_models/booking.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_status_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/payment_status_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/payment_status.vm.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
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
    final bookingStatuses = ref.watch(bookingStatusListVM);
    final paymentStatuses = ref.watch(paymentStatusListVM);
    final isCompact = context.showCompactLayout;
    final statusColor =
        _resolveStatusColor(widget.booking.statusID, bookingStatuses);
    _isSelected = selectedId == int.parse(widget.booking.booking.id);

    final tile = canManageBookings
        ? Draggable<BookingVM>(
            data: widget.booking,
            feedback: _buildTile(
              context,
              color: statusColor,
              bookingStatuses: bookingStatuses,
              paymentStatuses: paymentStatuses,
              opacity: 1.0,
            ),
            childWhenDragging: _buildTile(
              context,
              color: statusColor.withValues(alpha: 0.35),
              bookingStatuses: bookingStatuses,
              paymentStatuses: paymentStatuses,
              opacity: 0.5,
            ),
            child: _buildTile(
              context,
              color: statusColor,
              bookingStatuses: bookingStatuses,
              paymentStatuses: paymentStatuses,
              opacity: isCompact ? 1.0 : (_isHovered ? 0.85 : 1.0),
            ),
          )
        : _buildTile(
            context,
            color: statusColor,
            bookingStatuses: bookingStatuses,
            paymentStatuses: paymentStatuses,
            opacity: isCompact ? 1.0 : (_isHovered ? 0.85 : 1.0),
          );

    final interactiveTile = isCompact
        ? tile
        : MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: tile,
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
      {required Color color,
      required List<BookingStatusVM> bookingStatuses,
      required List<PaymentStatusVM> paymentStatuses,
      double opacity = 1.0}) {
    final isCompact = context.showCompactLayout;
    final hasSpecialRequest = widget.booking.booking.specialRequest != null &&
        widget.booking.booking.specialRequest!.trim().isNotEmpty;
    final needsPaymentAttention = _needsPaymentAttention(paymentStatuses);
    final paymentBadgeColor = _isOverdue(paymentStatuses)
        ? const Color(0xFFB3261E)
        : const Color(0xFFE29A2D);
    final foregroundColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : const Color(0xFF1F2933);
    final tooltip = _buildTooltip();

    return Opacity(
      opacity: opacity,
      child: Tooltip(
        message: tooltip,
        child: Container(
          height: isCompact ? 36 : 35,
          width: (isCompact
                  ? CalendarHeader.compactDayColumnWidth
                  : CalendarHeader.regularDayColumnWidth) *
              widget.tabSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
            border: _isSelected
                ? Border.all(color: Colors.white, width: isCompact ? 1.5 : 2)
                : null,
            boxShadow: [
              if (_isSelected || _isHovered)
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: _isSelected ? 0.22 : 0.12),
                  blurRadius: _isSelected ? 12 : 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "${widget.booking.firstName} ${widget.booking.lastName}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: foregroundColor,
                            fontSize: isCompact ? 10 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: isCompact ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasSpecialRequest)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.star,
                            color: Colors.amberAccent,
                            size: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (needsPaymentAttention)
                Positioned(
                  top: isCompact ? 3 : 4,
                  right: isCompact ? 3 : 4,
                  child: _buildStatusBadge(
                    backgroundColor: paymentBadgeColor,
                    icon: Icons.payments_rounded,
                    size: isCompact ? 15 : 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required Color backgroundColor,
    required IconData icon,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
      ),
      child: Icon(icon, size: size * 0.65, color: Colors.white),
    );
  }

  String _buildTooltip() {
    return _generateRatesTooltip(widget.booking);
  }

  Color _resolveStatusColor(int statusId, List<BookingStatusVM> statuses) {
    final status = _findStatus(statusId, statuses);
    final parsed = _parseStatusColor(status?.color);
    if (parsed != null) {
      return parsed;
    }

    final label = '${status?.code ?? ''} ${status?.name ?? ''}'.toLowerCase();
    if (label.contains('cancel') || label.contains('no_show')) {
      return const Color(0xFFD64545);
    }
    if (label.contains('checked_in') ||
        label.contains('checked in') ||
        label.contains('in_house') ||
        label.contains('in house')) {
      return const Color(0xFF2F8F6B);
    }
    if (label.contains('checked_out') ||
        label.contains('checked out') ||
        label.contains('depart')) {
      return const Color(0xFF6B7280);
    }
    if (label.contains('pending') || label.contains('tentative')) {
      return const Color(0xFFE29A2D);
    }
    if (label.contains('confirmed') ||
        label.contains('reserve') ||
        label.contains('booked')) {
      return const Color(0xFF2F6CAD);
    }

    switch (statusId) {
      case 1:
        return const Color(0xFF2F6CAD);
      case 2:
        return const Color(0xFF2F8F6B);
      case 3:
        return const Color(0xFFD64545);
      default:
        return const Color(0xFF4F6D7A);
    }
  }

  BookingStatusVM? _findStatus(int statusId, List<BookingStatusVM> statuses) {
    for (final status in statuses) {
      if (status.id == statusId) {
        return status;
      }
    }
    return null;
  }

  Color? _parseStatusColor(String? rawColor) {
    if (rawColor == null) {
      return null;
    }

    final normalized = rawColor.trim().replaceFirst('#', '');
    if (normalized.length != 6 && normalized.length != 8) {
      return null;
    }

    try {
      final value = int.parse(
        normalized.length == 6 ? 'FF$normalized' : normalized,
        radix: 16,
      );
      return Color(value);
    } on FormatException {
      return null;
    }
  }

  bool _needsPaymentAttention(List<PaymentStatusVM> paymentStatuses) {
    if (widget.booking.balanceDue > 0.009) {
      return true;
    }

    final paymentStatus = _findPaymentStatus(paymentStatuses);
    if (paymentStatus == null) {
      return false;
    }

    final label =
        '${paymentStatus.code} ${paymentStatus.name}'.toLowerCase().trim();
    return label.contains('unpaid') ||
        label.contains('pending') ||
        label.contains('partial') ||
        label.contains('overdue') ||
        label.contains('past due') ||
        label.contains('past_due');
  }

  bool _isOverdue(List<PaymentStatusVM> paymentStatuses) {
    final paymentStatus = _findPaymentStatus(paymentStatuses);
    if (paymentStatus == null) {
      return false;
    }

    final label =
        '${paymentStatus.code} ${paymentStatus.name}'.toLowerCase().trim();
    return label.contains('overdue') ||
        label.contains('past due') ||
        label.contains('past_due');
  }

  PaymentStatusVM? _findPaymentStatus(List<PaymentStatusVM> paymentStatuses) {
    final paymentStatusId = widget.booking.paymentStatusID.toString();
    for (final status in paymentStatuses) {
      if (status.id == paymentStatusId) {
        return status;
      }
    }
    return null;
  }

  String _generateRatesTooltip(BookingVM booking) {
    if (booking.bookingRates.isEmpty) return '';

    return booking.bookingRates
        .map((r) =>
            "${r.rateDate.year}-${r.rateDate.month.toString().padLeft(2, '0')}-${r.rateDate.day.toString().padLeft(2, '0')}: \$${r.nightlyRate.toStringAsFixed(2)}")
        .join("\n");
  }
}
