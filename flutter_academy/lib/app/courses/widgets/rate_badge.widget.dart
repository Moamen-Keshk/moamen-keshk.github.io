import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/room.vm.dart';
import 'package:flutter_academy/app/courses/view_models/season.vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/room_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/season_list.vm.dart';
import 'package:flutter_academy/app/rates/rate_plan.vm.dart';
import 'package:flutter_academy/app/rates/rate_plan_list.vm.dart';

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
    final ratePlans = ref.watch(ratePlanListVM);
    final rooms = ref.watch(roomListVM);
    final seasons = ref.watch(seasonListVM);

    final roomCategoryMap = _buildRoomCategoryMap(rooms);
    final roomIntId = int.tryParse(roomId);

    if (roomIntId == null) {
      return _buildBadge(0); // fallback if room ID is not an int
    }

    final categoryId = roomCategoryMap[roomIntId]?.toString();

    final price = _resolveRoomRate(
      date: date,
      categoryId: categoryId,
      ratePlans: ratePlans,
      seasons: seasons,
    );

    return _buildBadge(price);
  }

  /// Builds the visual badge with price and background color
  Widget _buildBadge(double price) {
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

  /// Calculates the applicable rate for a room and date
  double _resolveRoomRate({
    required DateTime date,
    required String? categoryId,
    required List<RatePlanVM> ratePlans,
    required List<SeasonVM> seasons,
  }) {
    final vm = ratePlans.firstWhere(
      (rp) =>
          rp.ratePlan.categoryId == categoryId &&
          date.isAfter(
              rp.ratePlan.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(rp.ratePlan.endDate.add(const Duration(days: 1))),
      orElse: () => RatePlanVM.empty(date),
    );

    double rate = vm.ratePlan.baseRate;

    // Use weekend rate if available
    if ((date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) &&
        vm.ratePlan.weekendRate != null) {
      rate = vm.ratePlan.weekendRate!;
    }

    // Check if the date is inside any season
    final isInSeason = seasons.any(
      (season) =>
          date.isAfter(season.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(season.endDate.add(const Duration(days: 1))),
    );

    // Apply seasonal multiplier if present
    if (isInSeason && vm.ratePlan.seasonalMultiplier != null) {
      rate *= vm.ratePlan.seasonalMultiplier!;
    }

    return rate;
  }

  /// Returns a background color based on price
  Color _getRateColor(double price) {
    if (price < 50) return Colors.green[200]!;
    if (price < 100) return Colors.orange[200]!;
    return Colors.red[200]!;
  }

  /// Builds a map of roomId (int) -> categoryId (int)
  Map<int, int> _buildRoomCategoryMap(List<RoomVM> rooms) {
    return {
      for (var room in rooms)
        if (int.tryParse(room.id) != null) int.parse(room.id): room.categoryId,
    };
  }
}
