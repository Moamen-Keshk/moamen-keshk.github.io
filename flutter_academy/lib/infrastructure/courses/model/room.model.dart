import 'dart:convert';

class Room {
  final String id;
  int roomNumber;
  final int propertyId;
  final int categoryId;
  final int? floorId;
  final int? statusId;

  Room({
    required this.id,
    required this.roomNumber,
    required this.propertyId,
    required this.categoryId,
    this.floorId,
    this.statusId,
  });

  Room copyWith({
    String? id,
    int? roomNumber,
    int? propertyId,
    int? categoryId,
    int? floorId,
    int? statusId,
  }) {
    return Room(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      propertyId: propertyId ?? this.propertyId,
      categoryId: categoryId ?? this.categoryId,
      floorId: floorId ?? this.floorId,
      statusId: statusId ?? this.statusId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_number': roomNumber,
      'property_id': propertyId,
      'category_id': categoryId,
      if (floorId != null) 'floor_id': floorId,
      if (statusId != null) 'status_id': statusId,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'].toString(),
      roomNumber: _parseInt(map['room_number']),
      propertyId: _parseInt(map['property_id']),
      categoryId: _parseInt(map['category_id']),
      floorId: _parseNullableInt(map['floor_id']),
      statusId: _parseNullableInt(map['status_id']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Room.fromJson(String source) => Room.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Room(id: $id, number: $roomNumber, propertyId: $propertyId, categoryId: $categoryId, floorId: $floorId, statusId: $statusId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Room &&
        other.id == id &&
        other.roomNumber == roomNumber &&
        other.propertyId == propertyId &&
        other.categoryId == categoryId &&
        other.floorId == floorId &&
        other.statusId == statusId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roomNumber.hashCode ^
        propertyId.hashCode ^
        categoryId.hashCode ^
        floorId.hashCode ^
        statusId.hashCode;
  }

  static int _parseInt(dynamic value) =>
      value is int ? value : int.tryParse(value.toString()) ?? 0;

  static int? _parseNullableInt(dynamic value) =>
      value == null ? null : _parseInt(value);
}
