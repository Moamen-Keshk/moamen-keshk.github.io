import 'dart:convert';

class ChannelRoomMap {
  final String id;
  final int propertyId;
  final String
      channelCode; // FIX: Matched to Flask's 'channel_code' (e.g., 'booking_com')
  final String internalRoomId; // FIX: Matched to Flask's 'internal_room_id'
  final String? internalRoomTypeId;
  final String?
      internalRoomName; // Optional: Kept for UI convenience if you join local data
  final String externalRoomId; // FIX: Matched to Flask's 'external_room_id'
  final String?
      externalRoomName; // FIX: Matched to Flask's 'external_room_name'
  final bool isActive;

  ChannelRoomMap({
    required this.id,
    required this.propertyId,
    required this.channelCode,
    required this.internalRoomId,
    this.internalRoomTypeId,
    this.internalRoomName,
    required this.externalRoomId,
    this.externalRoomName,
    this.isActive = true,
  });

  ChannelRoomMap copyWith({
    String? id,
    int? propertyId,
    String? channelCode,
    String? internalRoomId,
    String? internalRoomTypeId,
    String? internalRoomName,
    String? externalRoomId,
    String? externalRoomName,
    bool? isActive,
  }) {
    return ChannelRoomMap(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      channelCode: channelCode ?? this.channelCode,
      internalRoomId: internalRoomId ?? this.internalRoomId,
      internalRoomTypeId: internalRoomTypeId ?? this.internalRoomTypeId,
      internalRoomName: internalRoomName ?? this.internalRoomName,
      externalRoomId: externalRoomId ?? this.externalRoomId,
      externalRoomName: externalRoomName ?? this.externalRoomName,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // These keys now perfectly match your Flask POST/PUT expectations
      'id': id,
      'property_id': propertyId,
      'channel_code': channelCode,
      'internal_room_id': internalRoomId,
      'internal_room_type_id': internalRoomTypeId ?? internalRoomId,
      'external_room_id': externalRoomId,
      'external_room_name': externalRoomName,
      'is_active': isActive,
    };
  }

  factory ChannelRoomMap.fromMap(String id, Map<String, dynamic> map) {
    return ChannelRoomMap(
      id: id,
      propertyId: map['property_id'] ?? 0,
      channelCode: map['channel_code'] ?? '',
      internalRoomId: map['internal_room_id']?.toString() ?? '',
      internalRoomTypeId: map['internal_room_type_id']?.toString(),
      internalRoomName: map[
          'internal_room_name'], // Often null from backend, populated locally
      externalRoomId: map['external_room_id']?.toString() ?? '',
      externalRoomName: map['external_room_name'],
      isActive: map['is_active'] ?? true,
    );
  }

  factory ChannelRoomMap.fromResMap(Map<String, dynamic> map) {
    return ChannelRoomMap(
      id: map['id']?.toString() ?? '',
      propertyId: map['property_id'] ?? 0,
      channelCode: map['channel_code'] ?? '',
      internalRoomId: map['internal_room_id']?.toString() ?? '',
      internalRoomTypeId: map['internal_room_type_id']?.toString(),
      internalRoomName: map['internal_room_name'],
      externalRoomId: map['external_room_id']?.toString() ?? '',
      externalRoomName: map['external_room_name'],
      isActive: map['is_active'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChannelRoomMap.fromJson(String id, String source) =>
      ChannelRoomMap.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'ChannelRoomMap(id: $id, propertyId: $propertyId, channelCode: $channelCode, internalRoomId: $internalRoomId, internalRoomTypeId: $internalRoomTypeId, internalRoomName: $internalRoomName, externalRoomId: $externalRoomId, externalRoomName: $externalRoomName, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChannelRoomMap &&
        other.id == id &&
        other.propertyId == propertyId &&
        other.channelCode == channelCode &&
        other.internalRoomId == internalRoomId &&
        other.internalRoomTypeId == internalRoomTypeId &&
        other.internalRoomName == internalRoomName &&
        other.externalRoomId == externalRoomId &&
        other.externalRoomName == externalRoomName &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        propertyId.hashCode ^
        channelCode.hashCode ^
        internalRoomId.hashCode ^
        internalRoomTypeId.hashCode ^
        internalRoomName.hashCode ^
        externalRoomId.hashCode ^
        externalRoomName.hashCode ^
        isActive.hashCode;
  }
}
