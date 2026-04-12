import 'package:flutter_riverpod/legacy.dart';
import 'package:lotel_pms/app/api/view_models/notification.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/notification.service.dart';

class AllNotificationListVM extends StateNotifier<List<NotificationVM>> {
  AllNotificationListVM() : super(const []) {
    fetchNotifications();
  }

  final NotificationService _service = NotificationService();

  Future<void> fetchNotifications() async {
    try {
      final res = await _service.getAllNotifications();
      state = res.map((notification) => NotificationVM(notification)).toList();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> markRead(String notificationId) async {
    await _service.markNotificationRead(notificationId);
    state = [
      for (final notification in state)
        if (notification.id == notificationId)
          NotificationVM(notification.notification.copyWith(isRead: true))
        else
          notification,
    ];
  }

  Future<void> markAllRead() async {
    await _service.markAllNotificationsRead();
    state = [
      for (final notification in state)
        NotificationVM(notification.notification.copyWith(isRead: true))
    ];
  }
}

final allNotificationListVM =
    StateNotifierProvider<AllNotificationListVM, List<NotificationVM>>(
        (ref) => AllNotificationListVM());
