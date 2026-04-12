import 'package:flutter/material.dart';
import 'package:lotel_pms/app/users/view_models/theme_mode.vm.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardDrawer extends ConsumerWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeVM = ref.watch(themeModeProvider);

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
          ListTile(
            title: const Text("Courses"),
            onTap: () {
              ref.read(routerProvider).push('courses');
            },
          ),
          ListTile(
            title: const Text("Watchlist"),
            onTap: () {
              ref.read(routerProvider).push('watchlist');
            },
          ),
          ListTile(
            title: const Text("Invoices"),
            onTap: () {
              ref.read(routerProvider).push('invoices');
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
