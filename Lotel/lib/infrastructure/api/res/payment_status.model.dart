import 'dart:convert';

class PaymentStatus {
  final String id;
  final String code;
  final String name;
  final String color;
  PaymentStatus(
      {required this.id,
      required this.code,
      required this.name,
      required this.color});

  PaymentStatus copyWith(
      {String? id, String? code, String? name, String? color}) {
    return PaymentStatus(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        color: color ?? this.color);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'code': code, 'name': name, 'color': color};
  }

  factory PaymentStatus.fromMap(String id, Map<String, dynamic> map) {
    return PaymentStatus(
        id: map['id'].toString(),
        code: map['code'] ?? '',
        name: map['name'] ?? '',
        color: map['color'] ?? '');
  }

  factory PaymentStatus.fromResMap(Map<String, dynamic> map) {
    return PaymentStatus(
        id: map['id'].toString(),
        code: map['code'] ?? '',
        name: map['name'] ?? '',
        color: map['color'] ?? '');
  }

  String toJson() => json.encode(toMap());

  factory PaymentStatus.fromJson(String id, String source) =>
      PaymentStatus.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'PaymentStatus(id: $id, code: $code, name: $name, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaymentStatus &&
        other.id == id &&
        other.code == code &&
        other.name == name &&
        other.color == color;
  }

  @override
  int get hashCode {
    return id.hashCode ^ code.hashCode ^ name.hashCode ^ color.hashCode;
  }
}
