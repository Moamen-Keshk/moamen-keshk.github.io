import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';
import 'package:lotel_pms/app/api/views/categories_management.view.dart';

class CategoriesManagementPage extends StatelessWidget {
  const CategoriesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DashboardNav(),
      body: PermissionGuard(
        requiredPermission: PmsPermission.manageProperty,
        child: CategoriesManagementView(),
      ),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
