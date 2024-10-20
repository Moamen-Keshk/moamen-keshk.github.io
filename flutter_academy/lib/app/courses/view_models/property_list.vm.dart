import 'package:flutter_academy/app/courses/view_models/property.vm.dart';
import 'package:flutter_academy/infrastructure/courses/res/property.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PropertyListVM extends StateNotifier<List<PropertyVM>> {
  PropertyListVM() : super(const []) {
    fetchProperties();
  }
  Future<void> fetchProperties() async {
    final res = await PropertyService().getAllProperties();
    state = [...res.map((property) => PropertyVM(property))];
  }

  Future<bool> addToProperties({required String name,
      required String address}) async {
    if (await PropertyService().addProperty(name, address)) {
      await fetchProperties();
      return true;
    }
    return false;
  }
}

final propertyListVM =
    StateNotifierProvider<PropertyListVM, List<PropertyVM>>(
        (ref) => PropertyListVM());
