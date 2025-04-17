import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/res/booking.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingListVM extends StateNotifier<List<BookingVM>> {
  final BookingService bookingService;
  final int propertyId;
  final int year;
  final int month;
  BookingListVM(this.propertyId, this.year, this.month, this.bookingService)
      : super(const []) {
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final res = await bookingService.getAllBookings(propertyId, year, month);
    state = [...res.map((booking) => BookingVM(booking))];
  }

  Future<bool> addToBookings(Map<String, dynamic> booking) async {
    if (await bookingService.addBooking(booking)) {
      await fetchBookings();
      return true;
    }
    return false;
  }

  Future<bool> editBooking(
      int bookingId, Map<String, dynamic> updatedData) async {
    try {
      final success = await bookingService.editBooking(bookingId, updatedData);
      if (success) {
        await fetchBookings();
        return true;
      }
    } catch (e) {
      // Handle error, e.g., log it or update the state with an error message
    }
    return false;
  }

  Future<bool> deleteBooking(String bookingId) async {
    final success = await bookingService.deleteBooking(bookingId);
    if (success) {
      state = state.where((b) => b.booking.id != bookingId).toList();
    }
    return success;
  }
}

final selectedBookingIdProvider = StateProvider<int?>((ref) => null);

final bookingListVM =
    StateNotifierProvider<BookingListVM, List<BookingVM>>((ref) {
  final selectedProperty = ref.watch(selectedPropertyVM) ?? 0;
  final selectedMonth = ref.watch(selectedMonthVM);
  return BookingListVM(selectedProperty, selectedMonth.year,
      selectedMonth.month, BookingService());
});
