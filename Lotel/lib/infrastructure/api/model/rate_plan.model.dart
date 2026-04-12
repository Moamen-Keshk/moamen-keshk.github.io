import 'dart:convert';

class RatePlan {
  final String id;
  final String name;
  final double baseRate;
  final int propertyId;
  final String categoryId;
  final DateTime startDate;
  final DateTime endDate;
  final double? weekendRate;
  final double? seasonalMultiplier;
  final String pricingType;
  final String? parentRatePlanId;
  final String? derivedAdjustmentType;
  final double? derivedAdjustmentValue;
  final int? includedOccupancy;
  final double? singleOccupancyRate;
  final double? extraAdultRate;
  final double? extraChildRate;
  final int? minLos;
  final int? maxLos;
  final bool closed;
  final bool closedToArrival;
  final bool closedToDeparture;
  final String? mealPlanCode;
  final String? cancellationPolicy;
  final List<Map<String, dynamic>> losPricing;
  final bool isActive;

  RatePlan({
    required this.id,
    required this.name,
    required this.baseRate,
    required this.propertyId,
    required this.categoryId,
    required this.startDate,
    required this.endDate,
    this.weekendRate,
    this.seasonalMultiplier,
    this.pricingType = 'standard',
    this.parentRatePlanId,
    this.derivedAdjustmentType,
    this.derivedAdjustmentValue,
    this.includedOccupancy,
    this.singleOccupancyRate,
    this.extraAdultRate,
    this.extraChildRate,
    this.minLos,
    this.maxLos,
    this.closed = false,
    this.closedToArrival = false,
    this.closedToDeparture = false,
    this.mealPlanCode,
    this.cancellationPolicy,
    this.losPricing = const [],
    this.isActive = true,
  });

  RatePlan copyWith({
    String? id,
    String? name,
    double? baseRate,
    int? propertyId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    double? weekendRate,
    double? seasonalMultiplier,
    String? pricingType,
    String? parentRatePlanId,
    String? derivedAdjustmentType,
    double? derivedAdjustmentValue,
    int? includedOccupancy,
    double? singleOccupancyRate,
    double? extraAdultRate,
    double? extraChildRate,
    int? minLos,
    int? maxLos,
    bool? closed,
    bool? closedToArrival,
    bool? closedToDeparture,
    String? mealPlanCode,
    String? cancellationPolicy,
    List<Map<String, dynamic>>? losPricing,
    bool? isActive,
  }) {
    return RatePlan(
      id: id ?? this.id,
      name: name ?? this.name,
      baseRate: baseRate ?? this.baseRate,
      propertyId: propertyId ?? this.propertyId,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weekendRate: weekendRate ?? this.weekendRate,
      seasonalMultiplier: seasonalMultiplier ?? this.seasonalMultiplier,
      pricingType: pricingType ?? this.pricingType,
      parentRatePlanId: parentRatePlanId ?? this.parentRatePlanId,
      derivedAdjustmentType:
          derivedAdjustmentType ?? this.derivedAdjustmentType,
      derivedAdjustmentValue:
          derivedAdjustmentValue ?? this.derivedAdjustmentValue,
      includedOccupancy: includedOccupancy ?? this.includedOccupancy,
      singleOccupancyRate: singleOccupancyRate ?? this.singleOccupancyRate,
      extraAdultRate: extraAdultRate ?? this.extraAdultRate,
      extraChildRate: extraChildRate ?? this.extraChildRate,
      minLos: minLos ?? this.minLos,
      maxLos: maxLos ?? this.maxLos,
      closed: closed ?? this.closed,
      closedToArrival: closedToArrival ?? this.closedToArrival,
      closedToDeparture: closedToDeparture ?? this.closedToDeparture,
      mealPlanCode: mealPlanCode ?? this.mealPlanCode,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      losPricing: losPricing ?? this.losPricing,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'base_rate': baseRate,
      'property_id': propertyId,
      'category_id': categoryId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'weekend_rate': weekendRate,
      'seasonal_multiplier': seasonalMultiplier,
      'pricing_type': pricingType,
      'parent_rate_plan_id': parentRatePlanId,
      'derived_adjustment_type': derivedAdjustmentType,
      'derived_adjustment_value': derivedAdjustmentValue,
      'included_occupancy': includedOccupancy,
      'single_occupancy_rate': singleOccupancyRate,
      'extra_adult_rate': extraAdultRate,
      'extra_child_rate': extraChildRate,
      'min_los': minLos,
      'max_los': maxLos,
      'closed': closed,
      'closed_to_arrival': closedToArrival,
      'closed_to_departure': closedToDeparture,
      'meal_plan_code': mealPlanCode,
      'cancellation_policy': cancellationPolicy,
      'los_pricing': losPricing,
      'is_active': isActive,
    };
  }

  factory RatePlan.fromMap(String id, Map<String, dynamic> map) {
    return RatePlan(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      baseRate: (map['base_rate'] ?? 0).toDouble(),
      propertyId: map['property_id'] ?? 0,
      categoryId: map['category_id'].toString(),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      weekendRate: map['weekend_rate'] != null
          ? (map['weekend_rate'] as num).toDouble()
          : null,
      seasonalMultiplier: map['seasonal_multiplier'] != null
          ? (map['seasonal_multiplier'] as num).toDouble()
          : null,
      pricingType: map['pricing_type'] ?? 'standard',
      parentRatePlanId: map['parent_rate_plan_id']?.toString(),
      derivedAdjustmentType: map['derived_adjustment_type'],
      derivedAdjustmentValue: map['derived_adjustment_value'] != null
          ? (map['derived_adjustment_value'] as num).toDouble()
          : null,
      includedOccupancy: map['included_occupancy'] is String
          ? int.tryParse(map['included_occupancy'])
          : map['included_occupancy'],
      singleOccupancyRate: map['single_occupancy_rate'] != null
          ? (map['single_occupancy_rate'] as num).toDouble()
          : null,
      extraAdultRate: map['extra_adult_rate'] != null
          ? (map['extra_adult_rate'] as num).toDouble()
          : null,
      extraChildRate: map['extra_child_rate'] != null
          ? (map['extra_child_rate'] as num).toDouble()
          : null,
      minLos: map['min_los'] is String
          ? int.tryParse(map['min_los'])
          : map['min_los'],
      maxLos: map['max_los'] is String
          ? int.tryParse(map['max_los'])
          : map['max_los'],
      closed: map['closed'] ?? false,
      closedToArrival: map['closed_to_arrival'] ?? false,
      closedToDeparture: map['closed_to_departure'] ?? false,
      mealPlanCode: map['meal_plan_code'],
      cancellationPolicy: map['cancellation_policy'],
      losPricing: (map['los_pricing'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          const [],
      isActive: map['is_active'] ?? true,
    );
  }

  factory RatePlan.fromResMap(Map<String, dynamic> map) {
    return RatePlan(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      baseRate: (map['base_rate'] ?? 0).toDouble(),
      propertyId: map['property_id'] ?? 0,
      categoryId: map['category_id'].toString(),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      weekendRate: map['weekend_rate'] != null
          ? (map['weekend_rate'] as num).toDouble()
          : null,
      seasonalMultiplier: map['seasonal_multiplier'] != null
          ? (map['seasonal_multiplier'] as num).toDouble()
          : null,
      pricingType: map['pricing_type'] ?? 'standard',
      parentRatePlanId: map['parent_rate_plan_id']?.toString(),
      derivedAdjustmentType: map['derived_adjustment_type'],
      derivedAdjustmentValue: map['derived_adjustment_value'] != null
          ? (map['derived_adjustment_value'] as num).toDouble()
          : null,
      includedOccupancy: map['included_occupancy'] is String
          ? int.tryParse(map['included_occupancy'])
          : map['included_occupancy'],
      singleOccupancyRate: map['single_occupancy_rate'] != null
          ? (map['single_occupancy_rate'] as num).toDouble()
          : null,
      extraAdultRate: map['extra_adult_rate'] != null
          ? (map['extra_adult_rate'] as num).toDouble()
          : null,
      extraChildRate: map['extra_child_rate'] != null
          ? (map['extra_child_rate'] as num).toDouble()
          : null,
      minLos: map['min_los'] is String
          ? int.tryParse(map['min_los'])
          : map['min_los'],
      maxLos: map['max_los'] is String
          ? int.tryParse(map['max_los'])
          : map['max_los'],
      closed: map['closed'] ?? false,
      closedToArrival: map['closed_to_arrival'] ?? false,
      closedToDeparture: map['closed_to_departure'] ?? false,
      mealPlanCode: map['meal_plan_code'],
      cancellationPolicy: map['cancellation_policy'],
      losPricing: (map['los_pricing'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          const [],
      isActive: map['is_active'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory RatePlan.fromJson(String id, String source) =>
      RatePlan.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'RatePlan(id: $id, name: $name, baseRate: $baseRate, propertyId: $propertyId, categoryId: $categoryId, startDate: $startDate, endDate: $endDate, weekendRate: $weekendRate, seasonalMultiplier: $seasonalMultiplier, pricingType: $pricingType, parentRatePlanId: $parentRatePlanId, derivedAdjustmentType: $derivedAdjustmentType, derivedAdjustmentValue: $derivedAdjustmentValue, includedOccupancy: $includedOccupancy, singleOccupancyRate: $singleOccupancyRate, extraAdultRate: $extraAdultRate, extraChildRate: $extraChildRate, minLos: $minLos, maxLos: $maxLos, closed: $closed, closedToArrival: $closedToArrival, closedToDeparture: $closedToDeparture, mealPlanCode: $mealPlanCode, cancellationPolicy: $cancellationPolicy, losPricing: $losPricing, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RatePlan &&
        other.id == id &&
        other.name == name &&
        other.baseRate == baseRate &&
        other.propertyId == propertyId &&
        other.categoryId == categoryId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.weekendRate == weekendRate &&
        other.seasonalMultiplier == seasonalMultiplier &&
        other.pricingType == pricingType &&
        other.parentRatePlanId == parentRatePlanId &&
        other.derivedAdjustmentType == derivedAdjustmentType &&
        other.derivedAdjustmentValue == derivedAdjustmentValue &&
        other.includedOccupancy == includedOccupancy &&
        other.singleOccupancyRate == singleOccupancyRate &&
        other.extraAdultRate == extraAdultRate &&
        other.extraChildRate == extraChildRate &&
        other.minLos == minLos &&
        other.maxLos == maxLos &&
        other.closed == closed &&
        other.closedToArrival == closedToArrival &&
        other.closedToDeparture == closedToDeparture &&
        other.mealPlanCode == mealPlanCode &&
        other.cancellationPolicy == cancellationPolicy &&
        other.losPricing.toString() == losPricing.toString() &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        baseRate.hashCode ^
        categoryId.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        weekendRate.hashCode ^
        seasonalMultiplier.hashCode ^
        pricingType.hashCode ^
        parentRatePlanId.hashCode ^
        derivedAdjustmentType.hashCode ^
        derivedAdjustmentValue.hashCode ^
        includedOccupancy.hashCode ^
        singleOccupancyRate.hashCode ^
        extraAdultRate.hashCode ^
        extraChildRate.hashCode ^
        minLos.hashCode ^
        maxLos.hashCode ^
        closed.hashCode ^
        closedToArrival.hashCode ^
        closedToDeparture.hashCode ^
        mealPlanCode.hashCode ^
        cancellationPolicy.hashCode ^
        losPricing.hashCode ^
        isActive.hashCode;
  }
}
