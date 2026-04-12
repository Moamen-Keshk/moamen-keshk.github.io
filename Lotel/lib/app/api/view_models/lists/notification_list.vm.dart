import 'package:flutter_riverpod/legacy.dart';
import 'package:lotel_pms/app/api/view_models/notification.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/notification.service.dart';

class NotificationListVM extends StateNotifier<List<NotificationVM>> {
  NotificationListVM() : super(const []) {
    fetchNotifications();
  }

  final NotificationService _service = NotificationService();

  Future<void> fetchNotifications() async {
    try {
      final res = await _service.getNotifications();
      state = res.map((notification) => NotificationVM(notification)).toList();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> markRead(String notificationId) async {
    await _service.markNotificationRead(notificationId);
    state = state.where((item) => item.id != notificationId).toList();
  }

  Future<void> markAllRead() async {
    await _service.markAllNotificationsRead();
    state = const [];
  }
}

final notificationListVM =
    StateNotifierProvider<NotificationListVM, List<NotificationVM>>(
        (ref) => NotificationListVM());
