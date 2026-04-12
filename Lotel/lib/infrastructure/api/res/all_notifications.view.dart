import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/view_models/lists/all_notification_list.vm.dart';
import 'package:lotel_pms/app/api/widgets/all_notification_card.widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllNotificationsView extends StatelessWidget {
  const AllNotificationsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final notifications = ref.watch(allNotificationListVM);
      return Column(
        children: [
          ...notifications.map(
            (notification) => Padding(
                padding: const EdgeInsets.only(top: 0),
                child: AllNotificationCard(
                  id: notification.notification.id,
                  title: notification.title,
                  body: notification.body,
                  fireDate: notification.fireDate,
                  notificationType: notification.notificationType,
                  isRead: notification.isRead,
                  onActionPressed: () {},
                )),
          ),
        ],
      );
    });
  }
}
