import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/users/view_models/theme_mode.vm.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardDrawer extends ConsumerWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeVM = ref.watch(themeModeProvider);
    final effectivePropertyId = ref.watch(effectivePropertyIdProvider);
    final canViewBookings = hasPmsPermission(ref, PmsPermission.viewBookings);
    final canViewFinance = hasPmsPermission(ref, PmsPermission.viewFinance);
    final canManageProperty =
        hasPmsPermission(ref, PmsPermission.manageProperty);
    final canManageRates = hasPmsPermission(ref, PmsPermission.manageRates);
    final canManageStaff = hasPmsPermission(ref, PmsPermission.manageStaff);
    final canManageChannels =
        hasPmsPermission(ref, PmsPermission.manageChannels);
    final canUpdateRoomStatus =
        hasPmsPermission(ref, PmsPermission.updateRoomStatus);

    return Drawer(
      child: ListView(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Lotel PMS",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
          ListTile(
            title: const Text("Dashboard"),
            onTap: () {
              ref.read(routerProvider).replaceAllWith('dashboard');
            },
          ),
          if (canViewBookings)
            ListTile(
              title: const Text("Today's"),
              enabled: effectivePropertyId != null,
              onTap: effectivePropertyId == null
                  ? null
                  : () {
                      ref.read(routerProvider).push('todays');
                    },
            ),
          if (canViewBookings)
            ListTile(
              title: const Text("Bookings"),
              enabled: effectivePropertyId != null,
              onTap: effectivePropertyId == null
                  ? null
                  : () {
                      ref.read(routerProvider).push('booking_search');
                    },
            ),
          if (canUpdateRoomStatus)
            ListTile(
              title: const Text("Housekeeping"),
              enabled: effectivePropertyId != null,
              onTap: effectivePropertyId == null
                  ? null
                  : () {
                      ref.read(routerProvider).push('housekeeping');
                    },
            ),
          if (canManageChannels)
            ListTile(
              title: const Text("Channels"),
              enabled: effectivePropertyId != null,
              onTap: effectivePropertyId == null
                  ? null
                  : () {
                      ref.read(routerProvider).push('channel_manager');
                    },
            ),
          if (canManageProperty)
            ListTile(
              title: const Text("Property"),
              enabled: effectivePropertyId != null,
              onTap: effectivePropertyId == null
                  ? null
                  : () {
                      ref.read(routerProvider).push('edit_property');
                    },
            ),
          if (canManageRates)
            ListTile(
              title: const Text("Rate Plans"),
              enabled: effectivePropertyId != null,
              onTap: effectivePropertyId == null
                  ? null
                  : () {
                      ref.read(routerProvider).push('hotel_rate_plan');
                    },
            ),
          if (canManageRates)
            ListTile(
              title: const Text("Seasons"),
              enabled: effectivePropertyId != null,
              onTap: effectivePropertyId == null
                  ? null
                  : () {
                      ref.read(routerProvider).push('hotel_seasons');
                    },
            ),
          if (canManageStaff)
            ListTile(
              title: const Text("Staff & Roles"),
              enabled: effectivePropertyId != null,
              onTap: effectivePropertyId == null
                  ? null
                  : () {
                      ref.read(routerProvider).push('staff_management');
                    },
            ),
          if (canViewFinance)
            ListTile(
              title: const Text("Invoices"),
              enabled: effectivePropertyId != null,
              onTap: effectivePropertyId == null
                  ? null
                  : () {
                      ref.read(routerProvider).push('invoices');
                    },
            ),
          if (canViewFinance)
            ListTile(
              title: const Text("Reports"),
              enabled: effectivePropertyId != null,
              onTap: effectivePropertyId == null
                  ? null
                  : () {
                      ref.read(routerProvider).push('reports');
                    },
            ),
          ListTile(
            title: Text(themeModeVM.themeMode == ThemeMode.dark
                ? "Light Theme"
                : "Dark Theme"),
            onTap: () {
              themeModeVM.toggleThemeMode();
            },
          ),
        ],
      ),
    );
  }
}
