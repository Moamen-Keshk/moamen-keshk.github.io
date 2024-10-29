import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';
import 'package:flutter_academy/infrastructure/courses/res/floor.service.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FloorListVM extends StateNotifier<List<FloorVM>> {
  FloorListVM() : super(const []) {
    fetchFloors();
  }
  Future<void> fetchFloors() async {
    final res = await FloorService().getAllFloors();
    state = [...res.map((floor) => FloorVM(floor))];
  }

  Future<bool> addToFloors({required int number, required int propertyId, List<Room>? rooms}) async {
    if (await FloorService().addFloor(number, propertyId, rooms)) {
      await fetchFloors();
      return true;
    }
    return false;
  }
}

final floorListVM =
    StateNotifierProvider<FloorListVM, List<FloorVM>>(
        (ref) => FloorListVM());