import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';

class CalendarHeader extends StatelessWidget {
  static const double regularDayColumnWidth = 93.9;
  static const double compactDayColumnWidth = 76.0;
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
      final isCompact = context.showCompactLayout;
      final dayColumnWidth =
          isCompact ? compactDayColumnWidth : regularDayColumnWidth;

      return SizedBox(
        height: isCompact ? 64 : 70,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: daysInMonth.map((day) {
              final isToday = day.day == today.day &&
                  day.month == today.month &&
                  day.year == today.year;
              final isHighlighted = !isCompact && day.day == highlightedDay;

              return SizedBox(
                width: dayColumnWidth,
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
                      onTap: isCompact
                          ? null
                          : () {
                              ref
                                  .read(highlightedDayVM.notifier)
                                  .updateDay(day.day);
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: isCompact ? 32 : 42,
                        width: isCompact ? 32 : 42,
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.blue
                              : isHighlighted
                                  ? Colors.green[200]
                                  : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(isCompact ? 4 : 10),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: isToday ? Colors.white : Colors.black,
                              fontSize: isCompact ? 11 : 14,
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
