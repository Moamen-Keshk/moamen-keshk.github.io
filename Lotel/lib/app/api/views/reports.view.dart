import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/booking.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_status_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/payment_status_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_list.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/booking.service.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';

typedef ReportsQuery = ({int propertyId, DateTime fromDate, DateTime toDate});

final reportsBookingsByRangeProvider = FutureProvider.autoDispose
    .family<List<BookingVM>, ReportsQuery>((ref, query) async {
  if (query.propertyId <= 0) {
    return const [];
  }

  final service = BookingService();
  final seenBookingIds = <String>{};
  final bookings = <BookingVM>[];

  for (final month in _monthsInRange(query.fromDate, query.toDate)) {
    final monthlyBookings = await service.getAllBookings(
      query.propertyId,
      month.year,
      month.month,
    );

    for (final booking in monthlyBookings) {
      if (seenBookingIds.add(booking.id)) {
        bookings.add(BookingVM(booking));
      }
    }
  }

  return bookings;
});

final reportsRoomMappingProvider = Provider<Map<int, String>>((ref) {
  final rooms = ref.watch(roomListVM);
  return {
    for (final room in rooms)
      if (int.tryParse(room.id) != null)
        int.parse(room.id): room.roomNumber.toString(),
  };
});

final reportsBookingStatusMappingProvider =
    FutureProvider<Map<int, String>>((ref) async {
  return ref.read(bookingStatusListVM.notifier).bookingStatusMapping();
});

final reportsPaymentStatusMappingProvider =
    FutureProvider<Map<int, String>>((ref) async {
  return ref.read(paymentStatusListVM.notifier).paymentStatusMapping();
});

class ReportsView extends ConsumerStatefulWidget {
  const ReportsView({super.key});

  @override
  ConsumerState<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends ConsumerState<ReportsView> {
  late DateTime _fromDate;
  late DateTime _toDate;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '£');

  @override
  void initState() {
    super.initState();
    _resetToCurrentMonth();
  }

  @override
  Widget build(BuildContext context) {
    final propertyId = ref.watch(selectedPropertyVM);
    final bookingsAsync = ref.watch(
      reportsBookingsByRangeProvider((
        propertyId: propertyId ?? 0,
        fromDate: _fromDate,
        toDate: _toDate,
      )),
    );
    final rooms = ref.watch(roomListVM);
    final roomMapping = ref.watch(reportsRoomMappingProvider);
    final bookingStatusMapping = ref
        .watch(
          reportsBookingStatusMappingProvider,
        )
        .maybeWhen(
          data: (value) => value,
          orElse: () => <int, String>{},
        );
    final paymentStatusMapping = ref
        .watch(
          reportsPaymentStatusMappingProvider,
        )
        .maybeWhen(
          data: (value) => value,
          orElse: () => <int, String>{},
        );

    if (propertyId == null || propertyId <= 0) {
      return const Center(
        child: Text('Select a property to view reports'),
      );
    }

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Failed to load reports: $error'),
      ),
      data: (bookings) {
        final report = _buildReport(
          bookings: bookings,
          roomCount: rooms.length,
          bookingStatusMapping: bookingStatusMapping,
          paymentStatusMapping: paymentStatusMapping,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Simple booking and revenue summary for the selected date range.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 20),
              _buildFilters(context),
              const SizedBox(height: 20),
              _buildMetricCards(context, report),
              const SizedBox(height: 20),
              _buildBreakdownSection(
                title: 'Booking Status Breakdown',
                items: report.bookingStatusBreakdown,
              ),
              const SizedBox(height: 20),
              _buildBreakdownSection(
                title: 'Payment Status Breakdown',
                items: report.paymentStatusBreakdown,
              ),
              const SizedBox(height: 20),
              _buildBookingsSection(
                report: report,
                roomMapping: roomMapping,
                bookingStatusMapping: bookingStatusMapping,
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetToCurrentMonth() {
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = DateTime(now.year, now.month + 1, 0);
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  _ReportData _buildReport({
    required List<BookingVM> bookings,
    required int roomCount,
    required Map<int, String> bookingStatusMapping,
    required Map<int, String> paymentStatusMapping,
  }) {
    final rangeStart = _startOfDay(_fromDate);
    final rangeEnd = _startOfDay(_toDate);
    final rangeEndExclusive = rangeEnd.add(const Duration(days: 1));
    final daysInRange = rangeEndExclusive.difference(rangeStart).inDays;

    int totalBookings = 0;
    int arrivals = 0;
    int departures = 0;
    int roomNights = 0;
    double revenue = 0;
    double balanceDue = 0;
    final bookingStatusBreakdown = <String, int>{};
    final paymentStatusBreakdown = <String, int>{};
    final matchingBookings = <BookingVM>[];

    for (final booking in bookings) {
      final overlapsRange = _bookingOverlapsRange(
        booking: booking,
        rangeStart: rangeStart,
        rangeEndExclusive: rangeEndExclusive,
      );

      if (!overlapsRange) {
        continue;
      }

      totalBookings += 1;
      matchingBookings.add(booking);

      if (_isInInclusiveRange(
          _startOfDay(booking.checkIn), rangeStart, rangeEnd)) {
        arrivals += 1;
      }

      if (_isInInclusiveRange(
        _startOfDay(booking.checkOut),
        rangeStart,
        rangeEnd,
      )) {
        departures += 1;
      }

      final overlapNights = _calculateOverlapNights(
        booking: booking,
        rangeStart: rangeStart,
        rangeEndExclusive: rangeEndExclusive,
      );
      roomNights += overlapNights;
      revenue += _calculateRevenueInRange(
        booking: booking,
        rangeStart: rangeStart,
        rangeEndExclusive: rangeEndExclusive,
        overlapNights: overlapNights,
      );
      balanceDue += booking.balanceDue;

      final bookingStatusName =
          bookingStatusMapping[booking.statusID] ?? 'Unknown';
      final paymentStatusName =
          paymentStatusMapping[booking.paymentStatusID] ?? 'Unknown';

      bookingStatusBreakdown.update(
        bookingStatusName,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      paymentStatusBreakdown.update(
        paymentStatusName,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    matchingBookings
        .sort((left, right) => right.checkIn.compareTo(left.checkIn));
    final occupancyRate = roomCount == 0 || daysInRange == 0
        ? 0.0
        : roomNights / (roomCount * daysInRange);

    return _ReportData(
      totalBookings: totalBookings,
      arrivals: arrivals,
      departures: departures,
      roomNights: roomNights,
      occupancyRate: occupancyRate,
      revenue: revenue,
      balanceDue: balanceDue,
      bookingStatusBreakdown: _sortBreakdown(bookingStatusBreakdown),
      paymentStatusBreakdown: _sortBreakdown(paymentStatusBreakdown),
      bookings: matchingBookings,
    );
  }

  bool _bookingOverlapsRange({
    required BookingVM booking,
    required DateTime rangeStart,
    required DateTime rangeEndExclusive,
  }) {
    final bookingStart = _startOfDay(booking.checkIn);
    final bookingEndExclusive = _startOfDay(booking.checkOut);

    return bookingStart.isBefore(rangeEndExclusive) &&
        bookingEndExclusive.isAfter(rangeStart);
  }

  bool _isInInclusiveRange(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  int _calculateOverlapNights({
    required BookingVM booking,
    required DateTime rangeStart,
    required DateTime rangeEndExclusive,
  }) {
    final overlapStart = _laterDate(_startOfDay(booking.checkIn), rangeStart);
    final overlapEnd =
        _earlierDate(_startOfDay(booking.checkOut), rangeEndExclusive);
    final nights = overlapEnd.difference(overlapStart).inDays;
    return nights > 0 ? nights : 0;
  }

  double _calculateRevenueInRange({
    required BookingVM booking,
    required DateTime rangeStart,
    required DateTime rangeEndExclusive,
    required int overlapNights,
  }) {
    if (booking.bookingRates.isNotEmpty) {
      double sum = 0;
      for (final rate in booking.bookingRates) {
        final rateDate = _startOfDay(rate.rateDate);
        if (!rateDate.isBefore(rangeStart) &&
            rateDate.isBefore(rangeEndExclusive)) {
          sum += rate.nightlyRate;
        }
      }
      return sum;
    }

    if (overlapNights <= 0) {
      return 0;
    }

    final averageNightlyRate = booking.numberOfNights > 0
        ? booking.rate / booking.numberOfNights
        : booking.rate;
    return averageNightlyRate * overlapNights;
  }

  Map<String, int> _sortBreakdown(Map<String, int> source) {
    final entries = source.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    return {for (final entry in entries) entry.key: entry.value};
  }

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _laterDate(DateTime left, DateTime right) {
    return left.isAfter(right) ? left : right;
  }

  DateTime _earlierDate(DateTime left, DateTime right) {
    return left.isBefore(right) ? left : right;
  }

  Widget _buildFilters(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 220,
              child: _buildDateField(
                context: context,
                label: 'From',
                value: _fromDate,
                onPicked: (date) {
                  setState(() {
                    _fromDate = date;
                    if (_toDate.isBefore(_fromDate)) {
                      _toDate = _fromDate;
                    }
                  });
                },
              ),
            ),
            SizedBox(
              width: 220,
              child: _buildDateField(
                context: context,
                label: 'To',
                value: _toDate,
                onPicked: (date) {
                  setState(() {
                    _toDate = date;
                    if (_toDate.isBefore(_fromDate)) {
                      _fromDate = _toDate;
                    }
                  });
                },
              ),
            ),
            OutlinedButton(
              onPressed: () => setState(_resetToCurrentMonth),
              child: const Text('Current Month'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onPicked,
  }) {
    return InkWell(
      onTap: () => _pickDate(
        context: context,
        initialDate: value,
        onPicked: onPicked,
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(_dateFormat.format(value)),
      ),
    );
  }

  Widget _buildMetricCards(BuildContext context, _ReportData report) {
    final isCompact = context.showCompactLayout;
    final metrics = [
      _MetricTileData('Bookings', report.totalBookings.toString(), Icons.book),
      _MetricTileData('Arrivals', report.arrivals.toString(), Icons.login),
      _MetricTileData('Departures', report.departures.toString(), Icons.logout),
      _MetricTileData('Room Nights', report.roomNights.toString(), Icons.hotel),
      _MetricTileData(
        'Occupancy',
        '${(report.occupancyRate * 100).toStringAsFixed(1)}%',
        Icons.pie_chart,
      ),
      _MetricTileData(
        'Revenue',
        _currencyFormat.format(report.revenue),
        Icons.payments_outlined,
      ),
      _MetricTileData(
        'Balance Due',
        _currencyFormat.format(report.balanceDue),
        Icons.account_balance_wallet_outlined,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: metrics
          .map(
            (metric) => SizedBox(
              width: isCompact ? 160 : 220,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(metric.icon, color: Colors.blueGrey),
                      const SizedBox(height: 12),
                      Text(
                        metric.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metric.label,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBreakdownSection({
    required String title,
    required Map<String, int> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text('No data for the selected range')
            else
              ...items.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(entry.key)),
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsSection({
    required _ReportData report,
    required Map<int, String> roomMapping,
    required Map<int, String> bookingStatusMapping,
  }) {
    final visibleBookings = report.bookings.take(20).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bookings in Range',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Showing ${visibleBookings.length} of ${report.bookings.length} bookings',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            if (visibleBookings.isEmpty)
              const Text('No bookings found for the selected range')
            else
              ...visibleBookings.map(
                (booking) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 720) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${booking.firstName} ${booking.lastName}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Room ${roomMapping[booking.roomID] ?? 'N/A'}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_dateFormat.format(booking.checkIn)} - ${_dateFormat.format(booking.checkOut)}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bookingStatusMapping[booking.statusID] ??
                                  'Unknown',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currencyFormat.format(booking.balanceDue),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${booking.firstName} ${booking.lastName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Room ${roomMapping[booking.roomID] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${_dateFormat.format(booking.checkIn)} - ${_dateFormat.format(booking.checkOut)}',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              bookingStatusMapping[booking.statusID] ??
                                  'Unknown',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              _currencyFormat.format(booking.balanceDue),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportData {
  const _ReportData({
    required this.totalBookings,
    required this.arrivals,
    required this.departures,
    required this.roomNights,
    required this.occupancyRate,
    required this.revenue,
    required this.balanceDue,
    required this.bookingStatusBreakdown,
    required this.paymentStatusBreakdown,
    required this.bookings,
  });

  final int totalBookings;
  final int arrivals;
  final int departures;
  final int roomNights;
  final double occupancyRate;
  final double revenue;
  final double balanceDue;
  final Map<String, int> bookingStatusBreakdown;
  final Map<String, int> paymentStatusBreakdown;
  final List<BookingVM> bookings;
}

class _MetricTileData {
  const _MetricTileData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

List<DateTime> _monthsInRange(DateTime fromDate, DateTime toDate) {
  final startMonth = DateTime(fromDate.year, fromDate.month);
  final endMonth = DateTime(toDate.year, toDate.month);
  final months = <DateTime>[];

  var current = startMonth;
  while (!current.isAfter(endMonth)) {
    months.add(current);
    current = DateTime(current.year, current.month + 1);
  }

  return months;
}
