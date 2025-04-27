import 'dart:convert';
import 'package:intl/intl.dart';

DateFormat format = DateFormat("EEE, dd MMM yyyy HH:mm:ss z");

class BookingRate {
  final int id;
  final int bookingId;
  final DateTime rateDate;
  final double nightlyRate;

  BookingRate({
    required this.id,
    required this.bookingId,
    required this.rateDate,
    required this.nightlyRate,
  });

  BookingRate copyWith({
    int? id,
    int? bookingId,
    DateTime? rateDate,
    double? nightlyRate,
  }) {
    return BookingRate(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      rateDate: rateDate ?? this.rateDate,
      nightlyRate: nightlyRate ?? this.nightlyRate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'rate_date': rateDate.toIso8601String(),
      'nightly_rate': nightlyRate,
    };
  }

  factory BookingRate.fromMap(Map<String, dynamic> map) {
    return BookingRate(
      id: map['id'],
      bookingId: map['booking_id'],
      rateDate: DateTime.parse(map['rate_date']),
      nightlyRate: (map['nightly_rate'] as num).toDouble(),
    );
  }

  factory BookingRate.fromResMap(Map<String, dynamic> map) {
    return BookingRate.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory BookingRate.fromJson(String source) =>
      BookingRate.fromMap(json.decode(source));

  @override
  String toString() =>
      'BookingRate(id: $id, bookingId: $bookingId, rateDate: ${format.format(rateDate)}, nightlyRate: $nightlyRate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookingRate &&
        other.id == id &&
        other.bookingId == bookingId &&
        other.rateDate == rateDate &&
        other.nightlyRate == nightlyRate;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      bookingId.hashCode ^
      rateDate.hashCode ^
      nightlyRate.hashCode;
}
