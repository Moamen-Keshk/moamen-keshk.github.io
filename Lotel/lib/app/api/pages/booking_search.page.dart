import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/views/booking_search.view.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';

class BookingSearchPage extends StatelessWidget {
  const BookingSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: PermissionGuard(
        requiredPermission: PmsPermission.viewBookings,
        child: BookingSearchView(),
      ),
    );
  }
}
