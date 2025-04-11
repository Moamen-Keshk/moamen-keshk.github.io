import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomLabelColumn extends ConsumerWidget {
  final List<FloorVM> floors;
  final Map<int, int> roomsCategoryMapping;
  final Map<int, String> categoryMapping;

  const RoomLabelColumn({
    super.key,
    required this.floors,
    required this.roomsCategoryMapping,
    required this.categoryMapping,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlightedRoom = ref.watch(highlightedRoomVM);
    return Column(
      children: floors.map<Widget>((floor) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 25,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Floor ${floor.number}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: floor.rooms.map<Widget>((room) {
                final roomId = int.parse(room.id);
                final isHighlighted = roomId == highlightedRoom;

                return Container(
                  alignment: Alignment.center,
                  width: 160,
                  height: 35,
                  padding:
                      EdgeInsets.only(bottom: 2, top: 6, left: 6, right: 6),
                  decoration: BoxDecoration(
                    color:
                        isHighlighted ? Colors.green[200] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Room ${room.roomNumber}',
                        style: const TextStyle(fontSize: 16, height: 1.0),
                      ),
                      Text(
                        categoryMapping[roomsCategoryMapping[roomId]] ?? '',
                        style: const TextStyle(fontSize: 11, height: 1.0),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }).toList(),
    );
  }
}
