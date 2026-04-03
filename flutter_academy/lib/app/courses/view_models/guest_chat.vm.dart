import 'package:flutter_academy/infrastructure/courses/model/guest_chat.model.dart';

class GuestMessageVM {
  final GuestMessage guestMessage;

  GuestMessageVM(this.guestMessage);

  int get id => guestMessage.id;
  int get bookingId => guestMessage.bookingId;
  int get propertyId => guestMessage.propertyId;
  String get direction => guestMessage.direction; // 'inbound' or 'outbound'
  String get channel => guestMessage.channel; // 'whatsapp' or 'sms'
  String get messageBody => guestMessage.messageBody;
  DateTime get timestamp => guestMessage.timestamp;
  bool get isRead => guestMessage.isRead;

  // Helper getter to easily check if the message was sent by the hotel
  bool get isOutbound => guestMessage.direction == 'outbound';
}
