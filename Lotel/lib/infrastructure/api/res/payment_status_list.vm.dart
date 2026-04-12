import 'package:flutter_riverpod/legacy.dart';

import 'package:lotel_pms/app/api/view_models/payment_status.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/payment_status.service.dart';

class PaymentStatusListVM extends StateNotifier<List<PaymentStatusVM>> {
  // 1. Removed propertyId from the constructor entirely!
  PaymentStatusListVM() : super(const []) {
    fetchPaymentStatus();
  }

  Future<void> fetchPaymentStatus() async {
    // 2. Removed propertyId from the service call
    final res = await PaymentStatusService().getAllPaymentStatus();
    state = res.map((status) => PaymentStatusVM(status)).toList();
  }

  Future<bool> addToPaymentStatus(
      {required String name, required String description}) async {
    // 3. Removed propertyId from the service call
    if (await PaymentStatusService().addPaymentStatus(name, description)) {
      await fetchPaymentStatus();
      return true;
    }
    return false;
  }

  Future<Map<int, String>> paymentStatusMapping() async {
    Map<int, String> statusMap = {};
    // 4. Removed propertyId from the service call
    final res = await PaymentStatusService().getAllPaymentStatus();

    for (var status in res) {
      statusMap[int.parse(status.id)] = status.name;
    }
    return statusMap;
  }
}

// 5. The provider is now completely independent.
// It no longer watches `selectedPropertyVM`!
final paymentStatusListVM =
    StateNotifierProvider<PaymentStatusListVM, List<PaymentStatusVM>>(
        (ref) => PaymentStatusListVM());
