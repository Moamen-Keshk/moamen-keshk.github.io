import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotel_pms/app/api/view_models/category.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/category_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/rate_plan_list.vm.dart';
import 'package:lotel_pms/app/api/view_models/rate_plan.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/model/rate_plan.model.dart';
import 'package:lotel_pms/main.dart';

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
  String pricingType = 'standard';
  String? parentRatePlanId;
  String derivedAdjustmentType = 'percent';
  double? derivedAdjustmentValue;
  int? includedOccupancy;
  double? singleOccupancyRate;
  double? extraAdultRate;
  double? extraChildRate;
  int? minLos;
  int? maxLos;
  bool closed = false;
  bool closedToArrival = false;
  bool closedToDeparture = false;
  String? mealPlanCode;
  String? cancellationPolicy;
  String losPricingText = '';
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    final ratePlanVM = ref.read(ratePlanListVM.notifier);
    final categories = ref.watch(categoryListVM);
    final ratePlans = ref.watch(ratePlanListVM);
    final propertyId = ref.watch(selectedPropertyVM);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
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
                  initialValue: categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Room Type',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((CategoryVM c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() {
                    categoryId = val;
                    if (!_availableParentPlans(ratePlans).any(
                        (plan) => plan.id == parentRatePlanId)) {
                      parentRatePlanId = null;
                    }
                  }),
                  validator: (val) =>
                      val == null ? 'Please select room type' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: pricingType,
                  decoration: const InputDecoration(
                    labelText: 'Pricing Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'standard', child: Text('Standard')),
                    DropdownMenuItem(value: 'derived', child: Text('Derived')),
                    DropdownMenuItem(value: 'occupancy', child: Text('Occupancy')),
                    DropdownMenuItem(value: 'los', child: Text('Length of Stay')),
                  ],
                  onChanged: (val) => setState(() => pricingType = val ?? 'standard'),
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
                if (pricingType == 'derived') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: parentRatePlanId,
                    decoration: const InputDecoration(
                      labelText: 'Parent Rate Plan',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableParentPlans(ratePlans)
                        .map((plan) => DropdownMenuItem<String>(
                              value: plan.id,
                              child: Text(plan.name),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => parentRatePlanId = val),
                    validator: (val) => pricingType == 'derived' && val == null
                        ? 'Select a parent plan'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: derivedAdjustmentType,
                    decoration: const InputDecoration(
                      labelText: 'Derived Adjustment Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'percent', child: Text('Percent')),
                      DropdownMenuItem(value: 'amount', child: Text('Amount')),
                    ],
                    onChanged: (val) =>
                        setState(() => derivedAdjustmentType = val ?? 'percent'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Derived Adjustment Value',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) =>
                        derivedAdjustmentValue = double.tryParse(val),
                    validator: (val) => pricingType == 'derived' &&
                            (val == null || double.tryParse(val) == null)
                        ? 'Enter adjustment value'
                        : null,
                  ),
                ],
                if (pricingType == 'occupancy') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Included Occupancy',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => includedOccupancy = int.tryParse(val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Single Occupancy Rate',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) =>
                        singleOccupancyRate = double.tryParse(val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Extra Adult Rate',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) => extraAdultRate = double.tryParse(val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Extra Child Rate',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) => extraChildRate = double.tryParse(val),
                  ),
                ],
                if (pricingType == 'los') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'LOS Pricing',
                      hintText: '2:95,3:90,7:80',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => losPricingText = val,
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Minimum Length of Stay',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => minLos = int.tryParse(val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Maximum Length of Stay',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => maxLos = int.tryParse(val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Meal Plan Code (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => mealPlanCode = val.isEmpty ? null : val,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Cancellation Policy (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) =>
                      cancellationPolicy = val.isEmpty ? null : val,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: closed,
                  title: const Text('Closed'),
                  onChanged: (val) => setState(() => closed = val),
                ),
                SwitchListTile(
                  value: closedToArrival,
                  title: const Text('Closed to Arrival'),
                  onChanged: (val) => setState(() => closedToArrival = val),
                ),
                SwitchListTile(
                  value: closedToDeparture,
                  title: const Text('Closed to Departure'),
                  onChanged: (val) => setState(() => closedToDeparture = val),
                ),
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
                    if (!_formKey.currentState!.validate() ||
                        startDate == null ||
                        endDate == null ||
                        categoryId == null ||
                        propertyId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields'),
                        ),
                      );
                      return;
                    }

                    if (startDate!.isAfter(endDate!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Start date cannot be after end date'),
                        ),
                      );
                      return;
                    }

                    List<Map<String, dynamic>> losPricing;
                    try {
                      losPricing = pricingType == 'los'
                          ? _parseLosPricing(losPricingText)
                          : const [];
                    } on FormatException {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('LOS pricing must use stay:rate pairs, e.g. 2:95,3:90'),
                        ),
                      );
                      return;
                    }

                    final newPlan = RatePlan(
                      id: '',
                      name: name,
                      baseRate: baseRate,
                      propertyId: propertyId,
                      categoryId: categoryId!,
                      startDate: startDate!,
                      endDate: endDate!,
                      weekendRate: weekendRate,
                      seasonalMultiplier: seasonalMultiplier,
                      pricingType: pricingType,
                      parentRatePlanId:
                          pricingType == 'derived' ? parentRatePlanId : null,
                      derivedAdjustmentType:
                          pricingType == 'derived' ? derivedAdjustmentType : null,
                      derivedAdjustmentValue: pricingType == 'derived'
                          ? derivedAdjustmentValue
                          : null,
                      includedOccupancy:
                          pricingType == 'occupancy' ? includedOccupancy : null,
                      singleOccupancyRate: pricingType == 'occupancy'
                          ? singleOccupancyRate
                          : null,
                      extraAdultRate:
                          pricingType == 'occupancy' ? extraAdultRate : null,
                      extraChildRate:
                          pricingType == 'occupancy' ? extraChildRate : null,
                      minLos: minLos,
                      maxLos: maxLos,
                      closed: closed,
                      closedToArrival: closedToArrival,
                      closedToDeparture: closedToDeparture,
                      mealPlanCode: mealPlanCode,
                      cancellationPolicy: cancellationPolicy,
                      losPricing: losPricing,
                      isActive: isActive,
                    );

                    final success = await ratePlanVM.saveRatePlan(
                      ratePlan: newPlan,
                    );

                    if (!context.mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rate Plan created successfully'),
                        ),
                      );
                      ref.read(routerProvider).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not create rate plan'),
                        ),
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

  List<RatePlanVM> _availableParentPlans(List<RatePlanVM> ratePlans) {
    return ratePlans.where((plan) {
      if (categoryId == null) return false;
      return plan.categoryId == categoryId;
    }).toList();
  }

  List<Map<String, dynamic>> _parseLosPricing(String value) {
    if (value.trim().isEmpty) return const [];

    return value.split(',').map((entry) {
      final parts = entry.split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid LOS entry');
      }
      return {
        'stay_length': int.parse(parts[0].trim()),
        'nightly_rate': double.parse(parts[1].trim()),
      };
    }).toList();
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
