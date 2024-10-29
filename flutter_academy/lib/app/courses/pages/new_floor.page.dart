import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';
import 'package:flutter_academy/app/courses/views/new_floor.view.dart';
import 'package:flutter_academy/app/courses/widgets/dashboard_drawer.widget.dart';
import 'package:flutter_academy/app/courses/widgets/dashboard_nav.widget.dart';

class NewFloorPage extends StatelessWidget {
  const NewFloorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const <Widget>[DashboardNav(), Center(heightFactor: 2.0, child: NewFloorView())],
      ),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
