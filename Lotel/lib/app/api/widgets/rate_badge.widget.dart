import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_online_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/room_online.vm.dart';
import 'package:lotel_pms/app/api/widgets/rate_input.widget.dart';
import 'package:lotel_pms/app/auth/view_models/access_control.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/model/room_online.model.dart';

class RateBadgeWidget extends ConsumerWidget {
  final String roomId;
  final DateTime date;
  final String categoryId;

  const RateBadgeWidget({
    super.key,
    required this.roomId,
    required this.date,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManageRates = hasPmsPermission(ref, PmsPermission.manageRates);
    final roomOnlineState = ref.watch(roomOnlineListVM);
    final propertyId = ref.read(selectedPropertyVM);
    final override = ref.watch(
      roomOnlineIndexProvider.select(
        (index) => index[roomOnlineCellKey(roomId, date)],
      ),
    );

    final price = override?.roomOnline.price;
    final isOverride = override != null;
    final hasLoadingPlaceholder = roomOnlineState.isLoading &&
        roomOnlineState.items.isEmpty &&
        override == null;
    final hasErrorPlaceholder = roomOnlineState.errorMessage != null &&
        roomOnlineState.items.isEmpty &&
        override == null;

    return GestureDetector(
      onTap: canManageRates
          ? () => _editRate(
                context,
                ref,
                propertyId: propertyId,
                override: override,
                initialPrice: price ?? 0.0,
              )
          : null,
      onLongPress: canManageRates && isOverride
          ? () => _removeRate(context, ref, override)
          : null,
      child: _buildBadge(
        context,
        price,
        isOverride: isOverride,
        isLoading: hasLoadingPlaceholder,
        hasError: hasErrorPlaceholder,
        canManageRates: canManageRates,
      ),
    );
  }

  Future<void> _editRate(
    BuildContext context,
    WidgetRef ref, {
    required int? propertyId,
    required RoomOnlineVM? override,
    required double initialPrice,
  }) async {
    final newRate = await showDialog<double>(
      context: context,
      builder: (_) => RateInputDialog(
        date: date,
        initialPrice: initialPrice,
      ),
    );

    if (newRate == null) return;
    if (propertyId == null || propertyId == 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Select a property before editing rates.')),
        );
      }
      return;
    }

    final newRoomOnline = RoomOnline(
      id: override?.id ?? '',
      roomId: roomId,
      date: date,
      price: newRate,
      propertyId: propertyId,
      categoryId: categoryId,
    );

    final saved = await ref
        .read(roomOnlineListVM.notifier)
        .upsertRoomOnline(newRoomOnline);
    if (!context.mounted) return;
    if (!saved) {
      final error = ref.read(roomOnlineListVM).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to save nightly rate.')),
      );
    }
  }

  Future<void> _removeRate(
    BuildContext context,
    WidgetRef ref,
    RoomOnlineVM override,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Custom Rate?'),
        content: const Text('This will clear the rate override.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final deleted =
        await ref.read(roomOnlineListVM.notifier).deleteRoomOnline(override.id);
    if (!context.mounted || deleted) return;

    final error = ref.read(roomOnlineListVM).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Failed to remove nightly rate.')),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    double? price, {
    required bool isOverride,
    required bool isLoading,
    required bool hasError,
    required bool canManageRates,
  }) {
    final isCompact = context.showCompactLayout;
    Widget content;
    if (isLoading) {
      content = const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (hasError) {
      content = const Icon(Icons.error_outline, size: 16, color: Colors.red);
    } else {
      content = Text(
        price == null ? '--' : '\$${price.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: isCompact ? 11 : 12,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return SizedBox(
      height: isCompact ? 42 : 35,
      width: 93.9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError
                    ? Colors.redAccent
                    : (isOverride ? Colors.blueAccent : Colors.transparent),
                width: 2,
              ),
              color:
                  canManageRates ? null : Colors.grey.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          content,
        ],
      ),
    );
  }
}
