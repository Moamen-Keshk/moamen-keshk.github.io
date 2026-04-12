import 'dart:convert';

class PaymentTransaction {
  final String id;
  final String bookingId;
  final String? invoiceId;
  final String? stripePaymentIntentId;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final String source;
  final String? reference;
  final String? notes;
  final String? recordedBy;
  final bool isVcc;
  final DateTime? createdAt;

  PaymentTransaction({
    required this.id,
    required this.bookingId,
    this.invoiceId,
    this.stripePaymentIntentId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.source,
    this.reference,
    this.notes,
    this.recordedBy,
    required this.isVcc,
    this.createdAt,
  });

  factory PaymentTransaction.fromMap(Map<String, dynamic> map) {
    return PaymentTransaction(
      id: map['id'].toString(),
      bookingId: map['booking_id'].toString(),
      invoiceId: map['invoice_id']?.toString(),
      stripePaymentIntentId: map['stripe_payment_intent_id']?.toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency']?.toString() ?? 'usd',
      status: map['status']?.toString() ?? 'pending',
      paymentMethod: map['payment_method']?.toString() ?? 'card',
      source: map['source']?.toString() ?? 'manual',
      reference: map['reference']?.toString(),
      notes: map['notes']?.toString(),
      recordedBy: map['recorded_by']?.toString(),
      isVcc: map['is_vcc'] == true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'invoice_id': invoiceId,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_method': paymentMethod,
      'source': source,
      'reference': reference,
      'notes': notes,
      'recorded_by': recordedBy,
      'is_vcc': isVcc,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());
}
