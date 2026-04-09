import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const <Widget>[
          DashboardNav(),
        ],
      ),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
