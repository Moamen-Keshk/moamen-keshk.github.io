import 'package:flutter/material.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawerNav extends ConsumerWidget {
  const DrawerNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            title: const Text("About"),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              ref.read(routerProvider).push('about');
            },
          ),
          ListTile(
            title: const Text("Login"),
            onTap: () {
              Navigator.of(context).pop();
              ref.read(routerProvider).push('login');
            },
          ),
          ListTile(
            title: const Text("Contact"),
            onTap: () {
              Navigator.of(context).pop();
              ref.read(routerProvider).push('contact');
            },
          ),
        ],
      ),
    );
  }
}
