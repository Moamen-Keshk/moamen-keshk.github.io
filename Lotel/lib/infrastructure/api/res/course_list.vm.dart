import 'package:lotel_pms/app/api/view_models/course.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/course.service.dart';
import 'package:flutter_riverpod/legacy.dart';

class CourseListVM extends StateNotifier<List<CourseVM>> {
  CourseListVM() : super(const []) {
    fetchCourses();
  }
  Future<void> fetchCourses() async {
    final res = await CourseService().getCourses();
    state = [...res.map((course) => CourseVM(course))];
  }
}

final courseListVM = StateNotifierProvider<CourseListVM, List<CourseVM>>(
    (ref) => CourseListVM());
