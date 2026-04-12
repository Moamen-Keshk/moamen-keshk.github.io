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

    final query = await sendGetRequestOrThrow(
      token,
      "/api/v1/properties/$propertyId/bookings/$bookingId/chat",
      fallbackMessage: 'Failed to load guest communication.',
    );

    if (query is! Map<String, dynamic> || query['data'] is! List) {
      debugPrint("Guest communication response was malformed: $query");
      throw ApiRequestException('Failed to load guest communication.');
    }

    return (query['data'] as List)
        .map((e) => GuestMessage.fromResMap(e))
        .toList();
  }

  // 2. SEND A NEW CHAT MESSAGE TO THE GUEST
  Future<GuestMessage> sendChatMessage(
      int propertyId, int bookingId, String message,
      {String channel = 'whatsapp'}) async {
    final token = await _auth.currentUser?.getIdToken();

    final query = await sendPostWithResponseRequestOrThrow(
      {"message": message, "channel": channel},
      token,
      "/api/v1/properties/$propertyId/bookings/$bookingId/chat",
      fallbackMessage: 'Failed to send guest message.',
    );

    if (query is! Map<String, dynamic> || query['data'] is! Map<String, dynamic>) {
      debugPrint("Guest communication send response was malformed: $query");
      throw ApiRequestException('Failed to send guest message.');
    }

    return GuestMessage.fromResMap(query['data']);
  }
}
