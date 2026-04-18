import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/channel_manager/views/channel_room_mapping.view.dart';

class RoomMappingPage extends StatelessWidget {
  final String connectionId;

  const RoomMappingPage({super.key, required this.connectionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Rooms'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: PermissionGuard(
        requiredPermission: PmsPermission.manageChannels,
        child: ChannelRoomMappingView(connectionId: connectionId),
      ),
      drawer: context.showCompactLayout ? const DashboardDrawer() : null,
    );
  }
}
