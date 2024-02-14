import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/notification.model.dart';

class NotificationService {
  final _auth = FirebaseAuth.instance;
  Future<List<Notification>> getNotifications() async {
    final query = await sendGetRequest(
        await _auth.currentUser?.getIdToken(), "/api/v1/notifications");
    return (query['data'] as List)
        .map((e) => Notification.fromResMap(e))
        .toList();
  }
}
