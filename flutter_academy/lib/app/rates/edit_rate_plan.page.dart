import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';
import 'package:flutter_academy/app/courses/widgets/dashboard_drawer.widget.dart';
import 'package:flutter_academy/app/courses/widgets/dashboard_nav.widget.dart';
import 'package:flutter_academy/app/rates/edit_rate_plan.view.dart';

class EditRatePlanPage extends StatelessWidget {
  const EditRatePlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardNav(),
      body: SingleChildScrollView(
          child: Center(heightFactor: 2.0, child: EditRatePlanView())),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
