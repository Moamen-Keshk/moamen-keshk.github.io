import 'package:flutter_academy/infrastructure/courses/model/amenity.model.dart';

class AmenityVM {
  final Amenity amenity;
  AmenityVM(this.amenity);

  String get id => amenity.id;
  String get name => amenity.name;
  String? get icon => amenity.icon;
}
