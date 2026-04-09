import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/view_models/season.vm.dart';
import 'package:lotel_pms/app/api/view_models/rate_plan.vm.dart';
import 'package:lotel_pms/app/api/view_models/floor.vm.dart';
import 'package:lotel_pms/app/api/view_models/property.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/property_list.vm.dart';

import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;

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
// ✅ FIXED: Now safely extends StateNotifier<int?> to match your UI logic
class SelectedPropertyVM extends StateNotifier<int?> {
  SelectedPropertyVM() : super(null); // Defaults to null (no property selected)

  void updateProperty(int? newProperty) => state = newProperty;
  void clear() => state = null;
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

// ==========================================
// PROVIDERS
// ==========================================

final selectedMonthVM = StateNotifierProvider<SelectedMonthVM, DateTime>(
    (ref) => SelectedMonthVM());

final selectedPropertyVM = StateNotifierProvider<SelectedPropertyVM, int?>(
    (ref) => SelectedPropertyVM());

// Backwards-compatible provider for screens that expect the selected property.
final selectedPropertyProvider = Provider<PropertyVM?>((ref) {
  final selectedPropertyId = ref.watch(selectedPropertyVM);
  if (selectedPropertyId == null) {
    return null;
  }

  final properties = ref.watch(propertyListVM);
  for (final property in properties) {
    if (int.tryParse(property.id) == selectedPropertyId) {
      return property;
    }
  }

  return null;
});

// 💡 PRO-TIP OPTIMIZATION:
// Since the number of days is purely derived from the selected month,
// you don't need a heavy StateNotifier for it! A simple Provider is faster
// and will automatically update whenever the month changes.
final numberOfDaysVM = Provider<int>((ref) {
  final selectedMonth = ref.watch(selectedMonthVM);
  return getDaysInMonth(selectedMonth);
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
