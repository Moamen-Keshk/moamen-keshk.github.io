import 'package:flutter_academy/infrastructure/courses/model/room_online.model.dart';

class RoomOnlineVM {
  final RoomOnline roomOnline;
  RoomOnlineVM(this.roomOnline);

  String get id => roomOnline.id;
  String get roomId => roomOnline.roomId;
  DateTime get date => roomOnline.date;
  double get price => roomOnline.price;
  int get propertyId => roomOnline.propertyId;
  String get categoryId => roomOnline.categoryId;
  int? get roomStatusId => roomOnline.roomStatusId;
}
