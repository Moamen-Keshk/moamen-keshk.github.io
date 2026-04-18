import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/views/categories_management.view.dart';

class CategoriesManagementPage extends StatelessWidget {
  const CategoriesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: PermissionGuard(
        requiredPermission: PmsPermission.manageProperty,
        child: CategoriesManagementView(),
      ),
    );
  }
}
