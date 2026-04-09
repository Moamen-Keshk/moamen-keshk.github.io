import 'package:lotel_pms/infrastructure/api/model/season.model.dart';

class SeasonVM {
  final Season season;
  SeasonVM(this.season);

  String get id => season.id;
  int get propertyId => season.propertyId;
  DateTime get startDate => season.startDate;
  DateTime get endDate => season.endDate;
  String? get label => season.label;
}
