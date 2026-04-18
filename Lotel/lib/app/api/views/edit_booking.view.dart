import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/api/view_models/booking.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/payment_status_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_list.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/app/api/view_models/lists/rate_plan_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_online_list.vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RateResolver {
  final WidgetRef ref;
  RateResolver(this.ref);

  double? getRateForRoomAndDate({
    required String roomId,
    required DateTime date,
    required String categoryId,
  }) {
    final roomOnlineIndex = ref.read(roomOnlineIndexProvider);
    final ratePlans = ref.read(ratePlanListVM);

    final match = roomOnlineIndex[roomOnlineCellKey(roomId, date)];
    if (match != null) {
      return match.price;
    }

    final plan = ratePlans.firstWhereOrNull(
      (rp) =>
          rp.categoryId == categoryId &&
          !date.isBefore(rp.startDate) &&
          !date.isAfter(rp.endDate) &&
          rp.isActive,
    );
    if (plan == null) {
      return null;
    }

    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    return isWeekend && plan.weekendRate != null
        ? plan.weekendRate
        : plan.baseRate;
  }
}

class EditBookingForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final BookingVM booking;
  final WidgetRef? ref;

  const EditBookingForm({
    super.key,
    required this.onSubmit,
    required this.booking,
    this.ref,
  });

  @override
  State<EditBookingForm> createState() => _EditBookingFormState();
}

class _EditBookingFormState extends State<EditBookingForm> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final noteController = TextEditingController();
  final specialRequestController = TextEditingController();
  final rateController = TextEditingController();
  final dateRangeController = TextEditingController();

  DateTime? checkInDate;
  DateTime? checkOutDate;
  int? _numberOfNights;
  int? _numberOfAdults;
  int? _numberOfChildren;
  int? _paymentStatusID;
  int? _roomID;

  // Added state variables for handling extra cost payments
  double _extraCost = 0.0;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();

    checkInDate = widget.booking.checkIn;
    checkOutDate = widget.booking.checkOut;
    _numberOfNights = widget.booking.numberOfNights;
    _numberOfAdults = widget.booking.numberOfAdults;
    _numberOfChildren = widget.booking.numberOfChildren;
    _paymentStatusID = widget.booking.paymentStatusID;
    _roomID = widget.booking.roomID;

    firstNameController.text = widget.booking.firstName;
    lastNameController.text = widget.booking.lastName;
    emailController.text = widget.booking.email ?? '';
    phoneController.text = widget.booking.phone ?? '';
    noteController.text = widget.booking.note ?? '';
    specialRequestController.text = widget.booking.specialRequest ?? '';
    rateController.text = widget.booking.rate.toStringAsFixed(2);

    if (checkInDate != null && checkOutDate != null) {
      dateRangeController.text =
          "${_formatDate(checkInDate!)} to ${_formatDate(checkOutDate!)}";
      calculateNumberOfNights();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    noteController.dispose();
    specialRequestController.dispose();
    rateController.dispose();
    dateRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ResponsiveFormRow(children: [
            TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
              validator: _requiredString,
            ),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
              validator: _requiredString,
            ),
          ]),
          const SizedBox(height: 12),
          ResponsiveFormRow(children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ]),
          TextFormField(
            controller: dateRangeController,
            decoration: const InputDecoration(labelText: 'Select Dates'),
            readOnly: true,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: now,
                lastDate: DateTime(2027),
                initialDateRange: checkInDate != null && checkOutDate != null
                    ? DateTimeRange(start: checkInDate!, end: checkOutDate!)
                    : null,
              );
              if (picked != null) {
                setState(() {
                  checkInDate = picked.start;
                  checkOutDate = picked.end;
                  dateRangeController.text =
                      "${_formatDate(picked.start)} to ${_formatDate(picked.end)}";
                  calculateNumberOfNights();
                });
                await _tryResolveAndSetRate();
              }
            },
            validator: _requiredString,
          ),
          const SizedBox(height: 12),
          ResponsiveFormRow(children: [
            _buildDropdown("Adults:", _numberOfAdults,
                (val) => setState(() => _numberOfAdults = val)),
            _buildDropdown("Children:", _numberOfChildren,
                (val) => setState(() => _numberOfChildren = val)),
          ]),
          const SizedBox(height: 12),
          ResponsiveFormRow(children: [
            Consumer(builder: (context, ref, _) {
              final rooms = ref.watch(roomListVM);
              return _buildDropdownField(
                label: 'Room',
                value: _roomID?.toString(),
                items: rooms
                    .map((r) => DropdownMenuItem(
                          value: r.id,
                          child: Text(r.roomNumber.toString()),
                        ))
                    .toList(),
                onChanged: (val) async {
                  setState(() => _roomID = int.tryParse(val!));
                  await _tryResolveAndSetRate();
                },
              );
            }),
            Consumer(builder: (context, ref, _) {
              final statuses = ref.watch(paymentStatusListVM);
              return _buildDropdownField(
                label: 'Payment',
                value: _paymentStatusID?.toString(),
                items: statuses
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _paymentStatusID = int.tryParse(val!)),
              );
            }),
          ]),
          TextFormField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note')),
          TextFormField(
              controller: specialRequestController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Special request')),
          TextFormField(
            controller: rateController,
            decoration: const InputDecoration(labelText: 'Rate'),
            validator: _requiredString,
            readOnly: true,
          ),

          // Dynamic checkbox for handling extra cost payment directly in the form
          if (_extraCost > 0)
            CheckboxListTile(
              title: Text(
                  'Guest paid the extra \$${_extraCost.toStringAsFixed(2)} now'),
              controlAffinity: ListTileControlAffinity.leading,
              value: _isPaid,
              onChanged: (val) {
                setState(() {
                  _isPaid = val ?? false;
                });
              },
            ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (checkInDate == null || checkOutDate == null) {
                  _showError(context, 'Please select valid dates.');
                  return;
                }

                if (_numberOfNights == null || _numberOfNights! <= 0) {
                  _showError(context, 'Invalid number of nights.');
                  return;
                }

                try {
                  // Calculate the final amount paid before submitting
                  double finalAmountPaid = widget.booking.amountPaid;
                  if (_isPaid && _extraCost > 0) {
                    finalAmountPaid += _extraCost;
                  }

                  final success = await widget.onSubmit({
                    'first_name': firstNameController.text,
                    'last_name': lastNameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'check_in': checkInDate!.toIso8601String(),
                    'check_out': checkOutDate!.toIso8601String(),
                    'number_of_days': _numberOfNights,
                    'number_of_adults': _numberOfAdults,
                    'number_of_children': _numberOfChildren,
                    'payment_status_id': _paymentStatusID,
                    'note': noteController.text,
                    'special_request': specialRequestController.text,
                    'check_in_day': checkInDate!.day,
                    'check_in_month': checkInDate!.month,
                    'check_in_year': checkInDate!.year,
                    'check_out_day': checkOutDate!.day,
                    'check_out_month': checkOutDate!.month,
                    'check_out_year': checkOutDate!.year,
                    'rate': rateController.text,
                    'amount_paid': finalAmountPaid, // Pass updated amount paid
                    'property_id': widget.ref!.read(selectedPropertyVM) ?? 0,
                    'room_id': _roomID,
                  });

                  if (!mounted) {
                    return;
                  }

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Booking updated successfully.')),
                    );
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (!context.mounted) {
                    return;
                  }
                  _showError(context, 'Something went wrong while saving.');
                }
              }
            },
            child: const Text('Submit'),
          )
        ]),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  String? _requiredString(String? value) =>
      (value == null || value.isEmpty) ? 'Required' : null;

  String? _requiredInt(int? value) => value == null ? 'Required' : null;

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void calculateNumberOfNights() {
    if (checkInDate != null && checkOutDate != null) {
      setState(() {
        _numberOfNights = checkOutDate!.difference(checkInDate!).inDays;
      });
    }
  }

  Future<void> _tryResolveAndSetRate() async {
    if (_roomID != null && checkInDate != null && checkOutDate != null) {
      await _resolveAndSetRate();
    } else {
      setState(() {
        rateController.text = '';
        _extraCost = 0.0;
        _isPaid = false;
      });
    }
  }

  Future<void> _resolveAndSetRate() async {
    if (_roomID == null ||
        checkInDate == null ||
        checkOutDate == null ||
        widget.ref == null) {
      return;
    }

    final roomVM = widget.ref!.read(roomListVM).firstWhereOrNull(
          (room) => int.tryParse(room.id) == _roomID,
        );
    final categoryId = roomVM?.categoryId.toString();
    if (categoryId == null) {
      return;
    }

    final resolver = RateResolver(widget.ref!);
    double totalRate = 0.0;
    DateTime currentDate = checkInDate!;

    while (currentDate.isBefore(checkOutDate!)) {
      final nightlyRate = resolver.getRateForRoomAndDate(
        roomId: _roomID.toString(),
        date: currentDate,
        categoryId: categoryId,
      );
      if (nightlyRate != null) {
        totalRate += nightlyRate;
      }
      currentDate = currentDate.add(Duration(days: 1));
    }

    setState(() {
      rateController.text = totalRate.toStringAsFixed(2);

      // Calculate extra cost dynamically on rate update
      _extraCost = totalRate - widget.booking.rate;
      if (_extraCost <= 0) {
        _isPaid = false; // reset flag if cost goes down or stays equal
      }
    });
  }

  Widget _buildDropdown(
      String label, int? value, ValueChanged<int?> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            initialValue: value,
            items: List.generate(
              5,
              (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
            ),
            onChanged: onChanged,
            validator: _requiredInt,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        initialValue: value,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
