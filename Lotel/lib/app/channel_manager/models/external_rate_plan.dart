import 'dart:convert';

class ExternalRatePlan {
  final String id; // The unique ID of the rate plan on the OTA's system
  final String name; // The name of the rate plan on the OTA
  final int
      channelId; // The ID representing the specific OTA (e.g., 1 for Booking.com)
  final String? currency; // Optional: The currency the OTA uses for this plan
  final bool isActive;

  ExternalRatePlan({
    required this.id,
    required this.name,
    required this.channelId,
    this.currency,
    this.isActive = true,
  });

  ExternalRatePlan copyWith({
    String? id,
    String? name,
    int? channelId,
    String? currency,
    bool? isActive,
  }) {
    return ExternalRatePlan(
      id: id ?? this.id,
      name: name ?? this.name,
      channelId: channelId ?? this.channelId,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'channel_id': channelId,
      'currency': currency,
      'is_active': isActive,
    };
  }

  factory ExternalRatePlan.fromMap(String id, Map<String, dynamic> map) {
    return ExternalRatePlan(
      id: id,
      name: map['name'] ?? '',
      channelId: map['channel_id'] ?? 0,
      currency: map['currency']?.toString(),
      isActive: map['is_active'] ?? true,
    );
  }

  factory ExternalRatePlan.fromResMap(Map<String, dynamic> map) {
    return ExternalRatePlan(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      channelId: map['channel_id'] ?? 0,
      currency: map['currency']?.toString(),
      isActive: map['is_active'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExternalRatePlan.fromJson(String id, String source) =>
      ExternalRatePlan.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'ExternalRatePlan(id: $id, name: $name, channelId: $channelId, currency: $currency, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExternalRatePlan &&
        other.id == id &&
        other.name == name &&
        other.channelId == channelId &&
        other.currency == currency &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        channelId.hashCode ^
        currency.hashCode ^
        isActive.hashCode;
  }
}
