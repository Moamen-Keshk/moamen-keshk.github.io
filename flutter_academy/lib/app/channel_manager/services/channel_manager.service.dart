import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/app/req/request.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

// Models
import 'package:flutter_academy/app/channel_manager/models/channel_connection.dart';
import 'package:flutter_academy/app/channel_manager/models/channel_room_map.dart';
import 'package:flutter_academy/app/channel_manager/models/channel_rate_plan_map.dart';
import 'package:flutter_academy/app/channel_manager/models/external_room.dart';
import 'package:flutter_academy/app/channel_manager/models/external_rate_plan.dart';
import 'package:flutter_academy/app/channel_manager/models/supported_channel.dart';

class ChannelManagerService {
  final String basePath = '/channel_manager';

  // Helper method to guarantee a fresh, unexpired token right before every request!
  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // ==========================================
  // CHANNEL CONNECTION ENDPOINTS
  // ==========================================

  Future<List<ChannelConnection>> getChannelConnections(int propertyId) async {
    // ⬇️ FIX: Moved propertyId from Query Params to the URL Path
    final response = await sendGetRequest(
      await _getToken(),
      '$basePath/properties/$propertyId/connections',
    );
    debugPrint("🔥 RAW BACKEND DATA: $response");

    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ChannelConnection.fromResMap(item))
          .toList();
    }
    debugPrint('Failed to load channel connections or list is empty.');
    return [];
  }

  Future<bool> connectChannel({
    required int propertyId,
    required String channelCode,
    required String hotelIdOnChannel,
    required String username,
    required String password,
  }) async {
    // ⬇️ FIX: Added propertyId to the URL Path
    return await sendPostRequest(
      {
        'property_id': propertyId,
        'channel_code': channelCode,
        'status': 'active',
        'credentials_json': {
          'hotel_id': hotelIdOnChannel,
          'username': username,
          'password': password,
        }
      },
      await _getToken(),
      '$basePath/properties/$propertyId/connections',
    );
  }

  // ⬇️ FIX: Added propertyId to parameters to fulfill the backend URL requirement
  Future<bool> disconnectChannel(int propertyId, String connectionId) async {
    final response = await sendDeleteRequest(
      await _getToken(),
      '$basePath/properties/$propertyId/connections/$connectionId',
    );

    if (response == null) return false;
    if (response is bool) return response;
    return response['status'] == 'success';
  }

  // ⬇️ FIX: Added propertyId to parameters
  Future<bool> forceSync(int propertyId, String connectionId) async {
    return await sendPostRequest(
      {},
      await _getToken(),
      '$basePath/properties/$propertyId/connections/$connectionId/sync',
    );
  }

  // ==========================================
  // ROOM MAPPING ENDPOINTS
  // ==========================================

  Future<List<ChannelRoomMap>> getRoomMappings(int propertyId) async {
    // ⬇️ FIX: Moved propertyId from Query Params to the URL Path
    final response = await sendGetRequest(
      await _getToken(),
      '$basePath/properties/$propertyId/room_maps',
    );

    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ChannelRoomMap.fromResMap(item))
          .toList();
    }
    return [];
  }

  // ⬇️ FIX: Added propertyId to parameters
  Future<bool> addRoomMapping(int propertyId, ChannelRoomMap mapping) async {
    return await sendPostRequest(
      mapping.toMap(),
      await _getToken(),
      '$basePath/properties/$propertyId/room_maps',
    );
  }

  // ⬇️ FIX: Added propertyId to parameters
  Future<bool> deleteRoomMapping(int propertyId, String mappingId) async {
    final response = await sendDeleteRequest(
      await _getToken(),
      '$basePath/properties/$propertyId/room_maps/$mappingId',
    );

    if (response == null) return false;
    if (response is bool) return response;
    return response['status'] == 'success';
  }

  // ==========================================
  // RATE PLAN MAPPING ENDPOINTS
  // ==========================================

  Future<List<ChannelRatePlanMap>> getRatePlanMappings(int propertyId) async {
    // ⬇️ FIX: Moved propertyId from Query Params to the URL Path
    final response = await sendGetRequest(
      await _getToken(),
      '$basePath/properties/$propertyId/rate_maps',
    );

    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ChannelRatePlanMap.fromResMap(item))
          .toList();
    }
    return [];
  }

  // ⬇️ FIX: Added propertyId to parameters
  Future<bool> addRatePlanMapping(
      int propertyId, ChannelRatePlanMap mapping) async {
    return await sendPostRequest(
      mapping.toMap(),
      await _getToken(),
      '$basePath/properties/$propertyId/rate_maps',
    );
  }

  // ⬇️ FIX: Added propertyId to parameters
  Future<bool> deleteRatePlanMapping(int propertyId, String mappingId) async {
    final response = await sendDeleteRequest(
      await _getToken(),
      '$basePath/properties/$propertyId/rate_maps/$mappingId',
    );

    if (response == null) return false;
    if (response is bool) return response;
    return response['status'] == 'success';
  }

  // ==========================================
  // EXTERNAL CHANNEL DATA (For Dropdowns)
  // ==========================================

  // ⬇️ FIX: Added propertyId to parameters
  Future<List<ExternalRoom>> getExternalRooms(
      int propertyId, int connectionId) async {
    final response = await sendGetRequest(
      await _getToken(),
      '$basePath/properties/$propertyId/connections/$connectionId/external_rooms',
    );

    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ExternalRoom.fromResMap(item))
          .toList();
    }
    return [];
  }

  // ⬇️ FIX: Added propertyId to parameters
  Future<List<ExternalRatePlan>> getExternalRatePlans(
      int propertyId, int connectionId) async {
    final response = await sendGetRequest(
      await _getToken(),
      '$basePath/properties/$propertyId/connections/$connectionId/external_rate_plans',
    );

    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ExternalRatePlan.fromResMap(item))
          .toList();
    }
    return [];
  }

  // ==========================================
  // SUPPORTED CHANNELS ENDPOINTS (Global)
  // ==========================================

  // These remain untouched because they are globally scoped in your Python backend!

  Future<List<SupportedChannel>> getSupportedChannels() async {
    final response = await sendGetRequest(
      await _getToken(),
      '$basePath/supported_channels',
    );

    // 1. If the API completely fails, fail gracefully.
    if (response == null) return [];

    try {
      if (response['data'] != null) {
        // 2. List.from() safely forces Dart to treat the JS Array as a standard List
        final List dataList = List.from(response['data']);
        return dataList
            .map((item) =>
                SupportedChannel.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // 3. If your SupportedChannel.fromMap ever crashes due to a typo, it will print here!
      debugPrint("❌ PARSING ERROR: $e");
    }

    // 4. Gracefully return an empty list instead of throwing a hard exception.
    // This allows the UI to render the "No supported channels available. Add one!" screen.
    return [];
  }

  Future<bool> addSupportedChannel(Map<String, dynamic> payload) async {
    return await sendPostRequest(
      payload,
      await _getToken(),
      '$basePath/supported_channels',
    );
  }
}
