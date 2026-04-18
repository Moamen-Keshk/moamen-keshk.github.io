import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/views/new_floor.view.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';

class NewFloorPage extends StatelessWidget {
  const NewFloorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: PermissionGuard(
        requiredPermission: PmsPermission.manageProperty,
        child: Center(heightFactor: 2.0, child: NewFloorView()),
      ),
    );
  }
}
