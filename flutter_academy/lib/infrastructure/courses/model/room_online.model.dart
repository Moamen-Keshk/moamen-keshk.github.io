import 'dart:convert';

class RoomOnline {
  final String id;
  final String roomId;
  final DateTime date;
  final double price;
  final int propertyId;
  final String categoryId;
  final int? roomStatusId; // ✅ New field

  RoomOnline(
      {required this.id,
      required this.roomId,
      required this.date,
      required this.price,
      required this.propertyId,
      required this.categoryId,
      this.roomStatusId});

  RoomOnline copyWith({
    String? id,
    String? roomId,
    DateTime? date,
    double? price,
    int? propertyId,
    String? categoryId,
    int? roomStatusId,
  }) {
    return RoomOnline(
        id: id ?? this.id,
        roomId: roomId ?? this.roomId,
        date: date ?? this.date,
        price: price ?? this.price,
        propertyId: propertyId ?? this.propertyId,
        categoryId: categoryId ?? this.categoryId,
        roomStatusId: roomStatusId ?? this.roomStatusId);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'date': date.toIso8601String(),
      'price': price,
      'property_id': propertyId,
      'category_id': categoryId
    };
  }

  factory RoomOnline.fromMap(String id, Map<String, dynamic> map) {
    return RoomOnline(
        id: id,
        roomId: map['room_id'].toString(),
        date: DateTime.tryParse(map['date'].toString()) ?? DateTime.now(),
        price: (map['price'] is String)
            ? double.tryParse(map['price']) ?? 0.0
            : (map['price'] ?? 0.0).toDouble(),
        propertyId: (map['property_id'] is String)
            ? int.tryParse(map['property_id']) ?? 0
            : (map['property_id'] ?? 0),
        categoryId: map['category_id'].toString(),
        roomStatusId: map['room_status_id']);
  }

  factory RoomOnline.fromResMap(Map<String, dynamic> map) {
    return RoomOnline(
        id: map['id'].toString(),
        roomId: map['room_id'].toString(),
        date: DateTime.tryParse(map['date'].toString()) ?? DateTime.now(),
        price: (map['price'] is String)
            ? double.tryParse(map['price']) ?? 0.0
            : (map['price'] ?? 0.0).toDouble(),
        propertyId: (map['property_id'] is String)
            ? int.tryParse(map['property_id']) ?? 0
            : (map['property_id'] ?? 0),
        categoryId: map['category_id'].toString(),
        roomStatusId: map['room_status_id']);
  }

  String toJson() => json.encode(toMap());

  factory RoomOnline.fromJson(String id, String source) =>
      RoomOnline.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'RoomOnline(id: $id, roomId: $roomId, date: $date, price: $price, propertyId: $propertyId, categoryId: $categoryId, roomStatusId: $roomStatusId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RoomOnline &&
        other.id == id &&
        other.roomId == roomId &&
        other.date == date &&
        other.price == price &&
        other.propertyId == propertyId &&
        other.categoryId == categoryId &&
        other.roomStatusId == roomStatusId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roomId.hashCode ^
        date.hashCode ^
        price.hashCode ^
        propertyId.hashCode ^
        categoryId.hashCode ^
        roomStatusId.hashCode;
  }
}
