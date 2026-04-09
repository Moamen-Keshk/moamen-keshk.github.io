import 'package:lotel_pms/infrastructure/api/model/category.model.dart';

class CategoryVM {
  final Category category;

  CategoryVM(this.category);

  String get id => category.id;
  String get name => category.name;
  String get description => category.description;
  int get capacity => category.capacity; // <-- Added capacity getter
}
