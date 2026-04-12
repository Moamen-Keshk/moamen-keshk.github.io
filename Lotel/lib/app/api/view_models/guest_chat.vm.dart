import 'package:lotel_pms/infrastructure/api/model/guest_chat.model.dart';

class GuestMessageVM {
  final GuestMessage guestMessage;

  GuestMessageVM(this.guestMessage);

  int get id => guestMessage.id;
  int get bookingId => guestMessage.bookingId;
  int get propertyId => guestMessage.propertyId;
  String get direction => guestMessage.direction; // 'inbound' or 'outbound'
  String get channel => guestMessage.channel; // 'whatsapp', 'sms', or 'email'
  String? get subject => guestMessage.subject;
  String get messageBody => guestMessage.messageBody;
  DateTime get timestamp => guestMessage.timestamp;
  bool get isRead => guestMessage.isRead;
  String get deliveryStatus => guestMessage.deliveryStatus;
  String? get deliveryError => guestMessage.deliveryError;
  String? get externalMessageId => guestMessage.externalMessageId;
  String? get sentByUserId => guestMessage.sentByUserId;

  // Helper getter to easily check if the message was sent by the hotel
  bool get isOutbound => guestMessage.direction == 'outbound';
  bool get isEmail => guestMessage.channel == 'email';
  bool get isFailed => guestMessage.deliveryStatus == 'failed';
  bool get isQueued => guestMessage.deliveryStatus == 'queued';
}
