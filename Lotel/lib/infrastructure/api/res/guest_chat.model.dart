import 'dart:convert';

class GuestMessage {
  final int id;
  final int bookingId;
  final int propertyId;
  final String direction;
  final String channel;
  final String messageBody;
  final DateTime timestamp;
  final bool isRead;

  GuestMessage({
    required this.id,
    required this.bookingId,
    required this.propertyId,
    required this.direction,
    required this.channel,
    required this.messageBody,
    required this.timestamp,
    required this.isRead,
  });

  GuestMessage copyWith({
    int? id,
    int? bookingId,
    int? propertyId,
    String? direction,
    String? channel,
    String? messageBody,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return GuestMessage(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      propertyId: propertyId ?? this.propertyId,
      direction: direction ?? this.direction,
      channel: channel ?? this.channel,
      messageBody: messageBody ?? this.messageBody,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'property_id': propertyId,
      'direction': direction,
      'channel': channel,
      'message_body': messageBody,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }

  factory GuestMessage.fromMap(int id, Map<String, dynamic> map) {
    return GuestMessage(
      id: id,
      bookingId: map['booking_id']?.toInt() ?? 0,
      propertyId: map['property_id']?.toInt() ?? 0,
      direction: map['direction'] ?? '',
      channel: map['channel'] ?? '',
      messageBody: map['message_body'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isRead: map['is_read'] ?? false,
    );
  }

  factory GuestMessage.fromResMap(Map<String, dynamic> map) {
    return GuestMessage(
      id: map['id']?.toInt() ?? 0,
      bookingId: map['booking_id']?.toInt() ?? 0,
      propertyId: map['property_id']?.toInt() ?? 0,
      direction: map['direction'] ?? '',
      channel: map['channel'] ?? '',
      messageBody: map['message_body'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isRead: map['is_read'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory GuestMessage.fromJson(int id, String source) =>
      GuestMessage.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'GuestMessage(id: $id, bookingId: $bookingId, propertyId: $propertyId, direction: $direction, channel: $channel, messageBody: $messageBody, timestamp: $timestamp, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GuestMessage &&
        other.id == id &&
        other.bookingId == bookingId &&
        other.propertyId == propertyId &&
        other.direction == direction &&
        other.channel == channel &&
        other.messageBody == messageBody &&
        other.timestamp == timestamp &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        bookingId.hashCode ^
        propertyId.hashCode ^
        direction.hashCode ^
        channel.hashCode ^
        messageBody.hashCode ^
        timestamp.hashCode ^
        isRead.hashCode;
  }
}
