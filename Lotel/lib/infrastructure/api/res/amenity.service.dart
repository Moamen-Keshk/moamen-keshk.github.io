import 'package:lotel_pms/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/infrastructure/api/model/amenity.model.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class AmenityService {
  final _auth = FirebaseAuth.instance;

  // 1. GET ALL AMENITIES
  Future<List<Amenity>> getAllAmenities() async {
    final token = await _auth.currentUser?.getIdToken();
    // Assuming you mount the global amenities to /all-amenities or /api/v1/amenities
    final query = await sendGetRequest(token, "/api/v1/amenities");

    // 👉 The Safety Net to prevent the 'null' crash
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch amenities. Returning empty list.");
      return [];
    }

    return (query['data'] as List).map((e) => Amenity.fromResMap(e)).toList();
  }

  // 2. ADD AMENITY
  Future<bool> addAmenity(String name, String? icon) async {
    final token = await _auth.currentUser?.getIdToken();
    return await sendPostRequest(
        {"name": name, "icon": icon}, token, "/api/v1/amenities");
  }

  // 3. EDIT AMENITY
  Future<bool> editAmenity(
      String amenityId, Map<String, dynamic> updatedData) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      return await sendPutRequest(
        updatedData,
        token,
        "/api/v1/amenities/$amenityId",
      );
    } catch (e) {
      debugPrint("Error editing amenity: $e");
      return false;
    }
  }

  // 4. DELETE AMENITY
  Future<bool> deleteAmenity(String amenityId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      final dynamic response = await sendDeleteRequest(
        token,
        "/api/v1/amenities/$amenityId",
      );

      if (response == null) return false;

      // 👉 The boolean fix
      if (response is bool) return response;

      if (response is Map<String, dynamic>) {
        return response['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error deleting amenity: $e");
      return false;
    }
  }
}
