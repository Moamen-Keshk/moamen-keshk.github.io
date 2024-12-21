import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/floor.model.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';

class FloorService {
  final _auth = FirebaseAuth.instance;
  Future<List<Floor>> getFloor() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/floors");
    return (query['data'] as List).map((e) => Floor.fromResMap(e)).toList();
  }

  Future<List<Floor>> getAllFloors(int propertyId) async {
    final query = await sendGetRequest(await _auth.currentUser?.getIdToken(),
        "/api/v1/all-floors/$propertyId");
    return (query['data'] as List).map((e) => Floor.fromResMap(e)).toList();
  }

  Future<bool> addFloor(int number, int propertyId, List<Room>? rooms) async {
    return await sendPostRequest(
        {"floor_number": number, "property_id": propertyId, "rooms": rooms},
        await _auth.currentUser?.getIdToken(),
        "/api/v1/new-floor");
  }

  Future<bool> editFloor(
      int floorId, Map<String, dynamic> updatedFloorData) async {
    try {
      final response = await sendPutRequest(
        updatedFloorData,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/edit_floor/$floorId",
      );
      return response; // Assuming the API returns a 'success' key
    } catch (e) {
      return false;
    }
  }
}
