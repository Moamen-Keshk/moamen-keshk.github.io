import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/notification_list.vm.dart';
import 'package:flutter_academy/app/courses/widgets/notification_card.widget.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;

class NotificationsView extends StatelessWidget {
  const NotificationsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final notifications = ref.watch(notificationListVM);
      final Color color =
          notifications.isNotEmpty ? Colors.blue : Colors.transparent;
      final String count =
          notifications.isNotEmpty ? notifications.length.toString() : '';
      return MenuAnchor(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            return Colors.transparent;
          }),
          shadowColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            return Colors.transparent;
          }),
        ),
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: badges.Badge(
              badgeContent: Text(count,
                  style: const TextStyle(fontSize: 12.0, color: Colors.white)),
              badgeStyle: badges.BadgeStyle(
                badgeColor: color,
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
          );
        },
        menuChildren: List<MenuItemButton>.generate(
              notifications.length,
              (int index) => MenuItemButton(
                child: NotificationCard(
                  id: notifications[index].notification.id,
                  title: notifications[index].title,
                  body: notifications[index].body,
                  fireDate: notifications[index].fireDate,
                  onActionPressed: () {},
                ),
              ),
            ) +
            [
              MenuItemButton(
                child: InkWell(
                  onTap: () {
                    ref.read(routerProvider).push('all_notifications');
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              )
            ],
      );
    });
  }
}
