import 'package:flutter/material.dart';

class CourseDetailsPage extends StatelessWidget {
  final int courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('title'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text("Course id: $courseId"),
        ],
      ),
    );
  }
}
