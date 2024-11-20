import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';
import 'package:flutter_academy/app/courses/view_models/floor_list.vm.dart';
import 'package:flutter_academy/infrastructure/courses/model/room.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Booking {
  final String guestName;
  final String room;
  final String checkIn;
  final String checkOut;

  Booking({
    required this.guestName,
    required this.room,
    required this.checkIn,
    required this.checkOut,
  });
}

class FloorRooms extends StatefulWidget {
  const FloorRooms({super.key});

  get outerTab => null;

  @override
  State<FloorRooms> createState() => _FloorRoomsState();
}

class _FloorRoomsState extends State<FloorRooms>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data: list of bookings
  final List<Booking> bookings = [
    Booking(
        guestName: 'John Doe',
        room: '101',
        checkIn: '2024-11-16',
        checkOut: '2024-11-20'),
    Booking(
        guestName: 'Alice Smith',
        room: '102',
        checkIn: '2024-11-18',
        checkOut: '2024-11-22'),
    Booking(
        guestName: 'Bob Johnson',
        room: '103',
        checkIn: '2024-11-19',
        checkOut: '2024-11-23'),
    Booking(
        guestName: 'John Doe',
        room: '101',
        checkIn: '2024-11-16',
        checkOut: '2024-11-20'),
    Booking(
        guestName: 'Alice Smith',
        room: '102',
        checkIn: '2024-11-18',
        checkOut: '2024-11-22'),
    Booking(
        guestName: 'Bob Johnson',
        room: '103',
        checkIn: '2024-11-19',
        checkOut: '2024-11-23'),
    Booking(
        guestName: 'John Doe',
        room: '101',
        checkIn: '2024-11-16',
        checkOut: '2024-11-20'),
    Booking(
        guestName: 'Alice Smith',
        room: '102',
        checkIn: '2024-11-18',
        checkOut: '2024-11-22'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: bookings.length, vsync: this);
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
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Column(
              children: floors.map<Padding>((FloorVM floor) {
            return Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Column(children: [
                  Row(children: [
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
                  ]),
                  Column(
                      children: floor.rooms.map<Padding>((Room room) {
                    return Padding(
                        padding: EdgeInsets.symmetric(vertical: 1),
                        child: Row(children: [
                          Container(
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
                                  ))),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Wrap(
                                spacing: 6.0,
                                runSpacing: 6.0,
                                children: List.generate(
                                  bookings.length,
                                  (index) => ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _tabController.animateTo(index);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _tabController.index == index
                                              ? Colors.blue
                                              : Colors.grey,
                                    ),
                                    child: Text(bookings[index].guestName),
                                  ),
                                ),
                              )),
                        ]));
                  }).toList()),
                ]));
          }).toList()));
    });
  }
}
