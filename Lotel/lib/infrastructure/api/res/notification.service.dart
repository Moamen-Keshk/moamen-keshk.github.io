import 'package:lotel_pms/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/infrastructure/api/model/notification.model.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class NotificationService {
  final _auth = FirebaseAuth.instance;

  // 1. GET NOTIFICATIONS
  // 👉 Removed propertyId parameter completely
  Future<List<Notification>> getNotifications() async {
    final token = await _auth.currentUser?.getIdToken();

    final query = await sendGetRequestOrThrow(
      token,
      "/api/v1/notifications",
      fallbackMessage: 'Failed to fetch notifications.',
    );

    if (query is! Map<String, dynamic> || query['data'] is! List) {
      debugPrint("Notifications response was malformed. Returning empty list.");
      return [];
    }

    return (query['data'] as List)
        .map((e) => Notification.fromResMap(e))
        .toList();
  }

  // 2. GET ALL NOTIFICATIONS
  // 👉 Removed propertyId parameter completely
  Future<List<Notification>> getAllNotifications() async {
    final token = await _auth.currentUser?.getIdToken();

    final query = await sendGetRequestOrThrow(
      token,
      "/api/v1/all-notifications",
      fallbackMessage: 'Failed to fetch all notifications.',
    );

    if (query is! Map<String, dynamic> || query['data'] is! List) {
      debugPrint(
          "All notifications response was malformed. Returning empty list.");
      return [];
    }

    return (query['data'] as List)
        .map((e) => Notification.fromResMap(e))
        .toList();
  }

  Future<void> markNotificationRead(String notificationId) async {
    final token = await _auth.currentUser?.getIdToken();
    await sendPutWithResponseRequestOrThrow(
      const {},
      token,
      "/api/v1/notifications/$notificationId/read",
      fallbackMessage: 'Failed to mark notification as read.',
    );
  }

  Future<void> markAllNotificationsRead() async {
    final token = await _auth.currentUser?.getIdToken();
    await sendPutWithResponseRequestOrThrow(
      const {},
      token,
      "/api/v1/notifications/read-all",
      fallbackMessage: 'Failed to mark notifications as read.',
    );
  }
}
