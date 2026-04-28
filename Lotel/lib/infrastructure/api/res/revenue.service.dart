import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/app/req/request.dart';
import 'package:lotel_pms/infrastructure/api/model/revenue.model.dart';

class RevenueService {
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> getMetadata(int propertyId) async {
    final response = await sendGetRequestOrThrow(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/metadata",
      fallbackMessage: 'Failed to load revenue metadata.',
    );
    return Map<String, dynamic>.from(response['data'] as Map? ?? const {});
  }

  Future<List<RevenuePolicy>> getPolicies(
    int propertyId, {
    String? sellableTypeId,
    String? channelCode,
  }) async {
    final response = await sendGetWithParamsRequestOrThrow(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/policies",
      {
        'sellable_type_id': sellableTypeId,
        'channel_code': channelCode,
      },
      fallbackMessage: 'Failed to load revenue policies.',
    );
    return (response['data'] as List<dynamic>? ?? const [])
        .map((e) => RevenuePolicy.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<RevenuePolicy> savePolicy(int propertyId, RevenuePolicy policy) async {
    final response = await sendPutWithResponseRequestOrThrow(
      policy.toMap(),
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/policies",
      fallbackMessage: 'Failed to save revenue policy.',
    );
    return RevenuePolicy.fromMap(
      Map<String, dynamic>.from(response['data'] as Map? ?? const {}),
    );
  }

  Future<List<MarketEventModel>> getEvents(
    int propertyId, {
    String? sellableTypeId,
  }) async {
    final response = await sendGetWithParamsRequestOrThrow(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/events",
      {'sellable_type_id': sellableTypeId},
      fallbackMessage: 'Failed to load market events.',
    );
    return (response['data'] as List<dynamic>? ?? const [])
        .map((e) => MarketEventModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<MarketEventModel> createEvent(
    int propertyId,
    MarketEventModel event,
  ) async {
    final response = await sendPostWithResponseRequestOrThrow(
      event.toMap(),
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/events",
      fallbackMessage: 'Failed to create market event.',
    );
    return MarketEventModel.fromMap(
      Map<String, dynamic>.from(response['data'] as Map? ?? const {}),
    );
  }

  Future<MarketEventModel> updateEvent(
    int propertyId,
    MarketEventModel event,
  ) async {
    final response = await sendPutWithResponseRequestOrThrow(
      event.toMap(),
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/events/${event.id}",
      fallbackMessage: 'Failed to update market event.',
    );
    return MarketEventModel.fromMap(
      Map<String, dynamic>.from(response['data'] as Map? ?? const {}),
    );
  }

  Future<void> deleteEvent(int propertyId, String eventId) async {
    await sendDeleteRequestOrThrow(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/events/$eventId",
      fallbackMessage: 'Failed to delete market event.',
    );
  }

  Future<List<RevenueRecommendation>> recomputeRecommendations(
    int propertyId, {
    required DateTime startDate,
    required DateTime endDate,
    String? sellableTypeId,
    String? ratePlanId,
    String? channelCode,
  }) async {
    final response = await sendPostWithResponseRequestOrThrow(
      {
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'sellable_type_id':
            sellableTypeId == null ? null : int.tryParse(sellableTypeId),
        'rate_plan_id': ratePlanId == null ? null : int.tryParse(ratePlanId),
        'channel_code': channelCode,
      },
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/recommendations",
      fallbackMessage: 'Failed to recompute recommendations.',
    );
    return (response['data'] as List<dynamic>? ?? const [])
        .map((e) => RevenueRecommendation.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<RevenueRecommendation>> getRecommendations(
    int propertyId, {
    required DateTime startDate,
    required DateTime endDate,
    String? sellableTypeId,
    String? ratePlanId,
    String? channelCode,
  }) async {
    final response = await sendGetWithParamsRequestOrThrow(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/recommendations",
      {
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'sellable_type_id': sellableTypeId,
        'rate_plan_id': ratePlanId,
        'channel_code': channelCode,
      },
      fallbackMessage: 'Failed to load recommendations.',
    );
    return (response['data'] as List<dynamic>? ?? const [])
        .map((e) => RevenueRecommendation.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<DailyRevenueRate>> getDailyRates(
    int propertyId, {
    required DateTime startDate,
    required DateTime endDate,
    String? sellableTypeId,
    String? ratePlanId,
    String? channelCode,
  }) async {
    final response = await sendGetWithParamsRequestOrThrow(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/daily_rates",
      {
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'sellable_type_id': sellableTypeId,
        'rate_plan_id': ratePlanId,
        'channel_code': channelCode,
      },
      fallbackMessage: 'Failed to load daily rates.',
    );
    return (response['data'] as List<dynamic>? ?? const [])
        .map((e) => DailyRevenueRate.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<DailyRevenueRate> applyRecommendation(
    int propertyId,
    String recommendationId, {
    bool lock = false,
  }) async {
    final response = await sendPostWithResponseRequestOrThrow(
      {'lock': lock},
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/recommendations/$recommendationId/apply",
      fallbackMessage: 'Failed to apply recommendation.',
    );
    return DailyRevenueRate.fromMap(
      Map<String, dynamic>.from(response['data'] as Map? ?? const {}),
    );
  }

  Future<DailyRevenueRate> overrideDailyRate(
    int propertyId, {
    required String sellableTypeId,
    required String ratePlanId,
    required DateTime stayDate,
    required String channelCode,
    required double amount,
    required bool lock,
    String? note,
  }) async {
    final response = await sendPutWithResponseRequestOrThrow(
      {
        'sellable_type_id': int.tryParse(sellableTypeId),
        'rate_plan_id': int.tryParse(ratePlanId),
        'stay_date': stayDate.toIso8601String().split('T').first,
        'channel_code': channelCode,
        'amount': amount,
        'lock': lock,
        'note': note,
      },
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/daily_rates/override",
      fallbackMessage: 'Failed to save manual override.',
    );
    return DailyRevenueRate.fromMap(
      Map<String, dynamic>.from(response['data'] as Map? ?? const {}),
    );
  }

  Future<void> resetDailyRate(
    int propertyId, {
    required String sellableTypeId,
    required String ratePlanId,
    required DateTime stayDate,
    required String channelCode,
  }) async {
    await sendPostWithResponseRequestOrThrow(
      {
        'sellable_type_id': int.tryParse(sellableTypeId),
        'rate_plan_id': int.tryParse(ratePlanId),
        'stay_date': stayDate.toIso8601String().split('T').first,
        'channel_code': channelCode,
      },
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/revenue/daily_rates/reset",
      fallbackMessage: 'Failed to reset manual override.',
    );
  }
}
