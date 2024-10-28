import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';

class RoomService {
  final _auth = FirebaseAuth.instance;
  Future<List<Room>> getRoom() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/rooms");
    return (query['data'] as List)
        .map((e) => Room.fromResMap(e))
        .toList();
  }

  Future<List<Room>> getAllRooms() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/all-rooms");
    return (query['data'] as List)
        .map((e) => Room.fromResMap(e))
        .toList();
  }

    Future<bool> addRoom(int roomNumber, int categoryId, int floorId) async {
      return await sendPostRequest(
          {"room_number": roomNumber, "category_id": categoryId, "floor_id": floorId},
          await _auth.currentUser?.getIdToken(),
          "/api/v1/new_room");
  }
}
