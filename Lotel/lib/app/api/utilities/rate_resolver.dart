import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_online_list.vm.dart';

class RateResolver {
  final WidgetRef ref;

  RateResolver(this.ref);

  double? getRateForRoomAndDate({
    required String roomId,
    required DateTime date,
    String? categoryId, // unused now but kept for compatibility
  }) {
    final match =
        ref.read(roomOnlineIndexProvider)[roomOnlineCellKey(roomId, date)];
    return match?.price;
  }
}
