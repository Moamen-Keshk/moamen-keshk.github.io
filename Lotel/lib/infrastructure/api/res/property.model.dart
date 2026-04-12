import 'dart:convert';
import 'package:lotel_pms/infrastructure/api/model/amenity.model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // <-- Added for listEquals

final formatter = DateFormat('yyyy-MM-dd');

class Property {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final String status;
  final DateTime publishedDate;
  final List<Amenity> amenities;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.status,
    required this.publishedDate,
    this.amenities = const [],
  });

  Property copyWith({
    String? id,
    String? name,
    String? address,
    String? phoneNumber,
    String? email,
    String? status,
    DateTime? publishedDate,
    List<Amenity>? amenities,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      status: status ?? this.status,
      publishedDate: publishedDate ?? this.publishedDate,
      amenities: amenities ?? this.amenities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'status': status,
      'published_date': formatter.format(publishedDate),
      'amenities': amenities.map((x) => x.toMap()).toList(),
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? '',
      // Safely parse date, fallback to now if null or empty
      publishedDate: (map['published_date'] != null &&
              map['published_date'].toString().isNotEmpty)
          ? formatter.parse(map['published_date'])
          : DateTime.now(),
      // Safely cast to List before mapping
      amenities: (map['amenities'] != null && map['amenities'] is List)
          ? (map['amenities'] as List)
              .map((x) => Amenity.fromResMap(x))
              .toList()
          : [],
    );
  }

  factory Property.fromResMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? '',
      // Safely parse date, fallback to now if null or empty
      publishedDate: (map['published_date'] != null &&
              map['published_date'].toString().isNotEmpty)
          ? formatter.parse(map['published_date'])
          : DateTime.now(),
      // Safely cast to List before mapping
      amenities: (map['amenities'] != null && map['amenities'] is List)
          ? (map['amenities'] as List)
              .map((x) => Amenity.fromResMap(x))
              .toList()
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Property.fromJson(String id, String source) =>
      Property.fromMap(id, json.decode(source));

  @override
  String toString() {
    return 'Property(id: $id, name: $name, address: $address, phoneNumber: $phoneNumber, email: $email, status: $status, publishedDate: $publishedDate, amenities: $amenities)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Property &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.status == status &&
        other.publishedDate == publishedDate &&
        listEquals(other.amenities, amenities);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        status.hashCode ^
        publishedDate.hashCode ^
        amenities.hashCode;
  }
}
