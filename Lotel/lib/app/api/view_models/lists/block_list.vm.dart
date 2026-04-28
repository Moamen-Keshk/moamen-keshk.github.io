import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/app/api/view_models/block.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/block.service.dart';
import 'package:flutter_riverpod/legacy.dart';

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
    if (!mounted) return;
    state = [...res.map((block) => BlockVM(block))];
  }

  Future<bool> addToBlocks(Map<String, dynamic> blockData) async {
    final success = await blockService.addBlock(propertyId, blockData);
    if (!mounted) return false;

    if (success) {
      await fetchBlocks();
      return true;
    }
    return false;
  }

  Future<bool> editBlock(int blockId, Map<String, dynamic> updatedData) async {
    try {
      final success =
          await blockService.editBlock(propertyId, blockId, updatedData);
      if (!mounted) return false;

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
    final success = await blockService.deleteBlock(propertyId, blockId);
    if (!mounted) return false;

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
