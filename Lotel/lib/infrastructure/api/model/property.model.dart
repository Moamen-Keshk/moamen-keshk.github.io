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
  final int? statusId;
  final String status;
  final DateTime publishedDate;
  final String timezone;
  final String currency;
  final double taxRate;
  final String defaultCheckInTime;
  final String defaultCheckOutTime;
  final List<Amenity> amenities;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    this.statusId,
    required this.status,
    required this.publishedDate,
    required this.timezone,
    required this.currency,
    required this.taxRate,
    required this.defaultCheckInTime,
    required this.defaultCheckOutTime,
    this.amenities = const [],
  });

  Property copyWith({
    String? id,
    String? name,
    String? address,
    String? phoneNumber,
    String? email,
    int? statusId,
    String? status,
    DateTime? publishedDate,
    String? timezone,
    String? currency,
    double? taxRate,
    String? defaultCheckInTime,
    String? defaultCheckOutTime,
    List<Amenity>? amenities,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      statusId: statusId ?? this.statusId,
      status: status ?? this.status,
      publishedDate: publishedDate ?? this.publishedDate,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      defaultCheckInTime: defaultCheckInTime ?? this.defaultCheckInTime,
      defaultCheckOutTime: defaultCheckOutTime ?? this.defaultCheckOutTime,
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
      'status_id': statusId,
      'status': status,
      'published_date': formatter.format(publishedDate),
      'timezone': timezone,
      'currency': currency,
      'tax_rate': taxRate,
      'default_check_in_time': defaultCheckInTime,
      'default_check_out_time': defaultCheckOutTime,
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
      statusId: _parseNullableInt(map['status_id']),
      status: map['status'] ?? '',
      publishedDate: _parsePublishedDate(map['published_date']),
      timezone: map['timezone'] ?? 'UTC',
      currency: map['currency'] ?? 'USD',
      taxRate: _parseDouble(map['tax_rate']),
      defaultCheckInTime: map['default_check_in_time'] ?? '15:00',
      defaultCheckOutTime: map['default_check_out_time'] ?? '11:00',
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
      statusId: _parseNullableInt(map['status_id']),
      status: map['status'] ?? '',
      publishedDate: _parsePublishedDate(map['published_date']),
      timezone: map['timezone'] ?? 'UTC',
      currency: map['currency'] ?? 'USD',
      taxRate: _parseDouble(map['tax_rate']),
      defaultCheckInTime: map['default_check_in_time'] ?? '15:00',
      defaultCheckOutTime: map['default_check_out_time'] ?? '11:00',
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
        other.statusId == statusId &&
        other.status == status &&
        other.publishedDate == publishedDate &&
        other.timezone == timezone &&
        other.currency == currency &&
        other.taxRate == taxRate &&
        other.defaultCheckInTime == defaultCheckInTime &&
        other.defaultCheckOutTime == defaultCheckOutTime &&
        listEquals(other.amenities, amenities);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        statusId.hashCode ^
        status.hashCode ^
        publishedDate.hashCode ^
        timezone.hashCode ^
        currency.hashCode ^
        taxRate.hashCode ^
        defaultCheckInTime.hashCode ^
        defaultCheckOutTime.hashCode ^
        amenities.hashCode;
  }

  static DateTime _parsePublishedDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return DateTime.now();
    }

    final raw = value.toString();
    try {
      return formatter.parse(raw);
    } catch (_) {
      try {
        return DateFormat('dd-MM-yy').parse(raw);
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    return value is int ? value : int.tryParse(value.toString());
  }

  static double _parseDouble(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }
}
