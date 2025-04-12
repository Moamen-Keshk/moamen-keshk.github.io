import 'dart:convert';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';

class Floor {
  final String id;
  final int number;
  final int propertyId;
  final List<Room> rooms;
  Floor(
      {required this.id,
      required this.number,
      required this.propertyId,
      required this.rooms});

  Floor copyWith(
      {String? id, int? number, int? propertyId, List<Room>? rooms}) {
    return Floor(
        id: id ?? this.id,
        number: number ?? this.number,
        propertyId: propertyId ?? this.propertyId,
        rooms: rooms ?? this.rooms);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'floor_number': number,
      'property_id': propertyId,
      'rooms': rooms
    };
  }

  factory Floor.fromMap(String id, Map<String, dynamic> map) {
    return Floor(
        id: map['id'].toString(),
        number: map['floor_number'] ?? '',
        propertyId: map['property_id'] ?? '',
        rooms: map['rooms'] ?? '');
  }

  factory Floor.fromResMap(Map<String, dynamic> map) {
    return Floor(
        id: map['id'].toString(),
        number: map['floor_number'] ?? '',
        propertyId: map['property_id'] ?? '',
        rooms: map['rooms'].map<Room>((dynamic map) {
              return Room.fromMap(map);
            }).toList() ??
            []);
  }

  String toJson() => json.encode(toMap());

  factory Floor.fromJson(String id, String source) =>
      Floor.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'Floor(id: $id, number: $number, propertyId: $propertyId, rooms: $rooms)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Floor &&
        other.id == id &&
        other.number == number &&
        other.propertyId == propertyId &&
        other.rooms == rooms;
  }

  @override
  int get hashCode {
    return id.hashCode ^ number.hashCode ^ propertyId.hashCode ^ rooms.hashCode;
  }
}
