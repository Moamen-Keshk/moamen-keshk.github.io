import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/views/revenue_optimization.view.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';

class RevenueOptimizationPage extends StatelessWidget {
  const RevenueOptimizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: PermissionGuard(
        requiredPermission: PmsPermission.manageRates,
        child: RevenueOptimizationView(),
      ),
    );
  }
}
