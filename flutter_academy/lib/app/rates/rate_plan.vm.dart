import 'package:flutter_academy/app/rates/rate_plan.model.dart';

class RatePlanVM {
  final RatePlan ratePlan;

  RatePlanVM(this.ratePlan);

  String get id => ratePlan.id;
  String get name => ratePlan.name;
  double get baseRate => ratePlan.baseRate;
  int get propertyId => ratePlan.propertyId;
  String get categoryId => ratePlan.categoryId;
  DateTime get startDate => ratePlan.startDate;
  DateTime get endDate => ratePlan.endDate;
  double? get weekendRate => ratePlan.weekendRate;
  double? get seasonalMultiplier => ratePlan.seasonalMultiplier;
  bool get isActive => ratePlan.isActive;

  /// Example computed property
  String get displayPeriod =>
      "${startDate.toLocal().toIso8601String().split('T').first} → ${endDate.toLocal().toIso8601String().split('T').first}";

  /// Example computed property
  double get estimatedAverageRate {
    double rate = baseRate;
    if (seasonalMultiplier != null) {
      rate *= seasonalMultiplier!;
    }
    return rate;
  }

  factory RatePlanVM.empty(DateTime date) {
    return RatePlanVM(
      RatePlan(
        id: '',
        name: 'Default',
        baseRate: 0.0,
        propertyId: 0,
        categoryId: '',
        startDate: date,
        endDate: date,
        isActive: false,
      ),
    );
  }
}
