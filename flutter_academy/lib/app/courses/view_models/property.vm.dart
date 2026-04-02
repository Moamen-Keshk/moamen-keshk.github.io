import 'package:flutter_academy/infrastructure/courses/model/property.model.dart';

class PropertyVM {
  final Property property;

  PropertyVM(this.property);

  String get id => property.id;
  String get name => property.name;
  String get address => property.address;
  String get phoneNumber =>
      property.phoneNumber; // <-- Added phone number getter
  String get email => property.email; // <-- Added email getter
  String get status => property.status;
  DateTime get publishedDate => property.publishedDate;
}
