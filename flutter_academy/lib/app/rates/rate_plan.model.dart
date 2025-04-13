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
      'is_active': isActive,
    };
  }

  factory RatePlan.fromMap(String id, Map<String, dynamic> map) {
    return RatePlan(
      id: id,
      name: map['name'] ?? '',
      baseRate: (map['base_rate'] ?? 0).toDouble(),
      propertyId: map['property_id'] ?? '',
      categoryId: map['category_id'] ?? '',
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      weekendRate: map['weekend_rate'] != null
          ? (map['weekend_rate'] as num).toDouble()
          : null,
      seasonalMultiplier: map['seasonal_multiplier'] != null
          ? (map['seasonal_multiplier'] as num).toDouble()
          : null,
      isActive: map['is_active'] ?? true,
    );
  }

  factory RatePlan.fromResMap(Map<String, dynamic> map) {
    return RatePlan.fromMap(map['id'].toString(), map);
  }

  String toJson() => json.encode(toMap());

  factory RatePlan.fromJson(String id, String source) =>
      RatePlan.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'RatePlan(id: $id, name: $name, baseRate: $baseRate, propertyId: $propertyId, categoryId: $categoryId, startDate: $startDate, endDate: $endDate, weekendRate: $weekendRate, seasonalMultiplier: $seasonalMultiplier, isActive: $isActive)';
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
        isActive.hashCode;
  }
}
