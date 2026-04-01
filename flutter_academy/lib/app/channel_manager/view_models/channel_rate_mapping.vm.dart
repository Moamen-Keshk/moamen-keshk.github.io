import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/channel_manager/models/channel_rate_plan_map.dart';
import 'package:flutter_academy/app/channel_manager/services/channel_manager.service.dart';

// Service Provider
final channelManagerServiceProvider = Provider<ChannelManagerService>((ref) {
  return ChannelManagerService();
});

class ChannelRateMappingNotifier
    extends AsyncNotifier<List<ChannelRatePlanMap>> {
  @override
  Future<List<ChannelRatePlanMap>> build() async {
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;

    if (propertyId == 0) return [];

    final service = ref.read(channelManagerServiceProvider);
    // You'll need to add this method to your service file
    return await service.getRatePlanMappings(propertyId);
  }

  /// Adds a new rate plan mapping
  Future<bool> addRatePlanMapping(ChannelRatePlanMap mapping) async {
    final service = ref.read(channelManagerServiceProvider);
    final propertyId = ref.read(selectedPropertyVM) ?? 0;

    if (propertyId == 0) return false;

    final success = await service.addRatePlanMapping(propertyId, mapping);
    if (success) {
      // Refresh the list from the server to get the generated ID
      ref.invalidateSelf();
    }
    return success;
  }

  /// Deletes an existing rate plan mapping
  Future<bool> deleteRatePlanMapping(String mappingId) async {
    final service = ref.read(channelManagerServiceProvider);
    final propertyId = ref.read(selectedPropertyVM) ?? 0;

    if (propertyId == 0) return false;

    final success = await service.deleteRatePlanMapping(propertyId, mappingId);
    if (success && state.hasValue) {
      // Optimistic UI update: instantly remove the deleted mapping
      state = AsyncData(
        state.value!
            .where((map) => map.id.toString() != mappingId.toString())
            .toList(),
      );
    }
    return success;
  }
}

// The Provider definition
final channelRateMappingVMProvider =
    AsyncNotifierProvider<ChannelRateMappingNotifier, List<ChannelRatePlanMap>>(
  () => ChannelRateMappingNotifier(),
);
