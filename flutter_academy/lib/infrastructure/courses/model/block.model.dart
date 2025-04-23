import 'dart:convert';
import 'package:intl/intl.dart';

DateFormat format = DateFormat("EEE, dd MMM yyyy HH:mm:ss z");

class Block {
  final String id;
  final String? note;
  final DateTime blockDate;
  final DateTime startDate;
  final DateTime endDate;
  final int startDay;
  final int startMonth;
  final int startYear;
  final int endDay;
  final int endMonth;
  final int endYear;
  final int numberOfDays;
  final int propertyID;
  final int roomID;

  Block({
    required this.id,
    this.note,
    required this.blockDate,
    required this.startDate,
    required this.endDate,
    required this.startDay,
    required this.startMonth,
    required this.startYear,
    required this.endDay,
    required this.endMonth,
    required this.endYear,
    required this.numberOfDays,
    required this.propertyID,
    required this.roomID,
  });

  Block copyWith({
    String? id,
    String? note,
    DateTime? blockDate,
    DateTime? startDate,
    DateTime? endDate,
    int? startDay,
    int? startMonth,
    int? startYear,
    int? endDay,
    int? endMonth,
    int? endYear,
    int? numberOfDays,
    int? propertyID,
    int? roomID,
  }) {
    return Block(
      id: id ?? this.id,
      note: note ?? this.note,
      blockDate: blockDate ?? this.blockDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startDay: startDay ?? this.startDay,
      startMonth: startMonth ?? this.startMonth,
      startYear: startYear ?? this.startYear,
      endDay: endDay ?? this.endDay,
      endMonth: endMonth ?? this.endMonth,
      endYear: endYear ?? this.endYear,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      propertyID: propertyID ?? this.propertyID,
      roomID: roomID ?? this.roomID,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note': note,
      'block_date': blockDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'start_day': startDay,
      'start_month': startMonth,
      'start_year': startYear,
      'end_day': endDay,
      'end_month': endMonth,
      'end_year': endYear,
      'number_of_days': numberOfDays,
      'property_id': propertyID,
      'room_id': roomID,
    };
  }

  factory Block.fromMap(String id, Map<String, dynamic> map) {
    return Block(
      id: id,
      note: map['note'] ?? '',
      blockDate: DateTime.parse(map['block_date']),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      startDay: map['start_day'] ?? 0,
      startMonth: map['start_month'] ?? 0,
      startYear: map['start_year'] ?? 0,
      endDay: map['end_day'] ?? 0,
      endMonth: map['end_month'] ?? 0,
      endYear: map['end_year'] ?? 0,
      numberOfDays: map['number_of_days'] ?? 0,
      propertyID: map['property_id'] ?? 0,
      roomID: map['room_id'] ?? 0,
    );
  }

  factory Block.fromResMap(Map<String, dynamic> map) {
    return Block(
      id: map['id'].toString(),
      note: map['note'] ?? '',
      blockDate: format.parse(map['block_date']),
      startDate: format.parse(map['start_date']),
      endDate: format.parse(map['end_date']),
      startDay: map['start_day'] ?? 0,
      startMonth: map['start_month'] ?? 0,
      startYear: map['start_year'] ?? 0,
      endDay: map['end_day'] ?? 0,
      endMonth: map['end_month'] ?? 0,
      endYear: map['end_year'] ?? 0,
      numberOfDays: map['number_of_days'] ?? 0,
      propertyID: map['property_id'] ?? 0,
      roomID: map['room_id'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Block.fromJson(String id, String source) =>
      Block.fromMap(id, json.decode(source));

  @override
  String toString() {
    return '''Block(id: $id, note: $note, blockDate: $blockDate,
    startDate: $startDate, endDate: $endDate,
    startDay: $startDay, startMonth: $startMonth, startYear: $startYear,
    endDay: $endDay, endMonth: $endMonth, endYear: $endYear,
    numberOfDays: $numberOfDays, propertyID: $propertyID, roomID: $roomID)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Block &&
        other.id == id &&
        other.note == note &&
        other.blockDate == blockDate &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.startDay == startDay &&
        other.startMonth == startMonth &&
        other.startYear == startYear &&
        other.endDay == endDay &&
        other.endMonth == endMonth &&
        other.endYear == endYear &&
        other.numberOfDays == numberOfDays &&
        other.propertyID == propertyID &&
        other.roomID == roomID;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        note.hashCode ^
        blockDate.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        startDay.hashCode ^
        startMonth.hashCode ^
        startYear.hashCode ^
        endDay.hashCode ^
        endMonth.hashCode ^
        endYear.hashCode ^
        numberOfDays.hashCode ^
        propertyID.hashCode ^
        roomID.hashCode;
  }
}
