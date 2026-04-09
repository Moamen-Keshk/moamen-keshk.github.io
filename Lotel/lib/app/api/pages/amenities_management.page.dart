import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';
import 'package:lotel_pms/app/api/views/amenities_management.view.dart';

class AmenitiesManagementPage extends StatelessWidget {
  const AmenitiesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DashboardNav(),
      body: const AmenitiesManagementView(),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
