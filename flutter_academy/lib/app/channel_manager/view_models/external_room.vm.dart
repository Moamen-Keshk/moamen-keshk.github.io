import 'package:flutter_academy/app/channel_manager/view_models/channel_rate_mapping.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/channel_manager/models/external_room.dart';

// 1. IMPORT the shared, authenticated service provider!

// 2. Define the Global State using the modern Notifier pattern!
// (We keep this here because your external_rate_plan.vm imports it from here!)
class SelectedChannelIdNotifier extends Notifier<int?> {
  @override
  int? build() => null; // Default state is null

  // Easy method to update the selected channel from your UI
  void setChannel(int? id) => state = id;
}

final selectedChannelIdVM = NotifierProvider<SelectedChannelIdNotifier, int?>(
  () => SelectedChannelIdNotifier(),
);

// 3. The Notifier
class ExternalRoomNotifier extends AsyncNotifier<List<ExternalRoom>> {
  @override
  Future<List<ExternalRoom>> build() async {
    // Automatically rebuilds when the user selects a different channel
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;
    final channelId = ref.watch(selectedChannelIdVM) ?? 0;

    if (propertyId == 0 || channelId == 0) return [];

    // This now securely uses your authenticated Flask backend!
    final service = ref.read(channelManagerServiceProvider);
    return await service.getExternalRooms(propertyId, channelId);
  }

  // Force a manual refresh if you need to pull fresh data from the OTA
  Future<void> refreshExternalRooms() async {
    ref.invalidateSelf();
  }
}

// 4. The Provider definition
final externalRoomVMProvider =
    AsyncNotifierProvider<ExternalRoomNotifier, List<ExternalRoom>>(
  () => ExternalRoomNotifier(),
);
