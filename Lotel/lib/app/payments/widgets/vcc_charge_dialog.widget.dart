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
  final PaymentService _paymentService =
      PaymentService(); // Instantiate service

  bool _isProcessing = false;
  bool _isFetchingVCC = true; // NEW: State for initial data fetch

  late TextEditingController _amountController;
  final _cardNumberController = TextEditingController();
  final _expMonthController = TextEditingController();
  final _expYearController = TextEditingController();
  final _cvcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final double balance = widget.booking.balanceDue;
    _amountController = TextEditingController(text: balance.toStringAsFixed(2));

    // Fetch VCC details automatically on load
    _fetchSavedVccDetails();
  }

  Future<void> _fetchSavedVccDetails() async {
    final bookingId = int.tryParse(widget.booking.id);
    if (bookingId != null) {
      final vccData = await _paymentService.fetchBookingVCC(bookingId);

      if (vccData != null && mounted) {
        setState(() {
          _cardNumberController.text = vccData['card_number'] ?? '';
          _expMonthController.text = vccData['exp_month'] ?? '';
          _expYearController.text = vccData['exp_year'] ?? '';
          _cvcController.text = vccData['cvc'] ?? '';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isFetchingVCC = false; // Turn off initial loading spinner
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _cardNumberController.dispose();
    _expMonthController.dispose();
    _expYearController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _processCharge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final bookingId = int.tryParse(widget.booking.id);
    if (bookingId == null) return;

    final success = await _paymentVM.chargeVCC(
      context,
      bookingId: bookingId,
      amount: double.parse(_amountController.text),
      cardNumber: _cardNumberController.text,
      expMonth: _expMonthController.text,
      expYear: _expYearController.text,
      cvc: _cvcController.text,
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
      title: Text('Charge VCC - Booking #${widget.booking.id}'),
      content: SizedBox(
        width: 400,
        // Show a spinner while fetching the card details
        child: _isFetchingVCC
            ? const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator()),
              )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount to Charge (\$)',
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
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Virtual Card Number',
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Enter card number'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expMonthController,
                            decoration: const InputDecoration(
                                labelText: 'Exp Month (MM)',
                                border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _expYearController,
                            decoration: const InputDecoration(
                                labelText: 'Exp Year (YY)',
                                border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _cvcController,
                            decoration: const InputDecoration(
                                labelText: 'CVC', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
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
          onPressed: (_isProcessing || _isFetchingVCC) ? null : _processCharge,
          icon: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.payment),
          label: Text(_isProcessing ? 'Processing...' : 'Charge VCC'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }
}
