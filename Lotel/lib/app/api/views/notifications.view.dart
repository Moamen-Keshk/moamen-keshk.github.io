import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/lists/all_notification_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/notification_list.vm.dart';
import 'package:lotel_pms/app/api/widgets/notification_card.widget.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/main.dart';

class NotificationsView extends ConsumerWidget {
  const NotificationsView({super.key});

  Future<void> _openNotification(WidgetRef ref, String route, int? propertyId,
      String notificationId) async {
    if (propertyId != null) {
      ref.read(selectedPropertyVM.notifier).updateProperty(propertyId);
    }
    await ref.read(notificationListVM.notifier).markRead(notificationId);
    await ref.read(allNotificationListVM.notifier).markRead(notificationId);
    if (route.isNotEmpty) {
      ref.read(routerProvider).push(route);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListVM);
    final hasUnread = notifications.isNotEmpty;
    final isCompact = context.showCompactLayout;

    return MenuAnchor(
      style: MenuStyle(
        backgroundColor:
            WidgetStateProperty.all(Theme.of(context).colorScheme.surface),
      ),
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () async {
            await ref.read(notificationListVM.notifier).fetchNotifications();
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: badges.Badge(
            showBadge: hasUnread,
            badgeContent: Text(
              notifications.length.toString(),
              style: const TextStyle(fontSize: 12.0, color: Colors.white),
            ),
            badgeStyle: badges.BadgeStyle(
              badgeColor: hasUnread ? Colors.blue : Colors.transparent,
            ),
            child: const Icon(Icons.notifications_outlined),
          ),
        );
      },
      menuChildren: [
        if (notifications.isEmpty)
          const MenuItemButton(
            onPressed: null,
            child: Text('No unread notifications'),
          ),
        ...notifications.map(
          (notification) => MenuItemButton(
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(
                    horizontal: isCompact ? 8 : 12, vertical: 6),
              ),
            ),
            child: NotificationCard(
              id: notification.id,
              title: notification.title,
              body: notification.body,
              fireDate: notification.fireDate,
              notificationType: notification.notificationType,
              onActionPressed: () => _openNotification(
                ref,
                notification.routing,
                notification.propertyId,
                notification.id,
              ),
            ),
          ),
        ),
        MenuItemButton(
          onPressed: notifications.isEmpty
              ? null
              : () async {
                  await ref.read(notificationListVM.notifier).markAllRead();
                  await ref.read(allNotificationListVM.notifier).markAllRead();
                },
          child: const Text('Mark all as read'),
        ),
        MenuItemButton(
          onPressed: () {
            ref.read(routerProvider).push('all_notifications');
          },
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'See all',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
