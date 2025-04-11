import 'package:flutter/material.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends StatefulWidget {
  final List<DateTime> daysInMonth;

  const CalendarHeader({super.key, required this.daysInMonth});

  @override
  State<CalendarHeader> createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends State<CalendarHeader> {
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
    scrollController1.dispose();
    scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final highlightedDay = ref.watch(highlightedDayVM);
        return SizedBox(
          height: 70,
          child: SingleChildScrollView(
            controller: scrollController1,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.daysInMonth.map<Widget>((day) {
                final DateTime today = DateTime.now();
                final bool isToday = day.day == today.day &&
                    day.month == today.month &&
                    day.year == today.year;
                final bool isHighlighted = day.day == highlightedDay;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.E().format(day),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.blue
                              : isHighlighted
                                  ? Colors.green[200]
                                  : Colors.grey[200],
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
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
