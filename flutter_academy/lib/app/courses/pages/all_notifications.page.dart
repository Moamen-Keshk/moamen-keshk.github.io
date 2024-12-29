import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';
import 'package:flutter_academy/app/courses/views/all_notifications.view.dart';
import 'package:flutter_academy/app/courses/widgets/dashboard_drawer.widget.dart';
import 'package:flutter_academy/app/courses/widgets/dashboard_nav.widget.dart';

class AllNotificationsPage extends StatelessWidget {
  const AllNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardNav(),
      body: SingleChildScrollView(child: AllNotificationsView()),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
