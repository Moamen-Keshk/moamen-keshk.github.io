import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/view_models/auth.vm.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';
import 'package:flutter_academy/app/courses/views/notifications.view.dart';
import 'package:flutter_academy/app/users/view_models/theme_mode.vm.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

SampleItem? selectedMenu;

class DashboardNav extends StatelessWidget {
  const DashboardNav({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Flutter Academy'),
      elevation: kIsWeb ? 0 : null,
      centerTitle: kIsWeb ? false : null,
      backgroundColor: const Color.fromARGB(255, 241, 236, 245),
      actions: (MediaQuery.of(context).size.width <= ScreenSizes.md)
          ? [
              Consumer(builder: (context, ref, child) {
                return IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () async => {
                          if (await ref.read(authVM).logout())
                            routerDelegate.go('/')
                        });
              })
            ]
          : [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                onPressed: () {
                  routerDelegate.go('/');
                },
                child: const Text("Dashboard"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                onPressed: () {
                  routerDelegate.go('/courses');
                },
                child: const Text("Courses"),
              ),
              TextButton(
                onPressed: () {
                  routerDelegate.go('/watchlist');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                child: const Text("Watchlist"),
              ),
              Consumer(builder: (context, ref, child) {
                final themeModeVM = ref.watch(themeModeProvider);
                return TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  onPressed: () {
                    themeModeVM.toggleThemeMode();
                  },
                  child: Text(themeModeVM.themeMode == ThemeMode.dark
                      ? "Light Theme"
                      : "Dark Theme"),
                );
              }),
              const NotificationsView(),
              Consumer(builder: (context, ref, child) {
                return IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () async => {
                          if (await ref.read(authVM).logout())
                            routerDelegate.go('/')
                        });
              })
            ],
    );
  }

  setState(SampleItem Function() param0) {}
}
