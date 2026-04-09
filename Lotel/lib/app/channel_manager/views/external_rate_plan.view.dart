import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/channel_manager/models/external_rate_plan.dart';

// 1. ADD THIS IMPORT: Point this to wherever you saved the ViewModel
import 'package:lotel_pms/app/channel_manager/view_models/external_rate_plan.vm.dart';

class ExternalRatePlanSelector extends ConsumerWidget {
  final int channelId;
  final ExternalRatePlan? selectedPlan;
  final ValueChanged<ExternalRatePlan?> onChanged;

  const ExternalRatePlanSelector({
    super.key,
    required this.channelId,
    this.selectedPlan,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. UPDATED WATCH CALL:
    // If you kept the .family provider, use: ref.watch(externalRatePlanProvider(channelId))
    // If you used the updated global state provider from the last step, use:
    final externalPlansAsync = ref.watch(externalRatePlanVMProvider);

    return externalPlansAsync.when(
      data: (plans) {
        // Safe check to prevent Dropdown crash if selectedPlan isn't in the fetched list
        final validInitialValue =
            plans.contains(selectedPlan) ? selectedPlan : null;

        return DropdownButtonFormField<ExternalRatePlan>(
          initialValue:
              validInitialValue, // Use 'value' instead of 'initialValue' for DropdownButtonFormField
          decoration: const InputDecoration(
            labelText: 'Select Channel Rate Plan',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.list_alt),
          ),
          items: plans.map((plan) {
            return DropdownMenuItem(
              value: plan,
              child: Text(plan.name),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Please select a plan' : null,
        );
      },
      // Shimmer or simple text while loading the dropdown options
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Loading Channel Plans...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.downloading),
        ),
        child: LinearProgressIndicator(),
      ),
      // Error state for the dropdown
      error: (err, stack) => InputDecorator(
        decoration: InputDecoration(
          labelText: 'Error Loading Plans',
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red)),
          prefixIcon: const Icon(Icons.error, color: Colors.red),
        ),
        child: Text(
          'Could not fetch plans.',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
