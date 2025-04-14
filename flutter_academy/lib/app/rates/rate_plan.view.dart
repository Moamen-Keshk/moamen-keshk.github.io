import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';
import 'package:flutter_academy/app/courses/widgets/room_form.widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/rates/rate_plan_list.vm.dart';

class RatePlanView extends ConsumerStatefulWidget {
  const RatePlanView({super.key});

  @override
  ConsumerState<RatePlanView> createState() => _CreateRatePlanFormState();
}

class _CreateRatePlanFormState extends ConsumerState<RatePlanView> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  double baseRate = 0;
  int? categoryId;
  DateTime? startDate;
  DateTime? endDate;
  double? weekendRate;
  double? seasonalMultiplier;
  bool isActive = true;
  List<String?> selectedValues = [];

  @override
  Widget build(BuildContext context) {
    final ratePlanVM = ref.read(ratePlanListVM.notifier);

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Rate Plan Name'),
                onChanged: (val) => name = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Base Rate'),
                keyboardType: TextInputType.number,
                onChanged: (val) => baseRate = double.tryParse(val) ?? 0,
                validator: (val) => val == null || double.tryParse(val) == null
                    ? 'Enter valid number'
                    : null,
              ),
              // Replace with a dynamic dropdown of categories if needed
              Consumer(builder: (context, ref, child) {
                final categories = ref.watch(categoryListVM);
                return CategoryFormRow(
                  categories: categories,
                  onCategoryChanged: (newVal) {
                    setState(() {
                      categoryId = int.parse(newVal);
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
                    initialDate: DateTime.now(),
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
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => endDate = picked);
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Weekend Rate (optional)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => weekendRate = double.tryParse(val),
              ),
              TextFormField(
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
                      categoryId != null) {
                    final success = await ratePlanVM.addRatePlan(
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
                          content: Text('Rate Plan created successfully')));
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Create Rate Plan'),
              )
            ]),
          ),
        ));
  }
}
