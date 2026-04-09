import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/views/edit_season.view.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';

class EditSeasonPage extends StatelessWidget {
  const EditSeasonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardNav(),
      body: Center(heightFactor: 2.0, child: EditSeasonView()),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
