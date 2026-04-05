class BookingStatusModel {
  final int id;
  final String name;
  final String code;
  final String color;

  BookingStatusModel({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
  });

  factory BookingStatusModel.fromResMap(Map<String, dynamic> map) {
    return BookingStatusModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      color: map['color'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'color': color,
    };
  }
}
