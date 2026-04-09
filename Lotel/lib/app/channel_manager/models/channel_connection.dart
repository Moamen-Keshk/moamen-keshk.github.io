import 'dart:convert';

class ChannelConnection {
  final String id;
  final int propertyId;
  final String channelCode; // MATCHES FLASK: 'channel_code'
  final String status;
  final Map<String, dynamic>
      credentialsJson; // MATCHES FLASK: 'credentials_json'
  final Map<String, dynamic> settingsJson; // MATCHES FLASK: 'settings_json'
  final bool pollingEnabled;
  final DateTime? lastSuccessAt; // MATCHES FLASK: 'last_success_at'
  final DateTime? lastErrorAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChannelConnection({
    required this.id,
    required this.propertyId,
    required this.channelCode,
    required this.status,
    this.credentialsJson = const {},
    this.settingsJson = const {},
    this.pollingEnabled = true,
    this.lastSuccessAt,
    this.lastErrorAt,
    this.createdAt,
    this.updatedAt,
  });

  // NEW: A helpful getter to extract the hotel ID from the JSON payload easily
  String get hotelIdOnChannel => credentialsJson['hotel_id']?.toString() ?? '';

  ChannelConnection copyWith({
    String? id,
    int? propertyId,
    String? channelCode,
    String? status,
    Map<String, dynamic>? credentialsJson,
    Map<String, dynamic>? settingsJson,
    bool? pollingEnabled,
    DateTime? lastSuccessAt,
    DateTime? lastErrorAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChannelConnection(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      channelCode: channelCode ?? this.channelCode,
      status: status ?? this.status,
      credentialsJson: credentialsJson ?? this.credentialsJson,
      settingsJson: settingsJson ?? this.settingsJson,
      pollingEnabled: pollingEnabled ?? this.pollingEnabled,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastErrorAt: lastErrorAt ?? this.lastErrorAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'channel_code': channelCode,
      'status': status,
      'credentials_json': credentialsJson,
      'settings_json': settingsJson,
      'polling_enabled': pollingEnabled,
      'last_success_at': lastSuccessAt?.toIso8601String(),
      'last_error_at': lastErrorAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ChannelConnection.fromResMap(Map<String, dynamic> map) {
    return ChannelConnection(
      id: map['id']?.toString() ?? '',
      propertyId: map['property_id'] ?? 0,
      channelCode: map['channel_code'] ?? '', // PERFECT MATCH
      status: map['status'] ?? 'inactive',
      credentialsJson: map['credentials_json'] != null
          ? Map<String, dynamic>.from(map['credentials_json'])
          : {},
      settingsJson: map['settings_json'] != null
          ? Map<String, dynamic>.from(map['settings_json'])
          : {},
      pollingEnabled: map['polling_enabled'] ?? true,
      lastSuccessAt: map['last_success_at'] != null
          ? DateTime.tryParse(map['last_success_at'])
          : null,
      lastErrorAt: map['last_error_at'] != null
          ? DateTime.tryParse(map['last_error_at'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
    );
  }

  factory ChannelConnection.fromMap(String id, Map<String, dynamic> map) {
    final conn = ChannelConnection.fromResMap(map);
    return conn.copyWith(id: id);
  }

  String toJson() => json.encode(toMap());

  factory ChannelConnection.fromJson(String id, String source) =>
      ChannelConnection.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'ChannelConnection(id: $id, propertyId: $propertyId, channelCode: $channelCode, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChannelConnection &&
        other.id == id &&
        other.propertyId == propertyId &&
        other.channelCode == channelCode &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        propertyId.hashCode ^
        channelCode.hashCode ^
        status.hashCode;
  }
}
