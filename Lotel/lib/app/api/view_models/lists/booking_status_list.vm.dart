import 'package:flutter_riverpod/legacy.dart';

import 'package:lotel_pms/app/api/view_models/booking_status.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/booking_status.service.dart';

class BookingStatusListVM extends StateNotifier<List<BookingStatusVM>> {
  BookingStatusListVM(this.bookingStatusService) : super(const []) {
    fetchBookingStatuses();
  }

  final BookingStatusService bookingStatusService;

  Future<void> fetchBookingStatuses() async {
    final res = await bookingStatusService.getAllBookingStatuses();
    state = [...res.map((status) => BookingStatusVM(status))];
  }

  Future<bool> addBookingStatus({
    required String name,
    required String code,
    String? color,
  }) async {
    if (await bookingStatusService.addBookingStatus(
      name: name,
      code: code,
      color: color,
    )) {
      await fetchBookingStatuses();
      return true;
    }
    return false;
  }

  Future<bool> editBookingStatus(
    String statusId, {
    required String name,
    required String code,
    String? color,
  }) async {
    final success = await bookingStatusService.editBookingStatus(
      statusId,
      {
        'name': name,
        'code': code,
        'color': color ?? '',
      },
    );

    if (success) {
      await fetchBookingStatuses();
      return true;
    }
    return false;
  }

  Future<bool> deleteBookingStatus(String statusId) async {
    final success = await bookingStatusService.deleteBookingStatus(statusId);
    if (success) {
      await fetchBookingStatuses();
      return true;
    }
    return false;
  }

  Future<Map<int, String>> bookingStatusMapping() async {
    final res = await bookingStatusService.getAllBookingStatuses();
    return {for (final status in res) status.id: status.name};
  }
}

final bookingStatusListVM =
    StateNotifierProvider<BookingStatusListVM, List<BookingStatusVM>>(
  (ref) => BookingStatusListVM(BookingStatusService()),
);
