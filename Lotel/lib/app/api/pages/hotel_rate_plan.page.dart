import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';
import 'package:lotel_pms/app/api/views/hotel_rate_plans.view.dart';

class HotelRatePlansPage extends StatelessWidget {
  const HotelRatePlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardNav(),
      body: HotelRatePlansView(),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
