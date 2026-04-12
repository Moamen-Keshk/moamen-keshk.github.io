import 'dart:convert';

import 'package:lotel_pms/infrastructure/api/model/invoice_line_item.model.dart';
import 'package:lotel_pms/infrastructure/api/model/payment_transaction.model.dart';

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final int propertyId;
  final String bookingId;
  final String guestName;
  final String status;
  final String currency;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final double amountPaid;
  final double balanceDue;
  final String? notes;
  final List<InvoiceLineItem> lineItems;
  final List<PaymentTransaction> payments;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.propertyId,
    required this.bookingId,
    required this.guestName,
    required this.status,
    required this.currency,
    this.issueDate,
    this.dueDate,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.amountPaid,
    required this.balanceDue,
    this.notes,
    required this.lineItems,
    required this.payments,
  });

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'].toString(),
      invoiceNumber: map['invoice_number']?.toString() ?? '',
      propertyId: map['property_id'] ?? 0,
      bookingId: map['booking_id'].toString(),
      guestName: map['guest_name']?.toString() ?? '',
      status: map['status']?.toString() ?? 'open',
      currency: map['currency']?.toString() ?? 'USD',
      issueDate: map['issue_date'] != null
          ? DateTime.tryParse(map['issue_date'].toString())
          : null,
      dueDate: map['due_date'] != null
          ? DateTime.tryParse(map['due_date'].toString())
          : null,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? 0.0,
      balanceDue: (map['balance_due'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes']?.toString(),
      lineItems: (map['line_items'] as List<dynamic>?)
              ?.map((e) => InvoiceLineItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      payments: (map['payments'] as List<dynamic>?)
              ?.map((e) => PaymentTransaction.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'property_id': propertyId,
      'booking_id': bookingId,
      'guest_name': guestName,
      'status': status,
      'currency': currency,
      'issue_date': issueDate?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'amount_paid': amountPaid,
      'balance_due': balanceDue,
      'notes': notes,
      'line_items': lineItems.map((e) => e.toMap()).toList(),
      'payments': payments.map((e) => e.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
}
