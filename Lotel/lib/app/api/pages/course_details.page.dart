import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';

class CourseDetailsPage extends StatelessWidget {
  final int courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('title'),
      ),
      body: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: <Widget>[
            Text("Course id: $courseId"),
          ],
        ),
      ),
    );
  }
}
