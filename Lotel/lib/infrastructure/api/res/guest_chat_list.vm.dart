import 'package:lotel_pms/infrastructure/api/model/guest_chat.model.dart';
import 'package:lotel_pms/app/api/view_models/guest_chat.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/guest_chat.service.dart';
import 'package:flutter_riverpod/legacy.dart';

class GuestMessageListVM extends StateNotifier<List<GuestMessageVM>> {
  GuestMessageListVM() : super(const []);

  Future<void> fetchChatHistory(int propertyId, int bookingId) async {
    final res =
        await GuestMessageService().getChatHistory(propertyId, bookingId);

    // Safety check: Don't update state if the user closed the chat window
    if (!mounted) return;

    state = [...res.map((message) => GuestMessageVM(message))];
  }

  Future<bool> sendChatMessage({
    required int propertyId,
    required int bookingId,
    required String message,
    String channel = 'whatsapp',
  }) async {
    // Instantly show the message on screen (Optimistic Update)
    final optimisticMessage = GuestMessageVM(GuestMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      bookingId: bookingId,
      propertyId: propertyId,
      direction: 'outbound',
      channel: channel,
      messageBody: message,
      timestamp: DateTime.now(),
      isRead: true,
    ));

    // It's safe to update state here because the user just tapped a button inside the active UI
    state = [...state, optimisticMessage];

    // Wait for the backend request to finish...
    final success = await GuestMessageService()
        .sendChatMessage(propertyId, bookingId, message, channel: channel);

    // THE FIX: Check if the user closed the chat while the network request was running!
    // If they did, stop executing immediately.
    if (!mounted) return success;

    return success;
  }
}

final guestMessageListVM =
    StateNotifierProvider.autoDispose<GuestMessageListVM, List<GuestMessageVM>>(
        (ref) => GuestMessageListVM());
