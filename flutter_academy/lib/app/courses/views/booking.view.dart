import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_academy/infrastructure/courses/res/booking.service.dart';
import 'package:flutter_academy/infrastructure/courses/model/booking.model.dart';
import 'package:flutter_academy/app/courses/view_models/lists/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/payment_status_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';

// 👉 IMPORT THE NEW BOOKING STATUS VM
import 'package:flutter_academy/app/courses/view_models/lists/booking_status_list.vm.dart';

// Import the Chat View
import 'package:flutter_academy/app/courses/views/guest_chat.view.dart';

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

final bookingStatusMappingProvider =
    FutureProvider<Map<int, String>>((ref) async {
  return await ref.read(bookingStatusListVM.notifier).bookingStatusMapping();
});

// 👉 NEW: A dedicated Riverpod provider to fetch the single booking details
final bookingDetailsProvider =
    FutureProvider.autoDispose<Booking?>((ref) async {
  final bookingId = ref.watch(bookingIdProvider);
  if (bookingId == null) return null;
  final propertyId = ref.watch(selectedPropertyVM) ?? 0;
  return await BookingService()
      .getBookingById(propertyId, bookingId.toString());
});

class BookingView extends ConsumerStatefulWidget {
  const BookingView({super.key});

  @override
  ConsumerState<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends ConsumerState<BookingView> {
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
              title: Text('Email ${booking.firstName} ${booking.lastName}'),
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
                                    Text('Email sent to guest successfully.'),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Failed to send email.'),
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

  Future<void> _showUpdatePaymentDialog(
      BuildContext context,
      WidgetRef ref,
      int bookingId,
      int currentPaymentStatusId,
      Map<int, String> paymentStatusMapping) async {
    int selectedStatusId = currentPaymentStatusId;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Payment Status'),
              content: DropdownButtonFormField<int>(
                initialValue: paymentStatusMapping.containsKey(selectedStatusId)
                    ? selectedStatusId
                    : null,
                decoration: const InputDecoration(
                    labelText: 'Payment Status', border: OutlineInputBorder()),
                items: paymentStatusMapping.entries.map((e) {
                  return DropdownMenuItem<int>(
                    value: e.key,
                    child: Text(e.value),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedStatusId = val;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Save Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true && context.mounted) {
      final success = await ref
          .read(bookingListVM.notifier)
          .updatePaymentStatus(bookingId, selectedStatusId);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Payment status updated successfully.'),
                backgroundColor: Colors.green),
          );
          // 👉 Instantly refresh UI
          ref.invalidate(bookingDetailsProvider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to update payment status.'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _handleExtendBooking(BuildContext context, WidgetRef ref,
      int bookingId, Booking booking) async {
    final DateTime? newCheckOut = await showDatePicker(
      context: context,
      initialDate: booking.checkOut.add(const Duration(days: 1)),
      firstDate: booking.checkOut.add(const Duration(days: 1)),
      lastDate: booking.checkOut.add(const Duration(days: 365)),
      helpText: 'Select New Check-Out Date',
    );

    if (newCheckOut == null || !context.mounted) return;

    final formattedNewDate = DateFormat('yyyy-MM-dd').format(newCheckOut);
    final formattedOldDate = DateFormat('yyyy-MM-dd').format(booking.checkOut);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final notifier = ref.read(bookingListVM.notifier);
    final availability = await notifier.checkExtensionAvailability(
        booking.roomID, formattedOldDate, formattedNewDate);

    if (context.mounted) Navigator.pop(context);
    if (!context.mounted) return;

    if (availability['available'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Room is not available for these extended dates."),
            backgroundColor: Colors.red),
      );
      return;
    }

    int extraNights = newCheckOut.difference(booking.checkOut).inDays;
    double avgNightlyRate = booking.numberOfNights > 0
        ? (booking.rate / booking.numberOfNights)
        : 0.0;

    double extraCost = (availability['extra_cost'] as num?)?.toDouble() ??
        (extraNights * avgNightlyRate);
    bool isPaid = false;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Confirm Extension'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Extending by: $extraNights night(s)"),
                  const SizedBox(height: 8),
                  Text(
                      "New Check-Out: ${DateFormat.yMMMd().format(newCheckOut)}"),
                  const SizedBox(height: 16),
                  Text(
                    "Additional Cost: £${extraCost.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Row(
                    children: [
                      Checkbox(
                        value: isPaid,
                        onChanged: (val) {
                          setState(() {
                            isPaid = val ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child:
                            Text("Guest has paid this additional amount now"),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogCtx, true),
                  child: const Text('Confirm Extension'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true && context.mounted) {
      final success = await notifier.extendBooking(
        bookingId,
        formattedNewDate,
        isPaid: isPaid,
        extraCost: extraCost,
      );

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Booking extended successfully."),
                backgroundColor: Colors.blue),
          );
          // 👉 Instantly refresh UI
          ref.invalidate(bookingDetailsProvider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Failed to extend booking."),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, int bookingId,
      String actionType) async {
    bool success = false;
    final notifier = ref.read(bookingListVM.notifier);

    switch (actionType) {
      case 'check_in':
        success = await notifier.checkInBooking(bookingId);
        break;
      case 'check_out':
        success = await notifier.checkOutBooking(bookingId);
        break;
      case 'cancel':
        success = await notifier.deleteBooking(bookingId.toString());
        break;
    }

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Action completed successfully."),
              backgroundColor: Colors.green),
        );
        // 👉 Instantly refresh UI
        ref.invalidate(bookingDetailsProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to perform action."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showRecordPaymentDialog(BuildContext context, WidgetRef ref,
      int bookingId, Booking booking) async {
    final TextEditingController amountController =
        TextEditingController(text: booking.amountPaid.toStringAsFixed(2));

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Record Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Rate: £${booking.rate.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Total Amount Paid by Guest',
                  prefixText: '£ ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save Payment')),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      final double? newAmount = double.tryParse(amountController.text);
      if (newAmount != null) {
        final success = await ref
            .read(bookingListVM.notifier)
            .recordPayment(bookingId, newAmount);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Payment recorded!'),
              backgroundColor: Colors.green));
          ref.invalidate(bookingDetailsProvider); // Refresh the UI instantly
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingId = ref.watch(bookingIdProvider);
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;
    final roomMapping = ref.watch(roomMappingProvider);

    final paymentStatusMappingAsync = ref.watch(paymentStatusMappingProvider);
    final bookingStatusMappingAsync = ref.watch(bookingStatusMappingProvider);

    // 👉 Listen to the unified booking provider
    final bookingDetailsAsync = ref.watch(bookingDetailsProvider);

    if (bookingId == null) {
      return const Center(child: Text("No booking selected"));
    }

    // Wait for payment statuses
    return paymentStatusMappingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          Center(child: Text("Error loading payment statuses: $err")),
      data: (paymentStatusMapping) {
        // Wait for booking statuses
        return bookingStatusMappingAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) =>
              Center(child: Text("Error loading booking statuses: $err")),
          data: (bookingStatusMapping) {
            // 👉 Use .when() on the fetched booking to reactively display details
            return bookingDetailsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (booking) {
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Wrap(
                          spacing: 12.0,
                          runSpacing: 8.0,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.chat),
                              label: const Text("Chat Guest"),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom,
                                    ),
                                    child: FractionallySizedBox(
                                      heightFactor: 0.85,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                        child: GuestChatView(
                                          propertyId: propertyId,
                                          bookingId: bookingId,
                                          guestName:
                                              '${booking.firstName} ${booking.lastName}',
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                            if (booking.email != null &&
                                booking.email!.isNotEmpty)
                              OutlinedButton.icon(
                                icon: const Icon(Icons.email_outlined),
                                label: const Text("Email Guest"),
                                onPressed: () => _showSendMessageDialog(
                                    context, ref, bookingId, booking),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                              ),
                          ],
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
                            "Phone": booking.phone ?? "-",
                            "Adults": "${booking.numberOfAdults}",
                            "Children": "${booking.numberOfChildren}",
                          }),
                          _section("Status & Meta", {
                            "Payment Status":
                                paymentStatusMapping[booking.paymentStatusID] ??
                                    "Unknown",
                            "Booking Status":
                                bookingStatusMapping[booking.statusID] ??
                                    'Unknown',
                            "Room": roomMapping[booking.roomID] ??
                                'Room ${booking.roomID}',
                          }),
                          _section("Dates", {
                            "Check-in": format.format(booking.checkIn),
                            "Check-out": format.format(booking.checkOut),
                            "Created": format.format(booking.bookingDate),
                          }),
                          _section("Reference", {
                            "Confirmation Number":
                                booking.confirmationNumber.toString(),
                            "Email": booking.email ?? "-",
                          }),
                          _section("Nightly Rates", {
                            for (var rate in booking.bookingRates)
                              DateFormat('dd MMM').format(rate.rateDate):
                                  "£${rate.nightlyRate.toStringAsFixed(2)}"
                          }),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 260),
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: booking.balanceDue <= 0
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Financials",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Total Rate:"),
                                        Text(
                                            "£${booking.rate.toStringAsFixed(2)}"),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Amount Paid:"),
                                        Text(
                                            "£${booking.amountPaid.toStringAsFixed(2)}"),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Balance Due:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "£${booking.balanceDue.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _showRecordPaymentDialog(
                                          context,
                                          ref,
                                          bookingId,
                                          booking,
                                        ),
                                        child: const Text("Record Payment"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              if (booking.statusID == 1)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.login),
                                  label: const Text("Check In"),
                                  onPressed: () => _handleAction(
                                      context, ref, bookingId, 'check_in'),
                                ),
                              if (booking.statusID == 2)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.logout),
                                  label: const Text("Check Out"),
                                  onPressed: () => _handleAction(
                                      context, ref, bookingId, 'check_out'),
                                ),
                              if (booking.statusID == 1 ||
                                  booking.statusID == 2)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.calendar_month),
                                  label: const Text("Extend"),
                                  onPressed: () => _handleExtendBooking(
                                      context, ref, bookingId, booking),
                                ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.payments_outlined),
                                label: const Text("Update Payment"),
                                onPressed: () => _showUpdatePaymentDialog(
                                    context,
                                    ref,
                                    bookingId,
                                    booking.paymentStatusID,
                                    paymentStatusMapping),
                              ),
                              if (booking.statusID == 1)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.cancel),
                                  label: const Text("Cancel"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Cancel Booking'),
                                        content: const Text(
                                            'Are you sure you want to cancel this booking?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('No')),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Yes, Cancel',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && context.mounted) {
                                      _handleAction(
                                          context, ref, bookingId, 'cancel');
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
