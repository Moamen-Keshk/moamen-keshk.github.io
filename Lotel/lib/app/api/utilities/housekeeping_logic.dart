import 'package:flutter/material.dart';
import 'package:lotel_pms/infrastructure/api/model/housekeeping.model.dart';

class HousekeepingStatusDefinition {
  final int id;
  final String label;
  final Color color;
  final int priority;
  final bool manualSelectable;

  const HousekeepingStatusDefinition({
    required this.id,
    required this.label,
    required this.color,
    required this.priority,
    required this.manualSelectable,
  });
}

const List<HousekeepingStatusDefinition> housekeepingStatusDefinitions = [
  HousekeepingStatusDefinition(
    id: 1,
    label: 'Dirty',
    color: Colors.red,
    priority: 0,
    manualSelectable: true,
  ),
  HousekeepingStatusDefinition(
    id: 5,
    label: 'Service',
    color: Colors.purple,
    priority: 1,
    manualSelectable: true,
  ),
  HousekeepingStatusDefinition(
    id: 2,
    label: 'Waiting',
    color: Colors.orange,
    priority: 2,
    manualSelectable: false,
  ),
  HousekeepingStatusDefinition(
    id: 4,
    label: 'Refresh',
    color: Colors.blue,
    priority: 3,
    manualSelectable: true,
  ),
  HousekeepingStatusDefinition(
    id: 7,
    label: 'Ready',
    color: Colors.teal,
    priority: 4,
    manualSelectable: true,
  ),
  HousekeepingStatusDefinition(
    id: 3,
    label: 'Clean',
    color: Colors.green,
    priority: 5,
    manualSelectable: true,
  ),
  HousekeepingStatusDefinition(
    id: 6,
    label: 'Occupied',
    color: Colors.grey,
    priority: 6,
    manualSelectable: false,
  ),
];

const HousekeepingStatusDefinition unknownHousekeepingStatus =
    HousekeepingStatusDefinition(
  id: 0,
  label: 'Unknown Status',
  color: Colors.grey,
  priority: 999,
  manualSelectable: false,
);

HousekeepingStatusDefinition housekeepingStatusFor(int? statusId) {
  for (final definition in housekeepingStatusDefinitions) {
    if (definition.id == statusId) {
      return definition;
    }
  }
  return unknownHousekeepingStatus;
}

List<HousekeepingStatusDefinition> get manualHousekeepingStatuses =>
    housekeepingStatusDefinitions
        .where((definition) => definition.manualSelectable)
        .toList(growable: false);

class HousekeepingSection<T> {
  final String key;
  final String title;
  final Color color;
  final List<T> items;

  const HousekeepingSection({
    required this.key,
    required this.title,
    required this.color,
    required this.items,
  });
}

enum HousekeepingDayKind { today, past, future, empty }

class HousekeepingDayData {
  final HousekeepingDayKind kind;
  final String emptyMessage;
  final List<HousekeepingSection<HousekeepingRoom>> roomSections;
  final List<CleaningLog> logs;
  final List<HousekeepingSection<Forecast>> forecastSections;

  const HousekeepingDayData({
    required this.kind,
    this.emptyMessage = '',
    this.roomSections = const [],
    this.logs = const [],
    this.forecastSections = const [],
  });

  factory HousekeepingDayData.today(List<HousekeepingRoom> rooms) {
    final sections = buildTodaySections(rooms);
    return HousekeepingDayData(
      kind: HousekeepingDayKind.today,
      emptyMessage: 'No rooms found.',
      roomSections: sections,
    );
  }

  factory HousekeepingDayData.past(List<CleaningLog> logs) {
    return HousekeepingDayData(
      kind: HousekeepingDayKind.past,
      emptyMessage: 'No cleaning status changes recorded on this date.',
      logs: sortCleaningLogs(logs),
    );
  }

  factory HousekeepingDayData.future(List<Forecast> forecasts) {
    final sections = buildForecastSections(forecasts);
    return HousekeepingDayData(
      kind: HousekeepingDayKind.future,
      emptyMessage: 'No forecast data for this date.',
      forecastSections: sections,
    );
  }

  factory HousekeepingDayData.empty(String message) {
    return HousekeepingDayData(
      kind: HousekeepingDayKind.empty,
      emptyMessage: message,
    );
  }
}

bool isTodayHousekeepingDate(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

HousekeepingRoom applyManualStatusToRoom(
  HousekeepingRoom room,
  int newBaseStatusId,
) {
  final baseStatus = housekeepingStatusFor(newBaseStatusId);
  final displayStatusId = room.isOccupied &&
          (newBaseStatusId == 3 || newBaseStatusId == 7)
      ? 6
      : newBaseStatusId;
  final displayStatus = housekeepingStatusFor(displayStatusId);

  return HousekeepingRoom(
    id: room.id,
    roomNumber: room.roomNumber,
    cleaningStatusId: displayStatus.id,
    cleaningStatus: displayStatus.label,
    baseCleaningStatusId: newBaseStatusId,
    baseCleaningStatus: baseStatus.label,
    isOccupied: room.isOccupied,
  );
}

HousekeepingDayData applyManualStatusToDayData(
  HousekeepingDayData data,
  int roomId,
  int newBaseStatusId,
) {
  if (data.kind != HousekeepingDayKind.today) {
    return data;
  }

  final updatedRooms = <HousekeepingRoom>[];
  for (final section in data.roomSections) {
    for (final room in section.items) {
      updatedRooms.add(
        room.id == roomId ? applyManualStatusToRoom(room, newBaseStatusId) : room,
      );
    }
  }

  return HousekeepingDayData.today(updatedRooms);
}

int compareRoomNumbers(String left, String right) {
  final leftNumber = _extractRoomNumber(left);
  final rightNumber = _extractRoomNumber(right);

  if (leftNumber != null && rightNumber != null && leftNumber != rightNumber) {
    return leftNumber.compareTo(rightNumber);
  }

  return left.compareTo(right);
}

int? _extractRoomNumber(String value) {
  final match = RegExp(r'\d+').firstMatch(value);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(0)!);
}

String housekeepingRoomSubtitle(HousekeepingRoom room) {
  final status = housekeepingStatusFor(room.cleaningStatusId);
  final parts = <String>['Current Status: ${status.label}'];

  if (room.isOccupied) {
    parts.add('Occupied');
  }

  if (room.baseCleaningStatus != null &&
      room.baseCleaningStatus!.isNotEmpty &&
      room.baseCleaningStatus != room.cleaningStatus) {
    parts.add('Base: ${room.baseCleaningStatus}');
  }

  return parts.join(' • ');
}

List<HousekeepingSection<HousekeepingRoom>> buildTodaySections(
  List<HousekeepingRoom> rooms,
) {
  if (rooms.isEmpty) {
    return const [];
  }

  final grouped = <int, List<HousekeepingRoom>>{};
  for (final room in rooms) {
    grouped.putIfAbsent(room.cleaningStatusId, () => <HousekeepingRoom>[])
        .add(room);
  }

  final sections = <HousekeepingSection<HousekeepingRoom>>[];
  final orderedDefinitions = [
    ...housekeepingStatusDefinitions,
    unknownHousekeepingStatus,
  ];

  for (final definition in orderedDefinitions) {
    final items = [...(grouped[definition.id] ?? const <HousekeepingRoom>[])];
    if (items.isEmpty) {
      continue;
    }

    items.sort((left, right) => compareRoomNumbers(
          left.roomNumber,
          right.roomNumber,
        ));

    sections.add(
      HousekeepingSection(
        key: 'status-${definition.id}',
        title: definition.label,
        color: definition.color,
        items: items,
      ),
    );
  }

  return sections;
}

List<CleaningLog> sortCleaningLogs(List<CleaningLog> logs) {
  final sorted = [...logs];
  sorted.sort((left, right) => right.timestamp.compareTo(left.timestamp));
  return sorted;
}

const List<String> forecastPriority = [
  'To be cleaned',
  'To be refreshed',
  'Ready',
  'Expected Occupied',
  'Clean',
  'Other',
];

String normalizeForecastStatus(String rawStatus) {
  final normalized = rawStatus.trim().toLowerCase();
  switch (normalized) {
    case 'to be cleaned':
      return 'To be cleaned';
    case 'to be refreshed':
      return 'To be refreshed';
    case 'ready':
      return 'Ready';
    case 'clean':
      return 'Clean';
    case 'expected occupied':
    case 'occupied':
      return 'Expected Occupied';
    default:
      return 'Other';
  }
}

Color forecastStatusColor(String forecastStatus) {
  switch (forecastStatus) {
    case 'To be cleaned':
      return Colors.red;
    case 'To be refreshed':
      return Colors.blue;
    case 'Ready':
      return Colors.teal;
    case 'Clean':
      return Colors.green;
    case 'Expected Occupied':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

List<HousekeepingSection<Forecast>> buildForecastSections(
  List<Forecast> forecasts,
) {
  if (forecasts.isEmpty) {
    return const [];
  }

  final grouped = <String, List<Forecast>>{};
  for (final forecast in forecasts) {
    final key = normalizeForecastStatus(forecast.forecastStatus);
    grouped.putIfAbsent(key, () => <Forecast>[]).add(forecast);
  }

  final sections = <HousekeepingSection<Forecast>>[];
  for (final status in forecastPriority) {
    final items = [...(grouped[status] ?? const <Forecast>[])];
    if (items.isEmpty) {
      continue;
    }

    items.sort((left, right) => compareRoomNumbers(
          left.roomNumber,
          right.roomNumber,
        ));

    sections.add(
      HousekeepingSection(
        key: status,
        title: status,
        color: forecastStatusColor(status),
        items: items,
      ),
    );
  }

  return sections;
}
