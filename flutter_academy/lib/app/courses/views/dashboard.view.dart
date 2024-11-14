import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/widgets/test.widget.dart';
import 'package:flutter_academy/main.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SingleRowMonthCalendar(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
          onPressed: () {
            routerDelegate.go('/new_floor');
          },
          child: const Text("New Floor"),
        ),
        const SizedBox(width: 10.0),
        ElevatedButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () {
              routerDelegate.go('/new_category');
            },
            child: const Text("New Category")),
      ]),
    ]);
  }
}
