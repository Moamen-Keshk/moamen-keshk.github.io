import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:timeago/timeago.dart' as timeago;

class AllNotificationCard extends StatelessWidget {
  const AllNotificationCard({
    super.key,
    required this.id,
    required this.title,
    required this.body,
    required this.fireDate,
    required this.notificationType,
    required this.isRead,
    required this.onActionPressed,
  });

  final String id;
  final String title;
  final String body;
  final DateTime fireDate;
  final String notificationType;
  final bool isRead;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final appearance = _appearanceFor(notificationType);
    final isCompact = context.showCompactLayout;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: isRead ? null : appearance.color.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onActionPressed,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              appearance.color.withValues(alpha: 0.12),
                          child: Icon(appearance.icon,
                              color: appearance.color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isRead ? Colors.black87 : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(body),
                    const SizedBox(height: 8),
                    Text(
                      timeago.format(fireDate, allowFromNow: true),
                      style: const TextStyle(
                          fontSize: 11.0, color: Colors.black54),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: appearance.color.withValues(alpha: 0.12),
                      child: Icon(appearance.icon,
                          color: appearance.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isRead ? Colors.black87 : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(body),
                          const SizedBox(height: 8),
                          Text(
                            timeago.format(fireDate, allowFromNow: true),
                            style: const TextStyle(
                                fontSize: 11.0, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  static _NotificationAppearance _appearanceFor(String type) {
    switch (type) {
      case 'booking_new':
        return const _NotificationAppearance(
            Icons.add_box_outlined, Colors.blue);
      case 'booking_changed':
        return const _NotificationAppearance(
            Icons.edit_calendar_outlined, Colors.indigo);
      case 'arrival_issue':
        return const _NotificationAppearance(
            Icons.warning_amber_rounded, Colors.orange);
      case 'guest_message':
        return const _NotificationAppearance(
            Icons.mark_chat_unread_outlined, Colors.teal);
      case 'guest_message_failed':
        return const _NotificationAppearance(
            Icons.sms_failed_outlined, Colors.red);
      case 'payment_failed':
        return const _NotificationAppearance(
            Icons.credit_card_off_outlined, Colors.redAccent);
      default:
        return const _NotificationAppearance(
            Icons.sync_problem_outlined, Colors.deepOrange);
    }
  }
}

class _NotificationAppearance {
  final IconData icon;
  final Color color;

  const _NotificationAppearance(this.icon, this.color);
}
