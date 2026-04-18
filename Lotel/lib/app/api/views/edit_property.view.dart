import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/api/view_models/category.vm.dart';
import 'package:lotel_pms/app/api/view_models/property.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/category_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/floor_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/property_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/room.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/amenity_list.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/model/room.model.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<int, int> roomsCategoryMapping = {};
Map<int, String> roomMapping = {};
Map<int, String> categoryMapping = {};
const Map<int, String> propertyStatusOptions = {
  1: 'Open',
  2: 'Pre-Open',
  3: 'Hold',
  4: 'Closed',
  5: 'Maintain',
};

class EditPropertyView extends ConsumerStatefulWidget {
  const EditPropertyView({super.key});

  @override
  ConsumerState<EditPropertyView> createState() => _EditPropertyViewState();
}

class _EditPropertyViewState extends ConsumerState<EditPropertyView> {
  @override
  Widget build(BuildContext context) {
    final property = ref.watch(selectedPropertyProvider);
    final isCompact = context.showCompactLayout;

    if (property == null) {
      return const Center(child: Text("No property selected."));
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            isScrollable: isCompact,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: "Basic Details"),
              Tab(text: "Amenities"),
              Tab(text: "Floors"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBasicDetailsTab(property),
                _AmenitiesTab(property: property),
                _buildFloorsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: BASIC DETAILS & DANGER ZONE
  // ==========================================
  Widget _buildBasicDetailsTab(PropertyVM property) {
    final isCompact = context.showCompactLayout;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Basic Details Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text("Edit"),
                              onPressed: () => _showEditPropertyDialog(
                                  context, ref, property),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                property.name,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text("Edit"),
                              onPressed: () => _showEditPropertyDialog(
                                context,
                                ref,
                                property,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 8),
                  Text(
                    property.address,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Divider(height: 30),
                  _detailRow(
                    const Icon(Icons.phone, size: 20, color: Colors.grey),
                    property.phoneNumber.isNotEmpty
                        ? property.phoneNumber
                        : 'No phone set',
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    const Icon(Icons.email, size: 20, color: Colors.grey),
                    property.email.isNotEmpty ? property.email : 'No email set',
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    const Icon(Icons.public, size: 20, color: Colors.grey),
                    '${property.timezone} • ${property.currency} • ${property.taxRate.toStringAsFixed(2)}% tax',
                    expanded: true,
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    const Icon(Icons.schedule, size: 20, color: Colors.grey),
                    'Check-in ${property.defaultCheckInTime} • Check-out ${property.defaultCheckOutTime}',
                    expanded: true,
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    const Icon(Icons.flag, size: 20, color: Colors.grey),
                    'Status: ${property.status}',
                    expanded: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 👉 THE DANGER ZONE
          Card(
            color: Colors.red[50],
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Danger Zone",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Deleting this property will permanently remove all floors, rooms, bookings, and staff access associated with it. This action cannot be undone.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text("Delete Property Entirely"),
                    onPressed: () => _confirmDeleteProperty(context, property),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: FLOORS
  // ==========================================
  Widget _buildFloorsTab() {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < ScreenSizes.md
        ? 1
        : width < ScreenSizes.xl
            ? 2
            : 3;

    return Column(
      children: [
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final floors = ref.watch(floorListVM);
              roomsCategoryMapping = setRoomCategory(
                  ref.read(roomListVM), ref.read(categoryListVM));

              if (floors.isEmpty) {
                return const Center(child: Text("No floors configured yet."));
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: crossAxisCount == 1 ? 1.3 : 1,
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
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: floors[index]
                                      .rooms
                                      .map<Widget>((Room room) {
                                    final categoryName = categoryMapping[
                                            roomsCategoryMapping[
                                                    int.parse(room.id)] ??
                                                -1] ??
                                        'Undefined Category';

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: crossAxisCount == 1
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    room.roomNumber.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        height: 1.0),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    categoryName,
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        height: 1.0),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: 90,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    room.roomNumber.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        height: 1.0),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      categoryName,
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          height: 1.0),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
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
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
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
          padding: const EdgeInsets.all(10),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("New Floor"),
            onPressed: () {
              ref.read(routerProvider).push('new_floor');
            },
          ),
        )
      ],
    );
  }

  Widget _detailRow(Widget icon, String text, {bool expanded = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 12),
        if (expanded) Expanded(child: Text(text)) else Text(text),
      ],
    );
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  Future<void> _showEditPropertyDialog(
      BuildContext context, WidgetRef ref, PropertyVM property) async {
    final nameController = TextEditingController(text: property.name);
    final addressController = TextEditingController(text: property.address);
    final phoneController = TextEditingController(text: property.phoneNumber);
    final emailController = TextEditingController(text: property.email);
    final timezoneController = TextEditingController(text: property.timezone);
    final currencyController = TextEditingController(text: property.currency);
    final taxRateController =
        TextEditingController(text: property.taxRate.toStringAsFixed(2));
    final checkInController =
        TextEditingController(text: property.defaultCheckInTime);
    final checkOutController =
        TextEditingController(text: property.defaultCheckOutTime);
    int selectedStatusId = property.statusId ?? 1;

    return showDialog(
      context: context,
      builder: (dialogContext) {
        Future<void> pickTime(TextEditingController controller) async {
          final parts = controller.text.split(':');
          final initialTime = TimeOfDay(
            hour: int.tryParse(parts.first) ?? 12,
            minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
          );
          final selected = await showTimePicker(
            context: dialogContext,
            initialTime: initialTime,
          );
          if (selected != null) {
            controller.text =
                '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Property Details"),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.showCompactLayout ? 320 : 480,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: "Property Name"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: "Address"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        decoration:
                            const InputDecoration(labelText: "Phone Number"),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: timezoneController,
                        decoration:
                            const InputDecoration(labelText: "Timezone"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: currencyController,
                        decoration:
                            const InputDecoration(labelText: "Currency"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: taxRateController,
                        decoration:
                            const InputDecoration(labelText: "Tax Rate %"),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        initialValue: selectedStatusId,
                        decoration: const InputDecoration(labelText: "Status"),
                        items: propertyStatusOptions.entries
                            .map((entry) => DropdownMenuItem<int>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedStatusId = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      ResponsiveFormRow(
                        children: [
                          TextField(
                            controller: checkInController,
                            readOnly: true,
                            decoration: const InputDecoration(
                                labelText: "Default Check-In"),
                            onTap: () => pickTime(checkInController),
                          ),
                          TextField(
                            controller: checkOutController,
                            readOnly: true,
                            decoration: const InputDecoration(
                                labelText: "Default Check-Out"),
                            onTap: () => pickTime(checkOutController),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedData = {
                      'name': nameController.text,
                      'address': addressController.text,
                      'phone_number': phoneController.text,
                      'email': emailController.text,
                      'timezone': timezoneController.text,
                      'currency': currencyController.text,
                      'tax_rate':
                          double.tryParse(taxRateController.text) ?? 0.0,
                      'status_id': selectedStatusId,
                      'default_check_in_time': checkInController.text,
                      'default_check_out_time': checkOutController.text,
                    };

                    final propertyId = int.tryParse(property.id);
                    if (propertyId == null) return;

                    final success = await ref
                        .read(propertyListVM.notifier)
                        .editProperty(propertyId, updatedData);

                    if (!context.mounted) return;

                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Property updated successfully.'
                            : 'Failed to save property changes.'),
                      ),
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 👉 HIGH-FRICTION CONFIRMATION DIALOG
  Future<void> _confirmDeleteProperty(
      BuildContext context, PropertyVM property) async {
    final confirmController = TextEditingController();
    bool isMatched = false;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Delete Property?',
                style: TextStyle(color: Colors.red)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    "This action is irreversible. All data will be lost."),
                const SizedBox(height: 16),
                Text('Please type "${property.name}" to confirm:'),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmController,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  onChanged: (val) {
                    setState(() {
                      isMatched = val.trim() == property.name;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: isMatched ? () => Navigator.of(ctx).pop(true) : null,
                child: const Text('I understand, delete it',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );

    if (confirm == true) {
      final propertyId = int.tryParse(property.id);
      if (propertyId != null) {
        final success =
            await ref.read(propertyListVM.notifier).deleteProperty(propertyId);

        if (!mounted || !context.mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Property deleted permanently.'),
                backgroundColor: Colors.red),
          );
          // 1. Reset the global selected property
          ref.read(selectedPropertyVM.notifier).clear();
          // 2. Return to dashboard
          ref.read(routerProvider).replaceAllWith('dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete property.')),
          );
        }
      }
    }
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ==========================================
// TAB 2: AMENITIES (Private Widget)
// ==========================================
class _AmenitiesTab extends ConsumerStatefulWidget {
  final PropertyVM property;

  const _AmenitiesTab({required this.property});

  @override
  ConsumerState<_AmenitiesTab> createState() => _AmenitiesTabState();
}

class _AmenitiesTabState extends ConsumerState<_AmenitiesTab> {
  final List<String> _selectedAmenityIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 👉 Pre-fill the selected IDs based on what the backend returned
    if (widget.property.amenities.isNotEmpty) {
      for (var amenity in widget.property.amenities) {
        _selectedAmenityIds.add(amenity.id);
      }
    }
  }

  Future<void> _saveAmenities() async {
    setState(() => _isLoading = true);

    final propertyId = int.tryParse(widget.property.id);
    if (propertyId != null) {
      final success = await ref.read(propertyListVM.notifier).editProperty(
          propertyId,
          // Sending the integers to backend
          {
            'amenity_ids':
                _selectedAmenityIds.map((id) => int.parse(id)).toList()
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(success ? 'Amenities updated!' : 'Update failed.')),
        );
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final availableAmenities = ref.watch(amenityListVM);

    if (availableAmenities.isEmpty) {
      return const Center(child: Text("No amenities available globally."));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: availableAmenities.length,
            itemBuilder: (context, index) {
              final amenity = availableAmenities[index];
              final isSelected = _selectedAmenityIds.contains(amenity.id);

              return CheckboxListTile(
                title: Text(amenity.name),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedAmenityIds.add(amenity.id);
                    } else {
                      _selectedAmenityIds.remove(amenity.id);
                    }
                  });
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Amenities"),
                  onPressed: _saveAmenities,
                ),
        )
      ],
    );
  }
}
