import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:lotel_pms/app/api/view_models/room_online.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/app/req/request.dart';
import 'package:lotel_pms/infrastructure/api/model/room_online.model.dart';
import 'package:lotel_pms/infrastructure/api/res/room_online.service.dart';

String roomOnlineCellKey(String roomId, DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '$roomId|${normalized.year}-$month-$day';
}

class RoomOnlineListState {
  final List<RoomOnlineVM> items;
  final Map<String, RoomOnlineVM> indexedByCell;
  final bool isLoading;
  final String? errorMessage;

  const RoomOnlineListState({
    this.items = const [],
    this.indexedByCell = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  RoomOnlineListState copyWith({
    List<RoomOnlineVM>? items,
    Map<String, RoomOnlineVM>? indexedByCell,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RoomOnlineListState(
      items: items ?? this.items,
      indexedByCell: indexedByCell ?? this.indexedByCell,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RoomOnlineListVM extends StateNotifier<RoomOnlineListState> {
  final int? propertyId;
  final RoomOnlineService roomOnlineService;

  RoomOnlineListVM(this.propertyId, this.roomOnlineService)
      : super(const RoomOnlineListState()) {
    if (propertyId != null && propertyId != 0) {
      fetchRoomOnline();
    }
  }

  Future<void> fetchRoomOnline() async {
    if (propertyId == null || propertyId == 0) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await roomOnlineService.getAllRoomOnline(propertyId!);
      if (!mounted) return;
      _setItems(res);
    } on ApiRequestException catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load nightly rates.',
      );
    }
  }

  Future<bool> addRoomOnline(RoomOnline rate) async {
    try {
      final created = await roomOnlineService.addRoomOnline(rate);
      if (!mounted) return true;
      _upsertItem(RoomOnlineVM(created));
      return true;
    } on ApiRequestException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (_) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: 'Failed to save nightly rate.');
      return false;
    }
  }

  Future<bool> updateRoomOnline(RoomOnline rate) async {
    try {
      final updated = await roomOnlineService.updateRoomOnline(rate);
      if (!mounted) return true;
      _upsertItem(RoomOnlineVM(updated));
      return true;
    } on ApiRequestException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (_) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: 'Failed to update nightly rate.');
      return false;
    }
  }

  Future<bool> deleteRoomOnline(String roomOnlineId) async {
    if (propertyId == null || propertyId == 0) return false;
    try {
      await roomOnlineService.deleteRoomOnline(propertyId!, roomOnlineId);
      if (!mounted) return true;
      final filtered = state.items.where((rate) => rate.id != roomOnlineId).toList();
      _setItemVMs(filtered);
      return true;
    } on ApiRequestException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (_) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: 'Failed to remove nightly rate.');
      return false;
    }
  }

  Future<bool> upsertRoomOnline(RoomOnline rate) async {
    final existing = state.indexedByCell[roomOnlineCellKey(rate.roomId, rate.date)];
    if (existing != null) {
      final updatedRate = rate.copyWith(id: existing.id);
      return updateRoomOnline(updatedRate);
    }
    return addRoomOnline(rate);
  }

  Future<List<RoomOnlineVM>> fetchRoomByCategory(String categoryId) async {
    if (propertyId == null || propertyId == 0) return [];
    final result = await roomOnlineService.getRoomByPropertyAndCategory(
      propertyId: propertyId!,
      categoryId: categoryId,
    );
    return result.map((rate) => RoomOnlineVM(rate)).toList();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void _upsertItem(RoomOnlineVM vm) {
    final updated = [...state.items];
    final existingIndex = updated.indexWhere((item) => item.id == vm.id);
    if (existingIndex >= 0) {
      updated[existingIndex] = vm;
    } else {
      updated.add(vm);
    }
    updated.sort((a, b) {
      final roomCompare = a.roomOnline.roomId.compareTo(b.roomOnline.roomId);
      if (roomCompare != 0) return roomCompare;
      return a.roomOnline.date.compareTo(b.roomOnline.date);
    });
    _setItemVMs(updated);
  }

  void _setItems(List<RoomOnline> rates) {
    _setItemVMs(rates.map((rate) => RoomOnlineVM(rate)).toList());
  }

  void _setItemVMs(List<RoomOnlineVM> items) {
    final index = <String, RoomOnlineVM>{};
    for (final item in items) {
      index[roomOnlineCellKey(item.roomOnline.roomId, item.roomOnline.date)] = item;
    }
    state = state.copyWith(
      items: items,
      indexedByCell: index,
      isLoading: false,
      clearError: true,
    );
  }
}

final roomOnlineListVM =
    StateNotifierProvider<RoomOnlineListVM, RoomOnlineListState>(
  (ref) => RoomOnlineListVM(ref.watch(selectedPropertyVM), RoomOnlineService()),
);

final roomOnlineItemsProvider = Provider<List<RoomOnlineVM>>(
  (ref) => ref.watch(roomOnlineListVM).items,
);

final roomOnlineIndexProvider = Provider<Map<String, RoomOnlineVM>>(
  (ref) => ref.watch(roomOnlineListVM).indexedByCell,
);
