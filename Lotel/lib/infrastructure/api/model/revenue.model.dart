const Object _unsetRevenuePolicyField = Object();

class RevenuePolicy {
  final String id;
  final int propertyId;
  final String sellableTypeId;
  final String channelCode;
  final double? minRate;
  final double? maxRate;
  final double highOccupancyThreshold;
  final double lowOccupancyThreshold;
  final double highOccupancyUpliftPct;
  final double lowOccupancyDiscountPct;
  final int shortLeadTimeDays;
  final double shortLeadUpliftPct;
  final int longLeadTimeDays;
  final double longLeadDiscountPct;
  final int pickupWindowDays;
  final double pickupUpliftPct;
  final double channelAdjustmentPct;
  final double autoApplyMinConfidence;

  RevenuePolicy({
    required this.id,
    required this.propertyId,
    required this.sellableTypeId,
    required this.channelCode,
    required this.minRate,
    required this.maxRate,
    required this.highOccupancyThreshold,
    required this.lowOccupancyThreshold,
    required this.highOccupancyUpliftPct,
    required this.lowOccupancyDiscountPct,
    required this.shortLeadTimeDays,
    required this.shortLeadUpliftPct,
    required this.longLeadTimeDays,
    required this.longLeadDiscountPct,
    required this.pickupWindowDays,
    required this.pickupUpliftPct,
    required this.channelAdjustmentPct,
    required this.autoApplyMinConfidence,
  });

  factory RevenuePolicy.empty({
    required int propertyId,
    required String sellableTypeId,
    required String channelCode,
  }) {
    return RevenuePolicy(
      id: '',
      propertyId: propertyId,
      sellableTypeId: sellableTypeId,
      channelCode: channelCode,
      minRate: null,
      maxRate: null,
      highOccupancyThreshold: 0.75,
      lowOccupancyThreshold: 0.35,
      highOccupancyUpliftPct: 12.0,
      lowOccupancyDiscountPct: 8.0,
      shortLeadTimeDays: 7,
      shortLeadUpliftPct: 10.0,
      longLeadTimeDays: 30,
      longLeadDiscountPct: 5.0,
      pickupWindowDays: 3,
      pickupUpliftPct: 6.0,
      channelAdjustmentPct: 0.0,
      autoApplyMinConfidence: 0.85,
    );
  }

  RevenuePolicy copyWith({
    String? id,
    int? propertyId,
    String? sellableTypeId,
    String? channelCode,
    Object? minRate = _unsetRevenuePolicyField,
    Object? maxRate = _unsetRevenuePolicyField,
    double? highOccupancyThreshold,
    double? lowOccupancyThreshold,
    double? highOccupancyUpliftPct,
    double? lowOccupancyDiscountPct,
    int? shortLeadTimeDays,
    double? shortLeadUpliftPct,
    int? longLeadTimeDays,
    double? longLeadDiscountPct,
    int? pickupWindowDays,
    double? pickupUpliftPct,
    double? channelAdjustmentPct,
    double? autoApplyMinConfidence,
  }) {
    return RevenuePolicy(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      sellableTypeId: sellableTypeId ?? this.sellableTypeId,
      channelCode: channelCode ?? this.channelCode,
      minRate: identical(minRate, _unsetRevenuePolicyField)
          ? this.minRate
          : minRate as double?,
      maxRate: identical(maxRate, _unsetRevenuePolicyField)
          ? this.maxRate
          : maxRate as double?,
      highOccupancyThreshold:
          highOccupancyThreshold ?? this.highOccupancyThreshold,
      lowOccupancyThreshold:
          lowOccupancyThreshold ?? this.lowOccupancyThreshold,
      highOccupancyUpliftPct:
          highOccupancyUpliftPct ?? this.highOccupancyUpliftPct,
      lowOccupancyDiscountPct:
          lowOccupancyDiscountPct ?? this.lowOccupancyDiscountPct,
      shortLeadTimeDays: shortLeadTimeDays ?? this.shortLeadTimeDays,
      shortLeadUpliftPct: shortLeadUpliftPct ?? this.shortLeadUpliftPct,
      longLeadTimeDays: longLeadTimeDays ?? this.longLeadTimeDays,
      longLeadDiscountPct: longLeadDiscountPct ?? this.longLeadDiscountPct,
      pickupWindowDays: pickupWindowDays ?? this.pickupWindowDays,
      pickupUpliftPct: pickupUpliftPct ?? this.pickupUpliftPct,
      channelAdjustmentPct: channelAdjustmentPct ?? this.channelAdjustmentPct,
      autoApplyMinConfidence:
          autoApplyMinConfidence ?? this.autoApplyMinConfidence,
    );
  }

  factory RevenuePolicy.fromMap(Map<String, dynamic> map) {
    return RevenuePolicy(
      id: map['id']?.toString() ?? '',
      propertyId: map['property_id'] ?? 0,
      sellableTypeId:
          (map['sellable_type_id'] ?? map['room_type_id'] ?? map['category_id'])
              .toString(),
      channelCode: map['channel_code']?.toString() ?? 'direct',
      minRate: (map['min_rate'] as num?)?.toDouble(),
      maxRate: (map['max_rate'] as num?)?.toDouble(),
      highOccupancyThreshold:
          (map['high_occupancy_threshold'] as num?)?.toDouble() ?? 0.75,
      lowOccupancyThreshold:
          (map['low_occupancy_threshold'] as num?)?.toDouble() ?? 0.35,
      highOccupancyUpliftPct:
          (map['high_occupancy_uplift_pct'] as num?)?.toDouble() ?? 12.0,
      lowOccupancyDiscountPct:
          (map['low_occupancy_discount_pct'] as num?)?.toDouble() ?? 8.0,
      shortLeadTimeDays: map['short_lead_time_days'] ?? 7,
      shortLeadUpliftPct:
          (map['short_lead_uplift_pct'] as num?)?.toDouble() ?? 10.0,
      longLeadTimeDays: map['long_lead_time_days'] ?? 30,
      longLeadDiscountPct:
          (map['long_lead_discount_pct'] as num?)?.toDouble() ?? 5.0,
      pickupWindowDays: map['pickup_window_days'] ?? 3,
      pickupUpliftPct:
          (map['pickup_uplift_pct'] as num?)?.toDouble() ?? 6.0,
      channelAdjustmentPct:
          (map['channel_adjustment_pct'] as num?)?.toDouble() ?? 0.0,
      autoApplyMinConfidence:
          (map['auto_apply_min_confidence'] as num?)?.toDouble() ?? 0.85,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'property_id': propertyId,
      'sellable_type_id': int.tryParse(sellableTypeId),
      'channel_code': channelCode,
      'min_rate': minRate,
      'max_rate': maxRate,
      'high_occupancy_threshold': highOccupancyThreshold,
      'low_occupancy_threshold': lowOccupancyThreshold,
      'high_occupancy_uplift_pct': highOccupancyUpliftPct,
      'low_occupancy_discount_pct': lowOccupancyDiscountPct,
      'short_lead_time_days': shortLeadTimeDays,
      'short_lead_uplift_pct': shortLeadUpliftPct,
      'long_lead_time_days': longLeadTimeDays,
      'long_lead_discount_pct': longLeadDiscountPct,
      'pickup_window_days': pickupWindowDays,
      'pickup_uplift_pct': pickupUpliftPct,
      'channel_adjustment_pct': channelAdjustmentPct,
      'auto_apply_min_confidence': autoApplyMinConfidence,
    };
  }
}

class RevenueRecommendation {
  final String id;
  final String sellableTypeId;
  final String ratePlanId;
  final DateTime stayDate;
  final String channelCode;
  final double baselineAmount;
  final double recommendedAmount;
  final double confidenceScore;
  final String status;
  final List<String> reasonCodes;
  final Map<String, dynamic> explanation;

  RevenueRecommendation({
    required this.id,
    required this.sellableTypeId,
    required this.ratePlanId,
    required this.stayDate,
    required this.channelCode,
    required this.baselineAmount,
    required this.recommendedAmount,
    required this.confidenceScore,
    required this.status,
    required this.reasonCodes,
    required this.explanation,
  });

  factory RevenueRecommendation.fromMap(Map<String, dynamic> map) {
    return RevenueRecommendation(
      id: map['id']?.toString() ?? '',
      sellableTypeId:
          (map['sellable_type_id'] ?? map['room_type_id'] ?? map['category_id'])
              .toString(),
      ratePlanId: map['rate_plan_id']?.toString() ?? '',
      stayDate: DateTime.parse(map['stay_date']),
      channelCode: map['channel_code']?.toString() ?? 'direct',
      baselineAmount: (map['baseline_amount'] as num?)?.toDouble() ?? 0.0,
      recommendedAmount:
          (map['recommended_amount'] as num?)?.toDouble() ?? 0.0,
      confidenceScore: (map['confidence_score'] as num?)?.toDouble() ?? 0.0,
      status: map['status']?.toString() ?? 'pending',
      reasonCodes: (map['reason_codes_json'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      explanation: Map<String, dynamic>.from(
        map['explanation_json'] as Map? ?? const {},
      ),
    );
  }
}

class DailyRevenueRate {
  final String id;
  final String sellableTypeId;
  final String ratePlanId;
  final DateTime stayDate;
  final String channelCode;
  final double baseAmount;
  final double amount;
  final String sourceType;
  final bool isLocked;

  DailyRevenueRate({
    required this.id,
    required this.sellableTypeId,
    required this.ratePlanId,
    required this.stayDate,
    required this.channelCode,
    required this.baseAmount,
    required this.amount,
    required this.sourceType,
    required this.isLocked,
  });

  factory DailyRevenueRate.fromMap(Map<String, dynamic> map) {
    return DailyRevenueRate(
      id: map['id']?.toString() ?? '',
      sellableTypeId:
          (map['sellable_type_id'] ?? map['room_type_id'] ?? map['category_id'])
              .toString(),
      ratePlanId: map['rate_plan_id']?.toString() ?? '',
      stayDate: DateTime.parse(map['stay_date']),
      channelCode: map['channel_code']?.toString() ?? 'base',
      baseAmount: (map['base_amount'] as num?)?.toDouble() ?? 0.0,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      sourceType: map['source_type']?.toString() ?? 'rate_plan',
      isLocked: map['is_locked'] == true,
    );
  }
}

class MarketEventModel {
  final String id;
  final String sellableTypeId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double upliftPct;
  final double flatDelta;
  final bool isActive;

  MarketEventModel({
    required this.id,
    required this.sellableTypeId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.upliftPct,
    required this.flatDelta,
    required this.isActive,
  });

  factory MarketEventModel.fromMap(Map<String, dynamic> map) {
    final rawSellableTypeId =
        map['sellable_type_id'] ?? map['room_type_id'] ?? map['category_id'];
    return MarketEventModel(
      id: map['id']?.toString() ?? '',
      sellableTypeId: rawSellableTypeId?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      upliftPct: (map['uplift_pct'] as num?)?.toDouble() ?? 0.0,
      flatDelta: (map['flat_delta'] as num?)?.toDouble() ?? 0.0,
      isActive: map['is_active'] != false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellable_type_id':
          sellableTypeId.isEmpty ? null : int.tryParse(sellableTypeId),
      'name': name,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'uplift_pct': upliftPct,
      'flat_delta': flatDelta,
      'is_active': isActive,
    };
  }
}
