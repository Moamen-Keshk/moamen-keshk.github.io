import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_academy/infrastructure/courses/res/room.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // Keeping your legacy import if required

final roomServiceProvider = Provider((ref) => RoomService());

// Provider to hold the currently selected date for housekeeping
final housekeepingDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

// Provider to hold the current selected filter (All, Dirty, Clean, etc.)
final housekeepingFilterProvider = StateProvider<String>((ref) => 'All');

// FutureProvider to fetch all rooms for the property (For 'Today' view)
final housekeepingRoomsProvider =
    FutureProvider.family<List<Room>, int>((ref, propertyId) async {
  final roomService = ref.watch(roomServiceProvider);
  return await roomService.getAllRooms(propertyId);
});

// Helper class to pass multiple arguments to FutureProvider.family
class HousekeepingParams {
  final int propertyId;
  final DateTime date;
  HousekeepingParams(this.propertyId, this.date);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HousekeepingParams &&
          runtimeType == other.runtimeType &&
          propertyId == other.propertyId &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day;

  @override
  int get hashCode =>
      propertyId.hashCode ^
      date.year.hashCode ^
      date.month.hashCode ^
      date.day.hashCode;
}

// FutureProvider to fetch Past/Future data
final housekeepingDateDataProvider =
    FutureProvider.family<Map<String, dynamic>, HousekeepingParams>(
        (ref, params) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(params.date.year, params.date.month, params.date.day);

  // If the target date is today, we don't need this provider (we use housekeepingRoomsProvider)
  if (target.isAtSameMomentAs(today)) {
    return {'type': 'today'};
  }

  final roomService = ref.watch(roomServiceProvider);
  final result =
      await roomService.getHousekeepingByDate(params.propertyId, target);

  return result ?? {'type': 'error'};
});
