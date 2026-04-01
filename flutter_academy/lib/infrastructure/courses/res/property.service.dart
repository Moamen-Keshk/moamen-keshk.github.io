import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/property.model.dart';
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
  Future<bool> addProperty(String name, String address) async {
    final token = await _auth.currentUser?.getIdToken();
    return await sendPostRequest(
        {"name": name, "address": address}, token, "/api/v1/new_property");
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
}
