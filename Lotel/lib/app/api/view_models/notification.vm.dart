import 'package:lotel_pms/infrastructure/api/model/notification.model.dart';

class NotificationVM {
  final Notification notification;
  NotificationVM(this.notification);
  String get title => notification.title;
  String get body => notification.body;
  DateTime get fireDate => notification.fireDate;
}
