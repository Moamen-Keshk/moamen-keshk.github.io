import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabBarViewContainer extends StatelessWidget {
  final int tabIndex;
  final TabController tabController;
  final int tabSize;

  const TabBarViewContainer({
    super.key,
    required this.tabIndex,
    required this.tabController,
    required this.tabSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 93.9,
      color: Colors.blue[100 * (tabIndex + 1)], // Different color for each tab
      child: Center(
        child: GestureDetector(
          onTap: () {
            tabController.animateTo(tabIndex);
          },
          child: Text(
            "Tab $tabIndex\nSize: $tabSize",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class TabIndexNotifier extends StateNotifier<int> {
  TabIndexNotifier() : super(0);

  void setIndex(int index) => state = index;
}

final tabIndexProvider = StateNotifierProvider<TabIndexNotifier, int>((ref) {
  return TabIndexNotifier();
});

class FloorRooms extends StatefulWidget {
  const FloorRooms({super.key});

  get outerTab => null;

  @override
  State<FloorRooms> createState() => _FloorRoomsState();
}

class _FloorRoomsState extends State<FloorRooms> with TickerProviderStateMixin {
  late TabController _tabController;

  // Sample data: list of bookings

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    scrollController1.addListener(() {
      if (scrollController2.hasClients) {
        scrollController2.jumpTo(scrollController1.offset);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    scrollController1.dispose();
    scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final floors = ref.watch(floorListVM);
      final bookings = ref.watch(bookingListVM);
      _tabController = TabController(length: bookings.length, vsync: this);
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Row(children: [
            Column(
                children: floors.map<Column>((FloorVM floor) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 100,
                        height: 25,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text('Floor ${floor.number.toString()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ))),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: floor.rooms.map<Container>((Room room) {
                          return Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 35,
                              padding: EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Room ${room.roomNumber.toString()}',
                                  style: TextStyle(
                                    fontSize: 15,
                                  )));
                        }).toList())
                  ]);
            }).toList()),
            Expanded(
              child: Consumer(builder: (context, ref, child) {
                final numberOfDays = ref.watch(numberOfDaysVM);
                return SingleChildScrollView(
                    controller: scrollController2,
                    physics: ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Column(
                        children: floors.map<Padding>((FloorVM floor) {
                      return Padding(
                          padding: EdgeInsets.only(top: 25),
                          child: Column(
                              children: floor.rooms.map<Row>((Room room) {
                            final bookingsPerRoom =
                                isRoomHasBooking(bookings, int.parse(room.id!));
                            final bookingMapping =
                                isDayHasBooking(bookingsPerRoom);
                            final tabPositions = bookingMapping.keys.toList();
                            final tabSizes = tabSizeMapping(bookingMapping);
                            return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(numberOfDays, (index) {
                                  if (tabPositions.contains(index + 1)) {
                                    // Check if this index is a tab position
                                    final tabIndex =
                                        tabPositions.indexOf(index + 1);
                                    final tabSize = tabSizes[index + 1] ?? 1;
                                    return Flexible(
                                      flex: tabSize,
                                      fit: FlexFit.loose,
                                      child: TabBarViewContainer(
                                        tabIndex: tabIndex,
                                        tabController: _tabController,
                                        tabSize: tabSize,
                                      ),
                                    );
                                  } else {
                                    // Empty cell
                                    return SizedBox(
                                      height: 35,
                                      width: 93.9,
                                      child: Container(
                                        color: Colors.grey[200],
                                        margin: EdgeInsets.all(2),
                                        child: null,
                                      ),
                                    );
                                  }
                                }));
                          }).toList()));
                    }).toList()));
              }),
            )
          ]));
    });
  }

  List<BookingVM> isRoomHasBooking(List<BookingVM> bookings, int roomId) {
    // Filter bookings that belong to the given room ID
    return bookings.where((booking) => booking.roomID == roomId).toList();
  }

  Map<int, BookingVM> isDayHasBooking(List<BookingVM> bookingPerRoom) {
    Map<int, BookingVM> bookingsMap = {};
    for (BookingVM booking in bookingPerRoom) {
      bookingsMap[booking.checkInDay] = booking;
    }
    return Map.fromEntries(
      bookingsMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  Map<int, int> tabSizeMapping(Map<int, BookingVM> mapping) {
    Map<int, int> sizes = {};
    mapping.forEach((key, value) {
      sizes[key] = value.numberOfNights;
    });
    return sizes;
  }
}
