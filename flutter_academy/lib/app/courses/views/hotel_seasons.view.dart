import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/season.vm.dart';
import 'package:flutter_academy/app/courses/view_models/season_list.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HotelSeasonsView extends ConsumerWidget {
  const HotelSeasonsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonVM = ref.watch(seasonListVM);
    final seasonNotifier = ref.read(seasonListVM.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: seasonVM
                .map(
                  (season) => _SeasonCard(
                    season: season,
                    onTap: () {
                      ref.read(seasonToEditVM.notifier).update(season);
                      ref.read(routerProvider).push('edit_season');
                    },
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Season'),
                              content: const Text(
                                  'Are you sure you want to delete this season?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (confirm) {
                        final success =
                            await seasonNotifier.deleteSeason(season.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Season deleted successfully'
                                    : 'Failed to delete season',
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(routerProvider).push('new_season');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Season'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SeasonCard extends StatefulWidget {
  final SeasonVM season;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SeasonCard({
    required this.season,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_SeasonCard> createState() => _SeasonCardState();
}

class _SeasonCardState extends State<_SeasonCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final season = widget.season;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
            border: Border.all(
              color: _isHovered
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (season.label != null)
                Text(
                  season.label!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 8),
              Text(
                "${_format(season.startDate)} → ${_format(season.endDate)}",
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Season',
                  onPressed: widget.onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
