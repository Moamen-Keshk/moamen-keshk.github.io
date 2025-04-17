import 'package:flutter_academy/app/courses/view_models/payment_status.vm.dart';
import 'package:flutter_academy/infrastructure/courses/res/payment_status.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentStatusListVM extends StateNotifier<List<PaymentStatusVM>> {
  PaymentStatusListVM() : super(const []) {
    fetchPaymentStatus();
  }
  Future<void> fetchPaymentStatus() async {
    final res = await PaymentStatusService().getAllPaymentStatus();
    state = [...res.map((status) => PaymentStatusVM(status))];
  }

  Future<bool> addToPaymentStatus(
      {required String name, required String description}) async {
    if (await PaymentStatusService().addPaymentStatus(name, description)) {
      await fetchPaymentStatus();
      return true;
    }
    return false;
  }

  Future<Map<int, String>> paymentStatusMapping() async {
    Map<int, String> statusMap = {};
    final res = await PaymentStatusService().getAllPaymentStatus();
    for (var status in res) {
      statusMap[int.parse(status.id)] = status.name;
    }
    return statusMap;
  }
}

final paymentStatusListVM =
    StateNotifierProvider<PaymentStatusListVM, List<PaymentStatusVM>>(
        (ref) => PaymentStatusListVM());
