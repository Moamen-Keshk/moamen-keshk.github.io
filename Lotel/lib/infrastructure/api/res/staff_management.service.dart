import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/app/req/request.dart';

class StaffManagementService {
  final _auth = FirebaseAuth.instance;

  // --- GET ALL STAFF ---
  Future<List<dynamic>> getStaffMembers(int propertyId) async {
    final response = await sendGetRequestOrThrow(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/staff",
      fallbackMessage: 'Failed to load staff members.',
    );

    if (response is! Map<String, dynamic> || response['status'] != 'success') {
      throw ApiRequestException('Failed to load staff members.');
    }

    final data = response['data'];
    if (data is! List<dynamic>) {
      throw ApiRequestException('Invalid staff response from server.');
    }

    return data;
  }

  // --- SEND INVITE ---
  Future<bool> sendInvite(int propertyId, String email, int roleId) async {
    final payload = {
      "email": email,
      "role_id": roleId,
    };

    await sendPostWithResponseRequestOrThrow(
      payload,
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/invites",
      fallbackMessage: 'Failed to send invite.',
    );

    return true;
  }

  // --- UPDATE STAFF ROLE ---
  Future<bool> updateStaffRole(
      int propertyId, String userId, int newRoleId) async {
    final payload = {
      "role_id": newRoleId,
    };

    await sendPutWithResponseRequestOrThrow(
      payload,
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/staff/$userId/role",
      fallbackMessage: 'Failed to update staff role.',
    );

    return true;
  }

  // --- UPDATE STAFF STATUS (SOFT DELETE / DEACTIVATE) ---
  Future<bool> updateStaffStatus(
      int propertyId, String userId, int statusId) async {
    final payload = {
      "status_id": statusId,
    };

    await sendPutWithResponseRequestOrThrow(
      payload,
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/staff/$userId/status",
      fallbackMessage: 'Failed to update user status.',
    );

    return true;
  }

  // --- REMOVE STAFF MEMBER (HARD DELETE - Kept for future Super Admin use) ---
  Future<bool> removeStaff(int propertyId, String userId) async {
    final dynamic response = await sendDeleteRequestOrThrow(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/properties/$propertyId/staff/$userId",
      fallbackMessage: 'Failed to remove user.',
    );

    if (response is Map<String, dynamic>) {
      return response['status'] == 'success';
    }

    throw ApiRequestException('Invalid remove-staff response from server.');
  }
}
