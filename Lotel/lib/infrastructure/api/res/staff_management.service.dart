import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/app/req/request.dart';

class StaffManagementService {
  final _auth = FirebaseAuth.instance;

  // --- GET ALL STAFF ---
  Future<List<dynamic>> getStaffMembers(int propertyId) async {
    try {
      final response = await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/properties/$propertyId/staff",
      );

      if (response != null && response['status'] == 'success') {
        return response['data'] as List<dynamic>;
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

  // --- UPDATE STAFF STATUS (SOFT DELETE / DEACTIVATE) ---
  Future<bool> updateStaffStatus(
      int propertyId, String userId, int statusId) async {
    final payload = {
      "status_id": statusId,
    };

    try {
      return await sendPutRequest(
        payload,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/properties/$propertyId/staff/$userId/status",
      );
    } catch (e) {
      return false;
    }
  }

  // --- REMOVE STAFF MEMBER (HARD DELETE - Kept for future Super Admin use) ---
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
