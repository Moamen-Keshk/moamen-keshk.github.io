import 'dart:convert';

class InvoiceLineItem {
  final String id;
  final String invoiceId;
  final DateTime? lineDate;
  final String description;
  final double quantity;
  final double unitPrice;
  final double amount;

  InvoiceLineItem({
    required this.id,
    required this.invoiceId,
    this.lineDate,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  factory InvoiceLineItem.fromMap(Map<String, dynamic> map) {
    return InvoiceLineItem(
      id: map['id'].toString(),
      invoiceId: map['invoice_id'].toString(),
      lineDate: map['line_date'] != null
          ? DateTime.tryParse(map['line_date'].toString())
          : null,
      description: map['description']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'line_date': lineDate?.toIso8601String(),
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'amount': amount,
    };
  }

  String toJson() => json.encode(toMap());
}
