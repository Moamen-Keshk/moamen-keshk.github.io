import 'package:lotel_pms/infrastructure/api/model/booking_rate.model.dart';
import 'package:lotel_pms/infrastructure/api/res/booking_rate.service.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/legacy.dart';

class BookingRateListVM extends StateNotifier<List<BookingRate>> {
  final BookingRateService bookingRateService;
  final int propertyId;
  final int bookingId;

  BookingRateListVM(this.propertyId, this.bookingId, this.bookingRateService)
      : super(const []) {
    fetchBookingRates();
  }

  Future<void> fetchBookingRates() async {
    final res = await bookingRateService.getBookingRates(propertyId, bookingId);
    state = [...res];
  }

  Future<bool> addBookingRate(Map<String, dynamic> bookingRateData) async {
    if (await bookingRateService.addBookingRate(propertyId, bookingRateData)) {
      await fetchBookingRates();
      return true;
    }
    return false;
  }

  Future<bool> deleteBookingRate(int rateId) async {
    final success =
        await bookingRateService.deleteBookingRate(propertyId, rateId);
    if (success) {
      state = state.where((r) => r.id != rateId).toList();
    }
    return success;
  }
}

final bookingRateListVM =
    StateNotifierProvider.family<BookingRateListVM, List<BookingRate>, int>(
        (ref, bookingId) {
  final propertyId = ref.watch(selectedPropertyVM) ?? 0;
  return BookingRateListVM(
    propertyId,
    bookingId,
    BookingRateService(),
  );
});
