import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';

class RoomService {
  final _auth = FirebaseAuth.instance;
  Future<List<Room>> getRoom() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/rooms");
    return (query['data'] as List).map((e) => Room.fromMap(e)).toList();
  }

  Future<List<Room>> getAllRooms(int propertyId) async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/all-rooms/$propertyId");
    return (query['data'] as List).map((e) => Room.fromMap(e)).toList();
  }

  Future<bool> addRoom(
      int roomNumber, int propertyId, int categoryId, int floorId) async {
    return await sendPostRequest({
      "room_number": roomNumber,
      "property_id": propertyId,
      "category_id": categoryId,
      "floor_id": floorId
    }, await _auth.currentUser?.getIdToken(), "/api/v1/new_room");
  }

  Future<bool> deleteRoom(int roomId) async {
    try {
      final response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/delete_room/$roomId",
      );
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}
