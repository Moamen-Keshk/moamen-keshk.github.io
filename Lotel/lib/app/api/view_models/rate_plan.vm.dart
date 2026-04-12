import 'package:lotel_pms/infrastructure/api/model/rate_plan.model.dart';

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
  String get pricingType => ratePlan.pricingType;
  String? get parentRatePlanId => ratePlan.parentRatePlanId;
  String? get derivedAdjustmentType => ratePlan.derivedAdjustmentType;
  double? get derivedAdjustmentValue => ratePlan.derivedAdjustmentValue;
  int? get includedOccupancy => ratePlan.includedOccupancy;
  double? get singleOccupancyRate => ratePlan.singleOccupancyRate;
  double? get extraAdultRate => ratePlan.extraAdultRate;
  double? get extraChildRate => ratePlan.extraChildRate;
  int? get minLos => ratePlan.minLos;
  int? get maxLos => ratePlan.maxLos;
  bool get closed => ratePlan.closed;
  bool get closedToArrival => ratePlan.closedToArrival;
  bool get closedToDeparture => ratePlan.closedToDeparture;
  String? get mealPlanCode => ratePlan.mealPlanCode;
  String? get cancellationPolicy => ratePlan.cancellationPolicy;
  List<Map<String, dynamic>> get losPricing => ratePlan.losPricing;
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
