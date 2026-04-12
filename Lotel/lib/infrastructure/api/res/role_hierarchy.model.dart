enum RoleHierarchy {
  propertyAdmin(id: 1, name: 'Property Admin', rank: 100),
  revenueManager(id: 2, name: 'Revenue Manager', rank: 80),
  frontDesk(id: 3, name: 'Front Desk', rank: 50),
  housekeeping(id: 4, name: 'Housekeeping', rank: 10);

  final int id;
  final String name;
  final int rank;

  const RoleHierarchy({
    required this.id,
    required this.name,
    required this.rank,
  });

  // Helper to map the string role from UserVM to the Enum
  static RoleHierarchy? fromString(String? roleName) {
    if (roleName == null) return null;
    return RoleHierarchy.values.where((r) => r.name == roleName).firstOrNull;
  }

  // CORE LOGIC: Returns only roles that are less than or equal to this role's rank
  List<RoleHierarchy> getAssignableRoles() {
    return RoleHierarchy.values.where((r) => r.rank <= rank).toList();
  }
}
