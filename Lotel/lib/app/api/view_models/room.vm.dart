import 'package:lotel_pms/infrastructure/api/model/room.model.dart';

class RoomVM {
  final Room room;
  RoomVM(this.room);
  String get id => room.id;
  int get roomNumber => room.roomNumber;
  int get categoryId => room.categoryId;
  int? get floorId => room.floorId;
  int? get statusId => room.statusId;
  int? get cleaningStatusId => room.cleaningStatusId;
}
