import 'package:flutter/material.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final groupedPlans = _groupRatePlansByCategory(ratePlans, categories);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grouped Rate Plans by Category
            ...groupedPlans.entries.map((entry) {
              final categoryName = entry.key;
              final plansInCategory = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categoryName,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: plansInCategory.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                    ),
                    itemBuilder: (context, index) {
                      final plan = plansInCategory[index];
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(ratePlanToEditVM.notifier)
                              .updateRatePlan(plan);
                          routerDelegate.go('edit_rate_plan');
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(plan.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 6),
                                Text(
                                    "Base Rate: \$${plan.baseRate.toStringAsFixed(2)}"),
                                Text("Active: ${plan.isActive ? 'Yes' : 'No'}"),
                                Text(
                                    "Start: ${plan.startDate.toLocal().toString().split(" ")[0]}"),
                                Text(
                                    "End: ${plan.endDate.toLocal().toString().split(" ")[0]}"),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),

            // Add New Rate Plan Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  routerDelegate.go('rate_plan'); // update as needed
                },
                icon: const Icon(Icons.add),
                label: const Text("Add New Rate Plan"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Map<String, List<RatePlanVM>> _groupRatePlansByCategory(
      List<RatePlanVM> plans, List<CategoryVM> categories) {
    final Map<String, List<RatePlanVM>> grouped = {};

    for (var category in categories) {
      grouped[category.name] =
          plans.where((p) => p.categoryId == category.id).toList();
    }

    return grouped;
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 800) return 3;
    return 2;
  }
}
