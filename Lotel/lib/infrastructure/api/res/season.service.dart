import 'package:lotel_pms/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/infrastructure/api/model/season.model.dart';

class SeasonService {
  final _auth = FirebaseAuth.instance;

  Future<List<Season>> getAllSeasons(int propertyId) async {
    final response = await sendGetRequest(
      await _auth.currentUser?.getIdToken(),
      // UPDATED PATH:
      "/api/v1/properties/$propertyId/seasons",
    );

    if (response == null || response['data'] == null) return [];

    return (response['data'] as List).map((e) => Season.fromMap(e)).toList();
  }

  Future<bool> addSeason({
    required int propertyId,
    required DateTime startDate,
    required DateTime endDate,
    String? label,
  }) async {
    return await sendPostRequest(
        {
          "property_id": propertyId,
          "start_date": startDate.toIso8601String(),
          "end_date": endDate.toIso8601String(),
          if (label != null) "label": label,
        },
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/$propertyId/seasons");
  }

  Future<bool> updateSeason({
    required int propertyId,
    required String seasonId,
    required DateTime startDate,
    required DateTime endDate,
    String? label,
  }) async {
    return await sendPutRequest(
        {
          "property_id": propertyId,
          "start_date": startDate.toIso8601String(),
          "end_date": endDate.toIso8601String(),
          if (label != null) "label": label,
        },
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/$propertyId/seasons/$seasonId");
  }

  /// UPDATED: Added `propertyId` parameter to match backend URL requirement
  Future<bool> deleteSeason(int propertyId, String seasonId) async {
    try {
      final dynamic response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        // UPDATED PATH:
        "/api/v1/properties/$propertyId/seasons/$seasonId",
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
