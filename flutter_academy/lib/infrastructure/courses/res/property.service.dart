import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/property.model.dart';

class PropertyService {
  final _auth = FirebaseAuth.instance;
  Future<List<Property>> getProperty() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/properties");
    return (query['data'] as List).map((e) => Property.fromResMap(e)).toList();
  }

  Future<List<Property>> getAllProperties() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/all-properties");
    return (query['data'] as List).map((e) => Property.fromResMap(e)).toList();
  }

  Future<bool> addProperty(String name, String address) async {
    return await sendPostRequest({"name": name, "address": address},
        await _auth.currentUser?.getIdToken(), "/api/v1/new_property");
  }

  Future<bool> editProperty(
      int propertyId, Map<String, dynamic> updatedPropertyData) async {
    try {
      final response = await sendPutRequest(
        updatedPropertyData,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/edit_property/$propertyId",
      );
      return response; // Assuming the API returns a 'success' key
    } catch (e) {
      return false;
    }
  }
}
