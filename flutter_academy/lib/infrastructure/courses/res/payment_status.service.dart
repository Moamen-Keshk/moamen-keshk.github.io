import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/payment_status.model.dart';

class PaymentStatusService {
  final _auth = FirebaseAuth.instance;
  Future<List<PaymentStatus>> getPaymentStatus() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/payment-status");
    return (query['data'] as List)
        .map((e) => PaymentStatus.fromResMap(e))
        .toList();
  }

  Future<List<PaymentStatus>> getAllPaymentStatus() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/all-payment-status");
    return (query['data'] as List)
        .map((e) => PaymentStatus.fromResMap(e))
        .toList();
  }

  Future<bool> addPaymentStatus(String name, String description) async {
    return await sendPostRequest({"name": name, "description": description},
        await _auth.currentUser?.getIdToken(), "/api/v1/new-payment-status");
  }
}
