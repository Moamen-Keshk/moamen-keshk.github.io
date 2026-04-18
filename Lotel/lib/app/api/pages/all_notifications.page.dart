import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/api/views/all_notifications.view.dart';

class AllNotificationsPage extends StatelessWidget {
  const AllNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: SingleChildScrollView(child: AllNotificationsView()),
    );
  }
}
