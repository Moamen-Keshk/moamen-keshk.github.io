import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/room.vm.dart';
import 'package:flutter_academy/app/courses/view_models/season.vm.dart';
import 'package:flutter_academy/app/courses/widgets/rate_input.widget.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/rates/rate_plan.vm.dart';
import 'package:flutter_academy/app/rates/rate_plan_list.vm.dart';
import 'package:flutter_academy/app/rates/room_rate.model.dart';
import 'package:flutter_academy/app/rates/room_rate_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/season_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/room_list.vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

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
    final roomRates = ref.watch(roomRateListVM);
    final ratePlans = ref.watch(ratePlanListVM);
    final rooms = ref.watch(roomListVM);
    final seasons = ref.watch(seasonListVM);
    final propertyId = ref.read(selectedPropertyVM);

    final roomCategoryMap = _buildRoomCategoryMap(rooms);
    final roomIntId = int.tryParse(roomId);
    if (roomIntId == null) return _buildBadge(0);

    final categoryId = roomCategoryMap[roomIntId]?.toString();

    final override = roomRates.firstWhereOrNull(
      (r) =>
          r.roomRate.roomId == roomId &&
          DateUtils.isSameDay(r.roomRate.date, date),
    );

    final price = override?.roomRate.price ??
        _resolveRoomRate(
          date: date,
          categoryId: categoryId,
          ratePlans: ratePlans,
          seasons: seasons,
        );

    final isOverride = override != null;

    return GestureDetector(
      onTap: () async {
        final newRate = await showDialog<double>(
          context: context,
          builder: (_) => RateInputDialog(
            date: date,
            initialPrice: price,
          ),
        );
        if (newRate != null) {
          final newRoomRate = RoomRate(
            id: '', // Upsert will overwrite ID if exists
            roomId: roomId,
            date: date,
            price: newRate,
            propertyId: propertyId!,
          );
          await ref.read(roomRateListVM.notifier).upsertRoomRate(newRoomRate);
        }
      },
      onLongPress: isOverride
          ? () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Remove Custom Rate?"),
                  content: const Text(
                      "This will revert to the base rate from the rate plan."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Remove"),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref
                    .read(roomRateListVM.notifier)
                    .deleteRoomRate(override.id);
              }
            }
          : null,
      child: _buildBadge(price, isOverride: isOverride),
    );
  }

  Widget _buildBadge(double price, {bool isOverride = false}) {
    return SizedBox(
      height: 35,
      width: 93.9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _getRateColor(price, isOverride),
              border: Border.all(
                color: isOverride ? Colors.blueAccent : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
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
    required DateTime date,
    required String? categoryId,
    required List<RatePlanVM> ratePlans,
    required List<SeasonVM> seasons,
  }) {
    if (categoryId == null) return 0.0;

    final vm = ratePlans.firstWhere(
      (rp) =>
          rp.ratePlan.categoryId == categoryId &&
          !date.isBefore(rp.ratePlan.startDate) &&
          !date.isAfter(rp.ratePlan.endDate),
      orElse: () => RatePlanVM.empty(date),
    );

    double rate = vm.ratePlan.baseRate;

    if ((date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) &&
        vm.ratePlan.weekendRate != null) {
      rate = vm.ratePlan.weekendRate!;
    }

    final isInSeason = seasons.any(
      (season) =>
          !date.isBefore(season.startDate) && !date.isAfter(season.endDate),
    );

    if (isInSeason && vm.ratePlan.seasonalMultiplier != null) {
      rate *= vm.ratePlan.seasonalMultiplier!;
    }

    return rate;
  }

  Color _getRateColor(double price, bool isOverride) {
    if (isOverride) {
      if (price < 50) return Colors.lightBlue[100]!;
      if (price < 100) return Colors.lightBlue[300]!;
      return Colors.blue[400]!;
    } else {
      if (price < 50) return Colors.green[200]!;
      if (price < 100) return Colors.orange[200]!;
      return Colors.red[200]!;
    }
  }

  Map<int, int> _buildRoomCategoryMap(List<RoomVM> rooms) {
    return {
      for (var room in rooms)
        if (int.tryParse(room.id) != null) int.parse(room.id): room.categoryId,
    };
  }
}
