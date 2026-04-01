import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/app/req/request.dart';
import 'package:flutter_academy/infrastructure/courses/model/booking_rate.model.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class BookingRateService {
  final _auth = FirebaseAuth.instance;

  /// Fetch all booking rates for a specific booking
  Future<List<BookingRate>> getBookingRates(
      int propertyId, int bookingId) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 Updated to match the new Python backend route pattern
    final query = await sendGetRequest(
      token,
      "/api/v1/properties/$propertyId/booking_rates/$bookingId",
    );

    // 👉 THE SAFETY NET
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch booking rates. Returning empty list.");
      return [];
    }

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
    final token = await _auth.currentUser?.getIdToken();
    // 👉 Updated URL (property_id moved from params to the URL path)
    final query = await sendGetWithParamsRequest(
      token,
      "/api/v1/properties/$propertyId/booking_rates/by_room",
      {
        'room_id': roomId.toString(),
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      },
    );

    // 👉 THE SAFETY NET
    if (query == null || !query.containsKey('data')) {
      debugPrint(
          "Failed to fetch booking rates by room. Returning empty list.");
      return [];
    }

    return (query['data'] as List)
        .map((e) => BookingRate.fromResMap(e))
        .toList();
  }

  /// (Optional) Add booking rate manually — if needed
  Future<bool> addBookingRate(
      int propertyId, Map<String, dynamic> bookingRate) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 Updated URL
    return await sendPostRequest(
      bookingRate,
      token,
      "/api/v1/properties/$propertyId/booking_rates",
    );
  }

  /// (Optional) Delete a booking rate
  Future<bool> deleteBookingRate(int propertyId, int bookingRateId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      // 👉 Updated URL
      final dynamic response = await sendDeleteRequest(
        token,
        "/api/v1/properties/$propertyId/booking_rates/$bookingRateId",
      );

      // 👉 THE BOOLEAN FIX
      if (response == null) return false;
      if (response is bool) return response;
      if (response is Map<String, dynamic>) {
        return response['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error deleting booking rate: $e");
      return false;
    }
  }
}
