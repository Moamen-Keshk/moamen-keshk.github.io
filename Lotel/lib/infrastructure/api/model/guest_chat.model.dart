import 'dart:convert';

class GuestMessage {
  final int id;
  final int bookingId;
  final int propertyId;
  final String direction;
  final String channel;
  final String? subject;
  final String messageBody;
  final DateTime timestamp;
  final bool isRead;
  final String deliveryStatus;
  final String? deliveryError;
  final String? externalMessageId;
  final String? sentByUserId;

  GuestMessage({
    required this.id,
    required this.bookingId,
    required this.propertyId,
    required this.direction,
    required this.channel,
    this.subject,
    required this.messageBody,
    required this.timestamp,
    required this.isRead,
    required this.deliveryStatus,
    this.deliveryError,
    this.externalMessageId,
    this.sentByUserId,
  });

  GuestMessage copyWith({
    int? id,
    int? bookingId,
    int? propertyId,
    String? direction,
    String? channel,
    String? subject,
    String? messageBody,
    DateTime? timestamp,
    bool? isRead,
    String? deliveryStatus,
    String? deliveryError,
    String? externalMessageId,
    String? sentByUserId,
  }) {
    return GuestMessage(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      propertyId: propertyId ?? this.propertyId,
      direction: direction ?? this.direction,
      channel: channel ?? this.channel,
      subject: subject ?? this.subject,
      messageBody: messageBody ?? this.messageBody,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryError: deliveryError ?? this.deliveryError,
      externalMessageId: externalMessageId ?? this.externalMessageId,
      sentByUserId: sentByUserId ?? this.sentByUserId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'property_id': propertyId,
      'direction': direction,
      'channel': channel,
      'subject': subject,
      'message_body': messageBody,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'delivery_status': deliveryStatus,
      'delivery_error': deliveryError,
      'external_message_id': externalMessageId,
      'sent_by_user_id': sentByUserId,
    };
  }

  factory GuestMessage.fromMap(int id, Map<String, dynamic> map) {
    return GuestMessage(
      id: id,
      bookingId: map['booking_id']?.toInt() ?? 0,
      propertyId: map['property_id']?.toInt() ?? 0,
      direction: map['direction'] ?? '',
      channel: map['channel'] ?? '',
      subject: map['subject']?.toString(),
      messageBody: map['message_body'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isRead: map['is_read'] ?? false,
      deliveryStatus: map['delivery_status'] ?? 'sent',
      deliveryError: map['delivery_error']?.toString(),
      externalMessageId: map['external_message_id']?.toString(),
      sentByUserId: map['sent_by_user_id']?.toString(),
    );
  }

  factory GuestMessage.fromResMap(Map<String, dynamic> map) {
    return GuestMessage(
      id: map['id']?.toInt() ?? 0,
      bookingId: map['booking_id']?.toInt() ?? 0,
      propertyId: map['property_id']?.toInt() ?? 0,
      direction: map['direction'] ?? '',
      channel: map['channel'] ?? '',
      subject: map['subject']?.toString(),
      messageBody: map['message_body'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isRead: map['is_read'] ?? false,
      deliveryStatus: map['delivery_status'] ?? 'sent',
      deliveryError: map['delivery_error']?.toString(),
      externalMessageId: map['external_message_id']?.toString(),
      sentByUserId: map['sent_by_user_id']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory GuestMessage.fromJson(int id, String source) =>
      GuestMessage.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'GuestMessage(id: $id, bookingId: $bookingId, propertyId: $propertyId, direction: $direction, channel: $channel, subject: $subject, messageBody: $messageBody, timestamp: $timestamp, isRead: $isRead, deliveryStatus: $deliveryStatus, deliveryError: $deliveryError, externalMessageId: $externalMessageId, sentByUserId: $sentByUserId)';
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
        other.subject == subject &&
        other.messageBody == messageBody &&
        other.timestamp == timestamp &&
        other.isRead == isRead &&
        other.deliveryStatus == deliveryStatus &&
        other.deliveryError == deliveryError &&
        other.externalMessageId == externalMessageId &&
        other.sentByUserId == sentByUserId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        bookingId.hashCode ^
        propertyId.hashCode ^
        direction.hashCode ^
        channel.hashCode ^
        subject.hashCode ^
        messageBody.hashCode ^
        timestamp.hashCode ^
        isRead.hashCode ^
        deliveryStatus.hashCode ^
        deliveryError.hashCode ^
        externalMessageId.hashCode ^
        sentByUserId.hashCode;
  }
}
