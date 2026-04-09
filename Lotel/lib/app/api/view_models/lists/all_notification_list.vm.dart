import 'package:flutter_riverpod/legacy.dart';

import 'package:lotel_pms/app/api/view_models/notification.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/notification.service.dart';

class AllNotificationListVM extends StateNotifier<List<NotificationVM>> {
  // 2. Removed the propertyId from the constructor entirely!
  AllNotificationListVM() : super(const []) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    // 3. Removed the propertyId from the service call
    final res = await NotificationService().getAllNotifications();
    state = res.map((notification) => NotificationVM(notification)).toList();
  }
}

// 4. The provider is now completely independent.
// It no longer watches `selectedPropertyVM`!
final allNotificationListVM =
    StateNotifierProvider<AllNotificationListVM, List<NotificationVM>>(
        (ref) => AllNotificationListVM());
