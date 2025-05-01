import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_online_list.vm.dart';
import 'package:collection/collection.dart';

class RateResolver {
  final WidgetRef ref;

  RateResolver(this.ref);

  double? getRateForRoomAndDate({
    required String roomId,
    required DateTime date,
    String? categoryId, // unused now but kept for compatibility
  }) {
    final roomRates = ref.read(roomOnlineListVM);

    final match = roomRates.firstWhereOrNull(
      (r) =>
          r.roomId == roomId &&
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day,
    );

    return match?.price;
  }
}
