import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/app/req/request.dart';
import 'package:lotel_pms/infrastructure/api/model/rate_plan.model.dart';

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
        "/api/v1/properties/$propertyId/room_types/$categoryId/rate_plans",
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
      "room_type_id": ratePlan.categoryId,
      "start_date": ratePlan.startDate.toIso8601String(),
      "end_date": ratePlan.endDate.toIso8601String(),
      "weekend_rate": ratePlan.weekendRate,
      "seasonal_multiplier": ratePlan.seasonalMultiplier,
      "pricing_type": ratePlan.pricingType,
      "parent_rate_plan_id": ratePlan.parentRatePlanId,
      "derived_adjustment_type": ratePlan.derivedAdjustmentType,
      "derived_adjustment_value": ratePlan.derivedAdjustmentValue,
      "included_occupancy": ratePlan.includedOccupancy,
      "single_occupancy_rate": ratePlan.singleOccupancyRate,
      "extra_adult_rate": ratePlan.extraAdultRate,
      "extra_child_rate": ratePlan.extraChildRate,
      "min_los": ratePlan.minLos,
      "max_los": ratePlan.maxLos,
      "closed": ratePlan.closed,
      "closed_to_arrival": ratePlan.closedToArrival,
      "closed_to_departure": ratePlan.closedToDeparture,
      "meal_plan_code": ratePlan.mealPlanCode,
      "cancellation_policy": ratePlan.cancellationPolicy,
      "los_pricing": ratePlan.losPricing,
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
      "room_type_id": ratePlan.categoryId,
      "start_date": ratePlan.startDate.toIso8601String(),
      "end_date": ratePlan.endDate.toIso8601String(),
      "weekend_rate": ratePlan.weekendRate,
      "seasonal_multiplier": ratePlan.seasonalMultiplier,
      "pricing_type": ratePlan.pricingType,
      "parent_rate_plan_id": ratePlan.parentRatePlanId,
      "derived_adjustment_type": ratePlan.derivedAdjustmentType,
      "derived_adjustment_value": ratePlan.derivedAdjustmentValue,
      "included_occupancy": ratePlan.includedOccupancy,
      "single_occupancy_rate": ratePlan.singleOccupancyRate,
      "extra_adult_rate": ratePlan.extraAdultRate,
      "extra_child_rate": ratePlan.extraChildRate,
      "min_los": ratePlan.minLos,
      "max_los": ratePlan.maxLos,
      "closed": ratePlan.closed,
      "closed_to_arrival": ratePlan.closedToArrival,
      "closed_to_departure": ratePlan.closedToDeparture,
      "meal_plan_code": ratePlan.mealPlanCode,
      "cancellation_policy": ratePlan.cancellationPolicy,
      "los_pricing": ratePlan.losPricing,
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

  Future<Map<String, dynamic>?> getRatePlanQuote({
    required int propertyId,
    required String ratePlanId,
    required DateTime checkIn,
    required DateTime checkOut,
    int adults = 2,
    int children = 0,
    String? channelCode,
  }) async {
    try {
      final channelQuery =
          channelCode == null || channelCode.isEmpty ? '' : '&channel_code=$channelCode';
      final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/properties/$propertyId/rate_plans/$ratePlanId/quote?check_in=${checkIn.toIso8601String().split('T').first}&check_out=${checkOut.toIso8601String().split('T').first}&adults=$adults&children=$children$channelQuery",
      );
      return query['data'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}
