import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class RoomService {
  final _auth = FirebaseAuth.instance;

  // 1. GET ROOMS (Added propertyId for the backend route)
  Future<List<Room>> getRoom(int propertyId) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 Updated to match the new Python backend route
    final query =
        await sendGetRequest(token, "/api/v1/properties/$propertyId/rooms");

    // 👉 THE SAFETY NET: Prevent the 'null' crash
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch rooms. Returning empty list.");
      return [];
    }

    return (query['data'] as List).map((e) => Room.fromMap(e)).toList();
  }

  // 2. GET ALL ROOMS
  Future<List<Room>> getAllRooms(int propertyId) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 Updated to match the new Python backend route
    final query =
        await sendGetRequest(token, "/api/v1/properties/$propertyId/rooms");

    // 👉 THE SAFETY NET
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch all rooms. Returning empty list.");
      return [];
    }

    return (query['data'] as List).map((e) => Room.fromMap(e)).toList();
  }

  // 3. ADD ROOM
  Future<bool> addRoom(
      int roomNumber, int propertyId, int categoryId, int floorId) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 Updated to match the new Python backend route
    return await sendPostRequest({
      "room_number": roomNumber,
      "property_id": propertyId,
      "category_id": categoryId,
      "floor_id": floorId
    }, token, "/api/v1/properties/$propertyId/rooms");
  }

  // 4. DELETE ROOM (Added propertyId for backend security)
  Future<bool> deleteRoom(int propertyId, int roomId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      // 👉 Updated to match the new Python backend route
      final dynamic response = await sendDeleteRequest(
        token,
        "/api/v1/properties/$propertyId/rooms/$roomId",
      );

      // 👉 THE BOOLEAN FIX
      if (response == null) return false;
      if (response is bool) return response;
      if (response is Map<String, dynamic>) {
        return response['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error deleting room: $e");
      return false;
    }
  }
}
