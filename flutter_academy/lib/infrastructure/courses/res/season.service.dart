import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/season.model.dart';

class SeasonService {
  final _auth = FirebaseAuth.instance;

  Future<List<Season>> getAllSeasons(int propertyId) async {
    final response = await sendGetRequest(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/all_seasons/$propertyId",
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
    return await sendPostRequest({
      "property_id": propertyId,
      "start_date": startDate.toIso8601String(),
      "end_date": endDate.toIso8601String(),
      if (label != null) "label": label,
    }, await _auth.currentUser?.getIdToken(), "/api/v1/new_season");
  }

  Future<bool> updateSeason({
    required int propertyId,
    required String seasonId,
    required DateTime startDate,
    required DateTime endDate,
    String? label,
  }) async {
    return await sendPutRequest({
      "property_id": propertyId,
      "start_date": startDate.toIso8601String(),
      "end_date": endDate.toIso8601String(),
      if (label != null) "label": label,
    }, await _auth.currentUser?.getIdToken(),
        "/api/v1/update_season/$seasonId");
  }

  Future<bool> deleteSeason(String seasonId) async {
    try {
      final response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/delete_season/$seasonId",
      );
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}
