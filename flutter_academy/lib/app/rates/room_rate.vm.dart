import 'package:flutter_academy/app/rates/room_rate.model.dart';

class RoomRateVM {
  final RoomRate roomRate;
  RoomRateVM(this.roomRate);

  String get id => roomRate.id;
  String get roomId => roomRate.roomId;
  DateTime get date => roomRate.date;
  double get price => roomRate.price;
  int get propertyId => roomRate.propertyId;
}
