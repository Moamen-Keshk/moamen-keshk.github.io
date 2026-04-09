import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/views/todays.view.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';

class TodaysPage extends StatelessWidget {
  const TodaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardNav(),
      body: TodaysView(),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
