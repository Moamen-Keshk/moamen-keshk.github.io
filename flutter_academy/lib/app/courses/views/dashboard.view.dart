import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/widgets/floor_card.widget.dart';
import 'package:flutter_academy/main.dart';

class DashboardView extends StatelessWidget {
   const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloorCard(),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                child: const Text("New Category")
              )
        ])]);
  }
}

