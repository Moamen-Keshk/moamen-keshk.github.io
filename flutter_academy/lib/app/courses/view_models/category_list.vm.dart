import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/infrastructure/courses/res/category.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryListVM extends StateNotifier<List<CategoryVM>> {
  CategoryListVM() : super(const []) {
    fetchCategories();
  }
  Future<void> fetchCategories() async {
    final res = await CategoryService().getAllCategories();
    state = [...res.map((category) => CategoryVM(category))];
  }

  Future<bool> addToCategories({required String name, required String description}) async {
    if (await CategoryService().addCategory(name, description)) {
      await fetchCategories();
      return true;
    }
    return false;
  }
}

final categoryListVM =
    StateNotifierProvider<CategoryListVM, List<CategoryVM>>(
        (ref) => CategoryListVM());
