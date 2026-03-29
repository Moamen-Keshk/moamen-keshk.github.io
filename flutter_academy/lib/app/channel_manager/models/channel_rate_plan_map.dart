import 'dart:convert';

class ChannelRatePlanMap {
  final String id;
  final int propertyId;
  final String channelCode; // FIX: Matched to Flask's 'channel_code'
  final String
      internalRatePlanId; // FIX: Matched to Flask's 'internal_rate_plan_id'
  final String? internalRatePlanName; // Optional: Kept for UI convenience
  final String
      externalRatePlanId; // FIX: Matched to Flask's 'external_rate_plan_id'
  final String?
      externalRatePlanName; // FIX: Matched to Flask's 'external_rate_plan_name'
  final bool isActive;

  ChannelRatePlanMap({
    required this.id,
    required this.propertyId,
    required this.channelCode,
    required this.internalRatePlanId,
    this.internalRatePlanName,
    required this.externalRatePlanId,
    this.externalRatePlanName,
    this.isActive = true,
  });

  ChannelRatePlanMap copyWith({
    String? id,
    int? propertyId,
    String? channelCode,
    String? internalRatePlanId,
    String? internalRatePlanName,
    String? externalRatePlanId,
    String? externalRatePlanName,
    bool? isActive,
  }) {
    return ChannelRatePlanMap(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      channelCode: channelCode ?? this.channelCode,
      internalRatePlanId: internalRatePlanId ?? this.internalRatePlanId,
      internalRatePlanName: internalRatePlanName ?? this.internalRatePlanName,
      externalRatePlanId: externalRatePlanId ?? this.externalRatePlanId,
      externalRatePlanName: externalRatePlanName ?? this.externalRatePlanName,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'channel_code': channelCode,
      'internal_rate_plan_id': internalRatePlanId,
      'internal_rate_plan_name': internalRatePlanName,
      'external_rate_plan_id': externalRatePlanId,
      'external_rate_plan_name': externalRatePlanName,
      'is_active': isActive,
    };
  }

  factory ChannelRatePlanMap.fromMap(String id, Map<String, dynamic> map) {
    return ChannelRatePlanMap(
      id: id,
      propertyId: map['property_id'] ?? 0,
      channelCode: map['channel_code'] ?? '',
      internalRatePlanId: map['internal_rate_plan_id']?.toString() ?? '',
      internalRatePlanName: map['internal_rate_plan_name'],
      externalRatePlanId: map['external_rate_plan_id']?.toString() ?? '',
      externalRatePlanName: map['external_rate_plan_name'],
      isActive: map['is_active'] ?? true,
    );
  }

  factory ChannelRatePlanMap.fromResMap(Map<String, dynamic> map) {
    return ChannelRatePlanMap(
      id: map['id']?.toString() ?? '',
      propertyId: map['property_id'] ?? 0,
      channelCode: map['channel_code'] ?? '',
      internalRatePlanId: map['internal_rate_plan_id']?.toString() ?? '',
      internalRatePlanName: map['internal_rate_plan_name'],
      externalRatePlanId: map['external_rate_plan_id']?.toString() ?? '',
      externalRatePlanName: map['external_rate_plan_name'],
      isActive: map['is_active'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChannelRatePlanMap.fromJson(String id, String source) =>
      ChannelRatePlanMap.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'ChannelRatePlanMap(id: $id, propertyId: $propertyId, channelCode: $channelCode, internalRatePlanId: $internalRatePlanId, internalRatePlanName: $internalRatePlanName, externalRatePlanId: $externalRatePlanId, externalRatePlanName: $externalRatePlanName, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChannelRatePlanMap &&
        other.id == id &&
        other.propertyId == propertyId &&
        other.channelCode == channelCode &&
        other.internalRatePlanId == internalRatePlanId &&
        other.internalRatePlanName == internalRatePlanName &&
        other.externalRatePlanId == externalRatePlanId &&
        other.externalRatePlanName == externalRatePlanName &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        propertyId.hashCode ^
        channelCode.hashCode ^
        internalRatePlanId.hashCode ^
        internalRatePlanName.hashCode ^
        externalRatePlanId.hashCode ^
        externalRatePlanName.hashCode ^
        isActive.hashCode;
  }
}
