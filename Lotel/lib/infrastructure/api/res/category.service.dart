import 'package:lotel_pms/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/infrastructure/api/model/category.model.dart';
// 👉 FIX: Hide Flutter's internal Category class to prevent the conflict
import 'package:flutter/foundation.dart' hide Category;

class CategoryService {
  final _auth = FirebaseAuth.instance;

  Future<List<Category>> getAllCategories() async {
    final token = await _auth.currentUser?.getIdToken();
    final query = await sendGetRequest(token, "/api/v1/categories");

    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch categories.");
      return [];
    }
    return (query['data'] as List).map((e) => Category.fromResMap(e)).toList();
  }

  Future<bool> addCategory({
    required String name,
    required int capacity,
    String? description,
  }) async {
    final token = await _auth.currentUser?.getIdToken();
    return await sendPostRequest(
      {
        "name": name,
        "capacity": capacity,
        "description": description ?? '',
      },
      token,
      "/api/v1/categories",
    );
  }

  Future<bool> editCategory(
      String categoryId, Map<String, dynamic> updatedData) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      return await sendPutRequest(
          updatedData, token, "/api/v1/categories/$categoryId");
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      final dynamic response =
          await sendDeleteRequest(token, "/api/v1/categories/$categoryId");

      if (response == null) return false;
      if (response is bool) return response;
      if (response is Map<String, dynamic>) {
        return response['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
