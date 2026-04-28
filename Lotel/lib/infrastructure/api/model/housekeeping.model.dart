class CleaningLog {
  final int roomId;
  final String roomNumber;
  final String userName;
  final int oldStatusId;
  final int newStatusId;
  final DateTime timestamp;

  CleaningLog({
    required this.roomId,
    required this.roomNumber,
    required this.userName,
    required this.oldStatusId,
    required this.newStatusId,
    required this.timestamp,
  });

  factory CleaningLog.fromMap(Map<String, dynamic> map) {
    return CleaningLog(
      roomId: _readInt(map, ['room_id', 'roomId', 'id']),
      roomNumber: _readString(
        map,
        ['room_number', 'roomNumber'],
        fallback: 'N/A',
      ),
      userName: _readString(
        map,
        ['user_name', 'userName'],
        fallback: 'Unknown User',
      ),
      oldStatusId: _readInt(map, ['old_status_id', 'oldStatusId']),
      newStatusId: _readInt(map, ['new_status_id', 'newStatusId']),
      timestamp: _readDateTime(
        map,
        ['timestamp', 'created_at', 'createdAt', 'updated_at', 'updatedAt'],
      ),
    );
  }
}

class HousekeepingRoom {
  final int id;
  final String roomNumber;
  final int cleaningStatusId;
  final String cleaningStatus;
  final int? baseCleaningStatusId;
  final String? baseCleaningStatus;
  final bool isOccupied;

  HousekeepingRoom({
    required this.id,
    required this.roomNumber,
    required this.cleaningStatusId,
    required this.cleaningStatus,
    this.baseCleaningStatusId,
    this.baseCleaningStatus,
    required this.isOccupied,
  });

  factory HousekeepingRoom.fromMap(Map<String, dynamic> map) {
    return HousekeepingRoom(
      id: _readInt(map, ['id', 'room_id', 'roomId']),
      roomNumber: _readString(
        map,
        ['room_number', 'roomNumber'],
        fallback: 'N/A',
      ),
      cleaningStatusId: _readInt(
        map,
        ['cleaning_status_id', 'cleaningStatusId', 'status_id', 'statusId'],
      ),
      cleaningStatus: _readString(
        map,
        ['cleaning_status', 'cleaningStatus', 'status'],
        fallback: 'Unknown',
      ),
      baseCleaningStatusId: _readNullableInt(
        map,
        ['base_cleaning_status_id', 'baseCleaningStatusId'],
      ),
      baseCleaningStatus: _readNullableString(
        map,
        ['base_cleaning_status', 'baseCleaningStatus'],
      ),
      isOccupied: _readBool(map, ['is_occupied', 'isOccupied', 'occupied']),
    );
  }
}

class Forecast {
  final int roomId;
  final String roomNumber;
  final String forecastStatus;

  Forecast({
    required this.roomId,
    required this.roomNumber,
    required this.forecastStatus,
  });

  factory Forecast.fromMap(Map<String, dynamic> map) {
    return Forecast(
      roomId: _readInt(map, ['room_id', 'roomId', 'id']),
      roomNumber: _readString(
        map,
        ['room_number', 'roomNumber'],
        fallback: 'N/A',
      ),
      forecastStatus: _readString(
        map,
        ['forecast_status', 'forecastStatus', 'status'],
        fallback: 'Expected Occupied',
      ),
    );
  }
}

enum HousekeepingPayloadKind { today, past, future, empty }

HousekeepingPayloadKind inferHousekeepingPayloadKind({
  required DateTime targetDate,
  required DateTime today,
  String? rawType,
}) {
  final normalizedTarget = DateTime(
    targetDate.year,
    targetDate.month,
    targetDate.day,
  );
  final normalizedToday = DateTime(today.year, today.month, today.day);
  final normalizedType = rawType?.trim().toLowerCase();

  switch (normalizedType) {
    case 'today':
    case 'current':
      return HousekeepingPayloadKind.today;
    case 'past':
    case 'history':
    case 'logs':
      return HousekeepingPayloadKind.past;
    case 'future':
    case 'forecast':
    case 'forecasts':
      return HousekeepingPayloadKind.future;
    case 'empty':
      return HousekeepingPayloadKind.empty;
  }

  if (normalizedTarget.isAtSameMomentAs(normalizedToday)) {
    return HousekeepingPayloadKind.today;
  }

  return normalizedTarget.isBefore(normalizedToday)
      ? HousekeepingPayloadKind.past
      : HousekeepingPayloadKind.future;
}

List<Map<String, dynamic>> extractHousekeepingItems(dynamic payload) {
  if (payload is List) {
    return payload.whereType<Map>().map(_normalizeMap).toList(growable: false);
  }

  if (payload is! Map) {
    return const [];
  }

  final map = payload.cast<String, dynamic>();
  final candidates = [
    map['data'],
    map['items'],
    map['results'],
    map['rooms'],
    map['logs'],
    map['forecasts'],
  ];

  for (final candidate in candidates) {
    if (candidate is List) {
      return candidate
          .whereType<Map>()
          .map(_normalizeMap)
          .toList(growable: false);
    }
  }

  return const [];
}

Map<String, dynamic> _normalizeMap(Map source) {
  return source.map(
    (key, value) => MapEntry(key.toString(), value),
  );
}

dynamic _readValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    if (map.containsKey(key)) {
      return map[key];
    }
  }
  return null;
}

int _readInt(Map<String, dynamic> map, List<String> keys) {
  final value = _readValue(map, keys);
  if (value is int) {
    return value;
  }
  return int.tryParse('${value ?? 0}') ?? 0;
}

int? _readNullableInt(Map<String, dynamic> map, List<String> keys) {
  final value = _readValue(map, keys);
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  return int.tryParse('$value');
}

String _readString(
  Map<String, dynamic> map,
  List<String> keys, {
  required String fallback,
}) {
  final value = _readNullableString(map, keys);
  if (value == null || value.isEmpty) {
    return fallback;
  }
  return value;
}

String? _readNullableString(Map<String, dynamic> map, List<String> keys) {
  final value = _readValue(map, keys);
  if (value == null) {
    return null;
  }
  final normalized = value.toString().trim();
  return normalized.isEmpty ? null : normalized;
}

bool _readBool(Map<String, dynamic> map, List<String> keys) {
  final value = _readValue(map, keys);
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }

  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' ||
      normalized == '1' ||
      normalized == 'yes' ||
      normalized == 'occupied';
}

DateTime _readDateTime(Map<String, dynamic> map, List<String> keys) {
  final value = _readValue(map, keys);
  if (value is DateTime) {
    return value.toLocal();
  }
  if (value == null) {
    return DateTime.now();
  }

  final parsed = DateTime.tryParse(value.toString());
  return parsed?.toLocal() ?? DateTime.now();
}
