import 'dart:convert';

class ExternalRoom {
  final String id; // The unique ID of the room on the OTA's system
  final String name; // The name of the room on the OTA
  final int
      channelId; // The ID representing the specific OTA (e.g., 1 for Booking.com)
  final int?
      capacity; // Optional: Max occupancy to help users identify the room
  final bool isActive;

  ExternalRoom({
    required this.id,
    required this.name,
    required this.channelId,
    this.capacity,
    this.isActive = true,
  });

  ExternalRoom copyWith({
    String? id,
    String? name,
    int? channelId,
    int? capacity,
    bool? isActive,
  }) {
    return ExternalRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      channelId: channelId ?? this.channelId,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'channel_id': channelId,
      'capacity': capacity,
      'is_active': isActive,
    };
  }

  factory ExternalRoom.fromMap(String id, Map<String, dynamic> map) {
    return ExternalRoom(
      id: id,
      name: map['name'] ?? '',
      channelId: map['channel_id'] ?? 0,
      capacity: map['capacity'] != null
          ? int.tryParse(map['capacity'].toString())
          : null,
      isActive: map['is_active'] ?? true,
    );
  }

  factory ExternalRoom.fromResMap(Map<String, dynamic> map) {
    return ExternalRoom(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      channelId: map['channel_id'] ?? 0,
      capacity: map['capacity'] != null
          ? int.tryParse(map['capacity'].toString())
          : null,
      isActive: map['is_active'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExternalRoom.fromJson(String id, String source) =>
      ExternalRoom.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'ExternalRoom(id: $id, name: $name, channelId: $channelId, capacity: $capacity, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExternalRoom &&
        other.id == id &&
        other.name == name &&
        other.channelId == channelId &&
        other.capacity == capacity &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        channelId.hashCode ^
        capacity.hashCode ^
        isActive.hashCode;
  }
}
