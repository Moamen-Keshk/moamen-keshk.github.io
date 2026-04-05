import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/app/req/request.dart';
import 'package:flutter_academy/infrastructure/courses/model/booking_status.model.dart';

class BookingStatusService {
  final _auth = FirebaseAuth.instance;

  Future<List<BookingStatusModel>> getAllBookingStatuses() async {
    final token = await _auth.currentUser?.getIdToken();
    final query = await sendGetRequest(token, "/api/v1/booking-statuses");

    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch booking statuses.");
      return [];
    }

    return (query['data'] as List)
        .map((e) => BookingStatusModel.fromResMap(e))
        .toList();
  }

  Future<bool> addBookingStatus({
    required String name,
    required String code,
    String? color,
  }) async {
    final token = await _auth.currentUser?.getIdToken();
    return await sendPostRequest(
      {
        "name": name,
        "code": code,
        "color": color ?? '',
      },
      token,
      "/api/v1/booking-statuses",
    );
  }

  Future<bool> editBookingStatus(
      String statusId, Map<String, dynamic> updatedData) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      return await sendPutRequest(
          updatedData, token, "/api/v1/booking-statuses/$statusId");
    } catch (e) {
      debugPrint("Error editing booking status: $e");
      return false;
    }
  }

  Future<bool> deleteBookingStatus(String statusId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      final dynamic response =
          await sendDeleteRequest(token, "/api/v1/booking-statuses/$statusId");

      if (response == null) return false;
      if (response is bool) return response;
      if (response is Map<String, dynamic>) {
        return response['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error deleting booking status: $e");
      return false;
    }
  }
}
