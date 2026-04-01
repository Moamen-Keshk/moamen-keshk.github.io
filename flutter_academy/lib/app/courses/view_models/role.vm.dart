import 'package:flutter_academy/infrastructure/courses/model/role.model.dart';

class RoleVM {
  final Role role;

  RoleVM(this.role);

  int get id => role.id;
  String get name => role.name;
  String get description => role.description;
}
