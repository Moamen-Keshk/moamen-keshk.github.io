import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewFloorView extends ConsumerStatefulWidget {
  const NewFloorView({super.key});

  @override
  ConsumerState<NewFloorView> createState() => _NewFloorViewState();
}

class _NewFloorViewState extends ConsumerState<NewFloorView> {
  final _formKey = GlobalKey<FormState>();

  List<DropdownData> floorDropdownItems = [
    DropdownData(-1, 'B'),
    DropdownData(0, 'G'),
    DropdownData(1, '1'),
    DropdownData(2, '2'),
    DropdownData(3, '3'),
    DropdownData(4, '4'),
    DropdownData(5, '5'),
    DropdownData(6, '6'),
    DropdownData(7, '7'),
    DropdownData(8, '8'),
    DropdownData(9, '9')
  ];

  final Map<String, String> _roomsNumbers = {};
  final List<DropdownData> _roomsDropdownItems = [
    DropdownData(1, '1'),
    DropdownData(2, '2'),
    DropdownData(3, '3'),
    DropdownData(4, '4'),
    DropdownData(5, '5'),
    DropdownData(6, '6'),
    DropdownData(7, '7'),
    DropdownData(8, '8'),
    DropdownData(9, '9'),
    DropdownData(0, 'None')
  ];

  int? floorSelectedValue;
  int? floorInitialSelection;
  int? roomsSelectedValue = 0;
  int? roomsInitialSelection;
  Map<String, String>? categorySelectedValue = {};
  String? categoryInitialSelection;
  String? categorySelected;
  int dropdownCount = 0;
  List<String?> selectedValues = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              Text(
                "New Floor",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20.0),
              DropdownMenu<int>(
                  initialSelection: floorInitialSelection,
                  requestFocusOnTap: true,
                  label:
                      const Text('Floor No.', style: TextStyle(fontSize: 13)),
                  onSelected: (int? value) {
                    setState(() {
                      floorSelectedValue = value;
                      return;
                    });
                  },
                  dropdownMenuEntries: floorDropdownItems
                      .map<DropdownMenuEntry<int>>((DropdownData data) {
                    return DropdownMenuEntry<int>(
                      value: data.value,
                      label: data.label,
                      style: MenuItemButton.styleFrom(),
                    );
                  }).toList()),
              const SizedBox(height: 20.0),
              DropdownMenu<int>(
                  initialSelection: roomsInitialSelection,
                  requestFocusOnTap: true,
                  label: const Text('No. of Rooms',
                      style: TextStyle(fontSize: 13)),
                  onSelected: (int? newValue) {
                    setState(() {
                      _updateDropdownCount(newValue!);
                    });
                  },
                  dropdownMenuEntries: _roomsDropdownItems
                      .map<DropdownMenuEntry<int>>((DropdownData data) {
                    return DropdownMenuEntry<int>(
                      value: data.value,
                      label: data.label,
                      style: MenuItemButton.styleFrom(),
                    );
                  }).toList()),
              const SizedBox(height: 20.0),
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: dropdownCount,
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                        child: Row(
                      children: [
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Room No.',
                                      labelStyle: TextStyle(fontSize: 13)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter room number';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _roomsNumbers[value!] = value;
                                  },
                                ))),
                        Consumer(builder: (context, ref, child) {
                          final categories = ref.watch(categoryListVM);
                          return Expanded(
                              child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.grey, width: 1)),
                            child: DropdownButton<String>(
                                value: selectedValues[index],
                                hint: Text("Select category"),
                                isExpanded: true,
                                underline: SizedBox(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedValues[index] = newValue;
                                  });
                                },
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.black),
                                items: categories.map<DropdownMenuItem<String>>(
                                    (CategoryVM category) {
                                  return DropdownMenuItem<String>(
                                    value: category.id,
                                    child: Text(category.name),
                                  );
                                }).toList()),
                          ));
                        })
                      ],
                    ));
                  }),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: const Text("Add Floor"),
              )
            ],
          ),
        ));
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final selectedPropertyID = ref.read(selectedPropertyVM) ?? 0;
      if (await ref.read(floorListVM.notifier).addToFloors(
          number: floorSelectedValue!,
          propertyId: selectedPropertyID,
          rooms: createRooms())) {
        await ref.read(roomListVM.notifier).fetchRooms();
        await ref.read(floorListVM.notifier).fetchFloors();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Floor added successfully.')),
          );
        }
        routerDelegate.push('edit_property');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occured, try again!')),
          );
        }
      }
    }
    // Handle form submission here (e.g., send data to a server or update UI)
  }

  List<Room> createRooms() {
    final selectedPropertyID = ref.read(selectedPropertyVM) ?? 0;
    final List<Room> roomsList = [];
    int i = -1;
    _roomsNumbers.forEach((key, value) {
      i++;
      roomsList.add(Room(
          roomNumber: int.parse(key),
          propertyId: selectedPropertyID,
          categoryId: int.parse(selectedValues[i]!),
          id: ''));
    });
    return roomsList;
  }

  void _updateDropdownCount(int count) {
    dropdownCount = count;
    // Resize the selectedValues list to match the dropdownCount
    selectedValues = List<String?>.filled(count, null);
  }
}

class DropdownData {
  final int value;
  final String label;
  DropdownData(this.value, this.label);
}

class RoomsDropdownData {
  final String roomNumber;
  final String categoryId;
  RoomsDropdownData(this.roomNumber, this.categoryId);
}
