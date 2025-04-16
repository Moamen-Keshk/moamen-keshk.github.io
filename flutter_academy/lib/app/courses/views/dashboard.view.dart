import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/widgets/hotel_calendar.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FloorRooms(),
      Padding(
          padding: EdgeInsets.all(6),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              onPressed: () {
                ref.read(routerProvider).push('edit_property');
              },
              child: const Text("Edit Property"),
            ),
            const SizedBox(width: 10.0),
            ElevatedButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              onPressed: () {
                ref.read(routerProvider).push('hotel_rate_plan');
              },
              child: const Text("Edit Rates"),
            ),
            const SizedBox(width: 10.0),
            ElevatedButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                onPressed: () {
                  ref.read(routerProvider).push('new_category');
                },
                child: const Text("New Category")),
            const SizedBox(width: 10.0),
            ElevatedButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                onPressed: () {
                  ref.read(routerProvider).push('hotel_seasons');
                },
                child: const Text("Seasons"))
          ])),
    ]);
  }
}
