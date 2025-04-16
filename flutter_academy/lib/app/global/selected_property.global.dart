import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/season.vm.dart';
import 'package:flutter_academy/app/rates/rate_plan.vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/floor.vm.dart';

final ScrollController scrollController1 = ScrollController();
final ScrollController scrollController2 = ScrollController();

/// Utility method to get the number of days in a month
int getDaysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;

/// Selected Month State Management
class SelectedMonthVM extends StateNotifier<DateTime> {
  SelectedMonthVM() : super(DateTime.now());

  DateTime updateMonth(DateTime newMonth) => state = newMonth;
  void reset() => state = DateTime.now();
}

/// Selected Property State Management
class SelectedPropertyVM extends StateNotifier<int> {
  SelectedPropertyVM() : super(0);

  void updateProperty(int newProperty) => state = newProperty;
  void clear() => state = 0;
}

/// Number of Days in Selected Month
class NumberOfDaysVM extends StateNotifier<int> {
  NumberOfDaysVM(DateTime selectedMonth) : super(getDaysInMonth(selectedMonth));

  void updateDays(int newDays) => state = newDays;
}

/// Highlighted Day State Management
class HighlightedDayVM extends StateNotifier<int?> {
  HighlightedDayVM() : super(null);

  void updateDay(int? newDay) => state = newDay;
  void clear() => state = null;
}

/// Highlighted Room State Management
class HighlightedRoomVM extends StateNotifier<int?> {
  HighlightedRoomVM() : super(null);

  void updateRoom(int? newRoom) => state = newRoom;
  void clear() => state = null;
}

/// Floor to Edit State Management
class FloorToEditVM extends StateNotifier<FloorVM?> {
  FloorToEditVM() : super(null);

  void updateFloor(FloorVM floor) => state = floor;
  void clear() => state = null;
}

class RatePlanToEditVM extends StateNotifier<RatePlanVM?> {
  RatePlanToEditVM() : super(null);

  void updateRatePlan(RatePlanVM plan) => state = plan;
  void clear() => state = null;
}

class SeasonToEditVM extends StateNotifier<SeasonVM?> {
  SeasonToEditVM() : super(null);

  void update(SeasonVM season) => state = season;
  void clear() => state = null;
}

/// Providers
final selectedMonthVM = StateNotifierProvider<SelectedMonthVM, DateTime>(
    (ref) => SelectedMonthVM());

final selectedPropertyVM = StateNotifierProvider<SelectedPropertyVM, int?>(
    (ref) => SelectedPropertyVM());

final numberOfDaysVM = StateNotifierProvider<NumberOfDaysVM, int>((ref) {
  final selectedMonth = ref.watch(selectedMonthVM);
  return NumberOfDaysVM(selectedMonth);
});

final highlightedDayVM =
    StateNotifierProvider<HighlightedDayVM, int?>((ref) => HighlightedDayVM());

final highlightedRoomVM = StateNotifierProvider<HighlightedRoomVM, int?>(
    (ref) => HighlightedRoomVM());

final floorToEditVM =
    StateNotifierProvider<FloorToEditVM, FloorVM?>((ref) => FloorToEditVM());

final ratePlanToEditVM = StateNotifierProvider<RatePlanToEditVM, RatePlanVM?>(
    (ref) => RatePlanToEditVM());

final seasonToEditVM =
    StateNotifierProvider<SeasonToEditVM, SeasonVM?>((ref) => SeasonToEditVM());
