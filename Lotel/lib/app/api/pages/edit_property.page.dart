import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/views/edit_property.view.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';

class EditPropertyPage extends StatelessWidget {
  const EditPropertyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: PermissionGuard(
        requiredPermission: PmsPermission.manageProperty,
        child: EditPropertyView(),
      ),
    );
  }
}
