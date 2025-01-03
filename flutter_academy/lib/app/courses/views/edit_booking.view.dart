import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/payment_status.vm.dart';
import 'package:flutter_academy/app/courses/view_models/payment_status_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditBookingForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final BookingVM booking;
  final WidgetRef? ref;

  const EditBookingForm(
      {super.key, required this.onSubmit, this.ref, required this.booking});

  @override
  State<EditBookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<EditBookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController specialRequestController =
      TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController dateRangeController = TextEditingController();

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
    checkInDate = widget.booking.checkIn;
    checkOutDate = widget.booking.checkOut;
    dateRangeController.text =
        "${checkInDate?.year}-${checkInDate?.month}-${checkInDate?.day} to "
        "${checkOutDate?.year}-${checkOutDate?.month}-${checkOutDate?.day}";
    _numberOfNights = widget.booking.numberOfNights;
    _numberOfAdults = widget.booking.numberOfAdults;
    _numberOfChildren = widget.booking.numberOfChildren;
    _paymentStatusID = widget.booking.paymentStatusID;
    _roomID = widget.booking.roomID;
    firstNameController.text = widget.booking.firstName;
    lastNameController.text = widget.booking.lastName;
    noteController.text = widget.booking.note!;
    specialRequestController.text = widget.booking.specialRequest!;
    rateController.text = widget.booking.rate.toString();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    noteController.dispose();
    specialRequestController.dispose();
    rateController.dispose();
    dateRangeController.dispose();
    super.dispose();
  }

  void calculateNumberOfNights() {
    if (checkInDate != null && checkOutDate != null) {
      _numberOfNights = checkOutDate!.difference(checkInDate!).inDays;
    } else {
      _numberOfNights = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name Fields
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a first name';
                    }
                    return null;
                  },
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a last name';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          // Date Range Picker
          Row(children: [
            Expanded(
                child: TextFormField(
              controller: dateRangeController,
              decoration: InputDecoration(labelText: 'Select Dates'),
              readOnly: true,
              onTap: () async {
                final DateTimeRange? pickedDateRange =
                    await showDateRangePicker(
                  context: context,
                  firstDate: checkInDate!,
                  lastDate: DateTime(2027),
                  initialDateRange: checkInDate != null && checkOutDate != null
                      ? DateTimeRange(start: checkInDate!, end: checkOutDate!)
                      : null,
                );

                if (pickedDateRange != null) {
                  setState(() {
                    checkInDate = pickedDateRange.start;
                    checkOutDate = pickedDateRange.end;
                    dateRangeController.text =
                        "${checkInDate?.year}-${checkInDate?.month}-${checkInDate?.day} to "
                        "${checkOutDate?.year}-${checkOutDate?.month}-${checkOutDate?.day}";
                    calculateNumberOfNights();
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a date range';
                }
                return null;
              },
            )),
            if (_numberOfNights != null)
              SizedBox(
                  width: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '$_numberOfNights Nights',
                      style: TextStyle(fontSize: 12),
                    ),
                  ))
          ]),
          Row(children: [
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(children: [
                      SizedBox(
                          width: 90,
                          child: Text(
                            'Adults:',
                            style: TextStyle(fontSize: 16),
                          )),
                      SizedBox(
                          width: 70,
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            value: _numberOfAdults,
                            items: List.generate(5, (index) {
                              int value = index + 1;
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }),
                            onChanged: (value) {
                              _numberOfAdults = value;
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Please select a value";
                              }
                              return null;
                            },
                          ))
                    ]))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(children: [
                      SizedBox(
                          width: 90,
                          child: Text(
                            'Children:',
                            style: TextStyle(fontSize: 16),
                          )),
                      SizedBox(
                          width: 70,
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            value: _numberOfChildren,
                            items: List.generate(5, (index) {
                              int value = index + 1;
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }),
                            onChanged: (value) {
                              _numberOfChildren = value;
                            },
                          ))
                    ]))),
          ]),
          Row(children: [
            Consumer(builder: (context, ref, child) {
              final roomsList = ref.watch(roomListVM);
              return SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    hint: Text('Room'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    value: _roomID?.toString(),
                    items:
                        roomsList.map<DropdownMenuItem<String>>((RoomVM room) {
                      return DropdownMenuItem<String>(
                        value: room.id,
                        child: Text(room.roomNumber.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _roomID = int.parse(value!);
                    },
                  ));
            }),
            Consumer(builder: (context, ref, child) {
              final paymentStatusList = ref.watch(paymentStatusListVM);
              return SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    hint: Text('Payment'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    value: _paymentStatusID?.toString(),
                    items: paymentStatusList.map<DropdownMenuItem<String>>(
                        (PaymentStatusVM status) {
                      return DropdownMenuItem<String>(
                        value: status.id,
                        child: Text(status.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _paymentStatusID = int.parse(value!);
                    },
                  ));
            })
          ]),
          TextFormField(
            controller: noteController,
            decoration: InputDecoration(labelText: 'Note'),
          ),
          TextFormField(
            maxLines: 2,
            controller: specialRequestController,
            decoration: InputDecoration(labelText: 'Special request'),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(
                width: 50,
                child: TextFormField(
                  controller: rateController,
                  decoration: InputDecoration(labelText: 'Rate'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a rate';
                    }
                    return null;
                  },
                ))
          ]),

          // Additional Fields (Adults, Children, Room, Payment Status)
          // Similar structure to the original code...
          SizedBox(height: 20),
          // Submit Button
          Consumer(builder: (context, ref, child) {
            return ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (await widget.onSubmit({
                    'first_name': firstNameController.text,
                    'last_name': lastNameController.text,
                    'check_in': checkInDate?.toIso8601String(),
                    'check_out': checkOutDate?.toIso8601String(),
                    'number_of_nights': _numberOfNights,
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
                    'number_of_days': _numberOfNights,
                    'rate': rateController.text,
                    'property_id': ref.read(selectedPropertyVM),
                    'room_id': _roomID,
                    // Other fields...
                  })) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking edited successfully.')),
                      );
                      Navigator.of(context).pop();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('An error occurred. Please try again.')),
                      );
                    }
                  }
                }
              },
              child: Text('Submit'),
            );
          }),
        ],
      ),
    );
  }
}
