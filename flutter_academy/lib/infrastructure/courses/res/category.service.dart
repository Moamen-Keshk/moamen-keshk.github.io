import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/category.model.dart';

class CategoryService {
  final _auth = FirebaseAuth.instance;
  Future<List<Category>> getCategory() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/categories");
    return (query['data'] as List)
        .map((e) => Category.fromResMap(e))
        .toList();
  }

  Future<List<Category>> getAllCategories() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/all-categories");
    return (query['data'] as List)
        .map((e) => Category.fromResMap(e))
        .toList();
  }

    Future<bool> addCategory(String name, String description) async {
      return await sendPostRequest(
          {"name": name, "description": description},
          await _auth.currentUser?.getIdToken(),
          "/api/v1/new_category");
  }
}
