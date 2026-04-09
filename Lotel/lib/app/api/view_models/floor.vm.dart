import 'package:lotel_pms/infrastructure/api/model/floor.model.dart';
import 'package:lotel_pms/infrastructure/api/model/room.model.dart';

class FloorVM {
  final Floor floor;
  FloorVM(this.floor);
  String get id => floor.id;
  int get number => floor.number;
  int get propertyId => floor.propertyId;
  List<Room> get rooms => floor.rooms;
}
