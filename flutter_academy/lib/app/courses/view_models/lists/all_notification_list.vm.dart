import 'package:flutter_academy/app/courses/view_models/notification.vm.dart';
import 'package:flutter_academy/infrastructure/courses/res/notification.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllNotificationListVM extends StateNotifier<List<NotificationVM>> {
  AllNotificationListVM() : super(const []) {
    fetchNotifications();
  }
  Future<void> fetchNotifications() async {
    final res = await NotificationService().getAllNotifications();
    state = [...res.map((notification) => NotificationVM(notification))];
  }
}

final allNotificationListVM =
    StateNotifierProvider<AllNotificationListVM, List<NotificationVM>>(
        (ref) => AllNotificationListVM());
