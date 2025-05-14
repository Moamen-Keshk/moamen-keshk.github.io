import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/booking.model.dart';

class BookingService {
  final _auth = FirebaseAuth.instance;
  Future<List<Booking>> getBooking() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/bookings");
    return (query['data'] as List).map((e) => Booking.fromResMap(e)).toList();
  }

  Future<List<Booking>> getAllBookings(
      int propertyId, int year, int month) async {
    final query = await sendGetWithParamsRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/all-bookings", {
      'property_id': propertyId.toString(),
      'check_in_year': year.toString(),
      'check_in_month': month.toString()
    });
    return (query['data'] as List).map((e) => Booking.fromResMap(e)).toList();
  }

  Future<bool> addBooking(Map<String, dynamic> booking) async {
    return await sendPostRequest(
        booking, await _auth.currentUser?.getIdToken(), "/api/v1/new_booking");
  }

  Future<bool> editBooking(
      int bookingId, Map<String, dynamic> updatedBookingData) async {
    try {
      final response = await sendPutRequest(
        updatedBookingData,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/edit_booking/$bookingId",
      );
      return response; // Assuming the API returns a 'success' key
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBooking(String bookingId) async {
    try {
      final response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/delete_booking/$bookingId",
      );

      // Ensure a boolean is returned
      return response['status'] == 'success';
    } catch (e) {
      // Log or handle error
      return false; // fallback so it never returns null
    }
  }

  Future<bool> checkInBooking(int bookingId) async {
    try {
      final response = await sendPostRequest(
        {}, // No body needed
        await _auth.currentUser?.getIdToken(),
        "/api/v1/check_in_booking/$bookingId",
      );
      return response;
    } catch (e) {
      // You can optionally log the error
      return false;
    }
  }

  Future<List<Booking>> getBookingsByDate(int propertyId, DateTime date) async {
    final query = await sendGetWithParamsRequest(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/bookings_by_date",
      {
        'property_id': propertyId.toString(),
        'date': date.toIso8601String().split('T')[0], // format as YYYY-MM-DD
      },
    );

    return (query['data'] as List).map((e) => Booking.fromResMap(e)).toList();
  }
}
