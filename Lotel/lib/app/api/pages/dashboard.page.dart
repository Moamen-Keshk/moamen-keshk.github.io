import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/views/dashboard.view.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPageScaffold(
      body: DashboardView(),
    );
  }
}
