import 'package:lotel_pms/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/infrastructure/api/model/property.model.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class PropertyService {
  final _auth = FirebaseAuth.instance;

  // 1. GET PROPERTIES
  Future<List<Property>> getProperty() async {
    final token = await _auth.currentUser?.getIdToken();
    final query = await sendGetRequest(token, "/api/v1/properties");

    // 👉 THE SAFETY NET
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch properties. Returning empty list.");
      return [];
    }

    return (query['data'] as List).map((e) => Property.fromResMap(e)).toList();
  }

  // 2. GET ALL PROPERTIES
  Future<List<Property>> getAllProperties() async {
    final token = await _auth.currentUser?.getIdToken();
    final query = await sendGetRequest(token, "/api/v1/all-properties");

    // 👉 THE SAFETY NET
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch all properties. Returning empty list.");
      return [];
    }

    return (query['data'] as List).map((e) => Property.fromResMap(e)).toList();
  }

  // 3. ADD PROPERTY
  // 👉 UPDATED: Now uses named parameters to accept the full Wizard payload
  Future<bool> addProperty({
    required String name,
    required String address,
    String? phone,
    String? email,
    List<int>? floors,
    List<int>? amenityIds,
  }) async {
    final token = await _auth.currentUser?.getIdToken();

    // Construct the dynamic payload based on what was provided in the wizard
    final Map<String, dynamic> payload = {
      "name": name,
      "address": address,
    };

    if (phone != null && phone.isNotEmpty) payload["phone_number"] = phone;
    if (email != null && email.isNotEmpty) payload["email"] = email;
    if (floors != null && floors.isNotEmpty) payload["floors"] = floors;
    if (amenityIds != null && amenityIds.isNotEmpty) {
      payload["amenity_ids"] = amenityIds;
    }

    return await sendPostRequest(payload, token, "/api/v1/new_property");
  }

  // 4. EDIT PROPERTY
  Future<bool> editProperty(
      int propertyId, Map<String, dynamic> updatedPropertyData) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      return await sendPutRequest(
        updatedPropertyData,
        token,
        "/api/v1/edit_property/$propertyId",
      );
    } catch (e) {
      debugPrint("Error editing property: $e");
      return false;
    }
  }

  Future<bool> deleteProperty(int propertyId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      final dynamic response = await sendDeleteRequest(
        token,
        "/api/v1/properties/$propertyId",
      );

      if (response == null) return false;
      if (response is bool) return response;

      if (response is Map<String, dynamic>) {
        return response['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error deleting property: $e");
      return false;
    }
  }
}
