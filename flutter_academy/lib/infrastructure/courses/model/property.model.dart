import 'dart:convert';
import 'package:intl/intl.dart';

final formatter = DateFormat('yyyy-MM-dd');

class Property {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String email; // <-- Added email property
  final String status;
  final DateTime publishedDate;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email, // <-- Added to constructor
    required this.status,
    required this.publishedDate,
  });

  Property copyWith({
    String? id,
    String? name,
    String? address,
    String? phoneNumber,
    String? email, // <-- Added to copyWith
    String? status,
    DateTime? publishedDate,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email, // <-- Updated mapping
      status: status ?? this.status,
      publishedDate: publishedDate ?? this.publishedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'email': email, // <-- Added to JSON map
      'status': status,
      'publishedDate': publishedDate,
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      email: map['email'] ?? '', // <-- Parsed from JSON map
      status: map['status'] ?? '',
      publishedDate: formatter.parse(map['published_date'] ?? ''),
    );
  }

  factory Property.fromResMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      email: map['email'] ?? '', // <-- Parsed from JSON map
      status: map['status'] ?? '',
      publishedDate: formatter.parse(map['published_date'] ?? ''),
    );
  }

  String toJson() => json.encode(toMap());

  factory Property.fromJson(String id, String source) =>
      Property.fromMap(id, json.decode(source));

  @override
  String toString() {
    // <-- Added email to string representation
    return 'Property(id: $id, name: $name, address: $address, phoneNumber: $phoneNumber, email: $email, status: $status, publishedDate: $publishedDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Property &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.phoneNumber == phoneNumber &&
        other.email == email && // <-- Added to equality check
        other.status == status &&
        other.publishedDate == publishedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^ // <-- Added to hash code
        status.hashCode ^
        publishedDate.hashCode;
  }
}
