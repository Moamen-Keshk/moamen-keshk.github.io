import 'dart:convert';
import 'package:intl/intl.dart';

final formatter = DateFormat('EEE, d MMM yyyy HH:mm:ss');

class Notification {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime fireDate;
  final String routing;
  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.fireDate,
    required this.routing,
  });

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    DateTime? fireDate,
    String? routing,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      fireDate: fireDate ?? this.fireDate,
      routing: routing ?? this.routing,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'is_read': isRead,
      'fire_date': fireDate,
      'routing': routing,
    };
  }

  factory Notification.fromMap(String id, Map<String, dynamic> map) {
    return Notification(
      id: map['\$id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      isRead: map['is_read'] ?? false,
      fireDate: formatter.parse(map['fire_date'] ?? ''),
      routing: map['routing'] ?? '',
    );
  }

  factory Notification.fromResMap(Map<String, dynamic> map) {
    return Notification(
      id: map['\$id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      isRead: map['is_read'] ?? false,
      fireDate: formatter.parse(map['fire_date'] ?? ''),
      routing: map['routing'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Notification.fromJson(String id, String source) =>
      Notification.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, body: $body, isRead: $isRead, fireDate: $fireDate, routing: $routing)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Notification &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.isRead == isRead &&
        other.fireDate == fireDate &&
        other.routing == routing;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        body.hashCode ^
        isRead.hashCode ^
        fireDate.hashCode ^
        title.hashCode;
  }
}
