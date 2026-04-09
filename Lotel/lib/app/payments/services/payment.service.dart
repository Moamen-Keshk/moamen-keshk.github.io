import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/app/req/request.dart';

class PaymentService {
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> createPaymentIntent(
      int bookingId, double amount, bool isVcc) async {
    final token = await _auth.currentUser?.getIdToken();

    final response = await sendPostWithResponseRequest(
      {
        'booking_id': bookingId,
        'amount': amount,
        'is_vcc': isVcc,
      },
      token,
      "/api/v1/payments/create-payment-intent",
    );

    if (response != null && response is Map<String, dynamic>) {
      return response;
    }

    throw Exception('Failed to create payment intent');
  }

  // Add the direct charge method for VCC from the front desk UI
  Future<bool> chargeVCC({
    required int bookingId,
    required double amount,
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    final token = await _auth.currentUser?.getIdToken();

    final response = await sendPostWithResponseRequest(
      {
        'booking_id': bookingId,
        'amount': amount,
        'card_number': cardNumber,
        'exp_month': expMonth,
        'exp_year': expYear,
        'cvc': cvc,
      },
      token,
      "/api/v1/payments/charge-vcc", // Ensure this route matches your backend implementation
    );

    // Adapting to typical response structures. Adjust the success condition based on your backend.
    if (response != null &&
        (response['success'] == true || response['status'] == 'succeeded')) {
      return true;
    } else if (response != null) {
      throw Exception(
          response['message'] ?? response['error'] ?? 'Failed to charge VCC');
    }

    throw Exception('Failed to charge VCC: Invalid response from server');
  }

  Future<Map<String, dynamic>?> fetchBookingVCC(int bookingId) async {
    final token = await _auth.currentUser?.getIdToken();

    try {
      final response = await sendGetRequest(
        token,
        "/payments/vcc/$bookingId",
      );

      if (response != null && response['has_vcc'] == true) {
        return response;
      }
      return null;
    } catch (e) {
      debugPrint("Failed to fetch VCC details: $e");
      return null;
    }
  }
}
