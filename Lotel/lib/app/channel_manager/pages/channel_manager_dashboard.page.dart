import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/channel_manager/views/channel_manager_dashboard.view.dart';

class ChannelManagerPage extends StatelessWidget {
  const ChannelManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: PermissionGuard(
        requiredPermission: PmsPermission.manageChannels,
        child: ChannelManagerView(),
      ),
    );
  }
}
