import 'package:lotel_pms/infrastructure/api/model/property.model.dart';
import 'package:lotel_pms/infrastructure/api/model/amenity.model.dart';

class PropertyVM {
  final Property property;

  PropertyVM(this.property);

  String get id => property.id;
  String get name => property.name;
  String get address => property.address;
  String get phoneNumber => property.phoneNumber;
  String get email => property.email;
  int? get statusId => property.statusId;
  String get status => property.status;
  DateTime get publishedDate => property.publishedDate;
  String get timezone => property.timezone;
  String get currency => property.currency;
  double get taxRate => property.taxRate;
  String get defaultCheckInTime => property.defaultCheckInTime;
  String get defaultCheckOutTime => property.defaultCheckOutTime;
  List<Amenity> get amenities =>
      property.amenities; // <-- Added amenities getter
}
