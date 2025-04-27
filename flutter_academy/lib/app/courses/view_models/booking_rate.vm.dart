import 'package:flutter_academy/infrastructure/courses/model/booking_rate.model.dart';

class BookingRateVM {
  final BookingRate bookingRate;
  BookingRateVM(this.bookingRate);

  int get id => bookingRate.id;
  int get bookingId => bookingRate.id;
  DateTime get date => bookingRate.rateDate;
  double get nightlyRate => bookingRate.nightlyRate;
}
