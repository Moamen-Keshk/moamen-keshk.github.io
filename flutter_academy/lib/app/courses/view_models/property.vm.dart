import 'package:flutter_academy/infrastructure/courses/model/property.model.dart';

class PropertyVM {
  final Property property;
  PropertyVM(this.property);
  String get name => property.name;
  String get address => property.address;
  String get status => property.status;
  DateTime get publishedDate => property.publishedDate;
}
