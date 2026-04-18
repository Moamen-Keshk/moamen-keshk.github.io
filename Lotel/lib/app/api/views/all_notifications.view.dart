import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/lists/all_notification_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/notification_list.vm.dart';
import 'package:lotel_pms/app/api/widgets/all_notification_card.widget.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/main.dart';

class AllNotificationsView extends ConsumerWidget {
  const AllNotificationsView({super.key});

  Future<void> _openNotification(
    WidgetRef ref,
    String route,
    int? propertyId,
    String notificationId,
  ) async {
    if (propertyId != null) {
      ref.read(selectedPropertyVM.notifier).updateProperty(propertyId);
    }
    await ref.read(allNotificationListVM.notifier).markRead(notificationId);
    await ref.read(notificationListVM.notifier).fetchNotifications();
    if (route.isNotEmpty) {
      ref.read(routerProvider).push(route);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(allNotificationListVM);
    final isCompact = context.showCompactLayout;

    if (notifications.isEmpty) {
      return const Center(child: Text('No notifications yet.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: isCompact ? Alignment.centerLeft : Alignment.centerRight,
          child: SizedBox(
            width: isCompact ? double.infinity : null,
            child: TextButton(
              onPressed: () async {
                await ref.read(allNotificationListVM.notifier).markAllRead();
                await ref.read(notificationListVM.notifier).markAllRead();
              },
              child: const Text('Mark all as read'),
            ),
          ),
        ),
        ...notifications.map(
          (notification) => Padding(
            padding: const EdgeInsets.only(top: 6),
            child: AllNotificationCard(
              id: notification.id,
              title: notification.title,
              body: notification.body,
              fireDate: notification.fireDate,
              notificationType: notification.notificationType,
              isRead: notification.isRead,
              onActionPressed: () => _openNotification(
                ref,
                notification.routing,
                notification.propertyId,
                notification.id,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
