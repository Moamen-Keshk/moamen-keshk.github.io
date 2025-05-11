import 'package:flutter_academy/infrastructure/courses/model/booking.model.dart';
import 'package:flutter_academy/infrastructure/courses/model/booking_rate.model.dart';

class BookingVM {
  final Booking booking;

  BookingVM(this.booking);

  String get id => booking.id;
  int get confirmationNumber => booking.confirmationNumber;
  String get firstName => booking.firstName;
  String get lastName => booking.lastName;
  int get numberOfAdults => booking.numberOfAdults;
  int get numberOfChildren => booking.numberOfChildren;
  int get paymentStatusID => booking.paymentStatusID;
  int get statusID => booking.statusID;
  String? get note => booking.note;
  String? get specialRequest => booking.specialRequest;
  DateTime get bookingDate => booking.bookingDate;
  DateTime get checkIn => booking.checkIn;
  DateTime get checkOut => booking.checkOut;
  int get checkInDay => booking.checkInDay;
  int get checkInMonth => booking.checkInMonth;
  int get checkInYear => booking.checkInYear;
  int get checkOutDay => booking.checkOutDay;
  int get checkOutMonth => booking.checkOutMonth;
  int get checkOutYear => booking.checkOutYear;
  int get numberOfNights => booking.numberOfNights;
  double get rate => booking.rate;
  int get propertyID => booking.propertyID;
  int get roomID => booking.roomID;
  List<BookingRate> get bookingRates => booking.bookingRates;
}
