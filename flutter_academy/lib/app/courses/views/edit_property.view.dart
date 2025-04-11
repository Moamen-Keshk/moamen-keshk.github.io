import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<int, int> roomsCategoryMapping = {};

Map<int, String> roomMapping = {};

Map<int, String> categoryMapping = {};

class EditPropertyView extends StatefulWidget {
  const EditPropertyView({super.key});

  @override
  State<EditPropertyView> createState() => _EditPropertyViewState();
}

class _EditPropertyViewState extends State<EditPropertyView> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
          height: 700,
          child: Consumer(
            builder: (context, ref, child) {
              final floors = ref.watch(floorListVM);
              roomsCategoryMapping = setRoomCategory(
                  ref.read(roomListVM), ref.read(categoryListVM));
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1,
                ),
                padding: const EdgeInsets.all(10.0),
                itemCount: floors.length,
                itemBuilder: (context, index) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(floorToEditVM.notifier)
                                .updateFloor(floors[index]);
                            routerDelegate.go('edit_floor');
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  'Floor ${floors[index].number.toString()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ),
                              Expanded(
                                  child: SingleChildScrollView(
                                      physics: ClampingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: floors[index]
                                            .rooms
                                            .map<Row>((Room room) {
                                          return Row(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 2),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    width: 90,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      room.roomNumber
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          height: 1.0),
                                                    ),
                                                  )),
                                              Expanded(
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 2),
                                                      child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          height: 35,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .blue[100],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Text(
                                                            categoryMapping[
                                                                    roomsCategoryMapping[
                                                                            int.parse(room.id)] ??
                                                                        -1] ??
                                                                'Undefined Category',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                height: 1.0),
                                                          ))))
                                            ],
                                          );
                                        }).toList(),
                                      ))),
                              Center(
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.clear),
                                ),
                              ),
                            ],
                          ),
                        )),
                  );
                },
              );
            },
          )),
      Padding(
          padding: EdgeInsets.all(5),
          child: ElevatedButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () {
              routerDelegate.go('/new_floor');
            },
            child: const Text("New Floor"),
          ))
    ]);
  }

  Map<int, int> setRoomCategory(
      List<RoomVM> rooms, List<CategoryVM> categories) {
    // Only include categories with a non-null id.
    categoryMapping = {
      for (var category in categories) int.parse(category.id): category.name
    };

    Map<int, int> categoryMap = {};
    // Only include rooms with a non-null id.
    roomMapping = {
      for (var room in rooms) int.parse(room.id): room.roomNumber.toString()
    };

    // Build the mapping only for rooms with non-null id,
    // and provide a default value or handle the possibility of a null categoryId.
    for (var room in rooms) {
      // If room.categoryId might be null, you can decide on a default,
      // or skip this room.
      categoryMap[int.parse(room.id)] = room.categoryId;
    }

    return categoryMap;
  }
}
