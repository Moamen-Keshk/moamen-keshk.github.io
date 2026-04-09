import 'dart:convert';

class SupportedChannel {
  final int id;
  final String code;
  final String name;
  final String logo;
  final bool isActive;

  SupportedChannel({
    required this.id,
    required this.code,
    required this.name,
    required this.logo,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'logo': logo,
      'is_active': isActive,
    };
  }

  factory SupportedChannel.fromMap(Map<String, dynamic> map) {
    return SupportedChannel(
      id: map['id']?.toInt() ?? 0,
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      logo: map['logo'] ?? '🔗',
      isActive: map['is_active'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory SupportedChannel.fromJson(String source) =>
      SupportedChannel.fromMap(json.decode(source));
}
