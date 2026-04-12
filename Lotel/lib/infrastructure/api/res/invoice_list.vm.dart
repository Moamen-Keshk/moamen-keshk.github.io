import 'package:flutter_riverpod/legacy.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/model/invoice.model.dart';
import 'package:lotel_pms/infrastructure/api/res/invoice.service.dart';

class InvoiceListVM extends StateNotifier<List<InvoiceModel>> {
  final int propertyId;
  final InvoiceService service;

  InvoiceListVM(this.propertyId, this.service) : super(const []) {
    if (propertyId > 0) {
      fetchInvoices();
    }
  }

  Future<void> fetchInvoices() async {
    if (propertyId <= 0) {
      state = const [];
      return;
    }
    state = await service.getInvoices(propertyId);
  }
}

final invoiceListVM =
    StateNotifierProvider<InvoiceListVM, List<InvoiceModel>>((ref) {
  final propertyId = ref.watch(selectedPropertyVM) ?? 0;
  return InvoiceListVM(propertyId, InvoiceService());
});
