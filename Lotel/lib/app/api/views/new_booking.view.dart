import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/utilities/rate_resolver.dart';
import 'package:lotel_pms/app/api/view_models/lists/payment_status_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_list.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final dateFormatter = DateFormat('yyyy-MM-dd');

class BookingForm extends StatefulWidget {
  final Future<bool> Function(Map<String, dynamic>) onSubmit;
  final int? tabDay;
  final String? tabRoom;
  final WidgetRef? ref;

  const BookingForm({
    super.key,
    required this.onSubmit,
    this.tabDay,
    this.tabRoom,
    this.ref,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final noteController = TextEditingController();
  final specialRequestController = TextEditingController();
  final dateRangeController = TextEditingController();
  final checkInController = TextEditingController();
  final checkOutController = TextEditingController();

  final rateController = TextEditingController();
  final amountPaidController = TextEditingController();

  final ScrollController _formScroll = ScrollController();
  final ScrollController _noteVScroll = ScrollController();
  final ScrollController _specialVScroll = ScrollController();

  DateTime? checkInDate;
  // 👉 FIX: Treated as departure day (Exclusive of nightly rate)
  DateTime? checkOutDate;
  int? _numberOfNights;
  int? _numberOfAdults;
  int? _numberOfChildren;
  int? _paymentStatusID;
  int? _roomID;

  @override
  void initState() {
    super.initState();

    if (widget.tabDay != null && widget.ref != null) {
      checkInDate = DateTime(
        widget.ref!.read(selectedMonthVM).year,
        widget.ref!.read(selectedMonthVM).month,
        widget.tabDay!,
      );

      // 👉 FIX: Default check-out is the NEXT day (1 night stay)
      checkOutDate = checkInDate!.add(const Duration(days: 1));
      _numberOfNights = 1;

      checkInController.text = _formatDate(checkInDate!);
      checkOutController.text = _formatDate(checkOutDate!);
      _roomID = int.tryParse(widget.tabRoom ?? '');

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_roomID != null && checkInDate != null && checkOutDate != null) {
          await _tryResolveAndSetRate();
        }
      });
    }
  }

  void _updateAmountPaidBasedOnStatus() {
    if (_paymentStatusID == null || widget.ref == null) {
      return;
    }

    final statuses = widget.ref!.read(paymentStatusListVM);
    final status = statuses.firstWhereOrNull(
      (s) => s.id == _paymentStatusID.toString(),
    );

    if (status != null && rateController.text.isNotEmpty) {
      final name = status.name.toLowerCase();

      if (name == 'paid') {
        amountPaidController.text = rateController.text;
      } else if (name == 'pending' || name == 'unpaid') {
        amountPaidController.text = '0.00';
      } else if (name == 'partially paid') {
        final currentAmount = double.tryParse(amountPaidController.text) ?? 0.0;
        final totalRate = double.tryParse(rateController.text) ?? 0.0;
        if (currentAmount == 0.0 || currentAmount == totalRate) {
          amountPaidController.text = '';
        }
      }
    }
  }

  Future<void> _tryResolveAndSetRate() async {
    if (_roomID != null && checkInDate != null && checkOutDate != null) {
      await _resolveAndSetRate();
    } else {
      setState(() {
        rateController.text = '';
        amountPaidController.text = '';
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
          (room) => room.id == _roomID.toString(),
        );

    final categoryId = roomVM?.categoryId.toString();
    if (categoryId == null) {
      return;
    }

    final resolver = RateResolver(widget.ref!);

    double totalRate = 0.0;
    DateTime currentDate = checkInDate!;
    DateTime endLoop = checkOutDate!;

    // Safety fallback: if same day selected, charge for at least 1 night
    if (currentDate.isAtSameMomentAs(endLoop)) {
      endLoop = endLoop.add(const Duration(days: 1));
    }

    // 👉 FIX: Exclusive loop (stops before the check-out day)
    while (currentDate.isBefore(endLoop)) {
      final nightlyRate = resolver.getRateForRoomAndDate(
        roomId: _roomID.toString(),
        date: currentDate,
        categoryId: categoryId,
      );
      if (nightlyRate != null) {
        totalRate += nightlyRate;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    setState(() {
      rateController.text = totalRate.toStringAsFixed(2);
    });

    _updateAmountPaidBasedOnStatus();
  }

  void calculateNumberOfNights() {
    if (checkInDate != null && checkOutDate != null) {
      setState(() {
        // 👉 FIX: Standard calculation. (e.g. 4th - 1st = 3 nights)
        _numberOfNights = checkOutDate!.difference(checkInDate!).inDays;

        // Fallback for same-day selection to prevent 0 nights
        if (_numberOfNights! <= 0) {
          _numberOfNights = 1;
        }
      });
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
    dateRangeController.dispose();
    checkInController.dispose();
    checkOutController.dispose();
    rateController.dispose();
    amountPaidController.dispose();

    _formScroll.dispose();
    _noteVScroll.dispose();
    _specialVScroll.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);

    final maxContentWidth = 900.0;
    final contentWidth = screen.width < 600
        ? screen.width * 0.95
        : (screen.width * 0.85).clamp(320.0, maxContentWidth);

    return SizedBox(
      width: contentWidth,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _formScroll,
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                            ),
                            validator: _requiredString,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                            ),
                            validator: _requiredString,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: emailController,
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            decoration:
                                const InputDecoration(labelText: 'Phone'),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    widget.tabDay == null
                        ? _buildDateRangePicker()
                        : _buildDatePickers(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDropdown(
                          "Adults:",
                          _numberOfAdults,
                          (val) => setState(() => _numberOfAdults = val),
                        ),
                        _buildDropdown(
                          "Children:",
                          _numberOfChildren,
                          (val) => setState(() => _numberOfChildren = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final rooms = ref.watch(roomListVM);
                            return _buildDropdownField<String>(
                              label: 'Room',
                              value: _roomID?.toString(),
                              items: rooms
                                  .map(
                                    (r) => DropdownMenuItem(
                                      value: r.id,
                                      child: Text(r.roomNumber.toString()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() => _roomID = int.tryParse(val!));
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => _tryResolveAndSetRate(),
                                );
                              },
                            );
                          },
                        ),
                        Consumer(
                          builder: (context, ref, _) {
                            final statuses = ref.watch(paymentStatusListVM);
                            return _buildDropdownField<String>(
                              label: 'Payment Status',
                              value: _paymentStatusID?.toString(),
                              items: statuses
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s.id.toString(),
                                      child: Text(s.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(
                                    () => _paymentStatusID = int.parse(val!));
                                _updateAmountPaidBasedOnStatus();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _fixedHeightScrollableTextField(
                      controller: noteController,
                      scrollController: _noteVScroll,
                      label: 'Note',
                      height: 90,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 8),
                    _fixedHeightScrollableTextField(
                      controller: specialRequestController,
                      scrollController: _specialVScroll,
                      label: 'Special request',
                      height: 90,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: rateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                                labelText: 'Total Rate (£)',
                                border: OutlineInputBorder()),
                            validator: _requiredString,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: amountPaidController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                                labelText: 'Amount Paid (£)',
                                border: OutlineInputBorder()),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(val) == null) {
                                return 'Invalid Amount';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fixedHeightScrollableTextField({
    required TextEditingController controller,
    required ScrollController scrollController,
    required String label,
    double height = 90,
    int maxLines = 4,
  }) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        scrollController: scrollController,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: maxLines,
        minLines: maxLines,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (checkInDate == null || checkOutDate == null) {
      _showError(context, 'Please select both check-in and check-out dates.');
      return;
    }

    if (_numberOfNights == null || _numberOfNights! <= 0) {
      _showError(context, 'Invalid number of nights.');
      return;
    }

    try {
      final widgetRef = widget.ref;
      final propertyId = widgetRef?.read(selectedPropertyVM) ?? 0;

      final success = await widget.onSubmit({
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'check_in': dateFormatter.format(checkInDate!),
        'check_out': dateFormatter.format(checkOutDate!),
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
        'amount_paid': double.tryParse(amountPaidController.text) ?? 0.0,
        'room_id': _roomID,
        'property_id': propertyId,
      });

      if (!mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking added successfully.')),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        _showError(context, 'Something went wrong during submission.');
      }
    }
  }

  Widget _buildDateRangePicker() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: dateRangeController,
            decoration: const InputDecoration(labelText: 'Select Dates'),
            readOnly: true,
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2027),
              );

              if (picked != null) {
                setState(() {
                  checkInDate = picked.start;
                  // 👉 FIX: The Range picker "end" date is treated as departure day
                  checkOutDate = picked.end;
                  dateRangeController.text =
                      "${_formatDate(picked.start)} to ${_formatDate(picked.end)}";
                  calculateNumberOfNights();
                });

                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (_roomID != null) {
                    await _tryResolveAndSetRate();
                  }
                });
              }
            },
            validator: _requiredString,
          ),
        ),
        if (_numberOfNights != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('$_numberOfNights Nights'),
          ),
      ],
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: TextFormField(
            controller: checkInController,
            decoration: const InputDecoration(labelText: 'Check in'),
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                initialDate: checkInDate ?? DateTime.now(),
              );

              if (picked != null) {
                setState(() {
                  checkInDate = picked;
                  checkInController.text = _formatDate(picked);

                  // Force checkout to be at least 1 day after check-in
                  if (checkOutDate == null || !checkOutDate!.isAfter(picked)) {
                    checkOutDate = picked.add(const Duration(days: 1));
                    checkOutController.text = _formatDate(checkOutDate!);
                  }

                  calculateNumberOfNights();
                });

                await _tryResolveAndSetRate();
              }
            },
            validator: _requiredString,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 160,
          child: TextFormField(
            controller: checkOutController,
            decoration: const InputDecoration(labelText: 'Check out'),
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                // Block selecting a checkout date that is before check-in
                firstDate:
                    checkInDate?.add(const Duration(days: 1)) ?? DateTime.now(),
                lastDate: DateTime(2100),
                initialDate: checkOutDate ??
                    checkInDate?.add(const Duration(days: 1)) ??
                    DateTime.now(),
              );

              if (picked != null) {
                setState(() {
                  checkOutDate = picked;
                  checkOutController.text = _formatDate(picked);
                  calculateNumberOfNights();
                });

                await _tryResolveAndSetRate();
              }
            },
            validator: _requiredString,
          ),
        ),
        if (_numberOfNights != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '$_numberOfNights Nights',
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    int? value,
    ValueChanged<int?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          SizedBox(
            width: 70,
            child: DropdownButtonFormField<int>(
              initialValue: value,
              items: List.generate(
                5,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('${i + 1}'),
                ),
              ),
              onChanged: onChanged,
              validator: _requiredInt,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 160,
        child: DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: label,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => dateFormatter.format(date);

  String? _requiredString(String? value) =>
      (value == null || value.isEmpty) ? 'Required' : null;

  String? _requiredInt(int? value) => value == null ? 'Required' : null;

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
