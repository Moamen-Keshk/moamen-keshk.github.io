import 'dart:convert';

class Room {
  final String id;
  final int roomNumber;
  final int categoryId;
  final int floorId;
  final int statusId;
  Room({
    required this.id,
    required this.roomNumber,
    required this.categoryId,
    required this.floorId,
    required this.statusId
  });

  Room copyWith({
    String? id,
    int? roomNumber,
    int? categoryId,
    int? floorId,
    int? statusId,
  }) {
    return Room(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      categoryId: categoryId ?? this.categoryId,
      floorId: floorId ?? this.floorId,
      statusId: statusId ?? this.statusId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_number': roomNumber,
      'category_id': categoryId,
      'floor_id': floorId,
      'status_id': statusId,
    };
  }

  factory Room.fromMap(String id, Map<String, dynamic> map) {
    return Room(
      id: map['\$id'] ?? '',
      roomNumber: map['room_number'] ?? '',
      categoryId: map['category_id'] ?? '',
      floorId: map['floor_id'] ?? '',
      statusId: map['status_id'] ?? ''
    );
  }

  factory Room.fromResMap(Map<String, dynamic> map) {
    return Room(
      id: map['\$id'] ?? '',
      roomNumber: map['room_number'] ?? '',
      categoryId: map['category_id'] ?? '',
      floorId: map['floor_id'] ?? '',
      statusId: map['status_id'] ?? ''
    );
  }

  String toJson() => json.encode(toMap());

  factory Room.fromJson(String id, String source) =>
      Room.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'Room(id: $id, roomNumber: $roomNumber, categoryId: $categoryId, floorId: $floorId, statusId: $statusId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Room &&
        other.id == id &&
        other.roomNumber == roomNumber &&
        other.categoryId == categoryId &&
        other.floorId == floorId &&
        other.statusId == statusId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roomNumber.hashCode ^
        categoryId.hashCode ^
        floorId.hashCode ^
        statusId.hashCode;
  }
}