import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/courses/view_models/block.vm.dart';
import 'package:flutter_academy/app/courses/view_models/lists/block_list.vm.dart';

final selectedBlockIdProvider = StateProvider<String?>((ref) => null);

class BlockTile extends ConsumerStatefulWidget {
  final int tabIndex;
  final TabController tabController;
  final int tabSize;
  final BlockVM block;

  const BlockTile({
    super.key,
    required this.tabIndex,
    required this.tabController,
    required this.tabSize,
    required this.block,
  });

  @override
  ConsumerState<BlockTile> createState() => _BlockTileState();
}

class _BlockTileState extends ConsumerState<BlockTile> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Block"),
        content: const Text("Are you sure you want to delete this block?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(blockListVM.notifier);
      final success = await notifier.deleteBlock(widget.block.block.id);
      ref.read(selectedBlockIdProvider.notifier).state = null;

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Block deleted successfully."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedBlockIdProvider);
    final isSelected = selectedId == widget.block.block.id;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (widget.tabIndex < widget.tabController.length) {
          widget.tabController.animateTo(widget.tabIndex);
        }
        _focusNode.requestFocus();
        ref.read(selectedBlockIdProvider.notifier).state =
            isSelected ? null : widget.block.block.id;
      },
      child: Draggable<BlockVM>(
        data: widget.block,
        feedback: _buildTile(
          context,
          color: Colors.grey[700]!,
          opacity: 1.0,
          showDelete: false,
        ),
        childWhenDragging: _buildTile(
          context,
          color: Colors.grey[300]!,
          opacity: 0.5,
          showDelete: false,
        ),
        child: Focus(
          focusNode: _focusNode,
          child: _buildTile(
            context,
            color: _isFocused ? Colors.brown[300]! : Colors.grey[600]!,
            showDelete: isSelected,
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required Color color, double opacity = 1.0, bool showDelete = false}) {
    final note = widget.block.note?.trim();
    final hasNote = note != null && note.isNotEmpty;

    return TooltipTheme(
      data: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.black),
        waitDuration: const Duration(milliseconds: 300),
      ),
      child: Tooltip(
        message: hasNote ? note : 'Blocked without note',
        child: Opacity(
          opacity: opacity,
          child: Container(
            height: 35,
            width: 93.9 * widget.tabSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      "Blocked",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                if (showDelete)
                  IconButton(
                    icon:
                        const Icon(Icons.delete, size: 18, color: Colors.white),
                    padding: const EdgeInsets.only(right: 4),
                    constraints: const BoxConstraints(),
                    onPressed: () => _handleDelete(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
