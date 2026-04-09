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
      forecastStatus: map['forecast_status'] ?? 'Expected Idle',
    );
  }
}
