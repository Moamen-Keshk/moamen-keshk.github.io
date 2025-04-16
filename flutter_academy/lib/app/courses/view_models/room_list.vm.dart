import 'package:flutter_academy/app/courses/view_models/room.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/res/room.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomListVM extends StateNotifier<List<RoomVM>> {
  bool _disposed = false;
  final int? propertyId;

  RoomListVM(this.propertyId) : super(const []) {
    fetchRooms();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchRooms() async {
    final res = await RoomService().getAllRooms(propertyId!);
    if (_disposed) return;
    state = [...res.map((room) => RoomVM(room))];
  }

  Future<bool> addToRooms(
      {required int roomNumber,
      required int propertyId,
      required int categoryId,
      required int floorId}) async {
    if (await RoomService()
        .addRoom(roomNumber, propertyId, categoryId, floorId)) {
      await fetchRooms();
      return true;
    }
    return false;
  }

  Future<bool> deleteRoom(int roomId) async {
    final result = await RoomService().deleteRoom(roomId);
    if (result) {
      state = state.where((room) => room.id != roomId.toString()).toList();
      return true;
    }
    return false;
  }
}

final roomListVM = StateNotifierProvider<RoomListVM, List<RoomVM>>(
    (ref) => RoomListVM(ref.watch(selectedPropertyVM) ?? 0));
