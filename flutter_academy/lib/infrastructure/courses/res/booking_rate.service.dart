import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/app/req/request.dart';
import 'package:flutter_academy/infrastructure/courses/model/booking_rate.model.dart';

class BookingRateService {
  final _auth = FirebaseAuth.instance;

  /// Fetch all booking rates for a specific booking
  Future<List<BookingRate>> getBookingRates(int bookingId) async {
    final query = await sendGetRequest(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/booking_rates/$bookingId",
    );

    return (query['data'] as List)
        .map((e) => BookingRate.fromResMap(e))
        .toList();
  }

  /// Fetch booking rates for a property in a date range (optional use case)
  Future<List<BookingRate>> getRatesForProperty({
    required int propertyId,
    required int roomId,
    required DateTime from,
    required DateTime to,
  }) async {
    final query = await sendGetWithParamsRequest(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/booking_rates_by_room",
      {
        'property_id': propertyId.toString(),
        'room_id': roomId.toString(),
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      },
    );

    return (query['data'] as List)
        .map((e) => BookingRate.fromResMap(e))
        .toList();
  }

  /// (Optional) Add booking rate manually — if needed
  Future<bool> addBookingRate(Map<String, dynamic> bookingRate) async {
    return await sendPostRequest(
      bookingRate,
      await _auth.currentUser?.getIdToken(),
      "/api/v1/new_booking_rate",
    );
  }

  /// (Optional) Delete a booking rate
  Future<bool> deleteBookingRate(int bookingRateId) async {
    try {
      final response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/delete_booking_rate/$bookingRateId",
      );
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}
