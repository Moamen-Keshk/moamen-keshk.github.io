import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_academy/infrastructure/courses/res/booking.service.dart';
import 'package:flutter_academy/infrastructure/courses/model/booking.model.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/payment_status_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';

final roomMappingProvider = Provider<Map<int, String>>((ref) {
  final rooms = ref.watch(roomListVM);
  return {
    for (var room in rooms)
      if (int.tryParse(room.id) != null)
        int.parse(room.id): room.roomNumber.toString()
  };
});

final paymentStatusMappingProvider =
    FutureProvider<Map<int, String>>((ref) async {
  return await PaymentStatusListVM().paymentStatusMapping();
});

class BookingView extends ConsumerWidget {
  const BookingView({super.key});

  void _showSendMessageDialog(
      BuildContext context, WidgetRef ref, int bookingId, Booking booking) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Message ${booking.firstName} ${booking.lastName}'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(labelText: 'Subject'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSending ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(dialogContext);

                          if (subjectController.text.isEmpty ||
                              messageController.text.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Subject and message are required.'),
                              ),
                            );
                            return;
                          }

                          setState(() => isSending = true);

                          final success = await ref
                              .read(bookingListVM.notifier)
                              .sendGuestMessage(
                                bookingId,
                                subjectController.text,
                                messageController.text,
                              );

                          setState(() => isSending = false);

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }

                          if (success) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Message sent to guest successfully.'),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Failed to send message.'),
                              ),
                            );
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingId = ref.watch(bookingIdProvider);
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;
    final roomMapping = ref.watch(roomMappingProvider);
    final paymentStatusMappingAsync = ref.watch(paymentStatusMappingProvider);

    if (bookingId == null) {
      return const Center(child: Text("No booking selected"));
    }

    return paymentStatusMappingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
      data: (paymentStatusMapping) {
        return FutureBuilder<Booking?>(
          future: BookingService().getBookingById(
            propertyId,
            bookingId.toString(),
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final booking = snapshot.data;
            if (booking == null) {
              return const Center(child: Text("Booking not found"));
            }

            final format = DateFormat.yMMMd();

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Guest Communication Action Bar ---
                  if (booking.email != null && booking.email!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.email_outlined),
                        label: const Text("Message Guest"),
                        onPressed: () => _showSendMessageDialog(
                            context, ref, bookingId, booking),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),

                  // --- Booking Details ---
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.start,
                    children: [
                      _section("Guest Info", {
                        "Name": "${booking.firstName} ${booking.lastName}",
                        "Email": booking.email ?? "-",
                        "Phone": booking.phone ?? "-",
                        "Adults": "${booking.numberOfAdults}",
                        "Children": "${booking.numberOfChildren}",
                      }),
                      _section("Dates", {
                        "Check-in": format.format(booking.checkIn),
                        "Check-out": format.format(booking.checkOut),
                        "Created": format.format(booking.bookingDate),
                      }),
                      _section("Payment", {
                        "Rate": "£${booking.rate.toStringAsFixed(2)}",
                        "Status":
                            paymentStatusMapping[booking.paymentStatusID] ??
                                "Unknown",
                      }),
                      _section("Meta", {
                        "Room": roomMapping[booking.roomID] ??
                            'Room ${booking.roomID}',
                        "Confirmation Number":
                            booking.confirmationNumber.toString(),
                      }),
                      _section("Nightly Rates", {
                        for (var rate in booking.bookingRates)
                          DateFormat('dd MMM').format(rate.rateDate):
                              "£${rate.nightlyRate.toStringAsFixed(2)}"
                      }),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _section(String title, Map<String, String> data) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ...data.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Text(e.key,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: Text(e.value,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black87),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
