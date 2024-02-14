import 'package:flutter_academy/infrastructure/courses/model/notification.model.dart';

class NotificationVM {
  final Notification notification;
  NotificationVM(this.notification);
  String get title => notification.title;
  String get body => notification.body;
  DateTime get fireDate => notification.fireDate;
}
