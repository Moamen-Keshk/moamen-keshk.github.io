import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/api/views/hotel_seasons.view.dart';

class HotelSeasonsPage extends StatelessWidget {
  const HotelSeasonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: PermissionGuard(
        requiredPermission: PmsPermission.manageRates,
        child: HotelSeasonsView(),
      ),
    );
  }
}
