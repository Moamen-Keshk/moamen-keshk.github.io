import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/views/edit_season.view.dart';

class EditSeasonPage extends StatelessWidget {
  const EditSeasonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: PermissionGuard(
        requiredPermission: PmsPermission.manageRates,
        child: Center(heightFactor: 2.0, child: EditSeasonView()),
      ),
    );
  }
}
