import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/model/room_rate.model.dart';
import 'package:flutter_academy/infrastructure/courses/res/room_rate.service.dart';
import 'package:flutter_academy/app/courses/view_models/room_rate.vm.dart';
import 'package:collection/collection.dart';

class RoomRateListVM extends StateNotifier<List<RoomRateVM>> {
  final int? propertyId;
  final RoomRateService roomRateService;

  RoomRateListVM(this.propertyId, this.roomRateService) : super(const []) {
    if (propertyId != null && propertyId != 0) {
      fetchRoomRates();
    }
  }

  /// Fetch all room rates for the selected property from the backend
  Future<void> fetchRoomRates() async {
    if (propertyId == null) return;
    final res = await roomRateService.getAllRoomRates(propertyId!);
    state = res.map((rate) => RoomRateVM(rate)).toList();
  }

  /// Add a new custom room rate
  Future<bool> addRoomRate(RoomRate rate) async {
    final result = await roomRateService.addRoomRate(rate);
    if (result) {
      await fetchRoomRates();
      return true;
    }
    return false;
  }

  /// Update a room rate by ID with new data
  Future<bool> updateRoomRate(RoomRate rate) async {
    final result = await roomRateService.updateRoomRate(rate);
    if (result) {
      await fetchRoomRates();
      return true;
    }
    return false;
  }

  /// Delete a room rate by ID
  Future<bool> deleteRoomRate(String roomRateId) async {
    final result = await roomRateService.deleteRoomRate(roomRateId);
    if (result) {
      state = state.where((rate) => rate.id != roomRateId).toList();
      return true;
    }
    return false;
  }

  /// Add or update (upsert) a room rate
  Future<bool> upsertRoomRate(RoomRate rate) async {
    final existing = state.firstWhereOrNull((vm) =>
        vm.roomRate.roomId == rate.roomId &&
        _isSameDay(vm.roomRate.date, rate.date));

    if (existing != null) {
      final updatedRate = rate.copyWith(id: existing.id);
      return await updateRoomRate(updatedRate);
    } else {
      return await addRoomRate(rate);
    }
  }

  Future<List<RoomRateVM>> fetchRatesByCategory(String categoryId) async {
    if (propertyId == null) return [];
    final result = await roomRateService.getRatesByPropertyAndCategory(
      propertyId: propertyId!,
      categoryId: categoryId,
    );
    return result.map((rate) => RoomRateVM(rate)).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

final roomRateListVM = StateNotifierProvider<RoomRateListVM, List<RoomRateVM>>(
  (ref) => RoomRateListVM(ref.watch(selectedPropertyVM), RoomRateService()),
);
