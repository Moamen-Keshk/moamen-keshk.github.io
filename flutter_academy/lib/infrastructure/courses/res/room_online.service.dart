import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/app/req/request.dart';
import 'package:flutter_academy/infrastructure/courses/model/room_online.model.dart';

class RoomOnlineService {
  final _auth = FirebaseAuth.instance;

  /// Fetch all room rates for a specific property
  Future<List<RoomOnline>> getAllRoomOnline(int propertyId) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/all_room_online/$propertyId",
      );
      return (query['data'] as List)
          .map((e) => RoomOnline.fromResMap(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch user-specific room rates (if needed)
  Future<List<RoomOnline>> getRoomOnline() async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/room_online",
      );
      return (query['data'] as List)
          .map((e) => RoomOnline.fromResMap(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a new room rate
  Future<bool> addRoomOnline(RoomOnline roomOnline) async {
    final payload = {
      "room_id": roomOnline.roomId,
      "date": roomOnline.date.toIso8601String(),
      "price": roomOnline.price,
      "property_id": roomOnline.propertyId,
      "category_id": roomOnline.categoryId
    };

    try {
      return await sendPostRequest(
        payload,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/new_room_online",
      );
    } catch (e) {
      return false;
    }
  }

  /// Update an existing room rate (by ID)
  Future<bool> updateRoomOnline(RoomOnline roomOnline) async {
    final payload = {
      "price": roomOnline.price,
      "date": roomOnline.date.toIso8601String(),
      "category_id": roomOnline.categoryId,
      "room_status_id": roomOnline.roomStatusId
    };

    try {
      return await sendPutRequest(
        payload,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/update_room_online/${roomOnline.id}",
      );
    } catch (e) {
      return false;
    }
  }

  /// Delete a room rate by ID
  Future<bool> deleteRoomOnline(String roomOnlineId) async {
    try {
      final response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/delete_room_online/$roomOnlineId",
      );
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  /// Fetch a single room rate by ID
  Future<RoomOnline?> getRoomOnlineById(String id) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/room_online/$id",
      );
      return RoomOnline.fromResMap(query['data']);
    } catch (e) {
      return null;
    }
  }

  /// Fetch room rates by property and category
  Future<List<RoomOnline>> getRoomByPropertyAndCategory({
    required int propertyId,
    required String categoryId,
  }) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/room_online_by_category?property_id=$propertyId&category_id=$categoryId",
      );
      return (query['data'] as List)
          .map((e) => RoomOnline.fromResMap(e))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
