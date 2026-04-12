import 'package:lotel_pms/app/api/view_models/category.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/res/category.service.dart';
import 'package:flutter_riverpod/legacy.dart';

class CategoryListVM extends StateNotifier<List<CategoryVM>> {
  bool _disposed = false;
  final CategoryService categoryService;
  final int propertyId;

  CategoryListVM(this.categoryService, this.propertyId) : super(const []) {
    fetchCategories();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchCategories() async {
    if (propertyId == 0) {
      if (_disposed) return;
      state = const [];
      return;
    }

    final res = await categoryService.getAllCategories(propertyId);
    if (_disposed) return;
    state = [...res.map((category) => CategoryVM(category))];
  }

  Future<bool> addCategory({
    required String name,
    required int capacity,
    String? description,
  }) async {
    if (propertyId == 0) return false;
    if (await categoryService.addCategory(
      propertyId: propertyId,
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
    if (propertyId == 0) return false;
    final success = await categoryService.editCategory(
      propertyId,
      categoryId,
      {
        'name': name,
        'capacity': capacity,
        'max_guests': capacity,
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
    if (propertyId == 0) return false;
    final success = await categoryService.deleteCategory(propertyId, categoryId);
    if (success) {
      await fetchCategories();
      return true;
    }
    return false;
  }
}

final categoryListVM = StateNotifierProvider<CategoryListVM, List<CategoryVM>>(
    (ref) => CategoryListVM(
          CategoryService(),
          ref.watch(selectedPropertyVM) ?? 0,
        ));
