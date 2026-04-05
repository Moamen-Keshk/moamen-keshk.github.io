import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/payment_status.model.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class PaymentStatusService {
  final _auth = FirebaseAuth.instance;

  // 1. GET PAYMENT STATUS
  // 👉 Removed propertyId parameter
  Future<List<PaymentStatus>> getPaymentStatus() async {
    final token = await _auth.currentUser?.getIdToken();

    // 👉 Updated to match the global RESTful pattern
    final query = await sendGetRequest(token, "/api/v1/payment-statusesq");

    // 👉 THE SAFETY NET: Prevent the 'null' crash
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch payment statuses. Returning empty list.");
      return [];
    }

    return (query['data'] as List)
        .map((e) => PaymentStatus.fromResMap(e))
        .toList();
  }

  // 2. GET ALL PAYMENT STATUSES
  // 👉 Removed propertyId parameter
  Future<List<PaymentStatus>> getAllPaymentStatus() async {
    final token = await _auth.currentUser?.getIdToken();

    // 👉 Updated to match the global RESTful pattern
    final query = await sendGetRequest(token, "/api/v1/all-payment-statuses");

    // 👉 THE SAFETY NET
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch all payment statuses. Returning empty list.");
      return [];
    }

    return (query['data'] as List)
        .map((e) => PaymentStatus.fromResMap(e))
        .toList();
  }

  // 3. ADD PAYMENT STATUS
  // 👉 Removed propertyId parameter
  Future<bool> addPaymentStatus(String name, String description) async {
    final token = await _auth.currentUser?.getIdToken();

    // 👉 Removed property_id from the JSON payload and updated URL
    return await sendPostRequest(
        {"name": name, "description": description},
        token,
        "/api/v1/payment-statuses" // Make sure your Flask POST route matches this string!
        );
  }
}
