import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/category.model.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class CategoryService {
  final _auth = FirebaseAuth.instance;

  // 1. GET ALL CATEGORIES (Global)
  Future<List<Category>> getCategory() async {
    final token = await _auth.currentUser?.getIdToken();
    final query = await sendGetRequest(token, "/api/v1/categories");

    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch categories. Returning empty list.");
      return [];
    }

    return (query['data'] as List).map((e) => Category.fromResMap(e)).toList();
  }

  // 2. GET ALL CATEGORIES (Alias for backward compatibility in your UI)
  Future<List<Category>> getAllCategories() async {
    return await getCategory();
  }

  // 3. ADD CATEGORY (Global)
  Future<bool> addCategory(String name, String description) async {
    final token = await _auth.currentUser?.getIdToken();
    return await sendPostRequest(
        {"name": name, "description": description},
        token,
        "/api/v1/categories");
  }
}
