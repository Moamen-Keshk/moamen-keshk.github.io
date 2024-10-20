import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/view_models/auth.vm.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';
import 'package:flutter_academy/app/courses/view_models/property.vm.dart';
import 'package:flutter_academy/app/courses/view_models/property_list.vm.dart';
import 'package:flutter_academy/app/courses/views/notifications.view.dart';
import 'package:flutter_academy/app/users/view_models/theme_mode.vm.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

SampleItem? selectedMenu;

enum Property {
  savoy('Savoy'),
  wembar('Wembar'),
  dolphin('Dolphin'),
  fjaerland('Fjaerland'),
  villarose('Villa Rose');

  const Property(this.name);
  final String name;
}

String? selectedProperty;
String? initialSelection;

class DashboardNav extends StatelessWidget {
  const DashboardNav({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Lotel'),
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
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 109, 106, 106)),
                onPressed: () {
                  routerDelegate.go('/');
                },
                child: const Text("New booking"),
              ),
              const SizedBox(width: 10.0),
              Consumer(builder: (context, ref, child) {
                final properties = ref.watch(propertyListVM);
                if (properties.isEmpty) {
                  initialSelection = '';
                }
                else {
                  initialSelection = properties[0].name;
                }
              return DropdownMenu<String>(
                initialSelection: initialSelection,
                // requestFocusOnTap is enabled/disabled by platforms when it is null.
                // On mobile platforms, this is false by default. Setting this to true will
                // trigger focus request on the text field and virtual keyboard will appear
                // afterward. On desktop platforms however, this defaults to true.
                requestFocusOnTap: true,
                label: const Text('Property'),
                onSelected: (String? property) {
                  setState(() {
                    selectedProperty = property;
                    return null;
                  });
                },
                dropdownMenuEntries: properties.map<DropdownMenuEntry<String>>((PropertyVM property) {
                  return DropdownMenuEntry<String>(
                    value: property.name,
                    label: property.name,
                    style: MenuItemButton.styleFrom(),
                  );
                }).toList() + [DropdownMenuEntry(
                    value: '',
                    label: '',
                    style: MenuItemButton.styleFrom(overlayColor: Colors.transparent),
                    labelWidget: FloatingActionButton.small(
                    onPressed: () {
                      routerDelegate.go('new_property');
                    },
                    elevation: 0,
                    hoverElevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    child: const Icon(Icons.add),
                  )
                    )]
                );
                }),
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
                child: const Text("Today's"),
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

  setState(Property? Function() param0) {}
}
