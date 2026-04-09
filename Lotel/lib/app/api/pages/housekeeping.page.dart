import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/views/housekeeping.view.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';

class HousekeepingPage extends StatelessWidget {
  const HousekeepingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardNav(),
      body: HousekeepingView(),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
