import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/app/req/request.dart';
import 'package:flutter_academy/infrastructure/courses/model/rate_plan.model.dart';

class RatePlanService {
  final _auth = FirebaseAuth.instance;

  Future<List<RatePlan>> getRatePlans(int propertyId) async {
    final query = await sendGetRequest(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/all_rate_plans/$propertyId",
    );
    return (query['data'] as List).map((e) => RatePlan.fromResMap(e)).toList();
  }

  Future<List<RatePlan>> getRatePlansByCategoryId(
      int propertyId, String categoryId) async {
    final query = await sendGetRequest(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/rate_plans_by_category/$propertyId/$categoryId",
    );
    return (query['data'] as List).map((e) => RatePlan.fromResMap(e)).toList();
  }

  Future<bool> addRatePlan(RatePlan ratePlan) async {
    final payload = {
      "name": ratePlan.name,
      "base_rate": ratePlan.baseRate,
      "property_id": ratePlan.propertyId,
      "category_id": ratePlan.categoryId,
      "start_date": ratePlan.startDate.toIso8601String(),
      "end_date": ratePlan.endDate.toIso8601String(),
      "weekend_rate": ratePlan.weekendRate,
      "seasonal_multiplier": ratePlan.seasonalMultiplier,
      "is_active": ratePlan.isActive,
    };

    return await sendPostRequest(
      payload,
      await _auth.currentUser?.getIdToken(),
      "/api/v1/new_rate_plan",
    );
  }

  Future<RatePlan?> getRatePlanById(String id) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/rate_plan/$id",
      );
      return RatePlan.fromResMap(query['data']);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateRatePlan(RatePlan ratePlan) async {
    final payload = {
      "id": ratePlan.id,
      "name": ratePlan.name,
      "base_rate": ratePlan.baseRate,
      "property_id": ratePlan.propertyId,
      "category_id": ratePlan.categoryId,
      "start_date": ratePlan.startDate.toIso8601String(),
      "end_date": ratePlan.endDate.toIso8601String(),
      "weekend_rate": ratePlan.weekendRate,
      "seasonal_multiplier": ratePlan.seasonalMultiplier,
      "is_active": ratePlan.isActive,
    };

    try {
      return await sendPutRequest(
        payload,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/edit_rate_plan/${ratePlan.id}",
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRatePlan(String ratePlanId) async {
    try {
      final response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/delete_rate_plan/$ratePlanId",
      );
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}
