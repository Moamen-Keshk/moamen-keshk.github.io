import 'package:lotel_pms/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/infrastructure/api/model/floor.model.dart';
import 'package:lotel_pms/infrastructure/api/model/room.model.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class FloorService {
  final _auth = FirebaseAuth.instance;

  // 1. GET ALL FLOORS
  Future<List<Floor>> getAllFloors(int propertyId) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 Updated to match the new Python backend route
    final query =
        await sendGetRequest(token, "/api/v1/properties/$propertyId/floors");

    // 👉 The Safety Net to prevent the 'null' crash
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch floors. Returning empty list.");
      return [];
    }

    return (query['data'] as List).map((e) => Floor.fromResMap(e)).toList();
  }

  // 2. ADD FLOOR
  Future<bool> addFloor(int number, int propertyId, List<Room>? rooms) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 Updated to match the new Python backend route
    return await sendPostRequest(
        {"floor_number": number, "property_id": propertyId, "rooms": rooms},
        token,
        "/api/v1/properties/$propertyId/floors");
  }

  // 3. EDIT FLOOR (Requires propertyId for backend permissions)
  Future<bool> editFloor(int propertyId, int floorId,
      Map<String, dynamic> updatedFloorData) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      // 👉 Updated to match the new Python backend route
      return await sendPutRequest(
        updatedFloorData,
        token,
        "/api/v1/properties/$propertyId/floors/$floorId",
      );
    } catch (e) {
      debugPrint("Error editing floor: $e");
      return false;
    }
  }

  // 4. DELETE FLOOR (Requires propertyId for backend permissions)
  Future<bool> deleteFloor(int propertyId, int floorId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      // 👉 Updated to match the new Python backend route
      final dynamic response = await sendDeleteRequest(
        token,
        "/api/v1/properties/$propertyId/floors/$floorId",
      );

      if (response == null) return false;

      // 👉 The boolean fix
      if (response is bool) return response;

      if (response is Map<String, dynamic>) {
        return response['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error deleting floor: $e");
      return false;
    }
  }
}
