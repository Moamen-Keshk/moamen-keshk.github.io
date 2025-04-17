import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';

class CalendarHeader extends StatelessWidget {
  final List<DateTime> daysInMonth;
  final ScrollController scrollController;

  const CalendarHeader({
    super.key,
    required this.daysInMonth,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final highlightedDay = ref.watch(highlightedDayVM);
      final today = DateTime.now();

      return SizedBox(
        height: 70,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: daysInMonth.map((day) {
              final isToday = day.day == today.day &&
                  day.month == today.month &&
                  day.year == today.year;
              final isHighlighted = day.day == highlightedDay;

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
                    GestureDetector(
                      onTap: () {
                        ref.read(highlightedDayVM.notifier).updateDay(day.day);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
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
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}
