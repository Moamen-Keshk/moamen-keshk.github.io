import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/floor.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomLabelColumn extends ConsumerWidget {
  static const double compactRoomLabelWidth = 112;
  static const double regularRoomLabelWidth = 160;

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
    final isCompact = context.showCompactLayout;
    return Column(
      children: floors.map<Widget>((floor) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isCompact ? 70 : 100,
              height: isCompact ? 22 : 25,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                vertical: isCompact ? 2 : 4,
                horizontal: isCompact ? 8 : 20,
              ),
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Floor ${floor.number}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 11 : 14,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: floor.rooms.map<Widget>((room) {
                final roomId = int.parse(room.id);
                final isHighlighted = !isCompact && roomId == highlightedRoom;

                return Container(
                  alignment: Alignment.center,
                  width:
                      isCompact ? compactRoomLabelWidth : regularRoomLabelWidth,
                  height: isCompact ? 36 : 35,
                  padding: EdgeInsets.only(
                    bottom: isCompact ? 1 : 2,
                    top: isCompact ? 4 : 6,
                    left: 6,
                    right: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isHighlighted ? Colors.green[200] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Room ${room.roomNumber}',
                        style: TextStyle(
                          fontSize: isCompact ? 11 : 16,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        categoryMapping[roomsCategoryMapping[roomId]] ?? '',
                        style: TextStyle(
                          fontSize: isCompact ? 8.5 : 11,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
