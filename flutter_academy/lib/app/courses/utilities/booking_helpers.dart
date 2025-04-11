import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room.vm.dart';

Map<int, int> setRoomCategory(
  List<RoomVM> rooms,
  List<CategoryVM> categories,
  Map<int, String> categoryMapping,
  Map<int, String> roomMapping,
) {
  // Fill categoryMapping
  categoryMapping.addAll(
      {for (var category in categories) int.parse(category.id): category.name});

  // Fill roomMapping and build category map
  Map<int, int> categoryMap = {};
  roomMapping.addAll({
    for (var room in rooms)
      if (room.id case var id when int.tryParse(id) != null)
        int.parse(id): room.roomNumber.toString()
  });

  for (var room in rooms) {
    final roomId = int.tryParse(room.id) ?? 0;
    categoryMap[roomId] = room.categoryId;
  }

  return categoryMap;
}
