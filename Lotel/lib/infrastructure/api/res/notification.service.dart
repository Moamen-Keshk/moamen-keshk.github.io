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

    // 👉 Using the global RESTful pattern
    final query = await sendGetRequest(token, "/api/v1/notifications");

    // 👉 THE SAFETY NET: Prevent the 'null' crash
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch notifications. Returning empty list.");
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

    // 👉 Using the global RESTful pattern
    final query = await sendGetRequest(token, "/api/v1/all-notifications");

    // 👉 THE SAFETY NET
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch all notifications. Returning empty list.");
      return [];
    }

    return (query['data'] as List)
        .map((e) => Notification.fromResMap(e))
        .toList();
  }
}
