import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/channel_manager/models/channel_room_map.dart';
import 'package:flutter_academy/app/channel_manager/services/channel_manager.service.dart';

// Service Provider
final channelManagerServiceProvider = Provider<ChannelManagerService>((ref) {
  return ChannelManagerService();
});

class ChannelRoomMappingNotifier extends AsyncNotifier<List<ChannelRoomMap>> {
  @override
  Future<List<ChannelRoomMap>> build() async {
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;

    if (propertyId == 0) return [];

    final service = ref.read(channelManagerServiceProvider);
    // You'll need to add this method to your service file
    return await service.getRoomMappings(propertyId);
  }

  /// Adds a new room mapping
  Future<bool> addRoomMapping(ChannelRoomMap mapping) async {
    final service = ref.read(channelManagerServiceProvider);
    final propertyId = ref.read(selectedPropertyVM) ?? 0;

    if (propertyId == 0) return false;

    final success = await service.addRoomMapping(propertyId, mapping);
    if (success) {
      // Refresh the list from the server to get the generated ID
      ref.invalidateSelf();
    }
    return success;
  }

  /// Deletes an existing room mapping
  Future<bool> deleteRoomMapping(String mappingId) async {
    final service = ref.read(channelManagerServiceProvider);
    final propertyId = ref.read(selectedPropertyVM) ?? 0;

    if (propertyId == 0) return false;

    final success = await service.deleteRoomMapping(propertyId, mappingId);
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
final channelRoomMappingVMProvider =
    AsyncNotifierProvider<ChannelRoomMappingNotifier, List<ChannelRoomMap>>(
  () => ChannelRoomMappingNotifier(),
);
