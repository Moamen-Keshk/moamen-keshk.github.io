import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/staff_management.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/courses/view_models/lists/role_list.vm.dart';

class StaffManagementView extends ConsumerStatefulWidget {
  const StaffManagementView({super.key});

  @override
  ConsumerState<StaffManagementView> createState() =>
      _StaffManagementViewState();
}

class _StaffManagementViewState extends ConsumerState<StaffManagementView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  int? _selectedRoleId;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffVM = ref.watch(staffManagementVM);
    final allowedRoles = ref.watch(roleListVM);

    // Auto-select the first role if the list loads and nothing is selected yet
    if (allowedRoles.isNotEmpty && _selectedRoleId == null) {
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _selectedRoleId = allowedRoles.first.id;
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Staff'),
        automaticallyImplyLeading: false, // Prevents the duplicate back arrow
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  "Send Invitation",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10.0),
                const Text(
                    "An email with an invite code will be sent to the employee."),
                const SizedBox(height: 20.0),

                // --- EMAIL INPUT ---
                TextFormField(
                  controller: _emailController,
                  decoration:
                      const InputDecoration(labelText: "Employee Email"),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // --- ROLE DROPDOWN (Dynamic from Backend) ---
                if (allowedRoles.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Loading roles or you do not have permission to assign roles.",
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                else
                  DropdownButtonFormField<int>(
                    initialValue: _selectedRoleId,
                    decoration: const InputDecoration(labelText: 'Assign Role'),
                    items: allowedRoles.map((roleVM) {
                      return DropdownMenuItem<int>(
                        value: roleVM.id,
                        child: Text(roleVM.name),
                      );
                    }).toList(),
                    onChanged: (int? newRoleId) {
                      setState(() {
                        _selectedRoleId = newRoleId;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a role' : null,
                  ),
                const SizedBox(height: 30.0),

                // --- SUBMIT BUTTON ---
                ElevatedButton(
                  onPressed: (staffVM.isLoading || allowedRoles.isEmpty)
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate() &&
                              _selectedRoleId != null) {
                            final messenger = ScaffoldMessenger.of(context);

                            // Get current property ID from your global state
                            final propertyId = ref.read(selectedPropertyVM);
                            if (propertyId == null) return;

                            bool success =
                                await ref.read(staffManagementVM).sendInvite(
                                      propertyId: propertyId,
                                      email: _emailController.text.trim(),
                                      roleId: _selectedRoleId!,
                                    );

                            if (!mounted) return;

                            if (success) {
                              messenger.showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Invitation sent successfully!'),
                                    backgroundColor: Colors.green),
                              );
                              _emailController.clear();
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                    content: Text(staffVM.error),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  child: staffVM.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white))
                      : const Text("Send Invite"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
