import 'dart:convert';

class Notification {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final bool hasAction;
  final DateTime fireDate;
  final String routing;
  final String notificationType;
  final int? propertyId;
  final String? entityType;
  final String? entityId;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.hasAction,
    required this.fireDate,
    required this.routing,
    required this.notificationType,
    this.propertyId,
    this.entityType,
    this.entityId,
  });

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    bool? hasAction,
    DateTime? fireDate,
    String? routing,
    String? notificationType,
    int? propertyId,
    String? entityType,
    String? entityId,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      hasAction: hasAction ?? this.hasAction,
      fireDate: fireDate ?? this.fireDate,
      routing: routing ?? this.routing,
      notificationType: notificationType ?? this.notificationType,
      propertyId: propertyId ?? this.propertyId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'is_read': isRead,
      'has_action': hasAction,
      'fire_date': fireDate.toIso8601String(),
      'routing': routing,
      'notification_type': notificationType,
      'property_id': propertyId,
      'entity_type': entityType,
      'entity_id': entityId,
    };
  }

  factory Notification.fromResMap(Map<String, dynamic> map) {
    final fireDateValue = map['fire_date']?.toString();
    return Notification(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      isRead: map['is_read'] == true,
      hasAction: map['has_action'] == true,
      fireDate: fireDateValue != null && fireDateValue.isNotEmpty
          ? DateTime.parse(fireDateValue).toLocal()
          : DateTime.now(),
      routing: map['routing']?.toString() ?? '',
      notificationType: map['notification_type']?.toString() ?? '',
      propertyId: map['property_id'] is int
          ? map['property_id'] as int
          : int.tryParse(map['property_id']?.toString() ?? ''),
      entityType: map['entity_type']?.toString(),
      entityId: map['entity_id']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Notification.fromJson(String source) =>
      Notification.fromResMap(json.decode(source) as Map<String, dynamic>);
}
