import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room_list.vm.dart';
import 'package:flutter_academy/app/rates/rate_plan.vm.dart';
import 'package:flutter_academy/app/rates/rate_plan_list.vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<int, int> roomsCategoryMapping = {};
Map<int, String> roomMapping = {};
Map<int, String> categoryMapping = {};

class RateBadgeWidget extends ConsumerWidget {
  final String roomId;
  final DateTime date;

  const RateBadgeWidget({
    super.key,
    required this.roomId,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratePlanVMs = ref.watch(ratePlanListVM);
    roomsCategoryMapping = _setRoomCategory(
      ref.read(roomListVM),
      ref.read(categoryListVM),
    );

    final price = _resolveRoomRate(
      roomId: roomId,
      date: date,
      ratePlanVMs: ratePlanVMs,
    );

    return SizedBox(
      height: 35,
      width: 93.9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(2),
            color: _getRateColor(price),
          ),
          Text(
            '\$${price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  double _resolveRoomRate({
    required String roomId,
    required DateTime date,
    required List<RatePlanVM> ratePlanVMs,
  }) {
    final roomIntId = int.tryParse(roomId) ?? 0;
    final categoryId = roomsCategoryMapping[roomIntId]?.toString();

    final vm = ratePlanVMs.firstWhere(
      (rp) =>
          rp.ratePlan.categoryId == categoryId &&
          date.isAfter(
              rp.ratePlan.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(rp.ratePlan.endDate.add(const Duration(days: 1))),
      orElse: () => RatePlanVM.empty(date),
    );

    double rate = vm.ratePlan.baseRate;

    if ((date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) &&
        vm.ratePlan.weekendRate != null) {
      rate = vm.ratePlan.weekendRate!;
    }

    if (vm.ratePlan.seasonalMultiplier != null) {
      rate *= vm.ratePlan.seasonalMultiplier!;
    }

    return rate;
  }

  Color _getRateColor(double price) {
    if (price < 50) return Colors.green[200]!;
    if (price < 100) return Colors.orange[200]!;
    return Colors.red[200]!;
  }

  Map<int, int> _setRoomCategory(
      List<RoomVM> rooms, List<CategoryVM> categories) {
    categoryMapping = {
      for (var category in categories) int.parse(category.id): category.name
    };

    roomMapping = {
      for (var room in rooms)
        if (room.id case var id when int.tryParse(id) != null)
          int.parse(id): room.roomNumber.toString()
    };

    final categoryMap = <int, int>{};
    for (var room in rooms) {
      final roomId = int.tryParse(room.id) ?? 0;
      categoryMap[roomId] = room.categoryId;
    }

    return categoryMap;
  }
}
