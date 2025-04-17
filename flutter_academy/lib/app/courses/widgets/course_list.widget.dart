import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';
import 'package:flutter_academy/app/courses/view_models/lists/course_list.vm.dart';
import 'package:flutter_academy/app/courses/widgets/course_card.widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CourseList extends ConsumerWidget {
  const CourseList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(courseListVM);
    final width = MediaQuery.of(context).size.width;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width > ScreenSizes.xl
            ? 4
            : width > ScreenSizes.md
                ? 2
                : 1,
      ),
      itemCount: courses.length,
      itemBuilder: (BuildContext context, int index) {
        final course = courses[index];
        return CourseCard(
            id: course.course.id,
            image: course.image,
            title: course.title,
            onActionPressed: () {},
            description: course.description);
      },
    );
  }
}
