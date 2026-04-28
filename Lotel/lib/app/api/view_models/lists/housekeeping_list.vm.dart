import 'dart:async';

import 'package:lotel_pms/app/api/utilities/housekeeping_logic.dart';
import 'package:lotel_pms/infrastructure/api/model/housekeeping.model.dart';
import 'package:lotel_pms/infrastructure/api/res/room.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // Keeping your legacy import if required

final roomServiceProvider = Provider((ref) => RoomService());

// Provider to hold the currently selected date for housekeeping
final housekeepingDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

// FutureProvider to fetch all rooms for the property (For 'Today' view)
final housekeepingRoomsProvider = FutureProvider.autoDispose
    .family<List<HousekeepingRoom>, int>((ref, propertyId) async {
  if (propertyId <= 0) {
    return const [];
  }
  final roomService = ref.watch(roomServiceProvider);
  return await roomService.getTodayHousekeeping(propertyId);
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
final housekeepingDateDataProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, HousekeepingParams>((ref, params) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(params.date.year, params.date.month, params.date.day);

  if (params.propertyId <= 0) {
    return {'type': 'empty', 'data': const []};
  }

  // If the target date is today, we don't need this provider (we use housekeepingRoomsProvider)
  if (target.isAtSameMomentAs(today)) {
    return {'type': 'today'};
  }

  final roomService = ref.watch(roomServiceProvider);
  final result =
      await roomService.getHousekeepingByDate(params.propertyId, target);

  return result ?? {'type': 'error'};
});

final housekeepingDayVMProvider = StateNotifierProvider.autoDispose.family<
    HousekeepingDayVM,
    AsyncValue<HousekeepingDayData>,
    HousekeepingParams>((ref, params) {
  return HousekeepingDayVM(ref, params);
});

class HousekeepingDayVM extends StateNotifier<AsyncValue<HousekeepingDayData>> {
  final Ref ref;
  final HousekeepingParams params;

  HousekeepingDayVM(this.ref, this.params) : super(const AsyncValue.loading()) {
    unawaited(refresh());
  }

  Future<void> refresh({bool silent = false}) async {
    final previousData = state.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    if (!silent || previousData == null) {
      state = const AsyncValue.loading();
    }

    final nextState = await AsyncValue.guard(_fetchDayData);
    if (!mounted) return;

    if (silent && nextState.hasError && previousData != null) {
      state = AsyncValue.data(previousData);
      return;
    }

    state = nextState;
  }

  Future<bool> updateRoomStatus(int roomId, int newStatusId) async {
    final roomService = ref.read(roomServiceProvider);
    final success = await roomService.updateCleaningStatus(
      params.propertyId,
      roomId,
      newStatusId,
    );
    if (!mounted) return false;

    if (!success) {
      return false;
    }

    final currentData = state.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    if (currentData != null && isTodayHousekeepingDate(params.date)) {
      state = AsyncValue.data(
        applyManualStatusToDayData(currentData, roomId, newStatusId),
      );
      unawaited(refresh(silent: true));
    } else {
      await refresh();
    }

    return true;
  }

  Future<HousekeepingDayData> _fetchDayData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      params.date.year,
      params.date.month,
      params.date.day,
    );

    if (params.propertyId <= 0) {
      return HousekeepingDayData.empty(
          'Select a property to view housekeeping.');
    }

    final roomService = ref.read(roomServiceProvider);

    if (target.isAtSameMomentAs(today)) {
      final rooms = await roomService.getTodayHousekeeping(params.propertyId);
      return HousekeepingDayData.today(rooms);
    }

    final payload = await roomService.getHousekeepingByDate(
      params.propertyId,
      target,
    );
    final list = extractHousekeepingItems(payload);
    final kind = inferHousekeepingPayloadKind(
      targetDate: target,
      today: today,
      rawType: payload?['type']?.toString(),
    );

    switch (kind) {
      case HousekeepingPayloadKind.past:
        return HousekeepingDayData.past(
          list.map(CleaningLog.fromMap).toList(growable: false),
        );
      case HousekeepingPayloadKind.future:
        return HousekeepingDayData.future(
          list.map(Forecast.fromMap).toList(growable: false),
        );
      case HousekeepingPayloadKind.today:
        return HousekeepingDayData.today(
          list.map(HousekeepingRoom.fromMap).toList(growable: false),
        );
      case HousekeepingPayloadKind.empty:
        return target.isBefore(today)
            ? HousekeepingDayData.past(const [])
            : HousekeepingDayData.future(const []);
    }
  }
}
