import 'package:flutter/material.dart';

class StatusCards extends StatelessWidget {
  final Set<int> readyRoomIDs;
  final Set<int> toCleanRoomIDs;
  final Map<int, String> roomMapping;
  final String? selectedGroup;
  final void Function(String? group) onTap;

  const StatusCards({
    required this.readyRoomIDs,
    required this.toCleanRoomIDs,
    required this.roomMapping,
    required this.selectedGroup,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statusCard(
            context, 'Ready Rooms', readyRoomIDs.length, Colors.teal, 'Ready'),
        _statusCard(context, 'To Clean', toCleanRoomIDs.length, Colors.orange,
            'ToClean'),
      ],
    );
  }

  Widget _statusCard(BuildContext context, String title, int count, Color color,
      String groupKey) {
    final isSelected = selectedGroup == groupKey;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(isSelected ? null : groupKey),
      child: Card(
        color: isSelected ? color.withValues(blue: 0.85) : color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1.5,
        child: SizedBox(
          width: 150,
          height: 70,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
