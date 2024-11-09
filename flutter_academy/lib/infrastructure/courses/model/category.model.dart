import 'dart:convert';

class Category {
  final String id;
  final String name;
  final String description;
  Category({required this.id, required this.name, required this.description});

  Category copyWith({String? id, String? name, String? description}) {
    return Category(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description};
  }

  factory Category.fromMap(String id, Map<String, dynamic> map) {
    return Category(
        id: map['id'].toString(),
        name: map['name'] ?? '',
        description: map['description'] ?? '');
  }

  factory Category.fromResMap(Map<String, dynamic> map) {
    return Category(
        id: map['id'].toString(),
        name: map['name'] ?? '',
        description: map['description'] ?? '');
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String id, String source) =>
      Category.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ description.hashCode;
  }
}
