import 'package:lotel_pms/infrastructure/api/model/booking_status.model.dart';

class BookingStatusVM {
  final BookingStatusModel status;

  BookingStatusVM(this.status);

  int get id => status.id;
  String get name => status.name;
  String get code => status.code;
  String get color => status.color;
}
