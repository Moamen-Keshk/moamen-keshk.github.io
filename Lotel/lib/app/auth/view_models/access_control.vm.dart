import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/auth/view_models/auth.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/app/users/view_models/user.vm.dart';

class PmsPermission {
  static const viewBookings = 'view_bookings';
  static const manageBookings = 'manage_bookings';
  static const viewRates = 'view_rates';
  static const manageRates = 'manage_rates';
  static const viewFinance = 'view_finance';
  static const manageFinance = 'manage_finance';
  static const manageChannels = 'manage_channels';
  static const updateRoomStatus = 'update_room_status';
  static const manageStaff = 'manage_staff';
  static const manageProperty = 'manage_property';
}

final currentUserVMProvider = Provider<UserVM?>((ref) {
  return ref.watch(authVM).user;
});

final effectivePropertyIdProvider = Provider<int?>((ref) {
  final selectedPropertyId = ref.watch(selectedPropertyVM);
  if (selectedPropertyId != null && selectedPropertyId != 0) {
    return selectedPropertyId;
  }

  return ref.watch(currentUserVMProvider)?.propertyId;
});

final currentPermissionsProvider = Provider<Set<String>>((ref) {
  final user = ref.watch(currentUserVMProvider);
  if (user == null) return const <String>{};
  if (user.isSuperAdmin) {
    return {
      PmsPermission.viewBookings,
      PmsPermission.manageBookings,
      PmsPermission.viewRates,
      PmsPermission.manageRates,
      PmsPermission.viewFinance,
      PmsPermission.manageFinance,
      PmsPermission.manageChannels,
      PmsPermission.updateRoomStatus,
      PmsPermission.manageStaff,
      PmsPermission.manageProperty,
    };
  }
  return user.permissions.toSet();
});

bool hasPmsPermission(WidgetRef ref, String permission) {
  return ref.watch(currentPermissionsProvider).contains(permission);
}

class PermissionGuard extends ConsumerWidget {
  final String? requiredPermission;
  final bool requirePropertySelection;
  final Widget child;
  final Widget? fallback;
  final bool hideWhenUnauthorized;

  const PermissionGuard({
    super.key,
    required this.child,
    this.requiredPermission,
    this.requirePropertySelection = true,
    this.fallback,
    this.hideWhenUnauthorized = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserVMProvider);
    final propertyId = ref.watch(effectivePropertyIdProvider);
    final permissions = ref.watch(currentPermissionsProvider);

    final missingProperty =
        requirePropertySelection && (propertyId == null || propertyId == 0);
    final missingPermission = requiredPermission != null &&
        !userIsSuperAdmin(user) &&
        !permissions.contains(requiredPermission);

    if (!missingProperty && !missingPermission) {
      return child;
    }

    if (hideWhenUnauthorized) {
      return const SizedBox.shrink();
    }

    return fallback ??
        _PermissionFallback(
          missingProperty: missingProperty,
          permissionLabel: requiredPermission,
        );
  }

  bool userIsSuperAdmin(UserVM? user) => user?.isSuperAdmin == true;
}

class _PermissionFallback extends StatelessWidget {
  final bool missingProperty;
  final String? permissionLabel;

  const _PermissionFallback({
    required this.missingProperty,
    required this.permissionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = missingProperty ? 'Select a Property' : 'Access Restricted';
    final message = missingProperty
        ? 'Choose a property to continue.'
        : 'Your role does not have access to this section${permissionLabel == null ? '' : '.'}';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    missingProperty ? Icons.apartment : Icons.lock_outline,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
