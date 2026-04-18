import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/views/new_season.view.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';

class NewSeasonPage extends StatelessWidget {
  const NewSeasonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: PermissionGuard(
        requiredPermission: PmsPermission.manageRates,
        child: const ResponsiveContent(
          maxWidth: 720,
          child: NewSeasonView(),
        ),
      ),
    );
  }
}
