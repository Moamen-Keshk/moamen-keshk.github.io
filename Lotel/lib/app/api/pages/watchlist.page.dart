import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/api/view_models/course.vm.dart';
import 'package:lotel_pms/app/api/view_models/watchlist.vm.dart';
import 'package:lotel_pms/app/api/widgets/course_card.widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../res/responsive.res.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      body: Consumer(
        builder: ((context, ref, child) {
          final width = MediaQuery.of(context).size.width;
          final List<CourseVM> courses = ref.watch(watchlistVM);
          final horizontalPadding = context.responsiveHorizontalPadding;

          if (courses.isEmpty) {
            return ResponsiveContent(
              child: Center(
                child: Text(
                  'Your watchlist is empty.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          }

          return ResponsiveContent(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              context.responsiveVerticalPadding,
              horizontalPadding,
              0,
            ),
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: width > ScreenSizes.xl
                    ? 4
                    : width > ScreenSizes.lg
                        ? 3
                        : width > ScreenSizes.md
                            ? 2
                            : 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: width > ScreenSizes.md ? 0.88 : 0.98,
              ),
              itemBuilder: (context, index) {
                final course = courses[index];
                return CourseCard(
                    id: course.course.id,
                    image: course.image,
                    title: course.title,
                    onActionPressed: () {},
                    description: course.description);
              },
              itemCount: courses.length,
            ),
          );
        }),
      ),
    );
  }
}
