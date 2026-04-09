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
}
