import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/scripts/load_courses.dart';

class LoadCourses extends StatelessWidget {
  const LoadCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load'),
      ),
      body: ResponsiveContent(
        child: Center(
          child: SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: () {
                loadCourses();
              },
              child: const Text("Load Courses"),
            ),
          ),
        ),
      ),
    );
  }
}
