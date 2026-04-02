import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/app/courses/view_models/property.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/category_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/floor_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/property_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<int, int> roomsCategoryMapping = {};
Map<int, String> roomMapping = {};
Map<int, String> categoryMapping = {};

class EditPropertyView extends ConsumerStatefulWidget {
  const EditPropertyView({super.key});

  @override
  ConsumerState<EditPropertyView> createState() => _EditPropertyViewState();
}

class _EditPropertyViewState extends ConsumerState<EditPropertyView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---> NEW: Property Details Header Card <---
        Consumer(
          builder: (context, ref, child) {
            // Adjust 'selectedPropertyProvider' to match your actual exported provider name
            final property = ref.watch(selectedPropertyProvider);

            if (property == null) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.all(10.0),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showEditPropertyDialog(context, ref, property),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.address,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(property.phoneNumber.isNotEmpty
                            ? property.phoneNumber
                            : 'No phone set'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(property.email.isNotEmpty
                            ? property.email
                            : 'No email set'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // EXISTING: Floors GridView
        Expanded(
          // Changed from SizedBox(height: 700) to Expanded for better responsiveness
          child: Consumer(
            builder: (context, ref, child) {
              final floors = ref.watch(floorListVM);
              roomsCategoryMapping = setRoomCategory(
                  ref.read(roomListVM), ref.read(categoryListVM));

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1,
                ),
                padding: const EdgeInsets.all(10.0),
                itemCount: floors.length,
                itemBuilder: (context, index) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(floorToEditVM.notifier)
                              .updateFloor(floors[index]);
                          ref.read(routerProvider).push('edit_floor');
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                'Floor ${floors[index].number.toString()}',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      floors[index].rooms.map<Row>((Room room) {
                                    return Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 2),
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: 90,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              room.roomNumber.toString(),
                                              style: const TextStyle(
                                                  fontSize: 16, height: 1.0),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 2),
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                color: Colors.blue[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                categoryMapping[
                                                        roomsCategoryMapping[
                                                                int.parse(
                                                                    room.id)] ??
                                                            -1] ??
                                                    'Undefined Category',
                                                style: const TextStyle(
                                                    fontSize: 13, height: 1.0),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            Center(
                              child: IconButton(
                                onPressed: () async {
                                  final confirmed =
                                      await showDeleteConfirmationDialog(
                                          context);
                                  if (!confirmed) return;

                                  final floorId =
                                      int.tryParse(floors[index].id);
                                  if (floorId == null) return;

                                  final success = await ref
                                      .read(floorListVM.notifier)
                                      .deleteFloor(floorId);

                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Floor deleted.")),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.clear),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: ElevatedButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () {
              ref.read(routerProvider).push('new_floor');
            },
            child: const Text("New Floor"),
          ),
        )
      ],
    );
  }

  // ---> NEW: Edit Property Details Dialog <---
  Future<void> _showEditPropertyDialog(
      BuildContext context, WidgetRef ref, PropertyVM property) async {
    final nameController = TextEditingController(text: property.name);
    final addressController = TextEditingController(text: property.address);
    final phoneController = TextEditingController(text: property.phoneNumber);
    final emailController = TextEditingController(text: property.email);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Property Details"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Property Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  'name': nameController.text,
                  'address': addressController.text,
                  'phone_number': phoneController.text,
                  'email': emailController.text,
                };

                final propertyId = int.tryParse(property.id);
                if (propertyId == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to update property.'),
                      ),
                    );
                  }
                  return;
                }

                final success = await ref
                    .read(propertyListVM.notifier)
                    .editProperty(propertyId, updatedData);

                if (!success) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to save property changes.'),
                      ),
                    );
                  }
                  return;
                }

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Property updated successfully.'),
                    ),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Map<int, int> setRoomCategory(
      List<RoomVM> rooms, List<CategoryVM> categories) {
    categoryMapping = {
      for (var category in categories) int.parse(category.id): category.name
    };

    Map<int, int> categoryMap = {};
    roomMapping = {
      for (var room in rooms) int.parse(room.id): room.roomNumber.toString()
    };

    for (var room in rooms) {
      categoryMap[int.parse(room.id)] = room.categoryId;
    }

    return categoryMap;
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Floor"),
            content: const Text("Are you sure you want to delete this floor?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text("Delete"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}
