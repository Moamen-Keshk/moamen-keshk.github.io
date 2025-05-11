import 'dart:convert';
import 'package:flutter_academy/infrastructure/courses/model/booking_rate.model.dart';
import 'package:intl/intl.dart';

DateFormat format = DateFormat("EEE, dd MMM yyyy HH:mm:ss z");

class Booking {
  final String id;
  final int confirmationNumber;
  final String firstName;
  final String lastName;
  final int numberOfAdults;
  final int numberOfChildren;
  final int paymentStatusID;
  final int statusID;
  final String? note;
  final String? specialRequest;
  final DateTime bookingDate;
  final DateTime checkIn;
  final DateTime checkOut;
  final int checkInDay;
  final int checkInMonth;
  final int checkInYear;
  final int checkOutDay;
  final int checkOutMonth;
  final int checkOutYear;
  final int numberOfNights;
  final double rate;
  final int propertyID;
  final int roomID;
  final List<BookingRate> bookingRates;

  Booking({
    required this.id,
    required this.confirmationNumber,
    required this.firstName,
    required this.lastName,
    required this.numberOfAdults,
    required this.numberOfChildren,
    required this.paymentStatusID,
    required this.statusID, // ✅ added to constructor
    this.note,
    this.specialRequest,
    required this.bookingDate,
    required this.checkIn,
    required this.checkOut,
    required this.checkInDay,
    required this.checkInMonth,
    required this.checkInYear,
    required this.checkOutDay,
    required this.checkOutMonth,
    required this.checkOutYear,
    required this.numberOfNights,
    required this.rate,
    required this.propertyID,
    required this.roomID,
    required this.bookingRates,
  });

  Booking copyWith({
    String? id,
    int? confirmationNumber,
    String? firstName,
    String? lastName,
    int? numberOfAdults,
    int? numberOfChildren,
    int? paymentStatusID,
    int? statusID,
    String? note,
    String? specialRequest,
    DateTime? bookingDate,
    DateTime? checkIn,
    DateTime? checkOut,
    int? checkInDay,
    int? checkInMonth,
    int? checkInYear,
    int? checkOutDay,
    int? checkOutMonth,
    int? checkOutYear,
    int? numberOfNights,
    double? rate,
    int? propertyID,
    int? roomID,
    List<BookingRate>? bookingRates,
  }) {
    return Booking(
      id: id ?? this.id,
      confirmationNumber: confirmationNumber ?? this.confirmationNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      numberOfAdults: numberOfAdults ?? this.numberOfAdults,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      paymentStatusID: paymentStatusID ?? this.paymentStatusID,
      statusID: statusID ?? this.statusID,
      note: note ?? this.note,
      specialRequest: specialRequest ?? this.specialRequest,
      bookingDate: bookingDate ?? this.bookingDate,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      checkInDay: checkInDay ?? this.checkInDay,
      checkInMonth: checkInMonth ?? this.checkInMonth,
      checkInYear: checkInYear ?? this.checkInYear,
      checkOutDay: checkOutDay ?? this.checkOutDay,
      checkOutMonth: checkOutMonth ?? this.checkOutMonth,
      checkOutYear: checkOutYear ?? this.checkOutYear,
      numberOfNights: numberOfNights ?? this.numberOfNights,
      rate: rate ?? this.rate,
      propertyID: propertyID ?? this.propertyID,
      roomID: roomID ?? this.roomID,
      bookingRates: bookingRates ?? this.bookingRates,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'confirmation_number': confirmationNumber,
      'first_name': firstName,
      'last_name': lastName,
      'number_of_adults': numberOfAdults,
      'number_of_children': numberOfChildren,
      'payment_status_id': paymentStatusID,
      'status_id': statusID, // ✅ include in map
      'note': note,
      'special_request': specialRequest,
      'booking_date': bookingDate.toIso8601String(),
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'check_in_day': checkInDay,
      'check_in_month': checkInMonth,
      'check_in_year': checkInYear,
      'check_out_day': checkOutDay,
      'check_out_month': checkOutMonth,
      'check_out_year': checkOutYear,
      'number_of_days': numberOfNights,
      'rate': rate,
      'property_id': propertyID,
      'room_id': roomID,
      'booking_rates': bookingRates.map((r) => r.toMap()).toList(),
    };
  }

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    DateTime safeParseDate(String input) {
      try {
        return DateTime.parse(input);
      } catch (_) {
        return format.parse(input);
      }
    }

    return Booking(
      id: id,
      confirmationNumber: map['confirmation_number'] ?? 0,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      numberOfAdults: map['number_of_adults'] ?? 0,
      numberOfChildren: map['number_of_children'] ?? 0,
      paymentStatusID: map['payment_status_id'] ?? 0,
      statusID: map['status_id'] ?? 0, // ✅ parse from backend
      note: map['note'] ?? '',
      specialRequest: map['special_request'] ?? '',
      bookingDate: safeParseDate(map['booking_date']),
      checkIn: safeParseDate(map['check_in']),
      checkOut: safeParseDate(map['check_out']),
      checkInDay: map['check_in_day'] ?? 0,
      checkInMonth: map['check_in_month'] ?? 0,
      checkInYear: map['check_in_year'] ?? 0,
      checkOutDay: map['check_out_day'] ?? 0,
      checkOutMonth: map['check_out_month'] ?? 0,
      checkOutYear: map['check_out_year'] ?? 0,
      numberOfNights: map['number_of_days'] ?? 0,
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
      propertyID: map['property_id'] ?? 0,
      roomID: map['room_id'] ?? 0,
      bookingRates: (map['booking_rates'] as List<dynamic>?)
              ?.map((e) => BookingRate.fromMap(e))
              .toList() ??
          [],
    );
  }

  factory Booking.fromResMap(Map<String, dynamic> map) {
    return Booking.fromMap(map['id'].toString(), map);
  }

  String toJson() => json.encode(toMap());

  factory Booking.fromJson(String id, String source) =>
      Booking.fromMap(id, json.decode(source));

  @override
  String toString() {
    return '''Booking(id: $id, confirmationNumber: $confirmationNumber,
    firstName: $firstName, lastName: $lastName, numberOfAdults: $numberOfAdults,
    numberOfChildren: $numberOfChildren, paymentStatusID: $paymentStatusID, statusID: $statusID,
    note: $note, specialRequest: $specialRequest, bookingDate: $bookingDate,
    checkIn: $checkIn, checkOut: $checkOut, checkInDay: $checkInDay,
    checkInMonth: $checkInMonth, checkInYear: $checkInYear, checkOutDay: $checkOutDay,
    checkOutMonth: $checkOutMonth, checkOutYear: $checkOutYear, numberOfNights: $numberOfNights,
    rate: $rate, propertyID: $propertyID, roomID: $roomID, bookingRates: $bookingRates)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Booking &&
        other.id == id &&
        other.confirmationNumber == confirmationNumber &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.numberOfAdults == numberOfAdults &&
        other.numberOfChildren == numberOfChildren &&
        other.paymentStatusID == paymentStatusID &&
        other.statusID == statusID &&
        other.note == note &&
        other.specialRequest == specialRequest &&
        other.bookingDate == bookingDate &&
        other.checkIn == checkIn &&
        other.checkOut == checkOut &&
        other.checkInDay == checkInDay &&
        other.checkInMonth == checkInMonth &&
        other.checkInYear == checkInYear &&
        other.checkOutDay == checkOutDay &&
        other.checkOutMonth == checkOutMonth &&
        other.checkOutYear == checkOutYear &&
        other.numberOfNights == numberOfNights &&
        other.rate == rate &&
        other.propertyID == propertyID &&
        other.roomID == roomID &&
        other.bookingRates == bookingRates;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        confirmationNumber.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        numberOfAdults.hashCode ^
        numberOfChildren.hashCode ^
        paymentStatusID.hashCode ^
        statusID.hashCode ^
        note.hashCode ^
        specialRequest.hashCode ^
        bookingDate.hashCode ^
        checkIn.hashCode ^
        checkOut.hashCode ^
        checkInDay.hashCode ^
        checkInMonth.hashCode ^
        checkInYear.hashCode ^
        checkOutDay.hashCode ^
        checkOutMonth.hashCode ^
        checkOutYear.hashCode ^
        numberOfNights.hashCode ^
        rate.hashCode ^
        propertyID.hashCode ^
        roomID.hashCode ^
        bookingRates.hashCode;
  }
}
