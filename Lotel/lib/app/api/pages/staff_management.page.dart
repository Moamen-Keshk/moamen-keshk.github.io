import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/views/staff_management.view.dart'; // The view we created earlier
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardNav(),
      body: const Center(
        heightFactor: 2.0,
        child: StaffManagementView(),
      ),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
