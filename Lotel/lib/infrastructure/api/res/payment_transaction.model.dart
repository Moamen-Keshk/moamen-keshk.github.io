import 'dart:convert';

class PaymentTransaction {
  final String id;
  final String bookingId;
  final String? invoiceId;
  final String? stripePaymentIntentId;
  final double amount;
  final String currency;
  final String status;
  final String transactionType;
  final String? parentTransactionId;
  final String paymentMethod;
  final String source;
  final String? externalChannel;
  final String? reference;
  final String? processorReference;
  final String? processorStatus;
  final String? notes;
  final String? recordedBy;
  final bool isVcc;
  final DateTime? effectiveDate;
  final DateTime? settlementDate;
  final DateTime? createdAt;

  PaymentTransaction({
    required this.id,
    required this.bookingId,
    this.invoiceId,
    this.stripePaymentIntentId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.transactionType,
    this.parentTransactionId,
    required this.paymentMethod,
    required this.source,
    this.externalChannel,
    this.reference,
    this.processorReference,
    this.processorStatus,
    this.notes,
    this.recordedBy,
    required this.isVcc,
    this.effectiveDate,
    this.settlementDate,
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
      transactionType: map['transaction_type']?.toString() ?? 'payment',
      parentTransactionId: map['parent_transaction_id']?.toString(),
      paymentMethod: map['payment_method']?.toString() ?? 'card',
      source: map['source']?.toString() ?? 'manual',
      externalChannel: map['external_channel']?.toString(),
      reference: map['reference']?.toString(),
      processorReference: map['processor_reference']?.toString(),
      processorStatus: map['processor_status']?.toString(),
      notes: map['notes']?.toString(),
      recordedBy: map['recorded_by']?.toString(),
      isVcc: map['is_vcc'] == true,
      effectiveDate: map['effective_date'] != null
          ? DateTime.tryParse(map['effective_date'].toString())
          : null,
      settlementDate: map['settlement_date'] != null
          ? DateTime.tryParse(map['settlement_date'].toString())
          : null,
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
      'transaction_type': transactionType,
      'parent_transaction_id': parentTransactionId,
      'payment_method': paymentMethod,
      'source': source,
      'external_channel': externalChannel,
      'reference': reference,
      'processor_reference': processorReference,
      'processor_status': processorStatus,
      'notes': notes,
      'recorded_by': recordedBy,
      'is_vcc': isVcc,
      'effective_date': effectiveDate?.toIso8601String(),
      'settlement_date': settlementDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());
}
