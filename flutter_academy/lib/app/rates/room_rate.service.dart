import 'package:flutter_academy/app/rates/room_rate.model.dart';
import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomRateService {
  final _auth = FirebaseAuth.instance;
  Future<List<RoomRate>> getRoomRate() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/room_rate");
    return (query['data'] as List).map((e) => RoomRate.fromResMap(e)).toList();
  }

  Future<List<RoomRate>> getAllRoomRates(int propertyId) async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/all_room_rates");
    return (query['data'] as List).map((e) => RoomRate.fromResMap(e)).toList();
  }

  Future<bool> addRoomRate(
      String roomId, DateTime date, double price, int propertyId) async {
    return await sendPostRequest(
        {"room_id": roomId, "date": date, 'price': price},
        await _auth.currentUser?.getIdToken(),
        "/api/v1/new_room_rate");
  }

  Future<bool> deleteRoomRate(int roomRateId) async {
    try {
      final response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/delete_room_rate/$roomRateId",
      );
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}
