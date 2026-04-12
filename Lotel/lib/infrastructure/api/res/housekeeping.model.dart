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
      roomId: map['room_id'] ?? 0,
      roomNumber: map['room_number']?.toString() ?? 'N/A',
      userName: map['user_name'] ?? 'Unknown User',
      oldStatusId: map['old_status_id'] ?? 0,
      newStatusId: map['new_status_id'] ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp']).toLocal()
          : DateTime.now(),
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
      id: map['id'] ?? map['room_id'] ?? 0,
      roomNumber: map['room_number']?.toString() ?? 'N/A',
      cleaningStatusId: map['cleaning_status_id'] ?? 0,
      cleaningStatus: map['cleaning_status']?.toString() ?? 'Unknown',
      baseCleaningStatusId: map['base_cleaning_status_id'],
      baseCleaningStatus: map['base_cleaning_status']?.toString(),
      isOccupied: map['is_occupied'] == true,
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
      roomId: map['room_id'] ?? 0,
      roomNumber: map['room_number']?.toString() ?? 'N/A',
      forecastStatus: map['forecast_status'] ?? 'Expected Occupied',
    );
  }
}
