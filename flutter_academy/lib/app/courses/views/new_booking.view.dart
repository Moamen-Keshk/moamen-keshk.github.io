import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/utilities/rate_resolver.dart';
import 'package:flutter_academy/app/courses/view_models/lists/payment_status_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

final dateFormatter = DateFormat('yyyy-MM-dd');

class BookingForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
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
  final noteController = TextEditingController();
  final specialRequestController = TextEditingController();
  final rateController = TextEditingController();
  final dateRangeController = TextEditingController();
  final checkInController = TextEditingController();
  final checkOutController = TextEditingController();

  DateTime? checkInDate;
  DateTime? checkOutDate;
  int? _numberOfNights;
  int? _numberOfAdults;
  int? _numberOfChildren;
  int? _paymentStatusID;
  int? _roomID;

  @override
  void initState() {
    super.initState();

    if (widget.tabDay != null) {
      checkInDate = DateTime(
        widget.ref!.read(selectedMonthVM).year,
        widget.ref!.read(selectedMonthVM).month,
        widget.tabDay!,
      );
      checkOutDate = checkInDate!.add(Duration(days: 1));
      _numberOfNights = 1;

      checkInController.text = _formatDate(checkInDate!);
      checkOutController.text = _formatDate(checkOutDate!);
      _roomID = int.parse(widget.tabRoom!);

      _resolveAndSetRate();
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
    if (categoryId == null) return;

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
      currentDate = currentDate.add(const Duration(days: 1));
    }

    setState(() {
      rateController.text = totalRate.toStringAsFixed(2);
    });
  }

  void calculateNumberOfNights() {
    if (checkInDate != null && checkOutDate != null) {
      setState(() {
        _numberOfNights = checkOutDate!.difference(checkInDate!).inDays;
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    noteController.dispose();
    specialRequestController.dispose();
    rateController.dispose();
    dateRangeController.dispose();
    checkInController.dispose();
    checkOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(
              child: TextFormField(
            controller: firstNameController,
            decoration: InputDecoration(labelText: 'First Name'),
            validator: _requiredString,
          )),
          Expanded(
              child: TextFormField(
            controller: lastNameController,
            decoration: InputDecoration(labelText: 'Last Name'),
            validator: _requiredString,
          )),
        ]),
        widget.tabDay == null ? _buildDateRangePicker() : _buildDatePickers(),
        Row(children: [
          _buildDropdown("Adults:", _numberOfAdults,
              (val) => setState(() => _numberOfAdults = val)),
          _buildDropdown("Children:", _numberOfChildren,
              (val) => setState(() => _numberOfChildren = val)),
        ]),
        Row(children: [
          Consumer(builder: (context, ref, _) {
            final rooms = ref.watch(roomListVM);
            return _buildDropdownField<String>(
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
                await _resolveAndSetRate();
              },
            );
          }),
          Consumer(builder: (context, ref, _) {
            final statuses = ref.watch(paymentStatusListVM);
            return _buildDropdownField<String>(
              label: 'Payment',
              value: _paymentStatusID?.toString(),
              items: statuses
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      ))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _paymentStatusID = int.parse(val!)),
            );
          }),
        ]),
        TextFormField(
            controller: noteController,
            decoration: InputDecoration(labelText: 'Note')),
        TextFormField(
            controller: specialRequestController,
            maxLines: 2,
            decoration: InputDecoration(labelText: 'Special request')),
        Row(children: [
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: rateController,
              decoration: InputDecoration(labelText: 'Rate'),
              validator: _requiredString,
            ),
          ),
        ]),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (checkInDate == null || checkOutDate == null) {
                _showError(context,
                    'Please select both check-in and check-out dates.');
                return;
              }

              if (_numberOfNights == null || _numberOfNights! <= 0) {
                _showError(context, 'Invalid number of nights.');
                return;
              }

              try {
                final success = await widget.onSubmit({
                  'first_name': firstNameController.text,
                  'last_name': lastNameController.text,
                  "check_in": DateFormat('yyyy-MM-dd').format(checkInDate!),
                  "check_out": DateFormat('yyyy-MM-dd').format(checkOutDate!),
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
                  'room_id': _roomID,
                  'property_id': widget.ref!.read(selectedPropertyVM) ?? 0,
                });

                if (!mounted) return;

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Booking added successfully.')),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (!context.mounted) return;
                _showError(context, 'Something went wrong during submission.');
              }
            }
          },
          child: const Text('Submit'),
        )
      ]),
    );
  }

  Widget _buildDateRangePicker() {
    return Row(children: [
      Expanded(
        child: TextFormField(
          controller: dateRangeController,
          decoration: InputDecoration(labelText: 'Select Dates'),
          readOnly: true,
          onTap: () async {
            final now = DateTime.now();
            final safeStart =
                checkInDate?.isAfter(now) == true ? checkInDate! : now;
            final safeEnd = checkOutDate?.isAfter(safeStart) == true
                ? checkOutDate!
                : safeStart.add(Duration(days: 1));

            final picked = await showDateRangePicker(
              context: context,
              firstDate: now,
              lastDate: DateTime(2027),
              initialDateRange: DateTimeRange(start: safeStart, end: safeEnd),
            );

            if (picked != null) {
              setState(() {
                checkInDate = picked.start;
                checkOutDate = picked.end;
                dateRangeController.text =
                    "${_formatDate(picked.start)} to ${_formatDate(picked.end)}";
                calculateNumberOfNights();
              });
              await _resolveAndSetRate();
            }
          },
          validator: _requiredString,
        ),
      ),
      if (_numberOfNights != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('$_numberOfNights Nights'),
        )
    ]);
  }

  Widget _buildDatePickers() {
    return Row(children: [
      SizedBox(
        width: 160,
        child: TextFormField(
          controller: checkInController,
          decoration: InputDecoration(labelText: 'Check in'),
          readOnly: true,
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: checkInDate ?? now,
              firstDate: now,
              lastDate: DateTime(2100),
            );

            if (picked != null) {
              setState(() {
                checkInDate = picked;
                checkInController.text = _formatDate(picked);
                checkOutDate = picked.add(Duration(days: 1));
                checkOutController.text = _formatDate(checkOutDate!);
                calculateNumberOfNights();
              });
              await _resolveAndSetRate();
            }
          },
          validator: _requiredString,
        ),
      ),
      SizedBox(
        width: 160,
        child: TextFormField(
          controller: checkOutController,
          decoration: InputDecoration(labelText: 'Check out'),
          readOnly: true,
          onTap: () async {
            final base = checkInDate ?? DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: base.add(Duration(days: 1)),
              firstDate: base.add(Duration(days: 1)),
              lastDate: DateTime(2100),
            );

            if (picked != null) {
              setState(() {
                checkOutDate = picked;
                checkOutController.text = _formatDate(picked);
                calculateNumberOfNights();
              });
            }
          },
          validator: _requiredString,
        ),
      ),
      if (_numberOfNights != null)
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child:
              Text('$_numberOfNights Nights', style: TextStyle(fontSize: 12)),
        ),
    ]);
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

  Widget _buildDropdown(
      String label, int? value, ValueChanged<int?> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        SizedBox(width: 90, child: Text(label, style: TextStyle(fontSize: 16))),
        SizedBox(
          width: 70,
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(border: OutlineInputBorder()),
            value: value,
            items: List.generate(
              5,
              (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
            ),
            onChanged: onChanged,
            validator: _requiredInt,
          ),
        ),
      ]),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: 160,
        child: DropdownButtonFormField<T>(
          decoration:
              InputDecoration(border: OutlineInputBorder(), labelText: label),
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
