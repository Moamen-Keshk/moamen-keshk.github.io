import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/rates/room_rate.service.dart';
import 'package:flutter_academy/app/rates/room_rate.vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomRateListVM extends StateNotifier<List<RoomRateVM>> {
  final int? propertyId;

  RoomRateListVM(this.propertyId) : super(const []) {
    fetchRoomRates();
  }
  Future<void> fetchRoomRates() async {
    final res = await RoomRateService().getAllRoomRates(propertyId!);
    state = [...res.map((roomRate) => RoomRateVM(roomRate))];
  }

  Future<bool> addToRoomRates({
    required String roomId,
    required DateTime date,
    required double price,
    required int propertyId,
  }) async {
    if (await RoomRateService().addRoomRate(roomId, date, price, propertyId)) {
      await fetchRoomRates();
      return true;
    }
    return false;
  }

  Future<bool> deleteRoomRate(int roomRateId) async {
    final result = await RoomRateService().deleteRoomRate(roomRateId);
    if (result) {
      state = state
          .where((roomRate) => roomRate.id != roomRateId.toString())
          .toList();
      return true;
    }
    return false;
  }
}

final roomListVM = StateNotifierProvider<RoomRateListVM, List<RoomRateVM>>(
    (ref) => RoomRateListVM(ref.watch(selectedPropertyVM) ?? 0));
