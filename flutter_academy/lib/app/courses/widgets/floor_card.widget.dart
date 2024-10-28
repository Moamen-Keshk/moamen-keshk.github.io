import 'package:flutter/material.dart';

class Room {
  final String type;
  final int availableRooms;
  final double price;

  const Room({required this.type, required this.availableRooms, required this.price});
}

class FloorCard extends StatelessWidget {
   const FloorCard({super.key});

  final List<Room> rooms = const [
    Room(type: 'Single', availableRooms: 5, price: 120),
    Room(type: 'Double', availableRooms: 3, price: 150),
    Room(type: 'Suite', availableRooms: 2, price: 300),
    Room(type: 'Penthouse', availableRooms: 1, price: 500),
  ];

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(64),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        TableRow(
          children: <Widget>[
            Container(
              height: 32,
              color: Colors.green,
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.top,
              child: Container(
                height: 32,
                width: 32,
                color: Colors.red,
              ),
            ),
            Container(
              height: 64,
              color: Colors.blue,
            ),
          ],
        ),
        TableRow(
          decoration: const BoxDecoration(
            color: Colors.grey,
          ),
          children: <Widget>[
            Container(
              height: 64,
              width: 128,
              color: Colors.purple,
            ),
            Container(
              height: 32,
              color: Colors.yellow,
            ),
            Center(
              child: Container(
                height: 32,
                width: 32,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

