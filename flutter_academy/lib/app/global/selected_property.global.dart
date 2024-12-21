import 'package:flutter_riverpod/flutter_riverpod.dart';

final now = DateTime.now(); // Get the current date
final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

class SelectedMonthVM extends StateNotifier<DateTime> {
  SelectedMonthVM() : super(DateTime.now());

  DateTime? updateMonth(DateTime newMonth) {
    state = newMonth;
    return newMonth;
  }
}

final selectedMonthVM = StateNotifierProvider<SelectedMonthVM, DateTime>(
    (ref) => SelectedMonthVM());

class SelectedPropertyVM extends StateNotifier<int> {
  SelectedPropertyVM() : super(0);

  void updateProperty(int newProperty) {
    state = newProperty;
  }
}

final selectedPropertyVM = StateNotifierProvider<SelectedPropertyVM, int>(
    (ref) => SelectedPropertyVM());

class NumberOfDaysVM extends StateNotifier<int> {
  NumberOfDaysVM() : super(daysInMonth);

  void updateDays(int newDays) {
    state = newDays;
  }
}

final numberOfDaysVM =
    StateNotifierProvider<NumberOfDaysVM, int>((ref) => NumberOfDaysVM());

class HighlightedDayVM extends StateNotifier<int> {
  HighlightedDayVM() : super(0);

  void updateDay(int newDay) {
    state = newDay;
  }
}

final highlightedDayVM =
    StateNotifierProvider<HighlightedDayVM, int>((ref) => HighlightedDayVM());

class HighlightedRoomVM extends StateNotifier<int> {
  HighlightedRoomVM() : super(0);

  void updateRoom(int newRoom) {
    state = newRoom;
  }
}

final highlightedRoomVM =
    StateNotifierProvider<HighlightedRoomVM, int>((ref) => HighlightedRoomVM());
