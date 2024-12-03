import 'package:flutter_riverpod/flutter_riverpod.dart';

final now = DateTime.now(); // Get the current date
final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

final selectedPropertyVM = StateProvider<int>((ref) => 0);

final selectedMonthVM = StateProvider<DateTime>((ref) => DateTime.now());

final numberOfDaysVM = StateProvider<int>((ref) => daysInMonth);
