import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/payment_status.vm.dart';
import 'package:flutter_academy/app/courses/view_models/payment_status_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const BookingForm({super.key, required this.onSubmit});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  int? _numberOfAdults;
  int? _numberOfChildren;
  int? _paymentStatusID;
  int? _roomID;
  final TextEditingController noteController = TextEditingController();
  final TextEditingController specialRequestController =
      TextEditingController();
  final TextEditingController checkInController = TextEditingController();
  final TextEditingController checkOutController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  DateTime? checkInDate;
  DateTime? checkOutDate;
  int? _numberOfNights;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    noteController.dispose();
    specialRequestController.dispose();
    checkInController.dispose();
    checkOutController.dispose();
    rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(
                child: TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            )),
            Expanded(
                child: TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ))
          ]),
          Row(children: [
            SizedBox(
                width: 160,
                child: TextFormField(
                  controller: checkInController,
                  decoration: InputDecoration(labelText: 'Check in'),
                  readOnly: true,
                  onTap: () async {
                    checkInDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (checkInDate != null) {
                      setState(() {
                        checkInController.text =
                            "${checkInDate?.year}-${checkInDate?.month}-${checkInDate?.day}";
                      });
                      calculateNumberofNights();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                )),
            SizedBox(
                width: 160,
                child: TextFormField(
                  controller: checkOutController,
                  decoration: InputDecoration(labelText: 'Check out'),
                  readOnly: true,
                  onTap: () async {
                    checkOutDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (checkOutDate != null) {
                      setState(() {
                        checkOutController.text =
                            "${checkOutDate?.year}-${checkOutDate?.month}-${checkOutDate?.day}";
                      });
                      calculateNumberofNights();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                )),
            _numberOfNights != null
                ? Expanded(
                    child: Text('$_numberOfNights Nights',
                        style: TextStyle(fontSize: 10)))
                : Expanded(child: Text(''))
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
          SizedBox(height: 20),
          Consumer(builder: (context, ref, child) {
            return ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (await widget.onSubmit({
                    'first_name': firstNameController.text,
                    'last_name': lastNameController.text,
                    'number_of_adults': _numberOfAdults,
                    'number_of_children': _numberOfChildren ?? 0,
                    'payment_status_id': _paymentStatusID,
                    'note': noteController.text,
                    'special_request': specialRequestController.text,
                    'check_in': checkInController.text,
                    'check_out': checkOutController.text,
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
                  })) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking added successfully.')),
                      );
                      Navigator.of(context).pop();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('An error occured, try again!')),
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

  void calculateNumberofNights() {
    if (checkInDate != null && checkOutDate != null) {
      _numberOfNights = checkOutDate!.difference(checkInDate!).inDays;
    } else {
      _numberOfNights = null;
    }
  }
}
