import 'dart:convert';

class Category {
  final String id;
  final String name;
  final String description;
  final int capacity; // <-- Added capacity

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity, // <-- Added to constructor
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    int? capacity, // <-- Added to copyWith parameters
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity, // <-- Added to copyWith return
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity, // <-- Added to toMap
    };
  }

  factory Category.fromMap(String id, Map<String, dynamic> map) {
    return Category(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      // Parses capacity, defaulting to 0 if null
      capacity: map['capacity'] != null
          ? int.tryParse(map['capacity'].toString()) ?? 0
          : 0,
    );
  }

  factory Category.fromResMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      // Parses capacity, defaulting to 0 if null
      capacity: map['capacity'] != null
          ? int.tryParse(map['capacity'].toString()) ?? 0
          : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String id, String source) =>
      Category.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description, capacity: $capacity)'; // <-- Added to string output
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.capacity == capacity; // <-- Added to equality check
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        capacity.hashCode; // <-- Added to hash code
  }
}
