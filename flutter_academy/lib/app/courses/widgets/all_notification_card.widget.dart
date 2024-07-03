import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class AllNotificationCard extends StatelessWidget {
  const AllNotificationCard(
      {super.key,
      required this.id,
      required this.title,
      required this.body,
      required this.fireDate,
      required this.onActionPressed});

  final String id;
  final String title;
  final String body;
  final DateTime fireDate;
  final Function() onActionPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
      height: 100,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onActionPressed,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 7.0, right: 7.0),
                child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
              ),
              const Divider(
                thickness: 0.2,
                indent: 7,
                endIndent: 7,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 7.0, right: 7.0),
                child: Text(
                  body,
                  maxLines: 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 7.0, right: 7.0),
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(timeago.format(fireDate, allowFromNow: true),
                        style: const TextStyle(fontSize: 10.0))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
