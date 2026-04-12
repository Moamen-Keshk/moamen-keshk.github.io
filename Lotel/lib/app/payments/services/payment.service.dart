import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/app/req/request.dart';

class PaymentService {
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> createPaymentIntent(
      int propertyId, int bookingId, double amount, bool isVcc) async {
    final token = await _auth.currentUser?.getIdToken();

    final response = await sendPostWithResponseRequest(
      {
        'amount': amount,
        'is_vcc': isVcc,
      },
      token,
      "/api/v1/properties/$propertyId/bookings/$bookingId/payments/create-intent",
    );

    if (response != null && response is Map<String, dynamic>) {
      return response;
    }

    throw Exception('Failed to create payment intent');
  }

  Future<Map<String, dynamic>> recordPayment({
    required int propertyId,
    required int bookingId,
    required double amount,
    required String paymentMethod,
    String source = 'manual',
    String status = 'succeeded',
    String? reference,
    String? notes,
    String currency = 'usd',
  }) async {
    final token = await _auth.currentUser?.getIdToken();

    final response = await sendPostWithResponseRequest(
      {
        'amount': amount,
        'payment_method': paymentMethod,
        'source': source,
        'status': status,
        'reference': reference,
        'notes': notes,
        'currency': currency,
      },
      token,
      "/api/v1/properties/$propertyId/bookings/$bookingId/payments",
    );

    if (response != null && response is Map<String, dynamic>) {
      return response;
    }

    throw Exception('Failed to record payment');
  }

  Future<Map<String, dynamic>?> fetchBookingVCC(
      int propertyId, int bookingId) async {
    final token = await _auth.currentUser?.getIdToken();

    try {
      final response = await sendGetRequest(
        token,
        "/api/v1/properties/$propertyId/bookings/$bookingId/vcc",
      );

      if (response != null &&
          response['data'] is Map<String, dynamic> &&
          response['data']['has_vcc'] == true) {
        return response['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("Failed to fetch VCC details: $e");
      return null;
    }
  }
}
