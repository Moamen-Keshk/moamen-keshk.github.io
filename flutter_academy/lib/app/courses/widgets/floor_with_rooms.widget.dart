import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/booking.vm.dart';
import 'package:flutter_academy/app/courses/view_models/booking_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabBarViewContainer extends StatefulWidget {
  final int tabIndex;
  final TabController tabController;
  final int tabSize;
  final BookingVM booking;

  const TabBarViewContainer({
    super.key,
    required this.tabIndex,
    required this.tabController,
    required this.tabSize,
    required this.booking,
  });

  @override
  State<TabBarViewContainer> createState() => _TabBarViewContainerState();
}

class _TabBarViewContainerState extends State<TabBarViewContainer> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  void toggleAppearance() {
    setState(() {
      _focusNode.requestFocus();
      _isFocused = !_isFocused;
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.tabController.animateTo(widget.tabIndex);
        _focusNode.requestFocus();
      },
      child: Focus(
          focusNode: _focusNode,
          child: Container(
            height: 35,
            width: 93.9 * widget.tabSize,
            decoration: BoxDecoration(
              color: _isFocused ? Colors.blue[500] : Colors.blue[300],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                  "${widget.booking.firstName} ${widget.booking.lastName}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white)),
            ),
          )),
    );
  }
}

class FloorRooms extends StatefulWidget {
  const FloorRooms({super.key});

  @override
  State<FloorRooms> createState() => _FloorRoomsState();
}

class _FloorRoomsState extends State<FloorRooms> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        child: Column(
          children: [
            SizedBox(
                height: 530,
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Row(
                    children: [
                      Column(
                        children: floors.map<Column>((FloorVM floor) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 25,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.blue[300],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'Floor ${floor.number.toString()}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    floor.rooms.map<Container>((Room room) {
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
                                    child: Text(
                                      'Room ${room.roomNumber.toString()}',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      Expanded(
                        child: Consumer(builder: (context, ref, child) {
                          final numberOfDays = ref.watch(numberOfDaysVM);
                          int i = 0;
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
                                      final bookingsPerRoom = isRoomHasBooking(
                                          bookings, int.parse(room.id!));
                                      final bookingMapping =
                                          isDayHasBooking(bookingsPerRoom);
                                      final tabPositions =
                                          bookingMapping.keys.toList();
                                      final tabSizes =
                                          tabSizeMapping(bookingMapping);

                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: () {
                                          List<Widget> rowChildren = [];
                                          int currentDay = 1;

                                          while (currentDay <= numberOfDays) {
                                            if (tabPositions
                                                .contains(currentDay)) {
                                              final tabIndex = i;
                                              final tabSize =
                                                  tabSizes[currentDay] ?? 1;

                                              rowChildren.add(
                                                Flexible(
                                                  flex: tabSize,
                                                  fit: FlexFit.loose,
                                                  child: TabBarViewContainer(
                                                      tabIndex: tabIndex,
                                                      tabController:
                                                          _tabController,
                                                      tabSize: tabSize,
                                                      booking: bookingMapping[
                                                          currentDay]!),
                                                ),
                                              );

                                              currentDay += tabSize;
                                              i++;
                                            } else {
                                              rowChildren.add(
                                                SizedBox(
                                                  height: 35,
                                                  width: 93.9,
                                                  child: Container(
                                                    color: Colors.grey[200],
                                                    margin: EdgeInsets.all(2),
                                                  ),
                                                ),
                                              );

                                              currentDay++;
                                            }
                                          }

                                          return rowChildren;
                                        }(),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                )),
            SizedBox(
              height: 80,
              child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        physics: NeverScrollableScrollPhysics(),
                        children: bookings.map((booking) {
                          return Center(
                            child: Text(
                              'Details for Booking ID: ${booking.id}',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                      ))),
            ),
          ],
        ),
      );
    });
  }

  List<BookingVM> isRoomHasBooking(List<BookingVM> bookings, int roomId) {
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
