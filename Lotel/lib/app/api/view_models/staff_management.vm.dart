import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lotel_pms/infrastructure/api/res/staff_management.service.dart';

// Model to represent a staff member parsed from the backend
class StaffMember {
  final String userUid;
  final String username;
  final String email;
  final int roleId;
  final String roleName;
  final int statusId;
  final String statusName;
  final bool canManage;
  final bool isCurrentUser;

  StaffMember({
    required this.userUid,
    required this.username,
    required this.email,
    required this.roleId,
    required this.roleName,
    required this.statusId,
    required this.statusName,
    required this.canManage,
    required this.isCurrentUser,
  });

  factory StaffMember.fromMap(Map<String, dynamic> map) {
    return StaffMember(
      userUid: map['user_uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      roleId: map['role_id'] ?? 0,
      roleName: map['role_name'] ?? '',
      statusId: map['status_id'] ?? 0,
      statusName: map['status_name'] ?? '',
      canManage: map['can_manage'] ?? false,
      isCurrentUser: map['is_current_user'] ?? false,
    );
  }
}

class StaffManagementVM extends ChangeNotifier {
  final StaffManagementService _service = StaffManagementService();

  bool isLoading = false;
  String error = '';
  List<StaffMember> staffList = [];

  // --- FETCH STAFF ---
  Future<void> fetchStaff(int propertyId) async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      final data = await _service.getStaffMembers(propertyId);
      staffList = data
          .map((e) => StaffMember.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      error = 'Failed to load staff members.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- SEND INVITE ---
  Future<bool> sendInvite({
    required int propertyId,
    required String email,
    required int roleId,
  }) async {
    isLoading = true;
    error = '';
    notifyListeners();

    final success = await _service.sendInvite(propertyId, email, roleId);

    isLoading = false;
    if (success) {
      notifyListeners();
      return true;
    } else {
      error = 'Failed to send invite.';
      notifyListeners();
      return false;
    }
  }

  // --- UPDATE ROLE ---
  Future<bool> updateRole({
    required int propertyId,
    required String targetUserId,
    required int newRoleId,
  }) async {
    isLoading = true;
    error = '';
    notifyListeners();

    final success =
        await _service.updateStaffRole(propertyId, targetUserId, newRoleId);

    if (success) {
      await fetchStaff(propertyId); // Refresh the list
      return true;
    } else {
      error = 'Failed to update role.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- UPDATE STATUS (DEACTIVATE/ACTIVATE) ---
  Future<bool> updateStatus({
    required int propertyId,
    required String targetUserId,
    required int newStatusId,
  }) async {
    isLoading = true;
    error = '';
    notifyListeners();

    final success =
        await _service.updateStaffStatus(propertyId, targetUserId, newStatusId);

    if (success) {
      await fetchStaff(propertyId); // Refresh the list
      return true;
    } else {
      error = 'Failed to update user status.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- REMOVE STAFF (HARD DELETE) ---
  Future<bool> removeStaff({
    required int propertyId,
    required String targetUserId,
  }) async {
    isLoading = true;
    error = '';
    notifyListeners();

    final success = await _service.removeStaff(propertyId, targetUserId);

    if (success) {
      await fetchStaff(propertyId); // Refresh the list
      return true;
    } else {
      error = 'Failed to remove user.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

final staffManagementVM = ChangeNotifierProvider((ref) => StaffManagementVM());
