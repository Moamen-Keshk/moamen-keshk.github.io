import 'package:lotel_pms/app/api/view_models/category.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/category.service.dart';
import 'package:flutter_riverpod/legacy.dart';

class CategoryListVM extends StateNotifier<List<CategoryVM>> {
  bool _disposed = false;
  final CategoryService categoryService;

  CategoryListVM(this.categoryService) : super(const []) {
    fetchCategories();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchCategories() async {
    final res = await categoryService.getAllCategories();
    if (_disposed) return;
    state = [...res.map((category) => CategoryVM(category))];
  }

  Future<bool> addCategory({
    required String name,
    required int capacity,
    String? description,
  }) async {
    if (await categoryService.addCategory(
      name: name,
      capacity: capacity,
      description: description,
    )) {
      await fetchCategories();
      return true;
    }
    return false;
  }

  // 👉 NEW: Edit Category Method
  Future<bool> editCategory(
    String categoryId, {
    required String name,
    required int capacity,
    String? description,
  }) async {
    final success = await categoryService.editCategory(
      categoryId,
      {
        'name': name,
        'capacity': capacity,
        if (description != null) 'description': description,
      },
    );
    if (success) {
      await fetchCategories();
      return true;
    }
    return false;
  }

  Future<bool> deleteCategory(String categoryId) async {
    final success = await categoryService.deleteCategory(categoryId);
    if (success) {
      await fetchCategories();
      return true;
    }
    return false;
  }
}

final categoryListVM = StateNotifierProvider<CategoryListVM, List<CategoryVM>>(
    (ref) => CategoryListVM(CategoryService()));
