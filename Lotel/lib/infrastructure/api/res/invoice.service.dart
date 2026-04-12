import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lotel_pms/app/req/request.dart';
import 'package:lotel_pms/infrastructure/api/model/invoice.model.dart';
import 'package:lotel_pms/infrastructure/api/model/payment_transaction.model.dart';

class InvoiceService {
  final _auth = FirebaseAuth.instance;

  Future<List<InvoiceModel>> getInvoices(int propertyId) async {
    final token = await _auth.currentUser?.getIdToken();
    final response =
        await sendGetRequest(token, '/api/v1/properties/$propertyId/invoices');

    if (response == null || response['data'] is! List) {
      return const [];
    }

    return (response['data'] as List)
        .map((e) => InvoiceModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<InvoiceModel?> getBookingInvoice(int propertyId, int bookingId) async {
    final token = await _auth.currentUser?.getIdToken();
    final response = await sendGetRequest(
      token,
      '/api/v1/properties/$propertyId/bookings/$bookingId/invoice',
    );

    if (response == null || response['data'] is! Map<String, dynamic>) {
      return null;
    }

    return InvoiceModel.fromMap(response['data'] as Map<String, dynamic>);
  }

  Future<InvoiceModel?> syncBookingInvoice(
    int propertyId,
    int bookingId, {
    String? dueDate,
    double? taxAmount,
    String? notes,
  }) async {
    final token = await _auth.currentUser?.getIdToken();
    final response = await sendPostWithResponseRequest(
      {
        if (dueDate != null) 'due_date': dueDate,
        if (taxAmount != null) 'tax_amount': taxAmount,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      token,
      '/api/v1/properties/$propertyId/bookings/$bookingId/invoice/sync',
    );

    if (response == null || response['data'] is! Map<String, dynamic>) {
      return null;
    }

    return InvoiceModel.fromMap(response['data'] as Map<String, dynamic>);
  }

  Future<List<PaymentTransaction>> getBookingPayments(
      int propertyId, int bookingId) async {
    final token = await _auth.currentUser?.getIdToken();
    final response = await sendGetRequest(
      token,
      '/api/v1/properties/$propertyId/bookings/$bookingId/payments',
    );

    if (response == null || response['data'] is! List) {
      return const [];
    }

    return (response['data'] as List)
        .map((e) => PaymentTransaction.fromMap(e as Map<String, dynamic>))
        .toList();
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
      '/api/v1/properties/$propertyId/bookings/$bookingId/payments',
    );

    if (response != null && response is Map<String, dynamic>) {
      return response;
    }

    throw Exception('Failed to record payment');
  }

  Future<Map<String, dynamic>?> fetchBookingVcc(
      int propertyId, int bookingId) async {
    final token = await _auth.currentUser?.getIdToken();

    try {
      final response = await sendGetRequest(
        token,
        '/api/v1/properties/$propertyId/bookings/$bookingId/vcc',
      );

      if (response != null &&
          response['data'] is Map<String, dynamic> &&
          response['data']['has_vcc'] == true) {
        return response['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Failed to fetch VCC details: $e');
    }

    return null;
  }
}
