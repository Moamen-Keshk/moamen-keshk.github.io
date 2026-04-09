import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/channel_manager/models/supported_channel.dart';
import 'package:lotel_pms/app/channel_manager/services/channel_manager.service.dart';

final supportedChannelsVMProvider =
    AsyncNotifierProvider<SupportedChannelsNotifier, List<SupportedChannel>>(
        () {
  return SupportedChannelsNotifier();
});

class SupportedChannelsNotifier extends AsyncNotifier<List<SupportedChannel>> {
  @override
  Future<List<SupportedChannel>> build() async {
    return await fetchChannels();
  }

  Future<List<SupportedChannel>> fetchChannels() async {
    final service = ChannelManagerService();
    return await service.getSupportedChannels();
  }

  Future<bool> addChannel(String name, String code, String logo) async {
    final service = ChannelManagerService();

    // This now returns a boolean directly!
    final success = await service.addSupportedChannel({
      'name': name,
      'code': code,
      'logo': logo,
    });

    if (success) {
      // Changed from `if (newChannel != null)`
      ref.invalidateSelf();
      return true;
    }
    return false;
  }
}
