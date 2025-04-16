// Updated RatePlanView with hybrid conflict handling
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_academy/app/rates/rate_plan_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/app/rates/rate_plan.model.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';

class RatePlanView extends ConsumerStatefulWidget {
  const RatePlanView({super.key});

  @override
  ConsumerState<RatePlanView> createState() => _RatePlanViewState();
}

class _RatePlanViewState extends ConsumerState<RatePlanView> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  double baseRate = 0;
  String? categoryId;
  DateTime? startDate;
  DateTime? endDate;
  double? weekendRate;
  double? seasonalMultiplier;
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    final ratePlanVM = ref.read(ratePlanListVM.notifier);
    final categories = ref.watch(categoryListVM);
    final propertyId = ref.watch(selectedPropertyVM);

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
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Rate Plan Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => name = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Base Rate',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => baseRate = double.tryParse(val) ?? 0,
                  validator: (val) =>
                      val == null || double.tryParse(val) == null
                          ? 'Enter valid number'
                          : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((CategoryVM c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => categoryId = val),
                  validator: (val) =>
                      val == null ? 'Please select category' : null,
                ),
                const SizedBox(height: 16),
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
                    labelText: 'Weekend Rate (optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => weekendRate = double.tryParse(val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Seasonal Multiplier (optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => seasonalMultiplier = double.tryParse(val),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: isActive,
                  title: const Text('Active'),
                  onChanged: (val) => setState(() => isActive = val),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Create Rate Plan'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        startDate != null &&
                        endDate != null &&
                        categoryId != null &&
                        propertyId != null) {
                      final newPlan = RatePlan(
                        id: '', // will be ignored on creation
                        name: name,
                        baseRate: baseRate,
                        propertyId: propertyId,
                        categoryId: categoryId!,
                        startDate: startDate!,
                        endDate: endDate!,
                        weekendRate: weekendRate,
                        seasonalMultiplier: seasonalMultiplier,
                        isActive: isActive,
                      );

                      final conflicts =
                          await ratePlanVM.getConflictingPlans(newPlan);

                      bool override = false;
                      if (conflicts.isNotEmpty && context.mounted) {
                        override = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Conflict Detected'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'This rate plan overlaps with the following existing plan(s):',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    ...conflicts
                                        .map((plan) => Text('- ${plan.name}')),
                                    const SizedBox(height: 16),
                                    const Text('Do you want to override them?'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: const Text('Override')),
                                ],
                              ),
                            ) ??
                            false;
                      }

                      if (!context.mounted) return;

                      final success = await ratePlanVM.saveRatePlan(
                        ratePlan: newPlan,
                        overrideConflicts: override,
                      );

                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Rate Plan created successfully')),
                        );
                        ref.read(routerProvider).pop();
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Could not create rate plan')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all required fields')),
                      );
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
      title: Text(selectedDate == null
          ? label
          : '$label: ${selectedDate!.toLocal().toString().split(" ")[0]}'),
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
}
