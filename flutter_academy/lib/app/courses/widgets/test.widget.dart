import 'package:flutter/material.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

final formatter = DateFormat('MMM');

class SingleRowMonthCalendar extends ConsumerStatefulWidget {
  const SingleRowMonthCalendar({super.key});

  @override
  ConsumerState<SingleRowMonthCalendar> createState() =>
      _SingleRowMonthCalendarState();
}

class _SingleRowMonthCalendarState
    extends ConsumerState<SingleRowMonthCalendar> {
  late List<DateTime> _daysInMonth;

  @override
  void initState() {
    super.initState();
  }

  List<DateTime> _getDaysInMonth(int year, int month) {
    // Get the total days in the current month
    int daysCount = DateTime(year, month + 1, 0).day;
    return List<DateTime>.generate(
      daysCount,
      (index) => DateTime(year, month, index + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthVM);
    _daysInMonth = _getDaysInMonth(selectedMonth.year, selectedMonth.month);
    return Column(children: [
      Row(children: [
        Column(children: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              )),
              onPressed: () async {
                ref.read(selectedMonthVM.notifier).state =
                    (await showMonthYearPicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(20),
                  lastDate: DateTime(2027),
                ))!;
                setState(() {});
              },
              child: Text(
                DateFormat('MMMM yyyy').format(selectedMonth).toString(),
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          Text('Rooms',
              style: TextStyle(
                fontSize: 16.0, // Font size
                color: Colors.grey, // Text color
              )),
        ]),
        Expanded(
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _daysInMonth.length,
                  itemBuilder: (context, index) {
                    DateTime day = _daysInMonth[index];
                    DateTime today = DateTime.now();
                    bool isToday = day.day == today.day &&
                        day.month == today.month &&
                        day.year == today.year;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat.E().format(
                                day), // Short weekday name (e.g., Mon, Tue)
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: isToday ? Colors.blue : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Center(
                                child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: isToday ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                          ),
                        ],
                      ),
                    );
                  },
                )),
          ),
        ]))
      ])
    ]);
  }
}
