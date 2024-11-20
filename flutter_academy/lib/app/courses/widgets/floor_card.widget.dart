import 'package:flutter/material.dart';

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

class BookingTabPage extends StatefulWidget {
  const BookingTabPage({super.key});

  get outerTab => null;

  @override
  State<BookingTabPage> createState() => _BookingTabPageState();
}

class _BookingTabPageState extends State<BookingTabPage>
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
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
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
                    _tabController.index == index ? Colors.blue : Colors.grey,
              ),
              child: Text(bookings[index].guestName),
            ),
          ),
        ),
      ),
      SizedBox(
        height: 100,
        child: TabBarView(
          controller: _tabController,
          children: bookings.map((booking) {
            return Center(child: Text(booking.checkOut));
          }).toList(),
        ),
      ),
    ]);
  }
}
