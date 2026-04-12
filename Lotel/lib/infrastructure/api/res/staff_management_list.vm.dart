import 'package:lotel_pms/app/users/view_models/user.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/res/staff_management.service.dart';
import 'package:flutter_riverpod/legacy.dart';

class StaffListVM extends StateNotifier<List<UserVM>> {
  final int? propertyId;

  StaffListVM(this.propertyId) : super([]) {
    if (propertyId != null && propertyId != 0) {
      fetchStaff();
    }
  }

  Future<void> fetchStaff() async {
    if (propertyId == null || propertyId == 0) return;

    // Fetches the list of staff from the backend using the service
    final staffMembersData =
        await StaffManagementService().getStaffMembers(propertyId!);

    // Updates the Riverpod state
    state = staffMembersData
        .map(
          (member) => UserVM(
            email: member['email']?.toString() ?? '',
            name: member['username']?.toString() ?? '',
            id: member['user_uid']?.toString() ?? '',
            accountStatusId: _asInt(member['status_id']),
            role: member['role_name']?.toString(),
            propertyId: _asInt(member['property_id']) ?? propertyId,
          ),
        )
        .toList();
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<bool> updateStaffRole(String userId, int newRoleId) async {
    if (propertyId == null || propertyId == 0) return false;

    final success = await StaffManagementService().updateStaffRole(
      propertyId!,
      userId,
      newRoleId,
    );

    // Re-fetch the list to update the UI with the new role
    if (success) await fetchStaff();

    return success;
  }

  Future<bool> removeStaff(String userId) async {
    if (propertyId == null || propertyId == 0) return false;

    final success = await StaffManagementService().removeStaff(
      propertyId!,
      userId,
    );

    // Re-fetch the list to remove the user from the UI
    if (success) await fetchStaff();

    return success;
  }
}

// The Riverpod provider that automatically watches the selected property
final staffListVM = StateNotifierProvider<StaffListVM, List<UserVM>>(
  (ref) => StaffListVM(ref.watch(selectedPropertyVM)),
);
