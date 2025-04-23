import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/courses/view_models/block.vm.dart';
import 'package:flutter_academy/infrastructure/courses/res/block.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockListVM extends StateNotifier<List<BlockVM>> {
  final BlockService blockService;
  final int propertyId;
  final int year;
  final int month;

  BlockListVM(this.propertyId, this.year, this.month, this.blockService)
      : super(const []) {
    fetchBlocks();
  }

  Future<void> fetchBlocks() async {
    final res = await blockService.getAllBlocks(propertyId, year, month);
    state = [...res.map((block) => BlockVM(block))];
  }

  Future<bool> addToBlocks(Map<String, dynamic> blockData) async {
    if (await blockService.addBlock(blockData)) {
      await fetchBlocks();
      return true;
    }
    return false;
  }

  Future<bool> editBlock(int blockId, Map<String, dynamic> updatedData) async {
    try {
      final success = await blockService.editBlock(blockId, updatedData);
      if (success) {
        await fetchBlocks();
        return true;
      }
    } catch (e) {
      // Handle or log error
    }
    return false;
  }

  Future<bool> deleteBlock(String blockId) async {
    final success = await blockService.deleteBlock(blockId);
    if (success) {
      state = state.where((b) => b.block.id != blockId).toList();
    }
    return success;
  }
}

final blockListVM = StateNotifierProvider<BlockListVM, List<BlockVM>>((ref) {
  final selectedProperty = ref.watch(selectedPropertyVM) ?? 0;
  final selectedMonth = ref.watch(selectedMonthVM);
  return BlockListVM(
    selectedProperty,
    selectedMonth.year,
    selectedMonth.month,
    BlockService(),
  );
});
