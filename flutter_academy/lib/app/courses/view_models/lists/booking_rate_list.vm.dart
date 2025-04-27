import 'package:flutter_academy/infrastructure/courses/model/booking_rate.model.dart';
import 'package:flutter_academy/infrastructure/courses/res/booking_rate.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingRateListVM extends StateNotifier<List<BookingRate>> {
  final BookingRateService bookingRateService;
  final int bookingId;

  BookingRateListVM(this.bookingId, this.bookingRateService) : super(const []) {
    fetchBookingRates();
  }

  Future<void> fetchBookingRates() async {
    final res = await bookingRateService.getBookingRates(bookingId);
    state = [...res];
  }

  Future<bool> addBookingRate(Map<String, dynamic> bookingRateData) async {
    if (await bookingRateService.addBookingRate(bookingRateData)) {
      await fetchBookingRates();
      return true;
    }
    return false;
  }

  Future<bool> deleteBookingRate(int rateId) async {
    final success = await bookingRateService.deleteBookingRate(rateId);
    if (success) {
      state = state.where((r) => r.id != rateId).toList();
    }
    return success;
  }
}

final bookingRateListVM =
    StateNotifierProvider.family<BookingRateListVM, List<BookingRate>, int>(
        (ref, bookingId) {
  return BookingRateListVM(
    bookingId,
    BookingRateService(),
  );
});
