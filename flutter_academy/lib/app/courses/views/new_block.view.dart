import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockForm extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final int? tabDay;
  final String? tabRoom;
  final WidgetRef? ref;

  const BlockForm({
    super.key,
    required this.onSubmit,
    this.tabDay,
    this.tabRoom,
    this.ref,
  });

  @override
  ConsumerState<BlockForm> createState() => _BlockFormState();
}

class _BlockFormState extends ConsumerState<BlockForm> {
  final _formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();
  final dateRangeController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  int? numberOfDays;
  int? roomID;

  @override
  void initState() {
    super.initState();

    if (widget.tabDay != null && widget.tabRoom != null) {
      startDate = DateTime(
        widget.ref!.read(selectedMonthVM).year,
        widget.ref!.read(selectedMonthVM).month,
        widget.tabDay!,
      );
      endDate = startDate!.add(const Duration(days: 1));
      numberOfDays = 1;
      roomID = int.tryParse(widget.tabRoom!);
      dateRangeController.text =
          "${_formatDate(startDate!)} to ${_formatDate(endDate!)}";
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    dateRangeController.dispose();
    super.dispose();
  }

  void calculateNumberOfDays() {
    if (startDate != null && endDate != null) {
      setState(() {
        numberOfDays = endDate!.difference(startDate!).inDays;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _buildDateRangePicker(),
          Consumer(builder: (context, ref, _) {
            final rooms = ref.watch(roomListVM);
            return _buildDropdownField<String>(
              label: 'Room',
              value: roomID?.toString(),
              items: rooms
                  .map((r) => DropdownMenuItem(
                        value: r.id,
                        child: Text(r.roomNumber.toString()),
                      ))
                  .toList(),
              onChanged: (val) =>
                  setState(() => roomID = int.tryParse(val ?? '')),
            );
          }),
          TextFormField(
            controller: noteController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (startDate == null || endDate == null || roomID == null) {
                    _showError(context, 'Missing required fields.');
                    return;
                  }

                  final propertyID = ref.read(selectedPropertyVM) ?? 0;

                  final success = await widget.onSubmit({
                    'start_date': startDate!.toIso8601String(),
                    'end_date': endDate!.toIso8601String(),
                    'start_day': startDate!.day,
                    'start_month': startDate!.month,
                    'start_year': startDate!.year,
                    'end_day': endDate!.day,
                    'end_month': endDate!.month,
                    'end_year': endDate!.year,
                    'number_of_days': numberOfDays,
                    'note': noteController.text,
                    'room_id': roomID,
                    'property_id': propertyID,
                  });

                  if (!mounted) return;

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Block added successfully.')),
                    );
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Submit'))
        ]));
  }

  Widget _buildDateRangePicker() {
    return Row(children: [
      Expanded(
        child: TextFormField(
          controller: dateRangeController,
          decoration: const InputDecoration(labelText: 'Select Dates'),
          readOnly: true,
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDateRangePicker(
              context: context,
              firstDate: now,
              lastDate: DateTime(2100),
              initialDateRange: (startDate != null && endDate != null)
                  ? DateTimeRange(start: startDate!, end: endDate!)
                  : null,
            );
            if (picked != null) {
              setState(() {
                startDate = picked.start;
                endDate = picked.end;
                dateRangeController.text =
                    "${_formatDate(picked.start)} to ${_formatDate(picked.end)}";
                calculateNumberOfDays();
              });
            }
          },
          validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
        ),
      ),
      if (numberOfDays != null)
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text('$numberOfDays Days'),
        )
    ]);
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
          validator: (val) => val == null ? 'Required' : null,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
