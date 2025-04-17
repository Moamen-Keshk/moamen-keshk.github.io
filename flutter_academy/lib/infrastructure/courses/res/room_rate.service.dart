import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/app/req/request.dart';
import 'package:flutter_academy/infrastructure/courses/model/room_rate.model.dart';

class RoomRateService {
  final _auth = FirebaseAuth.instance;

  /// Fetch all room rates for a specific property
  Future<List<RoomRate>> getAllRoomRates(int propertyId) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/all_room_rates/$propertyId",
      );
      return (query['data'] as List)
          .map((e) => RoomRate.fromResMap(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch user-specific room rates (if needed)
  Future<List<RoomRate>> getRoomRate() async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/room_rate",
      );
      return (query['data'] as List)
          .map((e) => RoomRate.fromResMap(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a new room rate
  Future<bool> addRoomRate(RoomRate roomRate) async {
    final payload = {
      "room_id": roomRate.roomId,
      "date": roomRate.date.toIso8601String(),
      "price": roomRate.price,
      "property_id": roomRate.propertyId,
      "category_id": roomRate.categoryId, // ✅ Added categoryId
    };

    try {
      return await sendPostRequest(
        payload,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/new_room_rate",
      );
    } catch (e) {
      return false;
    }
  }

  /// Update an existing room rate (by ID)
  Future<bool> updateRoomRate(RoomRate roomRate) async {
    final payload = {
      "price": roomRate.price,
      "date": roomRate.date.toIso8601String(),
      "category_id": roomRate.categoryId, // ✅ Optional: include if needed
    };

    try {
      return await sendPutRequest(
        payload,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/update_room_rate/${roomRate.id}",
      );
    } catch (e) {
      return false;
    }
  }

  /// Delete a room rate by ID
  Future<bool> deleteRoomRate(String roomRateId) async {
    try {
      final response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/delete_room_rate/$roomRateId",
      );
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  /// Fetch a single room rate by ID
  Future<RoomRate?> getRoomRateById(String id) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/room_rate/$id",
      );
      return RoomRate.fromResMap(query['data']);
    } catch (e) {
      return null;
    }
  }

  /// Fetch room rates by property and category
  Future<List<RoomRate>> getRatesByPropertyAndCategory({
    required int propertyId,
    required String categoryId,
  }) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/room_rates_by_category?property_id=$propertyId&category_id=$categoryId",
      );
      return (query['data'] as List)
          .map((e) => RoomRate.fromResMap(e))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
