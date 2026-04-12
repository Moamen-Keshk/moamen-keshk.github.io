import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.id,
    required this.title,
    required this.body,
    required this.fireDate,
    required this.notificationType,
    required this.onActionPressed,
  });

  final String id;
  final String title;
  final String body;
  final DateTime fireDate;
  final String notificationType;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final appearance = _appearanceFor(notificationType);

    return SizedBox(
      width: 290,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onActionPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(appearance.icon, size: 18, color: appearance.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    timeago.format(fireDate, allowFromNow: true),
                    style: const TextStyle(fontSize: 11.0, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static _NotificationAppearance _appearanceFor(String type) {
    switch (type) {
      case 'booking_new':
        return const _NotificationAppearance(Icons.add_box_outlined, Colors.blue);
      case 'booking_changed':
        return const _NotificationAppearance(Icons.edit_calendar_outlined, Colors.indigo);
      case 'arrival_issue':
        return const _NotificationAppearance(Icons.warning_amber_rounded, Colors.orange);
      case 'guest_message':
        return const _NotificationAppearance(Icons.mark_chat_unread_outlined, Colors.teal);
      case 'guest_message_failed':
        return const _NotificationAppearance(Icons.sms_failed_outlined, Colors.red);
      case 'payment_failed':
        return const _NotificationAppearance(Icons.credit_card_off_outlined, Colors.redAccent);
      default:
        return const _NotificationAppearance(Icons.sync_problem_outlined, Colors.deepOrange);
    }
  }
}

class _NotificationAppearance {
  final IconData icon;
  final Color color;

  const _NotificationAppearance(this.icon, this.color);
}
