import 'package:flutter_academy/app/courses/view_models/notification.vm.dart';
import 'package:flutter_academy/infrastructure/courses/res/notification.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationListVM extends StateNotifier<List<NotificationVM>> {
  NotificationListVM() : super(const []) {
    fetchNotifications();
  }
  Future<void> fetchNotifications() async {
    final res = await NotificationService().getNotifications();
    state = [...res.map((notification) => NotificationVM(notification))];
  }
}

final notificationListVM =
    StateNotifierProvider<NotificationListVM, List<NotificationVM>>(
        (ref) => NotificationListVM());
