// Refactored EditFloorView with null safety, validation, and improved state handling
import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Map<String, String> _roomsNumbers = {};
final List<DropdownData> _roomsDropdownItems = List.generate(
  10,
  (index) => DropdownData(index, index == 0 ? 'None' : '$index'),
);

List<Room> updatedRooms = [];
String? floorId;
int? floorSelectedValue;
int dropdownCount = 0;
List<String?> selectedValues = [];
Map<int, int> roomsCategoryMapping = {};
Map<int, String> roomMapping = {};
Map<int, String> categoryMapping = {};

class EditFloorView extends ConsumerStatefulWidget {
  const EditFloorView({super.key});

  @override
  ConsumerState<EditFloorView> createState() => _EditFloorViewState();
}

class _EditFloorViewState extends ConsumerState<EditFloorView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final floor = ref.read(floorToEditVM);
    if (floor != null) {
      floorId = floor.id;
      floorSelectedValue = floor.number;
      updatedRooms = floor.rooms;
      roomsCategoryMapping =
          setRoomCategory(floor.rooms, ref.read(categoryListVM));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: 700,
            child: Consumer(
              builder: (context, ref, child) {
                final floor = ref.watch(floorToEditVM);
                final categories = ref.watch(categoryListVM);

                if (floor == null) {
                  return const Center(child: Text("No floor data available."));
                }

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: TextFormField(
                            initialValue: floor.number.toString(),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Floor No.',
                              labelStyle: TextStyle(fontSize: 13),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter floor number';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              floorSelectedValue = int.tryParse(value ?? '');
                            },
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: updatedRooms.map<Row>((room) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      height: 35,
                                      child: TextFormField(
                                        initialValue:
                                            room.roomNumber.toString(),
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Room No.',
                                          labelStyle: TextStyle(fontSize: 13),
                                        ),
                                        validator: (value) =>
                                            value == null || value.isEmpty
                                                ? 'Enter room number'
                                                : null,
                                        onSaved: (value) {
                                          room.roomNumber =
                                              int.tryParse(value ?? '') ??
                                                  room.roomNumber;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: roomsCategoryMapping[
                                                room.roomNumber]
                                            .toString(),
                                        hint: const Text("Select category"),
                                        isExpanded: true,
                                        onChanged: (newValue) {
                                          setState(() {
                                            roomsCategoryMapping[
                                                    room.roomNumber] =
                                                int.parse(newValue!);
                                          });
                                        },
                                        items: categories
                                            .map((cat) =>
                                                DropdownMenuItem<String>(
                                                  value: cat.id,
                                                  child: Text(cat.name),
                                                ))
                                            .toList(),
                                        validator: (value) => value == null
                                            ? 'Select category'
                                            : null,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.clear)),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const Text('Add Rooms', style: TextStyle(fontSize: 13)),
                        DropdownMenu<int>(
                          initialSelection: dropdownCount,
                          label: const Text('No. of Rooms',
                              style: TextStyle(fontSize: 13)),
                          onSelected: (value) =>
                              setState(() => _updateDropdownCount(value ?? 0)),
                          dropdownMenuEntries: _roomsDropdownItems
                              .map((data) => DropdownMenuEntry<int>(
                                    value: data.value,
                                    label: data.label,
                                  ))
                              .toList(),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: dropdownCount,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Room No.',
                                        labelStyle: TextStyle(fontSize: 13),
                                      ),
                                      validator: (value) =>
                                          value == null || value.isEmpty
                                              ? 'Enter room number'
                                              : null,
                                      onSaved: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          _roomsNumbers['$index'] = value;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedValues.length > index
                                        ? selectedValues[index]
                                        : null,
                                    hint: const Text("Select category"),
                                    isExpanded: true,
                                    onChanged: (value) => setState(
                                        () => selectedValues[index] = value),
                                    items: categories
                                        .map((cat) => DropdownMenuItem<String>(
                                              value: cat.id,
                                              child: Text(cat.name),
                                            ))
                                        .toList(),
                                    validator: (value) => value == null
                                        ? 'Select category'
                                        : null,
                                  ),
                                )
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _submitForm(context),
            child: const Text("Edit Floor"),
          )
        ],
      ),
    );
  }

  void _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (floorId == null || floorSelectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing floor ID or number.')),
      );
      return;
    }

    final selectedPropertyID = ref.read(selectedPropertyVM) ?? 0;
    final success = await ref.read(floorListVM.notifier).editFloor(
      int.parse(floorId!),
      {
        'floor_number': floorSelectedValue!,
        'property_id': selectedPropertyID,
        'rooms': createAppendRooms(selectedPropertyID.toString()),
      },
    );

    await ref.read(roomListVM.notifier).fetchRooms();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(success
                ? 'Floor edited successfully.'
                : 'An error occurred, try again!')),
      );
      if (success) routerDelegate.go('edit_property');
    }
  }

  List<Map<String, dynamic>> createAppendRooms(String propertyId) {
    final roomsList = updatedRooms.map((r) => r.toMap()).toList();
    _roomsNumbers.forEach((indexStr, roomNumberStr) {
      final index = int.tryParse(indexStr);
      if (index != null && index < selectedValues.length) {
        final selectedCategoryId = selectedValues[index];
        if (selectedCategoryId != null && roomNumberStr.isNotEmpty) {
          roomsList.add(Room(
            roomNumber: int.parse(roomNumberStr),
            propertyId: int.parse(propertyId),
            categoryId: int.parse(selectedCategoryId),
            id: '',
          ).toMap());
        }
      }
    });
    return roomsList;
  }

  void _updateDropdownCount(int count) {
    dropdownCount = count;
    _roomsNumbers.clear();
    if (count > selectedValues.length) {
      selectedValues
          .addAll(List<String?>.filled(count - selectedValues.length, null));
    } else {
      selectedValues = selectedValues.sublist(0, count);
    }
  }

  Map<int, int> setRoomCategory(List<Room> rooms, List<CategoryVM> categories) {
    categoryMapping = {
      for (var category in categories) int.parse(category.id): category.name
    };
    Map<int, int> categoryMap = {};
    roomMapping = {
      for (var room in rooms) room.roomNumber: room.roomNumber.toString()
    };
    for (var room in rooms) {
      categoryMap[room.roomNumber] = room.categoryId;
    }
    return categoryMap;
  }
}

class DropdownData {
  final int value;
  final String label;
  DropdownData(this.value, this.label);
}
