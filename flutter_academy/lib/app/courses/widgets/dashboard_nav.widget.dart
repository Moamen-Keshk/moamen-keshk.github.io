import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/view_models/auth.vm.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';
import 'package:flutter_academy/app/courses/view_models/property.vm.dart';
import 'package:flutter_academy/app/courses/view_models/property_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/courses/views/notifications.view.dart';
import 'package:flutter_academy/app/users/view_models/theme_mode.vm.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String? selectedProperty;

class DashboardNav extends StatefulWidget {
  const DashboardNav({super.key});

  @override
  State<DashboardNav> createState() => _DashboardNavState();
}

class _DashboardNavState extends State<DashboardNav> {
  Map<String, String> propertiesMapping = {};

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
                propertiesMapping = propertyMapping(properties);
                return Container(
                    width: 130,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey, width: 1)),
                    child: DropdownButton<String>(
                      value: selectedProperty,
                      hint: Text("Property"),
                      isExpanded: true,
                      underline: SizedBox(),
                      // requestFocusOnTap is enabled/disabled by platforms when it is null.
                      // On mobile platforms, this is false by default. Setting this to true will
                      // trigger focus request on the text field and virtual keyboard will appear
                      // afterward. On desktop platforms however, this defaults to true.
                      onChanged: (newValue) {
                        setState(() {
                          selectedProperty = newValue;
                          ref.read(selectedPropertyVM.notifier).state =
                              int.parse(newValue!);
                        });
                      },
                      items: properties.map<DropdownMenuItem<String>>(
                              (PropertyVM property) {
                            return DropdownMenuItem<String>(
                              value: property.id,
                              child: Text(property.name),
                            );
                          }).toList() +
                          [
                            DropdownMenuItem(
                                value: null,
                                onTap: () {
                                  routerDelegate.go('new_property');
                                },
                                child: const Icon(Icons.add))
                          ],
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    ));
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

  Map<String, String> propertyMapping(List<PropertyVM> propertyVMList) {
    Map<String, String> propertyMap = {};
    for (var property in propertyVMList) {
      propertyMap[property.id] = property.name;
    }
    return propertyMap;
  }
}
