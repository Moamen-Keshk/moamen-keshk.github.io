import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/views/booking_search.view.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_drawer.widget.dart';
import 'package:lotel_pms/app/api/widgets/dashboard_nav.widget.dart';

class BookingSearchPage extends StatelessWidget {
  const BookingSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardNav(),
      body: PermissionGuard(
        requiredPermission: PmsPermission.viewBookings,
        child: BookingSearchView(),
      ),
      drawer: MediaQuery.of(context).size.width > ScreenSizes.md
          ? null
          : const DashboardDrawer(),
    );
  }
}
