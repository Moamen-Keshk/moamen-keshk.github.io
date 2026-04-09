import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/views/booking.view.dart';
import 'package:lotel_pms/app/payments/services/payment.service.dart';

class PaymentHelper {
  final PaymentService _paymentService = PaymentService();

  Future<void> makePayment(BuildContext context, int bookingId, double amount,
      {bool isVcc = false, VoidCallback? onPaymentSuccess}) async {
    final messenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context, listen: false);

    try {
      // 1. Ask Backend to create a PaymentIntent
      final paymentData =
          await _paymentService.createPaymentIntent(bookingId, amount, isVcc);
      final clientSecret = paymentData['clientSecret'];

      // 2. Initialize the Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'My PMS Hotel',
          // If you want to collect billing details
          billingDetails: BillingDetails(
            name: 'Guest Name',
          ),
        ),
      );

      // 3. Display the Payment Sheet
      await displayPaymentSheet(
        messenger,
        container,
        onPaymentSuccess: onPaymentSuccess,
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error initializing payment: $e')),
      );
    }
  }

  Future<void> displayPaymentSheet(
      ScaffoldMessengerState messenger, ProviderContainer container,
      {VoidCallback? onPaymentSuccess}) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      // Payment Successful
      messenger.showSnackBar(
        SnackBar(content: Text('Payment completed successfully!')),
      );

      container.invalidate(bookingDetailsProvider);
      container.invalidate(bookingListByDateVM);
      container.invalidate(bookingListVM);
      onPaymentSuccess?.call();
    } on StripeException catch (e) {
      messenger.showSnackBar(
        SnackBar(
            content: Text(
                'Payment failed or canceled: ${e.error.localizedMessage}')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
  }
}
