import 'dart:convert';

class RoomRate {
  final String id;
  final String roomId;
  final DateTime date;
  final double price;
  RoomRate(
      {required this.id,
      required this.roomId,
      required this.date,
      required this.price});

  RoomRate copyWith(
      {String? id, String? roomId, DateTime? date, double? price}) {
    return RoomRate(
        id: id ?? this.id,
        roomId: roomId ?? this.roomId,
        date: date ?? this.date,
        price: price ?? this.price);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'room_id': roomId, 'date': date, 'price': price};
  }

  factory RoomRate.fromMap(String id, Map<String, dynamic> map) {
    return RoomRate(
        id: map['id'].toString(),
        roomId: map['room_id'] ?? '',
        date: map['date'] ?? '',
        price: map['price'] ?? '');
  }

  factory RoomRate.fromResMap(Map<String, dynamic> map) {
    return RoomRate(
        id: map['id'].toString(),
        roomId: map['room_id'] ?? '',
        date: map['date'] ?? DateTime.now(),
        price: map['rooms'] ?? 0.0);
  }

  String toJson() => json.encode(toMap());

  factory RoomRate.fromJson(String id, String source) =>
      RoomRate.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'Floor(id: $id, roomId: $roomId, date: $date, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RoomRate &&
        other.id == id &&
        other.roomId == roomId &&
        other.date == date &&
        other.price == price;
  }

  @override
  int get hashCode {
    return id.hashCode ^ roomId.hashCode ^ date.hashCode ^ price.hashCode;
  }
}
