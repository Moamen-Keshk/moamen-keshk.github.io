import 'package:lotel_pms/app/api/view_models/role.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/res/role.service.dart'; // We will define this below
import 'package:flutter_riverpod/legacy.dart';

class RoleListVM extends StateNotifier<List<RoleVM>> {
  bool _disposed = false;
  final int? propertyId;
  final RoleService roleService;

  RoleListVM(this.propertyId, this.roleService) : super(const []) {
    if (propertyId != null && propertyId != 0) {
      fetchRoles();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchRoles() async {
    if (propertyId == null || propertyId == 0) return;

    try {
      final res = await roleService.getAssignableRoles(propertyId!);

      if (_disposed) return;

      state = [...res.map((role) => RoleVM(role))];
    } catch (_) {
      if (_disposed) return;
      state = const [];
    }
  }
}

// The provider automatically watches the selected property and injects the service
final roleListVM = StateNotifierProvider<RoleListVM, List<RoleVM>>(
    (ref) => RoleListVM(ref.watch(selectedPropertyVM), RoleService()));
