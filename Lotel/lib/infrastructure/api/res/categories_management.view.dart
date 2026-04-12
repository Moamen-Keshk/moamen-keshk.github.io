import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/api/view_models/lists/category_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/category.vm.dart'; // 👉 Needed for typing the edit dialog

class CategoriesManagementView extends ConsumerStatefulWidget {
  const CategoriesManagementView({super.key});

  @override
  ConsumerState<CategoriesManagementView> createState() =>
      _CategoriesManagementViewState();
}

class _CategoriesManagementViewState
    extends ConsumerState<CategoriesManagementView> {
  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListVM);
    final categoryVM = ref.read(categoryListVM.notifier);

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
                    'Manage Room Types',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('New Room Type'),
                    onPressed: () => _showAddCategoryDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: categories.isEmpty
                    ? const Center(
                        child: Text(
                          "No room types found. Add some to get started!",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
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
                                child: Icon(Icons.bed,
                                    color: Theme.of(context).primaryColor),
                              ),
                              title: Text(
                                category.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Capacity: ${category.capacity} ${category.description.isNotEmpty ? ' • ${category.description}' : ''}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // 👉 CHANGED: Using a Row to show both Edit and Delete
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blueAccent),
                                    onPressed: () => _showEditCategoryDialog(
                                        context, ref, category),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title:
                                                  const Text('Delete Room Type'),
                                              content: Text(
                                                  'Are you sure you want to delete "${category.name}" for this property?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx)
                                                          .pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  onPressed: () =>
                                                      Navigator.of(ctx)
                                                          .pop(true),
                                                  child: const Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                          ) ??
                                          false;

                                      if (confirm && context.mounted) {
                                        final success = await categoryVM
                                            .deleteCategory(category.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(success
                                                    ? 'Room type deleted.'
                                                    : 'Failed to delete room type (it may be in use).')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
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
  // 👉 ADD CATEGORY POP-UP DIALOG
  // ==========================================
  Future<void> _showAddCategoryDialog(
      BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    int capacity = 1;
    String? description;
    bool isLoading = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Room Type"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Room Type Name *',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Double Room, Suite',
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
                          labelText: 'Base Capacity (Guests) *',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 2',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: '1',
                        onChanged: (val) => capacity = int.tryParse(val) ?? 1,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (int.tryParse(val) == null) {
                            return 'Must be a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          border: OutlineInputBorder(),
                          hintText: 'A short description of this room type...',
                        ),
                        maxLines: 2,
                        maxLength: 64,
                        onChanged: (val) => description =
                            val.trim().isEmpty ? null : val.trim(),
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
                                .read(categoryListVM.notifier)
                                .addCategory(
                                  name: name.trim(),
                                  capacity: capacity,
                                  description: description,
                                );

                            if (!context.mounted) return;

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? "Room type added successfully!"
                                    : "Failed to add room type."),
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

  // ==========================================
  // 👉 EDIT CATEGORY POP-UP DIALOG
  // ==========================================
  Future<void> _showEditCategoryDialog(
      BuildContext context, WidgetRef ref, CategoryVM category) async {
    final formKey = GlobalKey<FormState>();

    // Initialize with existing data
    String name = category.name;
    int capacity = category.capacity;
    String? description = category.description;
    bool isLoading = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Room Type"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: name,
                        decoration: const InputDecoration(
                          labelText: 'Room Type Name *',
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Required'
                            : null,
                        onChanged: (val) => name = val,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: capacity.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Base Capacity (Guests) *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            capacity = int.tryParse(val) ?? capacity,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (int.tryParse(val) == null) {
                            return 'Must be a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: description,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        maxLength: 64,
                        onChanged: (val) => description =
                            val.trim().isEmpty ? null : val.trim(),
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
                  label: Text(isLoading ? "Saving..." : "Save Updates"),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => isLoading = true);

                            final success = await ref
                                .read(categoryListVM.notifier)
                                .editCategory(
                                  category.id,
                                  name: name.trim(),
                                  capacity: capacity,
                                  description: description,
                                );

                            if (!context.mounted) return;

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? "Room type updated successfully!"
                                    : "Failed to update room type."),
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
