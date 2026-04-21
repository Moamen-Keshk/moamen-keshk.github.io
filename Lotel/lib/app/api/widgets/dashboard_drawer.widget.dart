import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/users/view_models/theme_mode.vm.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardDrawer extends ConsumerWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: const DashboardMenuPanel(),
    );
  }
}

class DashboardMenuPanel extends ConsumerWidget {
  const DashboardMenuPanel({super.key, this.asSheet = false});

  final bool asSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = context.showCompactLayout;
    final themeModeVM = ref.watch(themeModeProvider);
    final effectivePropertyId = ref.watch(effectivePropertyIdProvider);
    final canViewFinance = hasPmsPermission(ref, PmsPermission.viewFinance);
    final canManageProperty =
        hasPmsPermission(ref, PmsPermission.manageProperty);
    final canManageRates = hasPmsPermission(ref, PmsPermission.manageRates);
    final canManageStaff = hasPmsPermission(ref, PmsPermission.manageStaff);
    final canManageChannels =
        hasPmsPermission(ref, PmsPermission.manageChannels);

    final content = ListView(
      shrinkWrap: true,
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.all(isCompact ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (asSheet)
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              Text(
                "Lotel PMS",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
        if (canManageChannels)
          ListTile(
            leading: const Icon(Icons.sync_alt_outlined),
            title: const Text("Channels"),
            enabled: effectivePropertyId != null,
            onTap: effectivePropertyId == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    ref.read(routerProvider).push('channel_manager');
                  },
          ),
        if (canManageProperty)
          ListTile(
            leading: const Icon(Icons.apartment_outlined),
            title: const Text("Property"),
            enabled: effectivePropertyId != null,
            onTap: effectivePropertyId == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    ref.read(routerProvider).push('edit_property');
                  },
          ),
        if (canManageRates)
          ListTile(
            leading: const Icon(Icons.sell_outlined),
            title: const Text("Rate Plans"),
            enabled: effectivePropertyId != null,
            onTap: effectivePropertyId == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    ref.read(routerProvider).push('hotel_rate_plan');
                  },
          ),
        if (canManageRates)
          ListTile(
            leading: const Icon(Icons.event_available_outlined),
            title: const Text("Seasons"),
            enabled: effectivePropertyId != null,
            onTap: effectivePropertyId == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    ref.read(routerProvider).push('hotel_seasons');
                  },
          ),
        if (canManageStaff)
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text("Staff & Roles"),
            enabled: effectivePropertyId != null,
            onTap: effectivePropertyId == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    ref.read(routerProvider).push('staff_management');
                  },
          ),
        if (canViewFinance)
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text("Invoices"),
            enabled: effectivePropertyId != null,
            onTap: effectivePropertyId == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    ref.read(routerProvider).push('invoices');
                  },
          ),
        if (canViewFinance)
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text("Reports"),
            enabled: effectivePropertyId != null,
            onTap: effectivePropertyId == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    ref.read(routerProvider).push('reports');
                  },
          ),
        const Divider(height: 24),
        ListTile(
          leading: Icon(themeModeVM.themeMode == ThemeMode.dark
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined),
          title: Text(themeModeVM.themeMode == ThemeMode.dark
              ? "Light Theme"
              : "Dark Theme"),
          onTap: () {
            Navigator.of(context).pop();
            themeModeVM.toggleThemeMode();
          },
        ),
      ],
    );

    if (!asSheet) return content;

    return SafeArea(
      top: false,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}
