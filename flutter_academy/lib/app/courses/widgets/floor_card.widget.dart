import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class FloorCard extends StatefulWidget {
  const FloorCard({super.key});

  @override
  State<FloorCard> createState() => _FloorCardState();
}

class _FloorCardState extends State<FloorCard> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Sample data: reservations mapped by date
  final Map<DateTime, List<String>> _reservations = {
    DateTime(2024, 11, 11): ['Room 101', 'Room 202'],
    DateTime(2024, 11, 12): ['Room 103'],
    DateTime(2024, 11, 13): ['Room 102', 'Room 204', 'Room 305'],
  };

  List<String> _getReservationsForDay(DateTime date) {
    return _reservations[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 0,
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  eventLoader: _getReservationsForDay,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: _buildReservationList(),
                ),
              ],
            )));
  }

  Widget _buildReservationList() {
    final reservations = _getReservationsForDay(_selectedDay ?? _focusedDay);
    if (reservations.isEmpty) {
      return Center(
        child: Text('No Reservations'),
      );
    }
    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(reservations[index]),
        );
      },
    );
  }
}
