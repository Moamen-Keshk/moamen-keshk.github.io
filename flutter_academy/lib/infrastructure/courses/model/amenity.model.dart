import 'dart:convert';

class Amenity {
  final String id;
  final String name;
  final String? icon;

  Amenity({
    required this.id,
    required this.name,
    this.icon,
  });

  Amenity copyWith({
    String? id,
    String? name,
    String? icon,
  }) {
    return Amenity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  factory Amenity.fromMap(String id, Map<String, dynamic> map) {
    return Amenity(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      icon: map['icon'],
    );
  }

  factory Amenity.fromResMap(Map<String, dynamic> map) {
    return Amenity(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      icon: map['icon'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Amenity.fromJson(String id, String source) =>
      Amenity.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'Amenity(id: $id, name: $name, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Amenity &&
        other.id == id &&
        other.name == name &&
        other.icon == icon;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ icon.hashCode;
  }
}
