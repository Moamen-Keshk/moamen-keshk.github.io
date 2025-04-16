import 'dart:convert';

class Season {
  final String id;
  final int propertyId;
  DateTime startDate;
  DateTime endDate;
  final String? label;

  Season({
    required this.id,
    required this.propertyId,
    required this.startDate,
    required this.endDate,
    this.label,
  });

  Season copyWith({
    String? id,
    int? propertyId,
    DateTime? startDate,
    DateTime? endDate,
    String? label,
  }) {
    return Season(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      if (label != null) 'label': label,
    };
  }

  factory Season.fromMap(Map<String, dynamic> map) {
    return Season(
      id: map['id'].toString(),
      propertyId: map['property_id'] ?? '',
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      label: map['label'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Season.fromJson(String source) => Season.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Season(id: $id, propertyId: $propertyId, startDate: $startDate, endDate: $endDate, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Season &&
        other.id == id &&
        other.propertyId == propertyId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.label == label;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        propertyId.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        label.hashCode;
  }
}
