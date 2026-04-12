import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/payments/view_models/payments.vm.dart';
import 'package:lotel_pms/app/payments/services/payment.service.dart'; // Import service
import 'package:lotel_pms/infrastructure/api/model/booking.model.dart';

class VccChargeDialog extends ConsumerStatefulWidget {
  final Booking booking;

  const VccChargeDialog({super.key, required this.booking});

  @override
  ConsumerState<VccChargeDialog> createState() => _VccChargeDialogState();
}

class _VccChargeDialogState extends ConsumerState<VccChargeDialog> {
  final _formKey = GlobalKey<FormState>();
  final PaymentVM _paymentVM = PaymentVM();
  final PaymentService _paymentService = PaymentService();

  bool _isProcessing = false;
  bool _isFetchingVCC = true;

  late TextEditingController _amountController;
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  Map<String, dynamic>? _vccData;

  @override
  void initState() {
    super.initState();
    final double balance = widget.booking.balanceDue;
    _amountController = TextEditingController(text: balance.toStringAsFixed(2));
    _fetchSavedVccDetails();
  }

  Future<void> _fetchSavedVccDetails() async {
    final propertyId = widget.booking.propertyID;
    final bookingId = int.tryParse(widget.booking.id);
    if (bookingId != null) {
      final vccData = await _paymentService.fetchBookingVCC(propertyId, bookingId);

      if (vccData != null && mounted) {
        setState(() {
          _vccData = vccData;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isFetchingVCC = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processCharge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final propertyId = widget.booking.propertyID;
    final bookingId = int.tryParse(widget.booking.id);
    if (bookingId == null) return;

    final success = await _paymentVM.recordManualPayment(
      context,
      propertyId: propertyId,
      bookingId: bookingId,
      amount: double.parse(_amountController.text),
      paymentMethod: 'ota_vcc',
      source: 'manual',
      reference: _referenceController.text.trim().isEmpty
          ? 'OTA VCC'
          : _referenceController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? 'Recorded against OTA virtual card'
          : _notesController.text.trim(),
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('VCC Payment - Booking #${widget.booking.id}'),
      content: SizedBox(
        width: 400,
        child: _isFetchingVCC
            ? const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator()),
              )
            : _vccData == null
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No OTA virtual card details were found for this booking.',
                    ),
                  )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _readOnlyField('Card Number', _vccData?['card_number']),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _readOnlyField(
                              'Exp Month', _vccData?['exp_month']),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              _readOnlyField('Exp Year', _vccData?['exp_year']),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _readOnlyField('CVC', _vccData?['cvc']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount to Record',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter amount' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _referenceController,
                      decoration: const InputDecoration(
                        labelText: 'Reference',
                        prefixIcon: Icon(Icons.tag),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed:
              (_isProcessing || _isFetchingVCC || _vccData == null) ? null : _processCharge,
          icon: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.payment),
          label: Text(_isProcessing ? 'Recording...' : 'Record VCC Payment'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }

  Widget _readOnlyField(String label, dynamic value) {
    return TextFormField(
      initialValue: value?.toString() ?? '-',
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
    );
  }
}
