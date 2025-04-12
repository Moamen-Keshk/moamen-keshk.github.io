import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/res/floor.service.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FloorListVM extends StateNotifier<List<FloorVM>> {
  final int? propertyId;
  final FloorService floorService;

  FloorListVM(this.propertyId, this.floorService) : super(const []) {
    fetchFloors();
  }
  Future<void> fetchFloors() async {
    final res = await floorService.getAllFloors(propertyId!);
    state = [...res.map((floor) => FloorVM(floor))];
  }

  Future<bool> addToFloors(
      {required int number, required int propertyId, List<Room>? rooms}) async {
    if (await floorService.addFloor(number, propertyId, rooms)) {
      await fetchFloors();
      return true;
    }
    return false;
  }

  Future<bool> editFloor(int floorId, Map<String, dynamic> updatedData) async {
    try {
      final success = await floorService.editFloor(floorId, updatedData);
      if (success) {
        await fetchFloors();
        return true;
      }
    } catch (e) {
      // Handle error, e.g., log it or update the state with an error message
    }
    return false;
  }

  Future<bool> deleteFloor(int floorId) async {
    try {
      final success = await floorService.deleteFloor(floorId);
      if (success) {
        await fetchFloors(); // Refresh state
        return true;
      }
    } catch (e) {
      // Optionally log or show an error message
    }
    return false;
  }
}

final floorListVM = StateNotifierProvider<FloorListVM, List<FloorVM>>(
    (ref) => FloorListVM(ref.watch(selectedPropertyVM) ?? 0, FloorService()));
