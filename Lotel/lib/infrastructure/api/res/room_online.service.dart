import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/app/req/request.dart';
import 'package:lotel_pms/infrastructure/api/model/room_online.model.dart';

class RoomOnlineService {
  final _auth = FirebaseAuth.instance;

  /// Fetch all room rates for a specific property
  Future<List<RoomOnline>> getAllRoomOnline(int propertyId) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/$propertyId/room_online",
      );
      return (query['data'] as List)
          .map((e) => RoomOnline.fromResMap(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch user-specific room rates (if needed)
  /// NOTE: Your backend room_online.py does not actually have a route for this
  /// without a property_id. You might want to pass a propertyId here as well.
  Future<List<RoomOnline>> getRoomOnline() async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/properties/room_online",
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
        // UPDATED PATH:
        "/api/v1/properties/${roomOnline.propertyId}/room_online",
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
      "room_id": roomOnline.roomId,
      "room_status_id": roomOnline.roomStatusId
    };

    try {
      return await sendPutRequest(
        payload,
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/${roomOnline.propertyId}/room_online/${roomOnline.id}",
      );
    } catch (e) {
      return false;
    }
  }

  /// Delete a room rate by ID
  /// UPDATED: Added propertyId parameter because backend URL requires it
  Future<bool> deleteRoomOnline(int propertyId, String roomOnlineId) async {
    try {
      final dynamic response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/$propertyId/room_online/$roomOnlineId",
      );
      if (response is bool) return response;
      if (response is Map<String, dynamic>) {
        return response['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Fetch a single room rate by ID
  /// UPDATED: Added propertyId parameter because backend URL pattern requires it.
  /// NOTE: Your room_online.py currently does NOT have a GET route for a single rate ID.
  /// If you use this, you'll need to add it to your Flask backend!
  Future<RoomOnline?> getRoomOnlineById(int propertyId, String id) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/$propertyId/room_online/$id",
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
        // UPDATED PATH:
        "/api/v1/properties/$propertyId/room_online/by_category?category_id=$categoryId",
      );
      return (query['data'] as List)
          .map((e) => RoomOnline.fromResMap(e))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
