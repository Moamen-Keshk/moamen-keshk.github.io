import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';

import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';

// Import the smart view we are about to create!
import 'package:lotel_pms/app/channel_manager/views/channel_rate_mapping.view.dart';

class RatePlanMappingPage extends StatelessWidget {
  final String connectionId;

  const RatePlanMappingPage({
    super.key,
    required this.connectionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DashboardNav(),

      body: PermissionGuard(
        requiredPermission: PmsPermission.manageChannels,
        child: ChannelRateMappingView(connectionId: connectionId),
      ),

      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
