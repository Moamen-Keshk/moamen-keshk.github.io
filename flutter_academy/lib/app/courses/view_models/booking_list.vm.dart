import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/res/booking.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingListVM extends StateNotifier<List<BookingVM>> {
  final int propertyId;
  final int year;
  final int month;
  BookingListVM(this.propertyId, this.year, this.month) : super(const []) {
    fetchBookings();
  }
  Future<void> fetchBookings() async {
    final res = await BookingService().getAllBookings(propertyId, year, month);
    state = [...res.map((booking) => BookingVM(booking))];
  }

  Future<bool> addToBookings(Map<String, dynamic> booking) async {
    if (await BookingService().addBooking(booking)) {
      await fetchBookings();
      return true;
    }
    return false;
  }
}

final bookingListVM = StateNotifierProvider<BookingListVM, List<BookingVM>>(
    (ref) => BookingListVM(ref.watch(selectedPropertyVM),
        ref.watch(selectedMonthVM).year, ref.watch(selectedMonthVM).month));
