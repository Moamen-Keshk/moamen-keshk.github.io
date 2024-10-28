import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';

class RoomVM {
  final Room room;
  RoomVM(this.room);
  int get roomNumber => room.roomNumber;
  int get categoryId => room.categoryId;
  int get floorId => room.floorId;
  int get statusId => room.statusId;
}
