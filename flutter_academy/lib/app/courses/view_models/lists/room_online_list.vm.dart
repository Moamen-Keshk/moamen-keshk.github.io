import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/model/room_online.model.dart';
import 'package:flutter_academy/infrastructure/courses/res/room_online.service.dart';
import 'package:flutter_academy/app/courses/view_models/room_online.vm.dart';
import 'package:collection/collection.dart';

class RoomOnlineListVM extends StateNotifier<List<RoomOnlineVM>> {
  final int? propertyId;
  final RoomOnlineService roomOnlineService;

  RoomOnlineListVM(this.propertyId, this.roomOnlineService) : super(const []) {
    if (propertyId != null && propertyId != 0) {
      fetchRoomOnline();
    }
  }

  /// Fetch all room rates for the selected property from the backend
  Future<void> fetchRoomOnline() async {
    if (propertyId == null) return;
    final res = await roomOnlineService.getAllRoomOnline(propertyId!);
    state = res.map((rate) => RoomOnlineVM(rate)).toList();
  }

  /// Add a new custom room rate
  Future<bool> addRoomOnline(RoomOnline rate) async {
    final result = await roomOnlineService.addRoomOnline(rate);
    if (result) {
      await fetchRoomOnline();
      return true;
    }
    return false;
  }

  /// Update a room rate by ID with new data
  Future<bool> updateRoomOnline(RoomOnline rate) async {
    final result = await roomOnlineService.updateRoomOnline(rate);
    if (result) {
      await fetchRoomOnline();
      return true;
    }
    return false;
  }

  /// Delete a room rate by ID
  Future<bool> deleteRoomOnline(String roomOnlineId) async {
    final result = await roomOnlineService.deleteRoomOnline(roomOnlineId);
    if (result) {
      state = state.where((rate) => rate.id != roomOnlineId).toList();
      await fetchRoomOnline();
      return true;
    }
    return false;
  }

  /// Add or update (upsert) a room rate
  Future<bool> upsertRoomOnline(RoomOnline rate) async {
    final existing = state.firstWhereOrNull((vm) =>
        vm.roomOnline.roomId == rate.roomId &&
        _isSameDay(vm.roomOnline.date, rate.date));

    if (existing != null) {
      final updatedRate = rate.copyWith(id: existing.id);
      return await updateRoomOnline(updatedRate);
    } else {
      return await addRoomOnline(rate);
    }
  }

  Future<List<RoomOnlineVM>> fetchRoomByCategory(String categoryId) async {
    if (propertyId == null) return [];
    final result = await roomOnlineService.getRoomByPropertyAndCategory(
      propertyId: propertyId!,
      categoryId: categoryId,
    );
    return result.map((rate) => RoomOnlineVM(rate)).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

final roomOnlineListVM =
    StateNotifierProvider<RoomOnlineListVM, List<RoomOnlineVM>>(
  (ref) => RoomOnlineListVM(ref.watch(selectedPropertyVM), RoomOnlineService()),
);
