class Role {
  final int id;
  final String name;
  final String description;

  Role({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Role.fromResMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
