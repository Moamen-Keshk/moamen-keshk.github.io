import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/lists/amenity_list.vm.dart';

class AmenitiesManagementView extends ConsumerStatefulWidget {
  const AmenitiesManagementView({super.key});

  @override
  ConsumerState<AmenitiesManagementView> createState() =>
      _AmenitiesManagementViewState();
}

class _AmenitiesManagementViewState
    extends ConsumerState<AmenitiesManagementView> {
  @override
  Widget build(BuildContext context) {
    final amenities = ref.watch(amenityListVM);
    final amenityVM = ref.read(amenityListVM.notifier);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Amenities',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('New Amenity'),
                    // 👉 CHANGED: Now calls the dialog instead of router.push
                    onPressed: () => _showAddAmenityDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: amenities.isEmpty
                    ? const Center(
                        child: Text(
                          "No amenities found. Add some to get started!",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: amenities.length,
                        itemBuilder: (context, index) {
                          final amenity = amenities[index];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.check_circle_outline,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: Text(
                                amenity.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete Amenity'),
                                          content: Text(
                                              'Are you sure you want to globally delete "${amenity.name}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;

                                  if (confirm && context.mounted) {
                                    final success = await amenityVM
                                        .deleteAmenity(amenity.id);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(success
                                              ? 'Amenity deleted.'
                                              : 'Failed to delete amenity.'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 👉 ADD AMENITY POP-UP DIALOG
  // ==========================================
  Future<void> _showAddAmenityDialog(
      BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String? icon;
    bool isLoading = false;

    return showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing by tapping outside while loading
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Amenity"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Amenity Name *',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Free WiFi, Swimming Pool',
                        ),
                        autofocus: true,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Required'
                            : null,
                        onChanged: (val) => name = val,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Icon Identifier (optional)',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., wifi, pool',
                        ),
                        onChanged: (val) =>
                            icon = val.trim().isEmpty ? null : val.trim(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(isLoading ? "Saving..." : "Save"),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => isLoading = true);

                            final success = await ref
                                .read(amenityListVM.notifier)
                                .addAmenity(
                                  name: name.trim(),
                                  icon: icon,
                                );

                            if (!context.mounted) return;

                            Navigator.of(context).pop(); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? "Amenity added successfully!"
                                    : "Failed to add amenity."),
                                backgroundColor:
                                    success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
