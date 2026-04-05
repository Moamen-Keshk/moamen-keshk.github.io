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

  Future<bool> checkOutBooking(int propertyId, int bookingId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      return await sendPostRequest(
        {}, // No body needed
        token,
        "/api/v1/properties/$propertyId/bookings/$bookingId/check_out",
      );
    } catch (e) {
      debugPrint("Error checking out booking: $e");
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

  // Add this method to your BookingService class
  Future<bool> sendGuestMessage(
      int propertyId, int bookingId, String subject, String message) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      return await sendPostRequest(
        {
          'subject': subject,
          'message': message,
        },
        token,
        "/api/v1/properties/$propertyId/bookings/$bookingId/send_message",
      );
    } catch (e) {
      debugPrint("Error sending message: $e");
      return false;
    }
  }

  Future<bool> extendBooking(
    int propertyId,
    int bookingId,
    String newCheckOutDate, {
    bool isPaid = false,
    double extraCost = 0.0,
  }) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      return await sendPostRequest(
        {
          "new_check_out": newCheckOutDate,
          "is_paid": isPaid,
          "extra_cost": extraCost
        },
        token,
        "/api/v1/properties/$propertyId/bookings/$bookingId/extend",
      );
    } catch (e) {
      debugPrint("Error extending booking: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> checkExtensionAvailability(int propertyId,
      int roomId, String currentCheckOut, String newCheckOut) async {
    try {
      final token = await _auth.currentUser?.getIdToken();

      // Expected backend response: {"available": true, "extra_cost": 150.00}
      final response = await sendPostWithResponseRequest(
        {
          "room_id": roomId,
          "current_check_out": currentCheckOut,
          "new_check_out": newCheckOut
        },
        token,
        "/api/v1/properties/$propertyId/bookings/check_extension",
      );

      if (response != null && response is Map<String, dynamic>) {
        return response;
      }

      // Fallback if backend endpoint isn't built yet
      return {'available': true, 'extra_cost': null};
    } catch (e) {
      debugPrint("Error checking extension availability: $e");
      // Default to false if the network fails entirely
      return {'available': false, 'extra_cost': 0.0};
    }
  }
}
