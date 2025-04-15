import 'package:flutter/material.dart';
import 'package:flutter_academy/app/users/view_models/theme_mode.vm.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Flutter Academy",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
          ListTile(
            title: const Text("Dashboard"),
            onTap: () {
              routerDelegate.replaceAllWith('dashboard');
            },
          ),
          ListTile(
            title: const Text("Courses"),
            onTap: () {
              routerDelegate.push('courses');
            },
          ),
          ListTile(
            title: const Text("Watchlist"),
            onTap: () {
              routerDelegate.push('watchlist');
            },
          ),
          Consumer(builder: (context, ref, child) {
            final themeModeVM = ref.watch(themeModeProvider);
            return ListTile(
              title: Text(themeModeVM.themeMode == ThemeMode.dark
                  ? "Light Theme"
                  : "Dark Theme"),
              onTap: () {
                themeModeVM.toggleThemeMode();
              },
            );
          })
        ],
      ),
    );
  }
}
