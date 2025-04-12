import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room_list.vm.dart';
import 'package:flutter_academy/app/courses/widgets/room_form.widget.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditFloorView extends ConsumerStatefulWidget {
  const EditFloorView({super.key});

  @override
  ConsumerState<EditFloorView> createState() => _EditFloorViewState();
}

class _EditFloorViewState extends ConsumerState<EditFloorView> {
  final _formKey = GlobalKey<FormState>();

  String? floorId;
  int? floorSelectedValue;
  List<Room> updatedRooms = [];
  Map<String, int> roomsCategoryMapping = {};
  final Map<String, String> _roomsNumbers = {};
  final List<String?> selectedValues = [];
  int dropdownCount = 0;

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
    final categories = ref.watch(categoryListVM);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildSectionCard(
              title: "🏢 Floor Info",
              child: TextFormField(
                initialValue: floorSelectedValue?.toString(),
                decoration: _inputDecoration("Floor No."),
                style: const TextStyle(fontSize: 13),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter floor number'
                    : null,
                onSaved: (value) =>
                    floorSelectedValue = int.tryParse(value ?? ''),
              ),
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: "📦 Existing Rooms",
              child: Column(
                children: updatedRooms.map((room) {
                  return RoomFormRow(
                    room: room,
                    categoryId: roomsCategoryMapping[room.id]?.toString(),
                    categories: categories,
                    onCategoryChanged: (newVal) {
                      setState(() {
                        roomsCategoryMapping[room.id] = int.parse(newVal);
                      });
                    },
                    onRoomDeleted: () async {
                      final deleted = await ref
                          .read(roomListVM.notifier)
                          .deleteRoom(int.parse(room.id));
                      if (deleted && context.mounted) {
                        setState(() =>
                            updatedRooms.removeWhere((r) => r.id == room.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Room deleted")));
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: "➕ Add New Rooms",
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: dropdownCount,
                    decoration: _inputDecoration("No. of Rooms"),
                    style: const TextStyle(fontSize: 13),
                    isExpanded: true,
                    items: List.generate(10, (index) {
                      final label = index == 0 ? "None" : "$index";
                      return DropdownMenuItem(value: index, child: Text(label));
                    }),
                    onChanged: (value) =>
                        setState(() => _updateDropdownCount(value ?? 0)),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dropdownCount,
                    itemBuilder: (context, index) {
                      return NewRoomRow(
                        index: index,
                        categories: categories,
                        onRoomSaved: (val) => _roomsNumbers['$index'] = val,
                        selectedValue: selectedValues.length > index
                            ? selectedValues[index]
                            : null,
                        onCategorySelected: (val) =>
                            setState(() => selectedValues[index] = val),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _submitForm(context),
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (floorId == null || floorSelectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing floor ID or number.')));
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
    await ref.read(floorListVM.notifier).fetchFloors();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(success
                ? 'Floor edited successfully.'
                : 'An error occurred, try again!')),
      );
      if (success) {
        setState(() {
          dropdownCount = 0;
          _roomsNumbers.clear();
          selectedValues.clear();
        });
        routerDelegate.go('edit_property');
      }
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
      selectedValues.removeRange(count, selectedValues.length);
    }
  }

  Map<String, int> setRoomCategory(
      List<Room> rooms, List<CategoryVM> categories) {
    Map<String, int> categoryMap = {};
    for (var room in rooms) {
      categoryMap[room.id] = room.categoryId;
    }
    return categoryMap;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          child,
        ]),
      ),
    );
  }
}
