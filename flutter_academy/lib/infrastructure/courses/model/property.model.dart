import 'dart:convert';
import 'package:intl/intl.dart';

final formatter = DateFormat('yyyy-MM-dd');

class Property {
  final String id;
  final String name;
  final String address;
  final String status;
  final DateTime publishedDate;
  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.publishedDate,
  });

  Property copyWith({
    String? id,
    String? name,
    String? address,
    String? status,
    DateTime? publishedDate,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      status: status ?? this.status,
      publishedDate: publishedDate ?? this.publishedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'status': status,
      'publishedDate': publishedDate,
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      status: map['status'] ?? '',
      publishedDate: formatter.parse(map['published_date'] ?? ''),
    );
  }

  factory Property.fromResMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      status: map['status'] ?? '',
      publishedDate: formatter.parse(map['published_date'] ?? ''),
    );
  }

  String toJson() => json.encode(toMap());

  factory Property.fromJson(String id, String source) =>
      Property.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'Property(id: $id, name: $name, address: $address, status: $status, publishedDate: $publishedDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Property &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.status == status &&
        other.publishedDate == publishedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        status.hashCode ^
        publishedDate.hashCode;
  }
}
