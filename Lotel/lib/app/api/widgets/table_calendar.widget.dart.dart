import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HotelCalendar extends StatefulWidget {
  const HotelCalendar({super.key});

  @override
  State<HotelCalendar> createState() => _HotelCalendarState();
}

class _HotelCalendarState extends State<HotelCalendar> {
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _expand = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SingleChildScrollView(
          child: TableCalendar(
        firstDay: DateTime(2000),
        lastDay: DateTime(2100),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {CalendarFormat.week: 'Week'},
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _expand = !_expand;
        },
        calendarStyle: CalendarStyle(
          markerDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
        ),
      )),
      _expand ? const Text('Done') : Text('Not yet')
    ]);
  }
}
