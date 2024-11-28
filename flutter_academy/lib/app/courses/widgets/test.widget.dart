import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/widgets/floor_with_rooms.widget.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class SingleRowMonthCalendar extends StatefulWidget {
  const SingleRowMonthCalendar({super.key});

  @override
  State<SingleRowMonthCalendar> createState() => _SingleRowMonthCalendarState();
}

class _SingleRowMonthCalendarState extends State<SingleRowMonthCalendar> {
  late List<DateTime> _daysInMonth;

  @override
  void initState() {
    super.initState();
    scrollController2.addListener(() {
      if (scrollController1.hasClients) {
        scrollController1.jumpTo(scrollController2.offset);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
    return Consumer(builder: (context, ref, child) {
      final selectedMonth = ref.watch(selectedMonthVM);
      _daysInMonth = _getDaysInMonth(selectedMonth.year, selectedMonth.month);
      return Column(children: [
        Row(children: [
          Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(children: [
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )),
                    onPressed: () async {
                      final localSelectedMonth = ref
                          .read(selectedMonthVM.notifier)
                          .state = (await showMonthYearPicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(20),
                        lastDate: DateTime(2027),
                      ))!;
                      ref.read(numberOfDaysVM.notifier).state = DateTime(
                              localSelectedMonth.year,
                              localSelectedMonth.month + 1,
                              0)
                          .day;
                    },
                    child: Text(
                      DateFormat('MMMM yyyy').format(selectedMonth).toString(),
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                    alignment: Alignment.center,
                    width: 160,
                    height: 35,
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Rooms',
                        style: TextStyle(
                          fontSize: 15,
                        ))),
              ])),
          Expanded(
              child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                  height: 70,
                  child: ListView.builder(
                    controller: scrollController1,
                    physics: ClampingScrollPhysics(),
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
        ]),
        Row(children: [
          Expanded(child: FloorRooms()),
        ])
      ]);
    });
  }
}
