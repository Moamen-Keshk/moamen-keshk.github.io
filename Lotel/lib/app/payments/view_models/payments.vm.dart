import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/views/booking.view.dart';
import 'package:lotel_pms/app/payments/services/payment.service.dart';

class PaymentVM {
  final PaymentService _paymentService = PaymentService();

  Future<void> makePayment(
    BuildContext context,
    int propertyId,
    int bookingId,
    double amount, {
    bool isVcc = false,
    VoidCallback? onPaymentSuccess,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context, listen: false);

    try {
      final paymentData =
          await _paymentService.createPaymentIntent(propertyId, bookingId, amount, isVcc);
      final payload = paymentData['data'] is Map<String, dynamic>
          ? paymentData['data'] as Map<String, dynamic>
          : paymentData;
      final clientSecret = payload['clientSecret'];

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

  Future<bool> recordManualPayment(
    BuildContext context, {
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
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context, listen: false);

    try {
      await _paymentService.recordPayment(
        propertyId: propertyId,
        bookingId: bookingId,
        amount: amount,
        paymentMethod: paymentMethod,
        source: source,
        status: status,
        isVcc: isVcc,
        externalChannel: externalChannel,
        reference: reference,
        processorReference: processorReference,
        processorStatus: processorStatus,
        notes: notes,
        effectiveDate: effectiveDate,
        settlementDate: settlementDate,
      );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Payment recorded successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      container.invalidate(bookingDetailsProvider);
      container.invalidate(bookingListByDateVM);
      container.invalidate(bookingListVM);
      return true;
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error recording payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> refundPayment(
    BuildContext context, {
    required int propertyId,
    required int bookingId,
    required String transactionId,
    required double amount,
    String? reason,
    String? settlementDate,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context, listen: false);

    try {
      await _paymentService.refundPayment(
        propertyId: propertyId,
        bookingId: bookingId,
        transactionId: transactionId,
        amount: amount,
        reason: reason,
        settlementDate: settlementDate,
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Refund recorded successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      container.invalidate(bookingDetailsProvider);
      container.invalidate(bookingListByDateVM);
      container.invalidate(bookingListVM);
      return true;
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error recording refund: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
