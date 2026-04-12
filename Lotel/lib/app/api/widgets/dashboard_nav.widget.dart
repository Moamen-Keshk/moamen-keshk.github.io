import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/view_models/auth.vm.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/lists/block_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/booking_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/property_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/property.vm.dart';
import 'package:lotel_pms/app/api/views/new_block.view.dart';
import 'package:lotel_pms/app/api/views/new_booking.view.dart';
import 'package:lotel_pms/app/api/views/notifications.view.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ❌ REMOVED: String? selectedProperty;

class DashboardNav extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const DashboardNav({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  ConsumerState<DashboardNav> createState() => _DashboardNavState();
}

class _DashboardNavState extends ConsumerState<DashboardNav> {
  Map<String, String> propertiesMapping = {};

  @override
  Widget build(BuildContext context) {
    // ✅ ADDED: Get the selected property directly from Riverpod!
    final int? currentPropertyId = ref.watch(selectedPropertyVM);
    // Convert to string for the dropdown, but handle 0 or null cleanly
    final String? dropdownValue =
        (currentPropertyId == null || currentPropertyId == 0)
            ? null
            : currentPropertyId.toString();

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
                  onPressed: () async {
                    if (await ref.read(authVM).logout()) {
                      ref.read(routerProvider).replaceAllWith('home');
                    }
                  },
                );
              }),
            ]
          : [
              Consumer(builder: (context, ref, child) {
                return TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 109, 106, 106),
                  ),
                  onPressed: () {
                    showBlockDialog(context, ref);
                    ref.read(routerProvider).replaceAllWith('dashboard');
                  },
                  child: const Text("Create Block"),
                );
              }),
              const SizedBox(width: 10.0),
              Consumer(builder: (context, ref, child) {
                return TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[300],
                  ),
                  onPressed: () {
                    showBookingDialog(context, ref);
                    ref.read(routerProvider).replaceAllWith('dashboard');
                  },
                  child: const Text("New booking"),
                );
              }),
              const SizedBox(width: 10.0),

              // THE DROPDOWN FIX
              Consumer(builder: (context, ref, child) {
                final properties = ref.watch(propertyListVM);
                propertiesMapping = propertyMapping(properties);

                return Container(
                  width: 130,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: DropdownButton<String>(
                    value: dropdownValue, // ✅ Driven entirely by Riverpod
                    hint: const Text("Property"),
                    isExpanded: true,
                    underline: const SizedBox(),
                    onChanged: (newValue) {
                      if (newValue == 'add') {
                        ref.read(routerProvider).push('new_property');
                      } else if (newValue != null) {
                        // ✅ Tell Riverpod to update. The UI will automatically rebuild!
                        ref
                            .read(selectedPropertyVM.notifier)
                            .updateProperty(int.parse(newValue));
                      }
                    },
                    items: properties
                        .map<DropdownMenuItem<String>>((PropertyVM property) {
                      return DropdownMenuItem<String>(
                        value: property.id,
                        child: Text(property.name),
                      );
                    }).toList()
                      ..add(
                        const DropdownMenuItem(
                          value: 'add',
                          child: Row(
                            children: [
                              Icon(Icons.add),
                              SizedBox(width: 8),
                              Text("Add"),
                            ],
                          ),
                        ),
                      ),
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.black),
                  ),
                );
              }),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                onPressed: () {
                  ref.read(routerProvider).replaceAllWith('dashboard');
                },
                child: const Text("Dashboard"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                onPressed: () {
                  ref.read(routerProvider).push('todays');
                },
                child: const Text("Today's"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                onPressed: () {
                  ref.read(routerProvider).push('booking_search');
                },
                child: const Text("Bookings"),
              ),
              TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  onPressed: () {
                    ref.read(routerProvider).push('housekeeping');
                  },
                  child: const Text("Housekeeping")),

              // 💡 OPTION 1: Standalone TextButton for Channels
              if (currentPropertyId != null &&
                  currentPropertyId != 0) // ✅ Now uses Riverpod's state safely
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                  ),
                  onPressed: () {
                    ref.read(routerProvider).push('channel_manager');
                  },
                  child: const Text("Channels"),
                ),

              /// 💡 Settings Dropdown
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings),
                onSelected: (value) {
                  final router = ref.read(routerProvider);
                  switch (value) {
                    case 'property':
                      router.push('edit_property');
                      break;
                    case 'rate_plans':
                      router.push('hotel_rate_plan');
                      break;
                    case 'categories':
                      router.push('categories_management');
                      break;
                    case 'seasons':
                      router.push('hotel_seasons');
                      break;
                    case 'channels':
                      router.push('channel_manager');
                      break;
                    case 'staff':
                      router.push('staff_management');
                      break;
                    case 'invoices':
                      router.push('invoices');
                      break;
                    // ---> NEW: Route for Amenities Management <---
                    case 'amenities':
                      router.push('amenities_management');
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'property', child: Text('Property')),
                  PopupMenuItem(value: 'rate_plans', child: Text('Rate Plans')),
                  PopupMenuItem(value: 'categories', child: Text('Categories')),
                  PopupMenuItem(value: 'seasons', child: Text('Seasons')),
                  PopupMenuItem(
                      value: 'channels', child: Text('Channel Manager')),
                  PopupMenuItem(value: 'invoices', child: Text('Invoices')),
                  PopupMenuItem(value: 'staff', child: Text('Staff & Roles')),
                  // ---> NEW: Dropdown item for Amenities <---
                  PopupMenuItem(
                      value: 'amenities', child: Text('Global Amenities')),
                ],
              ),

              const NotificationsView(), // ✅ Your global notification widget!

              Consumer(builder: (context, ref, child) {
                return IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () async {
                    if (await ref.read(authVM).logout()) {
                      ref.read(routerProvider).replaceAllWith('home');
                    }
                  },
                );
              }),
            ],
    );
  }

  void showBookingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Booking'),
          content: BookingForm(
            onSubmit: (bookingData) async {
              return ref
                  .read(bookingListVM.notifier)
                  .addToBookings(bookingData);
            },
            ref: ref,
          ),
        );
      },
    );
  }

  void showBlockDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Block'),
          content: BlockForm(
            onSubmit: (blockData) async {
              return ref.read(blockListVM.notifier).addToBlocks(blockData);
            },
            ref: ref,
          ),
        );
      },
    );
  }

  Map<String, String> propertyMapping(List<PropertyVM> propertyVMList) {
    return {
      for (var property in propertyVMList) property.id: property.name,
    };
  }
}
