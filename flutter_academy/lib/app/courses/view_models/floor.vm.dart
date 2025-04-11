import 'package:flutter_academy/infrastructure/courses/model/floor.model.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';

class FloorVM {
  final Floor floor;
  FloorVM(this.floor);
  String get id => floor.id;
  int get number => floor.number;
  int get propertyId => floor.propertyId;
  List<Room> get rooms => floor.rooms;
}
