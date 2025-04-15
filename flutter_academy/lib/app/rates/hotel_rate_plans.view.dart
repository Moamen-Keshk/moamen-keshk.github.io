import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/rates/rate_plan.vm.dart';
import 'package:flutter_academy/app/rates/rate_plan_list.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category.vm.dart';
import 'package:flutter_academy/app/courses/view_models/category_list.vm.dart';

class HotelRatePlansView extends ConsumerWidget {
  const HotelRatePlansView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratePlans = ref.watch(ratePlanListVM);
    final categories = ref.watch(categoryListVM);

    if (ratePlans.isEmpty || categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final groupedPlans = _groupRatePlansByCategory(ratePlans, categories);

    if (groupedPlans.isEmpty) {
      return const Center(child: Text("No rate plans available."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...groupedPlans.entries.map((entry) {
            final categoryName = entry.key;
            final plans = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: plans
                      .map((plan) => _RatePlanCard(
                            plan: plan,
                            onTap: () {
                              ref
                                  .read(ratePlanToEditVM.notifier)
                                  .updateRatePlan(plan);
                              routerDelegate.push('edit_rate_plan');
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 32),
              ],
            );
          }),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => routerDelegate.push('rate_plan'),
              icon: const Icon(Icons.add),
              label: const Text("Add New Rate Plan"),
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

  Map<String, List<RatePlanVM>> _groupRatePlansByCategory(
    List<RatePlanVM> plans,
    List<CategoryVM> categories,
  ) {
    final grouped = <String, List<RatePlanVM>>{};
    final categoryMap = {
      for (var c in categories) c.id.trim(): c.name.trim(),
    };

    for (final plan in plans) {
      final categoryName =
          categoryMap[plan.categoryId.trim()] ?? "Uncategorized";
      grouped.putIfAbsent(categoryName, () => []).add(plan);
    }

    return grouped;
  }
}

class _RatePlanCard extends StatefulWidget {
  final RatePlanVM plan;
  final VoidCallback onTap;

  const _RatePlanCard({required this.plan, required this.onTap});

  @override
  State<_RatePlanCard> createState() => _RatePlanCardState();
}

class _RatePlanCardState extends State<_RatePlanCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

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
              Text(plan.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text("Base Rate: \$${plan.baseRate.toStringAsFixed(2)}"),
              Row(
                children: [
                  Icon(plan.isActive ? Icons.check : Icons.close,
                      color: plan.isActive ? Colors.green : Colors.red,
                      size: 18),
                  const SizedBox(width: 6),
                  Text(plan.isActive ? "Active" : "Inactive"),
                ],
              ),
              const SizedBox(height: 4),
              Text("Start: ${_formatDate(plan.startDate)}"),
              Text("End: ${_formatDate(plan.endDate)}"),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
