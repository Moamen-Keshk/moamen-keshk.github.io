import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/views/staff_management.view.dart'; // The view we created earlier
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: PermissionGuard(
        requiredPermission: PmsPermission.manageStaff,
        child: const Center(
          heightFactor: 2.0,
          child: StaffManagementView(),
        ),
      ),
    );
  }
}
