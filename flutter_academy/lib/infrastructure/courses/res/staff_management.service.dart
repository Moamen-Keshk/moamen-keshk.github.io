import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/app/req/request.dart';

class StaffManagementService {
  final _auth = FirebaseAuth.instance;

  // --- GET ALL STAFF ---
  Future<List<Map<String, dynamic>>> getStaffMembers(int propertyId) async {
    try {
      final response = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/properties/$propertyId/staff",
      );

      if (response != null && response['status'] == 'success') {
        final data = response['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((entry) => entry.map(
                    (key, value) => MapEntry(key.toString(), value),
                  ))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- SEND INVITE ---
  Future<bool> sendInvite(int propertyId, String email, int roleId) async {
    final payload = {
      "email": email,
      "role_id": roleId,
    };

    try {
      return await sendPostRequest(
        payload,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/properties/$propertyId/invites",
      );
    } catch (e) {
      return false;
    }
  }

  // --- UPDATE STAFF ROLE ---
  Future<bool> updateStaffRole(
      int propertyId, String userId, int newRoleId) async {
    final payload = {
      "role_id": newRoleId,
    };

    try {
      return await sendPutRequest(
        payload,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/properties/$propertyId/staff/$userId/role",
      );
    } catch (e) {
      return false;
    }
  }

  // --- REMOVE STAFF MEMBER ---
  Future<bool> removeStaff(int propertyId, String userId) async {
    try {
      final dynamic response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/properties/$propertyId/staff/$userId",
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
