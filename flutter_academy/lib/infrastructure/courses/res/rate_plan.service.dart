import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/app/req/request.dart';
import 'package:flutter_academy/infrastructure/courses/model/rate_plan.model.dart';

class RatePlanService {
  final _auth = FirebaseAuth.instance;

  Future<List<RatePlan>> getRatePlans(int propertyId) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/$propertyId/rate_plans",
      );
      return (query['data'] as List)
          .map((e) => RatePlan.fromResMap(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<RatePlan>> getRatePlansByCategoryId(
      int propertyId, String categoryId) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/$propertyId/categories/$categoryId/rate_plans",
      );
      return (query['data'] as List)
          .map((e) => RatePlan.fromResMap(e))
          .toList();
    } catch (e) {
      return [];
    }
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

    try {
      return await sendPostRequest(
        payload,
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/${ratePlan.propertyId}/rate_plans",
      );
    } catch (e) {
      return false;
    }
  }

  /// UPDATED: Added `propertyId` parameter to match the backend URL requirement
  Future<RatePlan?> getRatePlanById(int propertyId, String id) async {
    try {
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/$propertyId/rate_plans/$id",
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
        // UPDATED PATH:
        "/api/v1/properties/${ratePlan.propertyId}/rate_plans/${ratePlan.id}",
      );
    } catch (e) {
      return false;
    }
  }

  /// UPDATED: Added `propertyId` parameter to match the backend URL requirement
  Future<bool> deleteRatePlan(int propertyId, String ratePlanId) async {
    try {
      final dynamic response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/$propertyId/rate_plans/$ratePlanId",
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
}
