import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/widgets/hotel_calendar.widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        FloorRooms(),
      ],
    );
  }
}
