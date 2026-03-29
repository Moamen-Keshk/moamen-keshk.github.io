import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/app/req/request.dart';

// Models
import 'package:flutter_academy/app/channel_manager/models/channel_connection.dart';
import 'package:flutter_academy/app/channel_manager/models/channel_room_map.dart';
import 'package:flutter_academy/app/channel_manager/models/channel_rate_plan_map.dart';
import 'package:flutter_academy/app/channel_manager/models/external_room.dart';
import 'package:flutter_academy/app/channel_manager/models/external_rate_plan.dart';

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
    final response = await sendGetWithParamsRequest(
      await _getToken(), // Fetch fresh token here!
      '$basePath/connections',
      {'property_id': propertyId.toString()},
    );

    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ChannelConnection.fromResMap(item))
          .toList();
    }
    throw Exception('Failed to load channel connections.');
  }

  Future<bool> disconnectChannel(String connectionId) async {
    final response = await sendDeleteRequest(
      await _getToken(),
      '$basePath/connections/$connectionId',
    );
    return response != null;
  }

  Future<bool> forceSync(String connectionId) async {
    return await sendPostRequest(
      {},
      await _getToken(),
      '$basePath/connections/$connectionId/sync',
    );
  }

  // ==========================================
  // ROOM MAPPING ENDPOINTS
  // ==========================================

  Future<List<ChannelRoomMap>> getRoomMappings(int propertyId) async {
    final response = await sendGetWithParamsRequest(
      await _getToken(),
      '$basePath/room_maps',
      {'property_id': propertyId.toString()},
    );

    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ChannelRoomMap.fromResMap(item))
          .toList();
    }
    throw Exception('Failed to load room mappings.');
  }

  Future<bool> addRoomMapping(ChannelRoomMap mapping) async {
    return await sendPostRequest(
      mapping.toMap(),
      await _getToken(),
      '$basePath/room_maps',
    );
  }

  Future<bool> deleteRoomMapping(String mappingId) async {
    final response = await sendDeleteRequest(
      await _getToken(),
      '$basePath/room_maps/$mappingId',
    );
    return response != null;
  }

  // ==========================================
  // RATE PLAN MAPPING ENDPOINTS
  // ==========================================

  Future<List<ChannelRatePlanMap>> getRatePlanMappings(int propertyId) async {
    final response = await sendGetWithParamsRequest(
      await _getToken(),
      '$basePath/rate_maps',
      {'property_id': propertyId.toString()},
    );

    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ChannelRatePlanMap.fromResMap(item))
          .toList();
    }
    throw Exception('Failed to load rate plan mappings.');
  }

  Future<bool> addRatePlanMapping(ChannelRatePlanMap mapping) async {
    return await sendPostRequest(
      mapping.toMap(),
      await _getToken(),
      '$basePath/rate_maps',
    );
  }

  Future<bool> deleteRatePlanMapping(String mappingId) async {
    final response = await sendDeleteRequest(
      await _getToken(),
      '$basePath/rate_maps/$mappingId',
    );
    return response != null;
  }

  // ==========================================
  // EXTERNAL CHANNEL DATA (For Dropdowns)
  // ==========================================

  Future<List<ExternalRoom>> getExternalRooms(int connectionId) async {
    final response = await sendGetRequest(
      await _getToken(),
      '$basePath/connections/$connectionId/external_rooms',
    );

    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ExternalRoom.fromResMap(item))
          .toList();
    }
    throw Exception('Failed to fetch external rooms.');
  }

  Future<List<ExternalRatePlan>> getExternalRatePlans(int connectionId) async {
    final response = await sendGetRequest(
      await _getToken(),
      '$basePath/connections/$connectionId/external_rate_plans',
    );

    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ExternalRatePlan.fromResMap(item))
          .toList();
    }
    throw Exception('Failed to fetch external rate plans.');
  }
}
