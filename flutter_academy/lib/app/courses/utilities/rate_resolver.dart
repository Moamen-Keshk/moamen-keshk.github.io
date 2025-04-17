import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_rate_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/rate_plan_list.vm.dart';
import 'package:collection/collection.dart';

class RateResolver {
  final WidgetRef ref;

  RateResolver(this.ref);

  double? getRateForRoomAndDate({
    required String roomId,
    required DateTime date,
    required String categoryId,
  }) {
    final roomRates = ref.read(roomRateListVM);
    final ratePlans = ref.read(ratePlanListVM);

    final match = roomRates.firstWhereOrNull(
      (r) =>
          r.roomId == roomId &&
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day,
    );
    if (match != null) return match.price;

    final plan = ratePlans.firstWhereOrNull(
      (rp) =>
          rp.categoryId == categoryId &&
          !date.isBefore(rp.startDate) &&
          !date.isAfter(rp.endDate) &&
          rp.isActive,
    );
    if (plan == null) return null;

    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    return isWeekend && plan.weekendRate != null
        ? plan.weekendRate
        : plan.baseRate;
  }
}
