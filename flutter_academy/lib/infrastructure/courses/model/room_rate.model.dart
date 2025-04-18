import 'dart:convert';

class RoomRate {
  final String id;
  final String roomId;
  final DateTime date;
  final double price;
  final int propertyId;
  final String categoryId; // ✅ New field

  RoomRate({
    required this.id,
    required this.roomId,
    required this.date,
    required this.price,
    required this.propertyId,
    required this.categoryId,
  });

  RoomRate copyWith({
    String? id,
    String? roomId,
    DateTime? date,
    double? price,
    int? propertyId,
    String? categoryId,
  }) {
    return RoomRate(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      date: date ?? this.date,
      price: price ?? this.price,
      propertyId: propertyId ?? this.propertyId,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'date': date.toIso8601String(),
      'price': price,
      'property_id': propertyId,
      'category_id': categoryId, // ✅ Added here
    };
  }

  factory RoomRate.fromMap(String id, Map<String, dynamic> map) {
    return RoomRate(
      id: id,
      roomId: map['room_id'].toString(),
      date: DateTime.tryParse(map['date'].toString()) ?? DateTime.now(),
      price: (map['price'] is String)
          ? double.tryParse(map['price']) ?? 0.0
          : (map['price'] ?? 0.0).toDouble(),
      propertyId: (map['property_id'] is String)
          ? int.tryParse(map['property_id']) ?? 0
          : (map['property_id'] ?? 0),
      categoryId: map['category_id'].toString(), // ✅ Added here
    );
  }

  factory RoomRate.fromResMap(Map<String, dynamic> map) {
    return RoomRate(
      id: map['id'].toString(),
      roomId: map['room_id'].toString(),
      date: DateTime.tryParse(map['date'].toString()) ?? DateTime.now(),
      price: (map['price'] is String)
          ? double.tryParse(map['price']) ?? 0.0
          : (map['price'] ?? 0.0).toDouble(),
      propertyId: (map['property_id'] is String)
          ? int.tryParse(map['property_id']) ?? 0
          : (map['property_id'] ?? 0),
      categoryId: map['category_id'].toString(), // ✅ Added here
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomRate.fromJson(String id, String source) =>
      RoomRate.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'RoomRate(id: $id, roomId: $roomId, date: $date, price: $price, propertyId: $propertyId, categoryId: $categoryId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RoomRate &&
        other.id == id &&
        other.roomId == roomId &&
        other.date == date &&
        other.price == price &&
        other.propertyId == propertyId &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roomId.hashCode ^
        date.hashCode ^
        price.hashCode ^
        propertyId.hashCode ^
        categoryId.hashCode;
  }
}
