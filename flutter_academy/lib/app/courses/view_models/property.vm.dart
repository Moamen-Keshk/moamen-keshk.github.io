import 'package:flutter_academy/infrastructure/courses/model/property.model.dart';
import 'package:flutter_academy/infrastructure/courses/model/amenity.model.dart';

class PropertyVM {
  final Property property;

  PropertyVM(this.property);

  String get id => property.id;
  String get name => property.name;
  String get address => property.address;
  String get phoneNumber => property.phoneNumber;
  String get email => property.email;
  String get status => property.status;
  DateTime get publishedDate => property.publishedDate;
  List<Amenity> get amenities =>
      property.amenities; // <-- Added amenities getter
}
