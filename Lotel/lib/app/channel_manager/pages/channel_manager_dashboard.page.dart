import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';
import 'package:lotel_pms/app/channel_manager/views/channel_manager_dashboard.view.dart';

class ChannelManagerPage extends StatelessWidget {
  const ChannelManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DashboardNav(),
      body: ChannelManagerView(),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
