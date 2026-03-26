import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/infrastructure/courses/res/booking.service.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/legacy.dart';

class BookingListVM extends StateNotifier<List<BookingVM>> {
  final BookingService bookingService;
  final int propertyId;
  final int year;
  final int month;

  BookingListVM(
    this.propertyId,
    this.year,
    this.month,
    this.bookingService, {
    bool autoFetch = true,
  }) : super(const []) {
    if (autoFetch) {
      fetchBookings();
    }
  }

  Future<void> fetchBookings() async {
    final res = await bookingService.getAllBookings(propertyId, year, month);
    state = [...res.map((booking) => BookingVM(booking))];
  }

  Future<void> fetchBookingsByDate(DateTime date, String bookingState) async {
    final res =
        await bookingService.getBookingsByDate(propertyId, date, bookingState);
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
    int bookingId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final success = await bookingService.editBooking(bookingId, updatedData);
      if (success) {
        await fetchBookings();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> deleteBooking(String bookingId) async {
    final success = await bookingService.deleteBooking(bookingId);
    if (success) {
      state = state.where((b) => b.booking.id != bookingId).toList();
    }
    return success;
  }

  Future<bool> checkInBooking(int bookingId) async {
    final success = await bookingService.checkInBooking(bookingId);
    if (success) {
      await fetchBookings();
    }
    return success;
  }

  Future<BookingVM?> getBookingById(String bookingId) async {
    final booking = await bookingService.getBookingById(bookingId);
    if (booking != null) {
      return BookingVM(booking);
    }
    return null;
  }
}

final selectedBookingIdProvider = StateProvider<int?>((ref) => null);

final bookingListVM =
    StateNotifierProvider<BookingListVM, List<BookingVM>>((ref) {
  final propertyId = ref.watch(selectedPropertyVM) ?? 0;
  final selectedMonth = ref.watch(selectedMonthVM);

  return BookingListVM(
    propertyId,
    selectedMonth.year,
    selectedMonth.month,
    BookingService(),
    autoFetch: true,
  );
});

final bookingListByDateVM = StateNotifierProvider.family<
    BookingListVM,
    List<BookingVM>,
    (int propertyId, DateTime date, String bookingState)>((ref, args) {
  final (propertyId, date, bookingState) = args;

  return BookingListVM(
    propertyId,
    date.year,
    date.month,
    BookingService(),
    autoFetch: false,
  )..fetchBookingsByDate(date, bookingState);
});

final bookingIdProvider = StateProvider<int?>((ref) => null);
