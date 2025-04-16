import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/rates/rate_plan.vm.dart';
import 'package:flutter_academy/app/rates/rate_plan.model.dart';
import 'package:flutter_academy/app/rates/rate_plan.service.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';

class RatePlanListVM extends StateNotifier<List<RatePlanVM>> {
  final int? propertyId;

  RatePlanListVM(this.propertyId) : super([]) {
    if (propertyId != null && propertyId != 0) {
      fetchRatePlans();
    }
  }

  Future<void> fetchRatePlans() async {
    if (propertyId == null) return;
    final plans = await RatePlanService().getRatePlans(propertyId!);
    state = plans.map((plan) => RatePlanVM(plan)).toList();
  }

  Future<List<RatePlan>> getConflictingPlans(RatePlan newPlan) async {
    final existingPlans =
        await RatePlanService().getRatePlans(newPlan.propertyId);
    return existingPlans.where((plan) {
      if (plan.id == newPlan.id) return false;
      return plan.categoryId == newPlan.categoryId &&
          !(newPlan.endDate.isBefore(plan.startDate) ||
              newPlan.startDate.isAfter(plan.endDate));
    }).toList();
  }

  Future<bool> saveRatePlan({
    required RatePlan ratePlan,
    bool overrideConflicts = false,
  }) async {
    final conflicts = await getConflictingPlans(ratePlan);

    if (conflicts.isNotEmpty && !overrideConflicts) {
      return false;
    }

    if (overrideConflicts) {
      for (final plan in conflicts) {
        await RatePlanService().deleteRatePlan(plan.id);
      }
    }

    final success = ratePlan.id.isNotEmpty
        ? await RatePlanService().updateRatePlan(ratePlan)
        : await RatePlanService().addRatePlan(ratePlan);

    if (success) await fetchRatePlans();

    return success;
  }

  Future<bool> deleteRatePlan(String ratePlanId) async {
    final success = await RatePlanService().deleteRatePlan(ratePlanId);
    if (success) await fetchRatePlans();
    return success;
  }
}

final ratePlanListVM = StateNotifierProvider<RatePlanListVM, List<RatePlanVM>>(
  (ref) => RatePlanListVM(ref.watch(selectedPropertyVM)),
);
