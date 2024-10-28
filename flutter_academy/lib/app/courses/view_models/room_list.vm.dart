import 'package:flutter_academy/app/courses/view_models/room.vm.dart';
import 'package:flutter_academy/infrastructure/courses/res/room.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomListVM extends StateNotifier<List<RoomVM>> {
  RoomListVM() : super(const []) {
    fetchRooms();
  }
  Future<void> fetchRooms() async {
    final res = await RoomService().getAllRooms();
    state = [...res.map((room) => RoomVM(room))];
  }

  Future<bool> addToRooms({required int roomNumber, required int categoryId, required int floorId}) async {
    if (await RoomService().addRoom(roomNumber, categoryId, floorId)) {
      await fetchRooms();
      return true;
    }
    return false;
  }
}

final roomListVM =
    StateNotifierProvider<RoomListVM, List<RoomVM>>(
        (ref) => RoomListVM());
