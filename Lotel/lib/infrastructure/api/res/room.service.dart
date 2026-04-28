import 'package:lotel_pms/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/infrastructure/api/model/housekeeping.model.dart';
import 'package:lotel_pms/infrastructure/api/model/room.model.dart';
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
      "room_type_id": categoryId,
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

// Update Cleaning Status (Interactive - Today)
  Future<bool> updateCleaningStatus(
      int propertyId, int roomId, int cleaningStatusId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      final userName = _auth.currentUser?.email ?? 'Staff Member';

      // 1. Change type from dynamic to bool
      final bool success = await sendPutRequest(
        {"cleaning_status_id": cleaningStatusId, "user_name": userName},
        token,
        "/api/v1/properties/$propertyId/rooms/$roomId/status",
      );

      // 2. Just return the boolean directly
      return success;
    } catch (e) {
      debugPrint("Error updating cleaning status: $e");
      return false;
    }
  }

  Future<List<HousekeepingRoom>> getTodayHousekeeping(int propertyId) async {
    final result = await getHousekeepingByDate(propertyId, DateTime.now());
    final items = extractHousekeepingItems(result);
    if (items.isEmpty) {
      debugPrint(
        "Failed to fetch today's housekeeping data. Returning empty list.",
      );
      return [];
    }

    return items.map(HousekeepingRoom.fromMap).toList(growable: false);
  }

  // Fetch Past Logs or Future Forecasts
  Future<Map<String, dynamic>?> getHousekeepingByDate(
      int propertyId, DateTime date) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      // Format date as YYYY-MM-DD
      final dateString =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final dynamic response = await sendGetRequest(token,
          "/api/v1/properties/$propertyId/housekeeping?date=$dateString");

      if (response == null) {
        return null;
      }

      final today = DateTime.now();
      final kind = inferHousekeepingPayloadKind(
        targetDate: date,
        today: today,
        rawType: response is Map<String, dynamic>
            ? response['type']?.toString()
            : null,
      );
      final items = extractHousekeepingItems(response);

      if (response is Map<String, dynamic>) {
        return {
          ...response,
          'type': kind.name,
          'data': items,
        };
      }

      if (response is List) {
        return {
          'type': kind.name,
          'data': items,
        };
      }

      return null;
    } catch (e) {
      debugPrint("Error fetching housekeeping data by date: $e");
      return null;
    }
  }
}
