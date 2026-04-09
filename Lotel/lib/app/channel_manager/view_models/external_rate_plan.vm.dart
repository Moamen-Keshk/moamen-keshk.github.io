import 'package:lotel_pms/app/channel_manager/view_models/channel_rate_mapping.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/channel_manager/models/external_rate_plan.dart';

// 1. IMPORT the shared, authenticated service provider!

// 2. IMPORT the selected channel ID state
// (It's perfectly fine to keep pulling this from the room file if that's where you defined it!)
import 'package:lotel_pms/app/channel_manager/view_models/external_room.vm.dart';

// 3. The Notifier
class ExternalRatePlanNotifier extends AsyncNotifier<List<ExternalRatePlan>> {
  @override
  Future<List<ExternalRatePlan>> build() async {
    // Automatically rebuilds and fetches when the user selects a different channel.
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;
    final channelId = ref.watch(selectedChannelIdVM) ?? 0;

    if (propertyId == 0 || channelId == 0) return [];

    // This now securely uses your authenticated Flask backend!
    final service = ref.read(channelManagerServiceProvider);
    return await service.getExternalRatePlans(propertyId, channelId);
  }

  // Force a manual refresh if you need to pull fresh data from the OTA
  Future<void> refreshExternalRatePlans() async {
    ref.invalidateSelf();
  }
}

// 4. The Provider definition
final externalRatePlanVMProvider =
    AsyncNotifierProvider<ExternalRatePlanNotifier, List<ExternalRatePlan>>(
  () => ExternalRatePlanNotifier(),
);
