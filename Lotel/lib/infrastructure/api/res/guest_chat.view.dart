import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    // Fetch the chat history as soon as the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(guestMessageListVM.notifier).fetchChatHistory(
            widget.propertyId,
            widget.bookingId,
          );
    });
  }

  @override
  void dispose() {
    // THE FIX: We ONLY dispose the controller here.
    // Riverpod's .autoDispose handles clearing the chat state automatically!
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(guestMessageListVM);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.guestName}'),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text("No messages yet. Start the conversation!"))
                : ListView.builder(
                    reverse: false,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      bool isHotel = msg.isOutbound;

                      return Align(
                        alignment: isHotel
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isHotel ? Colors.blue[600] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg.messageBody,
                            style: TextStyle(
                              color: isHotel ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Input Field Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (text) => _sendMessage(text),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      ref.read(guestMessageListVM.notifier).sendChatMessage(
            propertyId: widget.propertyId,
            bookingId: widget.bookingId,
            message: text.trim(),
            channel: 'whatsapp',
          );
      _controller.clear();
    }
  }
}
