import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/booking.model.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class BookingService {
  final _auth = FirebaseAuth.instance;

  // Note: Added propertyId to match the new backend security requirements
  Future<List<Booking>> getBooking(int propertyId) async {
    final token = await _auth.currentUser?.getIdToken();
    final query =
        await sendGetRequest(token, "/api/v1/properties/$propertyId/bookings");

    // 👉 SAFETY NET
    if (query == null || !query.containsKey('data')) return [];

    return (query['data'] as List).map((e) => Booking.fromResMap(e)).toList();
  }

  Future<List<Booking>> getAllBookings(
      int propertyId, int year, int month) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 NEW URL PATTERN
    final query = await sendGetWithParamsRequest(
        token,
        "/api/v1/properties/$propertyId/bookings",
        {'check_in_year': year.toString(), 'check_in_month': month.toString()});

    // 👉 SAFETY NET
    if (query == null || !query.containsKey('data')) return [];

    return (query['data'] as List).map((e) => Booking.fromResMap(e)).toList();
  }

  Future<bool> addBooking(int propertyId, Map<String, dynamic> booking) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 NEW URL PATTERN
    return await sendPostRequest(
        booking, token, "/api/v1/properties/$propertyId/bookings");
  }

  Future<bool> editBooking(int propertyId, int bookingId,
      Map<String, dynamic> updatedBookingData) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      // 👉 NEW URL PATTERN
      return await sendPutRequest(
        updatedBookingData,
        token,
        "/api/v1/properties/$propertyId/bookings/$bookingId",
      );
    } catch (e) {
      debugPrint("Error editing booking: $e");
      return false;
    }
  }

  Future<bool> deleteBooking(int propertyId, String bookingId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      // 👉 NEW URL PATTERN
      final dynamic response = await sendDeleteRequest(
        token,
        "/api/v1/properties/$propertyId/bookings/$bookingId",
      );

      // 👉 BOOLEAN FIX
      if (response == null) return false;
      if (response is bool) return response;
      if (response is Map<String, dynamic>) {
        return response['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error deleting booking: $e");
      return false;
    }
  }

  Future<bool> checkInBooking(int propertyId, int bookingId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      // 👉 NEW URL PATTERN
      return await sendPostRequest(
        {}, // No body needed
        token,
        "/api/v1/properties/$propertyId/bookings/$bookingId/check_in",
      );
    } catch (e) {
      debugPrint("Error checking in booking: $e");
      return false;
    }
  }

  Future<List<Booking>> getBookingsByDate(
      int propertyId, DateTime date, String bookingState) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 NEW URL PATTERN
    final query = await sendGetWithParamsRequest(
      token,
      "/api/v1/properties/$propertyId/bookings/by_state",
      {
        'date': date.toIso8601String().split('T')[0], // format as YYYY-MM-DD
        'booking_state':
            bookingState, // e.g., "arrivals", "departures", "inhouse"
      },
    );

    // 👉 SAFETY NET
    if (query == null || !query.containsKey('data')) return [];

    return (query['data'] as List).map((e) => Booking.fromResMap(e)).toList();
  }

  Future<Booking?> getBookingById(int propertyId, String bookingId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      // 👉 NEW URL PATTERN
      final query = await sendGetRequest(
        token,
        "/api/v1/properties/$propertyId/bookings/$bookingId",
      );

      // 👉 SAFETY NET
      if (query == null || !query.containsKey('data')) return null;

      return Booking.fromResMap(query['data']);
    } catch (e) {
      debugPrint("Error fetching booking by ID: $e");
      return null;
    }
  }
}
