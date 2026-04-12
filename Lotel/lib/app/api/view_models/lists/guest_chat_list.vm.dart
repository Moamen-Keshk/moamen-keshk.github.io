import 'package:flutter_riverpod/legacy.dart';
import 'package:lotel_pms/app/api/view_models/guest_chat.vm.dart';
import 'package:lotel_pms/app/req/request.dart';
import 'package:lotel_pms/infrastructure/api/res/guest_chat.service.dart';

class GuestMessageListState {
  final List<GuestMessageVM> messages;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;
  final String activeChannel;

  const GuestMessageListState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
    this.activeChannel = 'whatsapp',
  });

  GuestMessageListState copyWith({
    List<GuestMessageVM>? messages,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
    String? activeChannel,
  }) {
    return GuestMessageListState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeChannel: activeChannel ?? this.activeChannel,
    );
  }
}

class GuestMessageListVM extends StateNotifier<GuestMessageListState> {
  GuestMessageListVM() : super(const GuestMessageListState());

  Future<void> fetchChatHistory(int propertyId, int bookingId,
      {bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final res =
          await GuestMessageService().getChatHistory(propertyId, bookingId);
      if (!mounted) return;

      state = state.copyWith(
        messages: [...res.map((message) => GuestMessageVM(message))],
        isLoading: false,
        clearError: true,
      );
    } on ApiRequestException catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load guest communication.',
      );
    }
  }

  void setChannel(String channel) {
    if (channel == 'whatsapp' || channel == 'sms') {
      state = state.copyWith(activeChannel: channel);
    }
  }

  Future<bool> sendChatMessage({
    required int propertyId,
    required int bookingId,
    required String message,
  }) async {
    state = state.copyWith(isSending: true, clearError: true);

    try {
      final res = await GuestMessageService().sendChatMessage(
        propertyId,
        bookingId,
        message,
        channel: state.activeChannel,
      );

      if (!mounted) return true;

      state = state.copyWith(
        isSending: false,
        messages: [...state.messages, GuestMessageVM(res)],
        clearError: true,
      );
      return true;
    } on ApiRequestException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isSending: false,
        errorMessage: e.message,
      );
      return false;
    } catch (_) {
      if (!mounted) return false;
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Failed to send guest message.',
      );
      return false;
    }
  }
}

final guestMessageListVM = StateNotifierProvider.autoDispose<GuestMessageListVM,
    GuestMessageListState>((ref) => GuestMessageListVM());
