import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/infrastructure/courses/res/category.service.dart';
import 'package:flutter_riverpod/legacy.dart';

class CategoryListVM extends StateNotifier<List<CategoryVM>> {
  // 1. Removed propertyId from the constructor
  CategoryListVM() : super(const []) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    // 2. Call the global service without propertyId
    final res = await CategoryService().getAllCategories();
    state = [...res.map((category) => CategoryVM(category))];
  }

  Future<bool> addToCategories(
      {required String name, required String description}) async {
    // 3. Add category globally without propertyId
    if (await CategoryService().addCategory(name, description)) {
      await fetchCategories();
      return true;
    }
    return false;
  }
}

// 4. The provider no longer needs to watch selectedPropertyVM!
final categoryListVM = StateNotifierProvider<CategoryListVM, List<CategoryVM>>(
    (ref) => CategoryListVM());
