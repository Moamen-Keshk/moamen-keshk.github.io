import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/app/channel_manager/models/channel_connection.dart';
import 'package:lotel_pms/app/channel_manager/services/channel_manager.service.dart';

// Service Provider
final channelManagerServiceProvider = Provider<ChannelManagerService>((ref) {
  return ChannelManagerService();
});

class ChannelConnectionListNotifier
    extends AsyncNotifier<List<ChannelConnection>> {
  @override
  Future<List<ChannelConnection>> build() async {
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;

    if (propertyId == 0) return [];

    final service = ref.read(channelManagerServiceProvider);
    // You'll need to add this method to your service file
    return await service.getChannelConnections(propertyId);
  }

  Future<bool> connectNewChannel({
    required int propertyId,
    required String channelCode,
    required String hotelId,
    required String username,
    required String password,
  }) async {
    final service = ChannelManagerService();
    final success = await service.connectChannel(
      propertyId: propertyId,
      channelCode: channelCode, // Pass the code to the service
      hotelIdOnChannel: hotelId,
      username: username,
      password: password,
    );

    if (success) {
      // Re-fetch the list so the new connection shows up immediately
      ref.invalidateSelf();
      return true;
    }
    return false;
  }

  /// Disconnects an OTA from the property
  Future<bool> disconnectChannel(String connectionId) async {
    final service = ref.read(channelManagerServiceProvider);
    final propertyId = ref.read(selectedPropertyVM) ?? 0;

    if (propertyId == 0) return false;

    final success = await service.disconnectChannel(propertyId, connectionId);
    if (success && state.hasValue) {
      // Optimistic UI update: instantly remove the disconnected channel
      state = AsyncData(
        state.value!.where((conn) => conn.id != connectionId).toList(),
      );
    }
    return success;
  }

  /// Triggers a manual sync for a specific channel
  Future<bool> forceSync(String connectionId) async {
    final service = ref.read(channelManagerServiceProvider);
    final propertyId = ref.read(selectedPropertyVM) ?? 0;

    if (propertyId == 0) return false;

    final success = await service.forceSync(propertyId, connectionId);
    if (success) {
      // Refresh the list to get the updated 'lastSync' timestamp
      ref.invalidateSelf();
    }
    return success;
  }
}

// The Provider definition
final channelConnectionListVMProvider = AsyncNotifierProvider<
    ChannelConnectionListNotifier, List<ChannelConnection>>(
  () => ChannelConnectionListNotifier(),
);
