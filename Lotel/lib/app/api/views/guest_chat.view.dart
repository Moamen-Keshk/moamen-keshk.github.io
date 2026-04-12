import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotel_pms/app/api/view_models/guest_chat.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/guest_chat_list.vm.dart';

class GuestChatView extends ConsumerStatefulWidget {
  final int propertyId;
  final int bookingId;
  final String guestName;

  const GuestChatView({
    super.key,
    required this.propertyId,
    required this.bookingId,
    this.guestName = "Guest",
  });

  @override
  ConsumerState<GuestChatView> createState() => _GuestChatViewState();
}

class _GuestChatViewState extends ConsumerState<GuestChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshMessages();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _refreshMessages(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshMessages({bool silent = false}) async {
    await ref.read(guestMessageListVM.notifier).fetchChatHistory(
          widget.propertyId,
          widget.bookingId,
          silent: silent,
        );
    if (!mounted) return;
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final success = await ref.read(guestMessageListVM.notifier).sendChatMessage(
          propertyId: widget.propertyId,
          bookingId: widget.bookingId,
          message: text,
        );

    if (!mounted) return;
    if (success) {
      _controller.clear();
      _scrollToBottom();
    } else {
      final error = ref.read(guestMessageListVM).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to send guest message.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guestMessageListVM);
    final messages = state.messages;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guest Communication'),
            Text(
              widget.guestName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () => _refreshMessages(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh communication',
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.errorMessage != null)
            MaterialBanner(
              content: Text(state.errorMessage!),
              actions: [
                TextButton(
                  onPressed: () => _refreshMessages(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMessages,
              child: _buildMessageList(context, messages, state.isLoading),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.05),
                )
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Chat via'),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('WhatsApp'),
                        selected: state.activeChannel == 'whatsapp',
                        onSelected: state.isSending
                            ? null
                            : (_) => ref
                                .read(guestMessageListVM.notifier)
                                .setChannel('whatsapp'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('SMS'),
                        selected: state.activeChannel == 'sms',
                        onSelected: state.isSending
                            ? null
                            : (_) =>
                                ref.read(guestMessageListVM.notifier).setChannel('sms'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          enabled: !state.isSending,
                          decoration: InputDecoration(
                            hintText: "Type a chat message...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: state.isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send, color: Colors.white),
                                onPressed: _sendMessage,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    List<GuestMessageVM> messages,
    bool isLoading,
  ) {
    if (isLoading && messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messages.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Center(child: Text("No communication yet. Start with chat or email.")),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: messages.length,
      itemBuilder: (context, index) => _MessageCard(message: messages[index]),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final GuestMessageVM message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final isHotel = message.isOutbound;
    final cardColor = message.isEmail
        ? const Color(0xFFFFF3E0)
        : isHotel
            ? Colors.blue[600]
            : Colors.grey[300];
    final textColor = isHotel && !message.isEmail ? Colors.white : Colors.black87;
    final timestamp = DateFormat('dd MMM, HH:mm').format(message.timestamp.toLocal());

    return Align(
      alignment: isHotel ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: message.isFailed
                ? Colors.red.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  message.isEmail ? Icons.email_outlined : Icons.chat_bubble_outline,
                  size: 16,
                  color: textColor,
                ),
                const SizedBox(width: 6),
                Text(
                  message.channel.toUpperCase(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (message.isOutbound) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor(message.deliveryStatus)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      message.deliveryStatus.toUpperCase(),
                      style: TextStyle(
                        color: _statusColor(message.deliveryStatus),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (message.subject != null && message.subject!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                message.subject!,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              message.messageBody,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              timestamp,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
            if (message.deliveryError != null &&
                message.deliveryError!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                message.deliveryError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'queued':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'received':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }
}
