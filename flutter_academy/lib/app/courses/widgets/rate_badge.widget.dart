import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/widgets/rate_input.widget.dart';
import 'package:flutter_academy/infrastructure/courses/model/room_online.model.dart';
import 'package:flutter_academy/app/courses/view_models/lists/room_online_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
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
    final roomOnlineList = ref.watch(roomOnlineListVM);
    final propertyId = ref.read(selectedPropertyVM);

    final override = roomOnlineList.firstWhereOrNull(
      (r) =>
          r.roomOnline.roomId == roomId &&
          DateUtils.isSameDay(r.roomOnline.date, date),
    );

    final price = override?.roomOnline.price ?? 0.0;
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
          final categoryId = override?.roomOnline.categoryId;
          if (categoryId != null && propertyId != null) {
            final newRoomOnline = RoomOnline(
              id: override?.id ?? '', // Upsert will overwrite if exists
              roomId: roomId,
              date: date,
              price: newRate,
              propertyId: propertyId,
              categoryId: categoryId,
            );
            await ref
                .read(roomOnlineListVM.notifier)
                .upsertRoomOnline(newRoomOnline);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Missing category or property ID.')),
            );
          }
        }
      },
      onLongPress: isOverride
          ? () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Remove Custom Rate?"),
                  content: const Text("This will clear the rate override."),
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
                    .read(roomOnlineListVM.notifier)
                    .deleteRoomOnline(override.id);
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
              // ✅ No background color here
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
}
