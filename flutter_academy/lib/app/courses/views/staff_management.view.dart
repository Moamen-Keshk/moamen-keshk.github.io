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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStaff();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _loadStaff() {
    final propertyId = ref.read(selectedPropertyVM);
    if (propertyId != null) {
      ref.read(staffManagementVM).fetchStaff(propertyId);
    }
  }

  // Dialog for Inviting Staff
  void _showInviteDialog(
      BuildContext context, int propertyId, List<dynamic> allowedRoles) {
    if (allowedRoles.isNotEmpty && _selectedRoleId == null) {
      _selectedRoleId = allowedRoles.first.id;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Invite Staff'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "An email with an invite code will be sent to the employee."),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        labelText: "Employee Email",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (allowedRoles.isEmpty)
                    const Text("You do not have permission to assign roles.",
                        style: TextStyle(color: Colors.red))
                  else
                    DropdownButtonFormField<int>(
                      initialValue: _selectedRoleId,
                      decoration: const InputDecoration(
                          labelText: 'Assign Role',
                          border: OutlineInputBorder()),
                      items: allowedRoles.map((role) {
                        return DropdownMenuItem<int>(
                          value: role.id,
                          child: Text(role.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        _selectedRoleId = val;
                      },
                      validator: (value) =>
                          value == null ? 'Please select a role' : null,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() &&
                    _selectedRoleId != null) {
                  final success = await ref.read(staffManagementVM).sendInvite(
                        propertyId: propertyId,
                        email: _emailController.text.trim(),
                        roleId: _selectedRoleId!,
                      );

                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  final messenger = ScaffoldMessenger.of(ctx);

                  if (success) {
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Invitation sent!'),
                        backgroundColor: Colors.green));
                    _emailController.clear();
                  } else {
                    messenger.showSnackBar(SnackBar(
                        content: Text(ref.read(staffManagementVM).error),
                        backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text("Send Invite"),
            ),
          ],
        );
      },
    );
  }

  // Dialog for Editing Role
  void _showEditRoleDialog(BuildContext context, int propertyId,
      StaffMember member, List<dynamic> allowedRoles) {
    int? editRoleId = member.roleId;

    // Check if the user is allowed to assign the role they currently have, if not default to first assignable
    if (!allowedRoles.any((r) => r.id == editRoleId) &&
        allowedRoles.isNotEmpty) {
      editRoleId = allowedRoles.first.id;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit Role: ${member.username}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (allowedRoles.isEmpty)
                const Text("You don't have permission to assign any roles.",
                    style: TextStyle(color: Colors.red))
              else
                DropdownButtonFormField<int>(
                  initialValue: editRoleId,
                  decoration: const InputDecoration(
                      labelText: 'New Role', border: OutlineInputBorder()),
                  items: allowedRoles.map((role) {
                    return DropdownMenuItem<int>(
                      value: role.id,
                      child: Text(role.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    editRoleId = val;
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: allowedRoles.isEmpty
                  ? null
                  : () async {
                      if (editRoleId != null) {
                        final success =
                            await ref.read(staffManagementVM).updateRole(
                                  propertyId: propertyId,
                                  targetUserId: member.userUid,
                                  newRoleId: editRoleId!,
                                );
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();
                        final messenger = ScaffoldMessenger.of(ctx);
                        if (success) {
                          messenger.showSnackBar(const SnackBar(
                              content: Text('Role updated!'),
                              backgroundColor: Colors.green));
                        } else {
                          messenger.showSnackBar(SnackBar(
                              content: Text(ref.read(staffManagementVM).error),
                              backgroundColor: Colors.red));
                        }
                      }
                    },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Dialog for Suspending/Reactivating Staff (Soft Delete)
  void _showToggleStatusDialog(
      BuildContext context, int propertyId, StaffMember member) {
    // Assuming Status 1 = Pending, 2 = Active, 3 = Suspended.
    // If they are anything other than Suspended (3), the button will Suspend them.
    final bool isCurrentlyActive = member.statusId != 3;
    final int targetStatusId = isCurrentlyActive ? 3 : 2;
    final String actionWord = isCurrentlyActive ? 'Suspend' : 'Reactivate';
    final Color actionColor = isCurrentlyActive ? Colors.orange : Colors.green;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('$actionWord Access'),
          content: Text(
              'Are you sure you want to $actionWord ${member.username}\'s access to this property?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: actionColor),
              onPressed: () async {
                final success = await ref.read(staffManagementVM).updateStatus(
                      propertyId: propertyId,
                      targetUserId: member.userUid,
                      newStatusId: targetStatusId,
                    );
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                final messenger = ScaffoldMessenger.of(ctx);
                if (success) {
                  messenger.showSnackBar(SnackBar(
                      content: Text('User access updated to $actionWord'),
                      backgroundColor: Colors.green));
                } else {
                  messenger.showSnackBar(SnackBar(
                      content: Text(ref.read(staffManagementVM).error),
                      backgroundColor: Colors.red));
                }
              },
              child:
                  Text(actionWord, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffVM = ref.watch(staffManagementVM);
    final propertyId = ref.watch(selectedPropertyVM);
    final allowedRoles = ref.watch(roleListVM);

    // Re-fetch staff if property changes
    ref.listen(selectedPropertyVM, (previous, next) {
      if (next != null && next != previous) {
        _loadStaff();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadStaff(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (propertyId != null) {
            _showInviteDialog(context, propertyId, allowedRoles);
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text("Invite"),
      ),
      body: staffVM.isLoading && staffVM.staffList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : staffVM.staffList.isEmpty
              ? const Center(child: Text("No staff found for this property."))
              : RefreshIndicator(
                  onRefresh: () async => _loadStaff(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: staffVM.staffList.length,
                    itemBuilder: (context, index) {
                      final staff = staffVM.staffList[index];
                      final bool isSuspended = staff.statusId == 3;

                      return Card(
                        color: isSuspended
                            ? Colors.grey.shade200
                            : Colors.white, // Grey out suspended users slightly
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isSuspended ? Colors.grey : Colors.blue,
                            child: Text(
                                staff.username.isNotEmpty
                                    ? staff.username[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(
                              staff.username.isEmpty
                                  ? staff.email
                                  : staff.username,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSuspended
                                      ? Colors.grey
                                      : Colors.black)),
                          subtitle: Text(
                              '${staff.roleName} • Status: ${staff.statusName}'),
                          trailing: staff.canManage
                              ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditRoleDialog(context, propertyId!,
                                          staff, allowedRoles);
                                    } else if (value == 'toggle_status') {
                                      _showToggleStatusDialog(
                                          context, propertyId!, staff);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit Role')
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'toggle_status',
                                      child: Row(
                                        children: [
                                          Icon(
                                              isSuspended
                                                  ? Icons.check_circle
                                                  : Icons.block,
                                              color: isSuspended
                                                  ? Colors.green
                                                  : Colors.orange,
                                              size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                              isSuspended
                                                  ? 'Reactivate Access'
                                                  : 'Suspend Access',
                                              style: TextStyle(
                                                  color: isSuspended
                                                      ? Colors.green
                                                      : Colors.orange))
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
