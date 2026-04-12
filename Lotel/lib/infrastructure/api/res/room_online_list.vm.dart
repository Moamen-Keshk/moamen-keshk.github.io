import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/model/room_online.model.dart';
import 'package:lotel_pms/infrastructure/api/res/room_online.service.dart';
import 'package:lotel_pms/app/api/view_models/room_online.vm.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/legacy.dart';

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
    await roomOnlineService.addRoomOnline(rate);
    await fetchRoomOnline();
    return true;
  }

  /// Update a room rate by ID with new data
  Future<bool> updateRoomOnline(RoomOnline rate) async {
    await roomOnlineService.updateRoomOnline(rate);
    await fetchRoomOnline();
    return true;
  }

  /// Delete a room rate by ID
  Future<bool> deleteRoomOnline(String roomOnlineId) async {
    if (propertyId == null) return false;
    await roomOnlineService.deleteRoomOnline(propertyId!, roomOnlineId);
    state = state.where((rate) => rate.id != roomOnlineId).toList();
    await fetchRoomOnline();
    return true;
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
