import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/api/view_models/role.vm.dart';
import 'package:lotel_pms/app/api/view_models/staff_management.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/app/api/view_models/lists/role_list.vm.dart';

class _StatusAction {
  final int targetStatusId;
  final String label;
  final Color color;
  final IconData icon;

  const _StatusAction({
    required this.targetStatusId,
    required this.label,
    required this.color,
    required this.icon,
  });
}

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

  static const Map<int, String> _statusLabels = {
    1: 'Pending',
    2: 'Active',
    3: 'Suspended',
    4: 'Cancelled',
  };

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

  void _resetInviteForm(List<RoleVM> allowedRoles) {
    _emailController.clear();
    if (allowedRoles.isEmpty) {
      _selectedRoleId = null;
      return;
    }

    final selectedRoleStillValid =
        allowedRoles.any((role) => role.id == _selectedRoleId);
    _selectedRoleId =
        selectedRoleStillValid ? _selectedRoleId : allowedRoles.first.id;
  }

  List<_StatusAction> _statusActionsFor(StaffMember member) {
    switch (member.statusId) {
      case 1:
        return const [
          _StatusAction(
            targetStatusId: 2,
            label: 'Approve Access',
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          _StatusAction(
            targetStatusId: 3,
            label: 'Suspend Access',
            color: Colors.orange,
            icon: Icons.block,
          ),
          _StatusAction(
            targetStatusId: 4,
            label: 'Cancel Invite',
            color: Colors.red,
            icon: Icons.cancel,
          ),
        ];
      case 2:
        return const [
          _StatusAction(
            targetStatusId: 3,
            label: 'Suspend Access',
            color: Colors.orange,
            icon: Icons.block,
          ),
          _StatusAction(
            targetStatusId: 4,
            label: 'Cancel Access',
            color: Colors.red,
            icon: Icons.cancel,
          ),
        ];
      case 3:
        return const [
          _StatusAction(
            targetStatusId: 2,
            label: 'Reactivate Access',
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          _StatusAction(
            targetStatusId: 4,
            label: 'Cancel Access',
            color: Colors.red,
            icon: Icons.cancel,
          ),
        ];
      case 4:
        return const [
          _StatusAction(
            targetStatusId: 2,
            label: 'Restore Access',
            color: Colors.green,
            icon: Icons.restore,
          ),
        ];
      default:
        return const [];
    }
  }

  Color _cardColorForStatus(int statusId) {
    switch (statusId) {
      case 1:
        return Colors.amber.shade50;
      case 3:
        return Colors.grey.shade200;
      case 4:
        return Colors.red.shade50;
      default:
        return Colors.white;
    }
  }

  Color _avatarColorForStatus(int statusId) {
    switch (statusId) {
      case 1:
        return Colors.amber;
      case 3:
        return Colors.grey;
      case 4:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _textColorForStatus(int statusId) {
    return statusId == 2 ? Colors.black : Colors.black87;
  }

  // Dialog for Inviting Staff
  void _showInviteDialog(
      BuildContext context, int propertyId, List<RoleVM> allowedRoles) {
    _resetInviteForm(allowedRoles);

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
              onPressed: allowedRoles.isEmpty
                  ? null
                  : () async {
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
    ).then((_) => _resetInviteForm(allowedRoles));
  }

  // Dialog for Editing Role
  void _showEditRoleDialog(BuildContext context, int propertyId,
      StaffMember member, List<RoleVM> allowedRoles) {
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

  void _showStatusDialog(BuildContext context, int propertyId, StaffMember member,
      _StatusAction action) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(action.label),
          content: Text(
              'Are you sure you want to ${action.label.toLowerCase()} for ${member.username}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: action.color),
              onPressed: () async {
                final success = await ref.read(staffManagementVM).updateStatus(
                      propertyId: propertyId,
                      targetUserId: member.userUid,
                      newStatusId: action.targetStatusId,
                    );
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                final messenger = ScaffoldMessenger.of(ctx);
                if (success) {
                  messenger.showSnackBar(SnackBar(
                      content: Text(
                          'User status updated to ${_statusLabels[action.targetStatusId] ?? 'Updated'}'),
                      backgroundColor: Colors.green));
                } else {
                  messenger.showSnackBar(SnackBar(
                      content: Text(ref.read(staffManagementVM).error),
                      backgroundColor: Colors.red));
                }
              },
              child:
                  Text(action.label, style: const TextStyle(color: Colors.white)),
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
    final List<RoleVM> allowedRoles = ref.watch(roleListVM);

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
      floatingActionButton: propertyId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showInviteDialog(context, propertyId, allowedRoles),
              icon: const Icon(Icons.person_add),
              label: const Text("Invite"),
            ),
      body: staffVM.isLoading && staffVM.staffList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadStaff(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (staffVM.error.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        staffVM.error,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  if (staffVM.staffList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text("No staff found for this property."),
                      ),
                    )
                  else
                    ...staffVM.staffList.map((staff) {
                      final statusActions = _statusActionsFor(staff);

                      return Card(
                        color: _cardColorForStatus(staff.statusId),
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _avatarColorForStatus(staff.statusId),
                            child: Text(
                              staff.username.isNotEmpty
                                  ? staff.username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            staff.username.isEmpty ? staff.email : staff.username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _textColorForStatus(staff.statusId),
                            ),
                          ),
                          subtitle: Text(
                            '${staff.roleName} • Status: ${staff.statusName}'
                            '${staff.isCurrentUser ? ' • You' : ''}',
                          ),
                          trailing: staff.canManage
                              ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditRoleDialog(context, propertyId!,
                                          staff, allowedRoles);
                                      return;
                                    }

                                    for (final action in statusActions) {
                                      if (value ==
                                          'status:${action.targetStatusId}') {
                                        _showStatusDialog(
                                            context, propertyId!, staff, action);
                                        return;
                                      }
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
                                    ...statusActions.map(
                                      (action) => PopupMenuItem(
                                        value: 'status:${action.targetStatusId}',
                                        child: Row(
                                          children: [
                                            Icon(action.icon,
                                                color: action.color, size: 18),
                                            const SizedBox(width: 8),
                                            Text(
                                              action.label,
                                              style:
                                                  TextStyle(color: action.color),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
