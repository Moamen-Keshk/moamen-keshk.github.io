import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/app/req/request.dart';
import 'package:flutter_academy/app/users/view_models/user.vm.dart';

class StaffManagementService {
  final _auth = FirebaseAuth.instance;

  // --- SEND INVITE ---
  // Uses the endpoint from your Python backend: POST /properties/<id>/invites
  Future<bool> sendInvite(int propertyId, String email, int roleId) async {
    final payload = {
      "email": email,
      "role_id": roleId,
    };

    try {
      return await sendPostRequest(
        payload,
        await _auth.currentUser?.getIdToken(),
        "/properties/$propertyId/invites",
      );
    } catch (e) {
      return false;
    }
  }

  // --- GET ALL STAFF ---
  Future<List<UserVM>> getStaffMembers(int propertyId) async {
    try {
      await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/properties/$propertyId/staff", // Adjust endpoint prefix if needed
      );

      // Note: You will need to add a factory like `UserVM.fromResMap(e)` to your UserVM class
      // return (query['data'] as List).map((e) => UserVM.fromResMap(e)).toList();

      // Temporary return until fromResMap is added:
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- GET SPECIFIC STAFF MEMBER ---
  Future<UserVM?> getStaffMemberById(int propertyId, String userId) async {
    try {
      await sendGetRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/properties/$propertyId/staff/$userId",
      );

      // return UserVM.fromResMap(query['data']);
      return null; // Temporary return until fromResMap is added
    } catch (e) {
      return null;
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
        "/api/v1/properties/$propertyId/staff/$userId",
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
