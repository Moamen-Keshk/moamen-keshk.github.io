import 'package:lotel_pms/app/api/view_models/floor.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/res/floor.service.dart';
import 'package:lotel_pms/infrastructure/api/model/room.model.dart';
import 'package:flutter_riverpod/legacy.dart';

class FloorListVM extends StateNotifier<List<FloorVM>> {
  bool _disposed = false;
  final int? propertyId;
  final FloorService floorService;

  FloorListVM(this.propertyId, this.floorService) : super(const []) {
    fetchFloors();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchFloors() async {
    final res = await floorService.getAllFloors(propertyId!);
    if (_disposed) return;
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
    if (propertyId == null) return false;
    try {
      final success =
          await floorService.editFloor(propertyId!, floorId, updatedData);
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
    if (propertyId == null) return false;
    try {
      final success = await floorService.deleteFloor(propertyId!, floorId);
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
