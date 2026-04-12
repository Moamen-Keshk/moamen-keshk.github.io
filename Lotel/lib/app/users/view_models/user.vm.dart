class UserVM {
  final String email;
  final String name;
  final String id;
  // --- NEW FIELDS FOR ROLE HIERARCHY ---
  final int?
      accountStatusId; // 1: Pending, 2: Active, 3: Suspended, 4: Cancelled
  final String? role; // e.g., 'Property Admin', 'Front Desk'
  final int? propertyId; // The property this user is assigned to
  final List<String> permissions;
  final bool isSuperAdmin;

  UserVM({
    required this.email,
    required this.name,
    required this.id,
    this.accountStatusId,
    this.role,
    this.propertyId,
    this.permissions = const [],
    this.isSuperAdmin = false,
  });

  // Helper method to update backend data later
  UserVM copyWith({
    String? email,
    String? name,
    String? id,
    int? accountStatusId,
    String? role,
    int? propertyId,
    List<String>? permissions,
    bool? isSuperAdmin,
  }) {
    return UserVM(
      email: email ?? this.email,
      name: name ?? this.name,
      id: id ?? this.id,
      accountStatusId: accountStatusId ?? this.accountStatusId,
      role: role ?? this.role,
      propertyId: propertyId ?? this.propertyId,
      permissions: permissions ?? this.permissions,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
    );
  }
}
