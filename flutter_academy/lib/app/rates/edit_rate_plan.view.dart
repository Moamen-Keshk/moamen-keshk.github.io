import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';
import 'package:flutter_academy/app/courses/widgets/room_form.widget.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/rates/rate_plan.vm.dart';
import 'package:flutter_academy/app/rates/rate_plan_list.vm.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditRatePlanView extends ConsumerStatefulWidget {
  const EditRatePlanView({super.key});

  @override
  ConsumerState<EditRatePlanView> createState() => _EditRatePlanViewState();
}

class _EditRatePlanViewState extends ConsumerState<EditRatePlanView> {
  final _formKey = GlobalKey<FormState>();

  String? ratePlanId;

  String name = '';
  double baseRate = 0;
  int? categoryId;
  DateTime? startDate;
  DateTime? endDate;
  double? weekendRate;
  double? seasonalMultiplier;
  bool isActive = true;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final planToEdit = ref.read(ratePlanToEditVM);
    if (planToEdit != null) {
      ratePlanId = planToEdit.id;
      _fetchRatePlan(planToEdit);
    }
  }

  Future<void> _fetchRatePlan(RatePlanVM plan) async {
    if (mounted) {
      setState(() {
        name = plan.name;
        baseRate = plan.baseRate;
        categoryId = int.tryParse(plan.categoryId);
        startDate = plan.startDate;
        endDate = plan.endDate;
        weekendRate = plan.weekendRate;
        seasonalMultiplier = plan.seasonalMultiplier;
        isActive = plan.isActive;
        isLoading = false;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to load rate plan."),
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratePlanVM = ref.read(ratePlanListVM.notifier);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Rate Plan Name'),
                onChanged: (val) => name = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: baseRate.toString(),
                decoration: const InputDecoration(labelText: 'Base Rate'),
                keyboardType: TextInputType.number,
                onChanged: (val) => baseRate = double.tryParse(val) ?? 0,
                validator: (val) => val == null || double.tryParse(val) == null
                    ? 'Enter valid number'
                    : null,
              ),
              Consumer(builder: (context, ref, child) {
                final categories = ref.watch(categoryListVM);
                return CategoryFormRow(
                  categories: categories,
                  initialValue: categoryId?.toString(),
                  onCategoryChanged: (newVal) {
                    setState(() {
                      categoryId = int.tryParse(newVal);
                    });
                  },
                );
              }),
              ListTile(
                title: Text(startDate == null
                    ? 'Start Date'
                    : 'Start Date: ${startDate!.toLocal().toString().split(" ")[0]}'),
                trailing: const Icon(Icons.date_range),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => startDate = picked);
                },
              ),
              ListTile(
                title: Text(endDate == null
                    ? 'End Date'
                    : 'End Date: ${endDate!.toLocal().toString().split(" ")[0]}'),
                trailing: const Icon(Icons.date_range),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => endDate = picked);
                },
              ),
              TextFormField(
                initialValue: weekendRate?.toString(),
                decoration:
                    const InputDecoration(labelText: 'Weekend Rate (optional)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => weekendRate = double.tryParse(val),
              ),
              TextFormField(
                initialValue: seasonalMultiplier?.toString(),
                decoration: const InputDecoration(
                    labelText: 'Seasonal Multiplier (optional)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => seasonalMultiplier = double.tryParse(val),
              ),
              SwitchListTile(
                value: isActive,
                title: const Text('Active'),
                onChanged: (val) => setState(() => isActive = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      startDate != null &&
                      endDate != null &&
                      categoryId != null &&
                      ratePlanId != null) {
                    final success = await ratePlanVM.updateRatePlan(
                      id: ratePlanId!,
                      name: name,
                      baseRate: baseRate,
                      categoryId: categoryId!.toString(),
                      startDate: startDate!,
                      endDate: endDate!,
                      weekendRate: weekendRate,
                      seasonalMultiplier: seasonalMultiplier,
                      isActive: isActive,
                    );

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Rate Plan updated successfully')));
                      routerDelegate.go('hotel_rate_plans');
                    }
                  }
                },
                child: const Text('Update Rate Plan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
