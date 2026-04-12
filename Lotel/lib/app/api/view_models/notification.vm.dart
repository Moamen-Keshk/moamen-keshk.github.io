import 'package:lotel_pms/infrastructure/api/model/notification.model.dart';

class NotificationVM {
  final Notification notification;
  NotificationVM(this.notification);
  String get id => notification.id;
  String get title => notification.title;
  String get body => notification.body;
  DateTime get fireDate => notification.fireDate;
  bool get isRead => notification.isRead;
  bool get hasAction => notification.hasAction;
  String get routing => notification.routing;
  String get notificationType => notification.notificationType;
  int? get propertyId => notification.propertyId;
  String? get entityType => notification.entityType;
  String? get entityId => notification.entityId;
}
