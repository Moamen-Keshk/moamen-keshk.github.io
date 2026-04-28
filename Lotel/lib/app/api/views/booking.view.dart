import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/utilities/invoice_print.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/booking.service.dart';
import 'package:lotel_pms/infrastructure/api/model/booking.model.dart';
import 'package:lotel_pms/infrastructure/api/model/invoice.model.dart';
import 'package:lotel_pms/infrastructure/api/model/payment_transaction.model.dart';
import 'package:lotel_pms/infrastructure/api/res/invoice.service.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/invoice_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/payment_status_list.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/app/payments/view_models/payments.vm.dart';

// 👉 IMPORT THE NEW BOOKING STATUS VM
import 'package:lotel_pms/app/api/view_models/lists/booking_status_list.vm.dart';

// Import the Chat View
import 'package:lotel_pms/app/api/views/guest_chat.view.dart';

// 👉 IMPORT THE NEW VCC CHARGE DIALOG
import 'package:lotel_pms/app/payments/widgets/vcc_charge_dialog.widget.dart';

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

final bookingInvoiceProvider =
    FutureProvider.autoDispose<InvoiceModel?>((ref) async {
  final bookingId = ref.watch(bookingIdProvider);
  if (bookingId == null) return null;
  final propertyId = ref.watch(selectedPropertyVM) ?? 0;
  if (propertyId <= 0) return null;
  return InvoiceService().getBookingInvoice(propertyId, bookingId);
});

final bookingPaymentsProvider =
    FutureProvider.autoDispose<List<PaymentTransaction>>((ref) async {
  final bookingId = ref.watch(bookingIdProvider);
  if (bookingId == null) return const [];
  final propertyId = ref.watch(selectedPropertyVM) ?? 0;
  if (propertyId <= 0) return const [];
  return InvoiceService().getBookingPayments(propertyId, bookingId);
});

class BookingView extends ConsumerStatefulWidget {
  const BookingView({super.key});

  @override
  ConsumerState<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends ConsumerState<BookingView> {
  final PaymentVM _paymentVM = PaymentVM();
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

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
                constraints: BoxConstraints(
                  minWidth: context.showCompactLayout ? 280 : 400,
                ),
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

                          final subject = subjectController.text.trim();
                          final message = messageController.text.trim();

                          if (subject.isEmpty || message.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Subject and message are required.'),
                              ),
                            );
                            return;
                          }

                          setState(() => isSending = true);

                          try {
                            await ref
                                .read(bookingListVM.notifier)
                                .sendGuestMessage(
                                  bookingId,
                                  subject,
                                  message,
                                );

                            setState(() => isSending = false);

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            messenger.showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Email sent to guest successfully.'),
                              ),
                            );
                          } catch (e) {
                            setState(() => isSending = false);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
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

  Future<void> _showInvoiceEmailDialog(
    BuildContext pageContext,
    Booking booking,
    InvoiceModel invoice,
  ) async {
    final bookingId = int.tryParse(booking.id);
    if (bookingId == null) {
      ScaffoldMessenger.of(pageContext).showSnackBar(
        const SnackBar(content: Text('Booking ID is invalid.')),
      );
      return;
    }

    final emailController =
        TextEditingController(text: booking.email?.trim() ?? '');
    final subjectController =
        TextEditingController(text: 'Invoice ${invoice.invoiceNumber}');
    final messageController = TextEditingController();
    bool isSending = false;

    await showDialog(
      context: pageContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Email Invoice ${invoice.invoiceNumber}'),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: context.showCompactLayout ? 280 : 420,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(labelText: 'Subject'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message (optional)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
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
                          final email = emailController.text.trim();
                          final subject = subjectController.text.trim();
                          final message = messageController.text.trim();

                          if (email.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Recipient email is required.'),
                              ),
                            );
                            return;
                          }

                          if (!_emailPattern.hasMatch(email)) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid email address.'),
                              ),
                            );
                            return;
                          }

                          if (subject.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Subject is required.'),
                              ),
                            );
                            return;
                          }

                          setState(() => isSending = true);

                          try {
                            await InvoiceService().emailBookingInvoice(
                              propertyId: booking.propertyID,
                              bookingId: bookingId,
                              email: email,
                              subject: subject,
                              message: message,
                            );

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            if (pageContext.mounted) {
                              ScaffoldMessenger.of(pageContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Invoice email queued.'),
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() => isSending = false);
                            messenger.showSnackBar(
                              SnackBar(content: Text(e.toString())),
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
                ),
              ],
            );
          },
        );
      },
    );

    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
  }

  Future<void> _printInvoice(BuildContext context, Booking booking) async {
    final bookingId = int.tryParse(booking.id);
    if (bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking ID is invalid.')),
      );
      return;
    }

    try {
      final html = await InvoiceService()
          .getBookingInvoicePrintHtml(booking.propertyID, bookingId);
      await openPrintableInvoiceHtml(html);
    } on UnsupportedError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message?.toString() ??
                'Printing is not supported on this platform.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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
          // 👉 Force TodaysView and Main List to refresh
          ref.invalidate(bookingListByDateVM);
          ref.invalidate(bookingListVM);
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
                  ResponsiveFormRow(
                    children: [
                      CheckboxListTile(
                        value: isPaid,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "Guest has paid this additional amount now",
                        ),
                        onChanged: (val) {
                          setState(() {
                            isPaid = val ?? false;
                          });
                        },
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
          // 👉 Force TodaysView and Main List to refresh
          ref.invalidate(bookingListByDateVM);
          ref.invalidate(bookingListVM);
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
        // 👉 Force TodaysView and Main List to refresh
        ref.invalidate(bookingListByDateVM);
        ref.invalidate(bookingListVM);
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
        TextEditingController(text: booking.balanceDue.toStringAsFixed(2));
    final TextEditingController referenceController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String selectedMethod = 'cash';
    String paymentFlow = 'settled';
    String externalChannel = 'booking_com';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Record Payment'),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.showCompactLayout ? 320 : 420,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Outstanding Balance: £${booking.balanceDue.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: paymentFlow,
                    decoration: const InputDecoration(
                      labelText: 'Entry Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'settled', child: Text('Settled Payment')),
                      DropdownMenuItem(
                          value: 'authorized',
                          child: Text('Card Authorization')),
                      DropdownMenuItem(
                          value: 'ota_collected', child: Text('OTA Collected')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        paymentFlow = value;
                        if (paymentFlow == 'authorized') {
                          selectedMethod = 'card';
                        } else if (paymentFlow == 'ota_collected') {
                          selectedMethod = 'ota_vcc';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'card', child: Text('Card')),
                      DropdownMenuItem(
                          value: 'bank_transfer', child: Text('Bank Transfer')),
                      DropdownMenuItem(
                          value: 'ota_vcc', child: Text('OTA VCC')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedMethod = value;
                      });
                    },
                  ),
                  if (paymentFlow == 'ota_collected') ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: externalChannel,
                      decoration: const InputDecoration(
                        labelText: 'Channel',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'booking_com', child: Text('Booking.com')),
                        DropdownMenuItem(
                            value: 'expedia', child: Text('Expedia')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            externalChannel = value;
                          });
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '£ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => amountController.text =
                            booking.balanceDue.toStringAsFixed(2),
                        child: const Text('Full Balance'),
                      ),
                      OutlinedButton(
                        onPressed: () => amountController.text =
                            (booking.balanceDue / 2).toStringAsFixed(2),
                        child: const Text('50%'),
                      ),
                    ],
                  ),
                  if (paymentFlow == 'authorized')
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Authorization records a hold only and does not reduce the invoice balance.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Reference',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(paymentFlow == 'authorized'
                      ? 'Save Authorization'
                      : 'Save Entry')),
            ],
          );
        });
      },
    );

    if (confirm == true && context.mounted) {
      final double? amount = double.tryParse(amountController.text);
      if (amount != null) {
        final status = paymentFlow == 'authorized' ? 'authorized' : 'succeeded';
        final source = paymentFlow == 'ota_collected'
            ? 'ota_collect'
            : paymentFlow == 'authorized'
                ? 'front_desk_authorization'
                : 'front_desk';
        final success = await _paymentVM.recordManualPayment(
          context,
          propertyId: booking.propertyID,
          bookingId: bookingId,
          amount: amount,
          paymentMethod: selectedMethod,
          source: source,
          status: status,
          isVcc: selectedMethod == 'ota_vcc',
          externalChannel:
              paymentFlow == 'ota_collected' ? externalChannel : null,
          reference: referenceController.text.trim(),
          notes: notesController.text.trim(),
        );
        if (success && context.mounted) {
          ref.invalidate(bookingDetailsProvider);
          ref.invalidate(bookingInvoiceProvider);
          ref.invalidate(bookingPaymentsProvider);
          ref.invalidate(bookingListByDateVM);
          ref.invalidate(bookingListVM);
        }
      }
    }
  }

  Future<void> _showRefundPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
    PaymentTransaction payment,
  ) async {
    final amountController =
        TextEditingController(text: payment.amount.toStringAsFixed(2));
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Refund'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.showCompactLayout ? 320 : 420,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Refunding ${payment.paymentMethod.replaceAll('_', ' ').toUpperCase()}',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Refund Amount',
                  prefixText: '£ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save Refund'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid refund amount.')),
      );
      return;
    }

    final success = await _paymentVM.refundPayment(
      context,
      propertyId: booking.propertyID,
      bookingId: int.parse(booking.id),
      transactionId: payment.id,
      amount: amount,
      reason: reasonController.text.trim().isEmpty
          ? null
          : reasonController.text.trim(),
    );

    if (success && context.mounted) {
      ref.invalidate(bookingDetailsProvider);
      ref.invalidate(bookingInvoiceProvider);
      ref.invalidate(bookingPaymentsProvider);
      ref.invalidate(bookingListByDateVM);
      ref.invalidate(bookingListVM);
    }
  }

  Future<void> _showStripePaymentDialog(
    BuildContext context,
    WidgetRef ref,
    int bookingId,
    Booking booking,
  ) async {
    final amountController =
        TextEditingController(text: booking.balanceDue.toStringAsFixed(2));

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Collect Card Payment'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.showCompactLayout ? 320 : 380,
          ),
          child: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '£ ',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) {
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    await _paymentVM.makePayment(
      context,
      booking.propertyID,
      bookingId,
      amount,
      onPaymentSuccess: () {
        ref.invalidate(bookingDetailsProvider);
        ref.invalidate(bookingInvoiceProvider);
        ref.invalidate(bookingPaymentsProvider);
        ref.invalidate(bookingListByDateVM);
        ref.invalidate(bookingListVM);
      },
    );
  }

  Future<void> _syncInvoice(
      BuildContext context, WidgetRef ref, Booking booking) async {
    final invoice = await InvoiceService().syncBookingInvoice(
      booking.propertyID,
      int.parse(booking.id),
    );

    if (!context.mounted) return;

    if (invoice != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice synchronized.')),
      );
      ref.invalidate(bookingInvoiceProvider);
      ref.invalidate(bookingPaymentsProvider);
      ref.invalidate(bookingDetailsProvider);
      ref.invalidate(invoiceListVM);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to synchronize invoice.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingId = ref.watch(bookingIdProvider);
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;
    final roomMapping = ref.watch(roomMappingProvider);
    final canManageBookings =
        hasPmsPermission(ref, PmsPermission.manageBookings);
    final canViewFinance = hasPmsPermission(ref, PmsPermission.viewFinance);
    final canManageFinance = hasPmsPermission(ref, PmsPermission.manageFinance);

    final paymentStatusMappingAsync = ref.watch(paymentStatusMappingProvider);
    final bookingStatusMappingAsync = ref.watch(bookingStatusMappingProvider);

    final bookingDetailsAsync = ref.watch(bookingDetailsProvider);
    final bookingInvoiceAsync = ref.watch(bookingInvoiceProvider);
    final bookingPaymentsAsync = ref.watch(bookingPaymentsProvider);

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
                final hasGuestPhone =
                    booking.phone != null && booking.phone!.trim().isNotEmpty;
                final hasGuestEmail =
                    booking.email != null && booking.email!.trim().isNotEmpty;

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
                            if (canManageBookings)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.chat),
                                label: Text(
                                  hasGuestPhone
                                      ? "Open Messages"
                                      : "No Phone for Chat",
                                ),
                                onPressed: hasGuestPhone
                                    ? () {
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
                                                borderRadius: const BorderRadius
                                                    .vertical(
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
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                              ),
                            if (canManageBookings)
                              OutlinedButton.icon(
                                icon: const Icon(Icons.email_outlined),
                                label: Text(
                                  hasGuestEmail
                                      ? "Email Guest"
                                      : "No Email Address",
                                ),
                                onPressed: hasGuestEmail
                                    ? () => _showSendMessageDialog(
                                        context, ref, bookingId, booking)
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // --- Booking Details ---
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.start,
                            children: [
                              _section(context, "Guest Info", {
                                "Name":
                                    "${booking.firstName} ${booking.lastName}",
                                "Phone": booking.phone ?? "-",
                                "Adults": "${booking.numberOfAdults}",
                                "Children": "${booking.numberOfChildren}",
                              }),
                              _section(context, "Status & Meta", {
                                "Payment Status": paymentStatusMapping[
                                        booking.paymentStatusID] ??
                                    "Unknown",
                                "Booking Status":
                                    bookingStatusMapping[booking.statusID] ??
                                        'Unknown',
                                "Room": roomMapping[booking.roomID] ??
                                    'Room ${booking.roomID}',
                              }),
                              _section(context, "Dates", {
                                "Check-in": format.format(booking.checkIn),
                                "Check-out": format.format(booking.checkOut),
                                "Created": format.format(booking.bookingDate),
                              }),
                              _section(context, "Reference", {
                                "Confirmation Number":
                                    booking.confirmationNumber.toString(),
                                "Email": booking.email ?? "-",
                                "Invoice Number": booking.invoiceNumber ?? "-",
                              }),
                              _section(context, "Notes & Requests", {
                                "Special Request":
                                    (booking.specialRequest != null &&
                                            booking.specialRequest!
                                                .trim()
                                                .isNotEmpty)
                                        ? booking.specialRequest!
                                        : "None",
                                "Note": (booking.note != null &&
                                        booking.note!.trim().isNotEmpty)
                                    ? booking.note!
                                    : "None",
                              }),
                              _section(context, "Nightly Rates", {
                                for (var rate in booking.bookingRates)
                                  DateFormat('dd MMM').format(rate.rateDate):
                                      "£${rate.nightlyRate.toStringAsFixed(2)}"
                              }),
                              if (canViewFinance)
                                bookingInvoiceAsync.when(
                                  loading: () => _financeCardSkeleton(),
                                  error: (err, _) => _infoCard(
                                    context,
                                    "Invoice",
                                    Text('Failed to load invoice: $err'),
                                  ),
                                  data: (invoice) => _invoiceCard(
                                    context,
                                    ref,
                                    booking,
                                    invoice,
                                    canManageFinance: canManageFinance,
                                  ),
                                ),
                              if (canViewFinance)
                                bookingPaymentsAsync.when(
                                  loading: () => _financeCardSkeleton(),
                                  error: (err, _) => _infoCard(
                                    context,
                                    "Payments",
                                    Text('Failed to load payments: $err'),
                                  ),
                                  data: (payments) => _paymentsCard(
                                    context,
                                    ref,
                                    booking,
                                    payments,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              if (canManageBookings && booking.statusID == 1)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.login),
                                  label: const Text("Check In"),
                                  onPressed: () => _handleAction(
                                      context, ref, bookingId, 'check_in'),
                                ),
                              if (canManageBookings && booking.statusID == 2)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.logout),
                                  label: const Text("Check Out"),
                                  onPressed: () => _handleAction(
                                      context, ref, bookingId, 'check_out'),
                                ),
                              if (canManageBookings &&
                                  (booking.statusID == 1 ||
                                      booking.statusID == 2))
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.calendar_month),
                                  label: const Text("Extend"),
                                  onPressed: () => _handleExtendBooking(
                                      context, ref, bookingId, booking),
                                ),
                              if (canManageFinance)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.credit_score),
                                  label: const Text("Card Payment"),
                                  onPressed: booking.balanceDue <= 0
                                      ? null
                                      : () => _showStripePaymentDialog(
                                          context, ref, bookingId, booking),
                                ),
                              if (canManageFinance)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.point_of_sale),
                                  label: const Text("Record Payment"),
                                  onPressed: () => _showRecordPaymentDialog(
                                      context, ref, bookingId, booking),
                                ),
                              if (canManageFinance)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.payments_outlined),
                                  label: const Text("Update Status"),
                                  onPressed: () => _showUpdatePaymentDialog(
                                      context,
                                      ref,
                                      bookingId,
                                      booking.paymentStatusID,
                                      paymentStatusMapping),
                                ),

                              // 👉 NEW: CHARGE VCC BUTTON
                              if (canManageFinance && booking.balanceDue > 0)
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          VccChargeDialog(booking: booking),
                                    );

                                    // Refresh UI state upon successful charge
                                    if (result == true) {
                                      ref.invalidate(bookingDetailsProvider);
                                      ref.invalidate(bookingListByDateVM);
                                      ref.invalidate(bookingListVM);
                                    }
                                  },
                                  icon: const Icon(Icons.credit_card),
                                  label: const Text('Charge VCC'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              if (canManageFinance)
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.sync),
                                  label: const Text('Sync Invoice'),
                                  onPressed: () =>
                                      _syncInvoice(context, ref, booking),
                                ),

                              if (canManageBookings && booking.statusID == 1)
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

  Widget _section(
      BuildContext context, String title, Map<String, String> data) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: context.showCompactLayout ? double.infinity : 260,
      ),
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
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Text(e.key,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 3,
                          child: Text(e.value,
                              textAlign: TextAlign.right,
                              maxLines: 5,
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

  Widget _financeCardSkeleton() {
    return _infoCard(
      null,
      "Finance",
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _infoCard(BuildContext? context, String title, Widget child) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: context == null || !context.showCompactLayout
            ? 320
            : double.infinity,
      ),
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
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _invoiceCard(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
    InvoiceModel? invoice, {
    required bool canManageFinance,
  }) {
    final currency = NumberFormat.currency(symbol: '£');

    if (invoice == null) {
      return _infoCard(
        context,
        'Invoice',
        const Text('No invoice is available for this booking yet.'),
      );
    }

    return _infoCard(
      context,
      'Invoice',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelValue('Invoice', invoice.invoiceNumber),
          _labelValue(
              'Status', invoice.status.replaceAll('_', ' ').toUpperCase()),
          _labelValue(
              'Issued',
              invoice.issueDate != null
                  ? DateFormat.yMMMd().format(invoice.issueDate!)
                  : '-'),
          _labelValue(
              'Due',
              invoice.dueDate != null
                  ? DateFormat.yMMMd().format(invoice.dueDate!)
                  : '-'),
          const Divider(),
          _labelValue('Subtotal', currency.format(invoice.subtotal)),
          _labelValue('Tax', currency.format(invoice.taxAmount)),
          _labelValue('Total', currency.format(invoice.totalAmount)),
          _labelValue('Paid', currency.format(invoice.amountPaid)),
          _labelValue('Balance', currency.format(invoice.balanceDue),
              bold: true),
          if (invoice.lineItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Line Items',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            ...invoice.lineItems.take(5).map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.description,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currency.format(item.amount),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )),
          ],
          if (invoice.notes != null && invoice.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              invoice.notes!,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _printInvoice(context, booking),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print Invoice'),
              ),
              if (canManageFinance)
                ElevatedButton.icon(
                  onPressed: () =>
                      _showInvoiceEmailDialog(context, booking, invoice),
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Email Invoice'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentsCard(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
    List<PaymentTransaction> payments,
  ) {
    final currency = NumberFormat.currency(symbol: '£');

    return _infoCard(
      context,
      'Payments',
      payments.isEmpty
          ? const Text('No payments have been posted yet.')
          : Column(
              children: payments.take(6).map((payment) {
                final createdAt = payment.createdAt != null
                    ? DateFormat.yMMMd().add_jm().format(payment.createdAt!)
                    : '-';
                final canRefund = payment.transactionType == 'payment' &&
                    const {'succeeded', 'captured', 'settled'}
                        .contains(payment.status);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${payment.transactionType.replaceAll('_', ' ').toUpperCase()} • ${payment.paymentMethod.replaceAll('_', ' ').toUpperCase()}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${payment.status.toUpperCase()} • $createdAt',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                if ((payment.externalChannel ?? '').isNotEmpty)
                                  Text(
                                    'Channel: ${payment.externalChannel}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                if ((payment.reference ?? '').isNotEmpty)
                                  Text(
                                    'Ref: ${payment.reference}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          Text(currency.format(payment.amount)),
                        ],
                      ),
                      if (canRefund)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _showRefundPaymentDialog(
                              context,
                              ref,
                              booking,
                              payment,
                            ),
                            icon: const Icon(Icons.reply, size: 18),
                            label: const Text('Refund'),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _labelValue(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
