import 'dart:convert';

class ChannelConnection {
  final String id;
  final int propertyId;
  final int channelId; // The internal ID for the OTA (e.g., 1 for Booking.com)
  final String channelName; // e.g., "Booking.com", "Expedia", "Airbnb"
  final String
      hotelIdOnChannel; // Your property's specific ID on the OTA's platform
  final String status; // e.g., 'active', 'inactive', 'pending', 'error'
  final DateTime?
      lastSync; // When the channel manager last synced with this OTA

  ChannelConnection({
    required this.id,
    required this.propertyId,
    required this.channelId,
    required this.channelName,
    required this.hotelIdOnChannel,
    required this.status,
    this.lastSync,
  });

  ChannelConnection copyWith({
    String? id,
    int? propertyId,
    int? channelId,
    String? channelName,
    String? hotelIdOnChannel,
    String? status,
    DateTime? lastSync,
  }) {
    return ChannelConnection(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      hotelIdOnChannel: hotelIdOnChannel ?? this.hotelIdOnChannel,
      status: status ?? this.status,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'channel_id': channelId,
      'channel_name': channelName,
      'hotel_id_on_channel': hotelIdOnChannel,
      'status': status,
      'last_sync': lastSync?.toIso8601String(),
    };
  }

  factory ChannelConnection.fromMap(String id, Map<String, dynamic> map) {
    return ChannelConnection(
      id: id,
      propertyId: map['property_id'] ?? 0,
      channelId: map['channel_id'] ?? 0,
      channelName: map['channel_name'] ?? '',
      hotelIdOnChannel: map['hotel_id_on_channel']?.toString() ?? '',
      status: map['status'] ?? 'inactive',
      lastSync:
          map['last_sync'] != null ? DateTime.tryParse(map['last_sync']) : null,
    );
  }

  factory ChannelConnection.fromResMap(Map<String, dynamic> map) {
    return ChannelConnection(
      id: map['id']?.toString() ?? '',
      propertyId: map['property_id'] ?? 0,
      channelId: map['channel_id'] ?? 0,
      channelName: map['channel_name'] ?? '',
      hotelIdOnChannel: map['hotel_id_on_channel']?.toString() ?? '',
      status: map['status'] ?? 'inactive',
      lastSync:
          map['last_sync'] != null ? DateTime.tryParse(map['last_sync']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChannelConnection.fromJson(String id, String source) =>
      ChannelConnection.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'ChannelConnection(id: $id, propertyId: $propertyId, channelId: $channelId, channelName: $channelName, hotelIdOnChannel: $hotelIdOnChannel, status: $status, lastSync: $lastSync)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChannelConnection &&
        other.id == id &&
        other.propertyId == propertyId &&
        other.channelId == channelId &&
        other.channelName == channelName &&
        other.hotelIdOnChannel == hotelIdOnChannel &&
        other.status == status &&
        other.lastSync == lastSync;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        propertyId.hashCode ^
        channelId.hashCode ^
        channelName.hashCode ^
        hotelIdOnChannel.hashCode ^
        status.hashCode ^
        lastSync.hashCode;
  }
}
