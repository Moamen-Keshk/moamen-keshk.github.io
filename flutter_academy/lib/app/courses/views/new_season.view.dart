import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/lists/season_list.vm.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';

class NewSeasonView extends ConsumerStatefulWidget {
  const NewSeasonView({super.key});

  @override
  ConsumerState<NewSeasonView> createState() => _NewSeasonFormState();
}

class _NewSeasonFormState extends ConsumerState<NewSeasonView> {
  final _formKey = GlobalKey<FormState>();
  DateTime? startDate;
  DateTime? endDate;
  String? label;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final propertyId = ref.watch(selectedPropertyVM);
    final seasonVM = ref.read(seasonListVM.notifier);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DatePickerTile(
                  label: 'Start Date',
                  selectedDate: startDate,
                  onSelect: (date) => setState(() => startDate = date),
                ),
                const SizedBox(height: 12),
                _DatePickerTile(
                  label: 'End Date',
                  selectedDate: endDate,
                  onSelect: (date) => setState(() => endDate = date),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Label (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => label = val,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(isSubmitting ? 'Saving...' : 'Create Season'),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (startDate == null || endDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please select both start and end dates'),
                              ),
                            );
                            return;
                          }

                          if (startDate!.isAfter(endDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Start date cannot be after end date.'),
                              ),
                            );
                            return;
                          }

                          setState(() => isSubmitting = true);

                          final conflicts =
                              await seasonVM.getConflictingSeasons(
                            propertyId: propertyId!,
                            startDate: startDate!,
                            endDate: endDate!,
                            excludeSeasonId: null,
                          );

                          bool override = false;

                          if (conflicts.isNotEmpty && context.mounted) {
                            override = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Conflict Detected'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'This season overlaps with the following existing season(s):',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        ...conflicts.map((s) =>
                                            Text('- ${s.label ?? "Unnamed"}')),
                                        const SizedBox(height: 16),
                                        const Text(
                                            'Do you want to override them?'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text('Override'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                          }

                          final success = await seasonVM.saveSeason(
                            propertyId: propertyId,
                            startDate: startDate!,
                            endDate: endDate!,
                            label: label,
                            seasonId: null,
                            overrideConflicts: override,
                          );

                          if (mounted) {
                            setState(() => isSubmitting = false);

                            if (success && context.mounted) {
                              ref.read(routerProvider).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Season created successfully'),
                                ),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Failed to create season or conflict not overridden'),
                                ),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime) onSelect;

  const _DatePickerTile({
    required this.label,
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        selectedDate == null ? label : '$label: ${_formatDate(selectedDate!)}',
      ),
      trailing: const Icon(Icons.date_range),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2100),
        );
        if (picked != null) onSelect(picked);
      },
    );
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
