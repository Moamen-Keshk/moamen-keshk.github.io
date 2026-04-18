import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/invoice_list.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/model/invoice.model.dart';
import 'package:lotel_pms/main.dart';

final NumberFormat _money = NumberFormat.currency(symbol: '£');
final DateFormat _date = DateFormat.yMMMd();

class InvoicesView extends ConsumerWidget {
  const InvoicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;
    final invoices = ref.watch(invoiceListVM);

    if (propertyId <= 0) {
      return const Center(
        child: Text('Select a property to load invoices.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: invoices.isEmpty
          ? RefreshIndicator(
              onRefresh: () => ref.read(invoiceListVM.notifier).fetchInvoices(),
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No invoices found for this property.')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(invoiceListVM.notifier).fetchInvoices(),
              child: ListView.separated(
                itemCount: invoices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final invoice = invoices[index];
                  return _InvoiceCard(invoice: invoice);
                },
              ),
            ),
    );
  }
}

class _InvoiceCard extends ConsumerWidget {
  final InvoiceModel invoice;

  const _InvoiceCard({required this.invoice});

  Color _statusColor(BuildContext context) {
    switch (invoice.status) {
      case 'paid':
        return Colors.green.shade700;
      case 'partially_paid':
        return Colors.orange.shade700;
      case 'draft':
        return Colors.blueGrey.shade600;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor(context);
    final isCompact = context.showCompactLayout;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(invoice.guestName.isEmpty
                          ? 'Guest not set'
                          : invoice.guestName),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          invoice.status.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.invoiceNumber,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(invoice.guestName.isEmpty
                                ? 'Guest not set'
                                : invoice.guestName),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          invoice.status.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                _meta(
                    'Issued',
                    invoice.issueDate != null
                        ? _date.format(invoice.issueDate!)
                        : '-'),
                _meta(
                    'Due',
                    invoice.dueDate != null
                        ? _date.format(invoice.dueDate!)
                        : '-'),
                _meta('Total', _money.format(invoice.totalAmount)),
                _meta('Paid', _money.format(invoice.amountPaid)),
                _meta('Balance', _money.format(invoice.balanceDue)),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  final bookingId = int.tryParse(invoice.bookingId);
                  if (bookingId == null) return;
                  ref.read(bookingIdProvider.notifier).state = bookingId;
                  ref.read(selectedBookingIdProvider.notifier).state =
                      bookingId;
                  ref.read(routerProvider).push('booking');
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('Open Booking Folio'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String label, String value) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
