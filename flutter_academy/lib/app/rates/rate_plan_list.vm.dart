import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/rates/rate_plan.model.dart';
import 'package:flutter_academy/app/rates/rate_plan.service.dart';
import 'package:flutter_academy/app/rates/rate_plan.vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RatePlanListVM extends StateNotifier<List<RatePlanVM>> {
  final int? propertyId;

  RatePlanListVM(this.propertyId) : super(const []) {
    fetchRatePlans();
  }

  Future<void> fetchRatePlans() async {
    final res = await RatePlanService()
        .getRatePlans(propertyId!); // Filter by propertyId if supported
    state = [...res.map((ratePlan) => RatePlanVM(ratePlan))];
  }

  Future<bool> addRatePlan({
    required String name,
    required double baseRate,
    required int propertyId,
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
    double? weekendRate,
    double? seasonalMultiplier,
    bool isActive = true,
  }) async {
    final newPlan = RatePlan(
      id: '', // let backend generate it
      name: name,
      baseRate: baseRate,
      propertyId: propertyId,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
      weekendRate: weekendRate,
      seasonalMultiplier: seasonalMultiplier,
      isActive: isActive,
    );

    final result = await RatePlanService().addRatePlan(newPlan);
    if (result) {
      await fetchRatePlans();
      return true;
    }
    return false;
  }

  Future<bool> deleteRatePlan(String ratePlanId) async {
    final result = await RatePlanService().deleteRatePlan(ratePlanId);
    if (result) {
      state = state.where((ratePlan) => ratePlan.id != ratePlanId).toList();
      return true;
    }
    return false;
  }
}

final ratePlanListVM = StateNotifierProvider<RatePlanListVM, List<RatePlanVM>>(
  (ref) => RatePlanListVM(ref.watch(selectedPropertyVM)),
);
