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
    bool isVcc = false,
    String? externalChannel,
    String? reference,
    String? processorReference,
    String? processorStatus,
    String? notes,
    String? effectiveDate,
    String? settlementDate,
    String currency = 'usd',
  }) async {
    final token = await _auth.currentUser?.getIdToken();

    final response = await sendPostWithResponseRequest(
      {
        'amount': amount,
        'payment_method': paymentMethod,
        'source': source,
        'status': status,
        'is_vcc': isVcc,
        'external_channel': externalChannel,
        'reference': reference,
        'processor_reference': processorReference,
        'processor_status': processorStatus,
        'notes': notes,
        'effective_date': effectiveDate,
        'settlement_date': settlementDate,
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

  Future<Map<String, dynamic>> refundPayment({
    required int propertyId,
    required int bookingId,
    required String transactionId,
    required double amount,
    String? reason,
    String? settlementDate,
  }) async {
    final token = await _auth.currentUser?.getIdToken();

    final response = await sendPostWithResponseRequest(
      {
        'amount': amount,
        'reason': reason,
        'settlement_date': settlementDate,
      },
      token,
      "/api/v1/properties/$propertyId/bookings/$bookingId/payments/$transactionId/refund",
    );

    if (response != null && response is Map<String, dynamic>) {
      return response;
    }

    throw Exception('Failed to record refund');
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
