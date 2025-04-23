import 'package:flutter_academy/app/req/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_academy/infrastructure/courses/model/block.model.dart';

class BlockService {
  final _auth = FirebaseAuth.instance;

  /// Fetch all blocks for a given property, year, and month
  Future<List<Block>> getAllBlocks(int propertyId, int year, int month) async {
    final query = await sendGetWithParamsRequest(
      await _auth.currentUser?.getIdToken(),
      "/api/v1/all_blocks",
      {
        'property_id': propertyId.toString(),
        'year': year.toString(),
        'month': month.toString(),
      },
    );

    return (query['data'] as List).map((e) => Block.fromResMap(e)).toList();
  }

  /// Add a new block
  Future<bool> addBlock(Map<String, dynamic> blockData) async {
    return await sendPostRequest(
      blockData,
      await _auth.currentUser?.getIdToken(),
      "/api/v1/new_block",
    );
  }

  /// Edit an existing block by ID
  Future<bool> editBlock(
      int blockId, Map<String, dynamic> updatedBlockData) async {
    try {
      final response = await sendPutRequest(
        updatedBlockData,
        await _auth.currentUser?.getIdToken(),
        "/api/v1/edit_block/$blockId",
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  /// Delete a block by ID
  Future<bool> deleteBlock(String blockId) async {
    try {
      final response = await sendDeleteRequest(
        await _auth.currentUser?.getIdToken(),
        "/api/v1/delete_block/$blockId",
      );

      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}
