import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/block.model.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class BlockService {
  final _auth = FirebaseAuth.instance;

  /// Fetch all blocks for a given property, year, and month
  Future<List<Block>> getAllBlocks(int propertyId, int year, int month) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 Updated to match the new Python backend route
    final query = await sendGetWithParamsRequest(
      token,
      "/api/v1/properties/$propertyId/blocks",
      {
        'year': year.toString(),
        'month': month.toString(),
      },
    );

    // 👉 THE SAFETY NET: Prevent the 'null' crash
    if (query == null || !query.containsKey('data')) {
      debugPrint("Failed to fetch blocks. Returning empty list.");
      return [];
    }

    return (query['data'] as List).map((e) => Block.fromResMap(e)).toList();
  }

  /// Add a new block (Added propertyId)
  Future<bool> addBlock(int propertyId, Map<String, dynamic> blockData) async {
    final token = await _auth.currentUser?.getIdToken();
    // 👉 Updated to match the new Python backend route
    return await sendPostRequest(
      blockData,
      token,
      "/api/v1/properties/$propertyId/blocks",
    );
  }

  /// Edit an existing block by ID (Added propertyId)
  Future<bool> editBlock(int propertyId, int blockId,
      Map<String, dynamic> updatedBlockData) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      // 👉 Updated to match the new Python backend route
      return await sendPutRequest(
        updatedBlockData,
        token,
        "/api/v1/properties/$propertyId/blocks/$blockId",
      );
    } catch (e) {
      debugPrint("Error editing block: $e");
      return false;
    }
  }

  /// Delete a block by ID (Added propertyId)
  Future<bool> deleteBlock(int propertyId, String blockId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      // 👉 Updated to match the new Python backend route
      final dynamic response = await sendDeleteRequest(
        token,
        "/api/v1/properties/$propertyId/blocks/$blockId",
      );

      // 👉 THE BOOLEAN FIX
      if (response == null) return false;
      if (response is bool) return response;
      if (response is Map<String, dynamic>) {
        return response['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error deleting block: $e");
      return false;
    }
  }
}
