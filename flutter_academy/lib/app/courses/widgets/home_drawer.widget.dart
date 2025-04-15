import 'package:flutter/material.dart';
import 'package:flutter_academy/main.dart';

class DrawerNav extends StatelessWidget {
  const DrawerNav({super.key});

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
            title: const Text("About"),
            onTap: () {
              routerDelegate.push('about');
            },
          ),
          ListTile(
            title: const Text("Login"),
            onTap: () {
              routerDelegate.push('login');
            },
          ),
          ListTile(
            title: const Text("Contact"),
            onTap: () {
              routerDelegate.push('contact');
            },
          ),
        ],
      ),
    );
  }
}
