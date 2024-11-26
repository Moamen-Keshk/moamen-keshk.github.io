import 'package:flutter_academy/infrastructure/courses/model/payment_status.model.dart';

class PaymentStatusVM {
  final PaymentStatus status;
  PaymentStatusVM(this.status);
  String get id => status.id;
  String get code => status.code;
  String get name => status.name;
  String get color => status.color;
}
