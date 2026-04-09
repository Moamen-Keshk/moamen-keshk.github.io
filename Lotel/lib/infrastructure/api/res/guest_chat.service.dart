import 'package:lotel_pms/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/infrastructure/api/model/guest_chat.model.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class GuestMessageService {
  final _auth = FirebaseAuth.instance;

  // 1. GET CHAT HISTORY FOR A SPECIFIC BOOKING
  Future<List<GuestMessage>> getChatHistory(
      int propertyId, int bookingId) async {
    final token = await _auth.currentUser?.getIdToken();

    // Adjust the base path (/api/v1/) if your backend routing requires it
    final query = await sendGetRequest(
        token, "/api/v1/properties/$propertyId/bookings/$bookingId/chat");

    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch chat history. Returning empty list.");
      return [];
    }

    return (query['data'] as List)
        .map((e) => GuestMessage.fromResMap(e))
        .toList();
  }

  // 2. SEND A NEW CHAT MESSAGE TO THE GUEST
  Future<bool> sendChatMessage(int propertyId, int bookingId, String message,
      {String channel = 'whatsapp'}) async {
    final token = await _auth.currentUser?.getIdToken();

    return await sendPostRequest({"message": message, "channel": channel},
        token, "/api/v1/properties/$propertyId/bookings/$bookingId/chat");
  }
}
