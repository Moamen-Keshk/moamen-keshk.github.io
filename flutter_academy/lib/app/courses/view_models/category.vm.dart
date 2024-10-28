import 'package:flutter_academy/infrastructure/courses/model/category.model.dart';

class CategoryVM {
  final Category category;
  CategoryVM(this.category);
  String get name => category.name;
  String get description => category.description;
}
