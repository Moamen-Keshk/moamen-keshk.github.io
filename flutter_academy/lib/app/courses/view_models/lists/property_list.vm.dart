import 'package:flutter_academy/app/courses/view_models/property.vm.dart';
import 'package:flutter_academy/infrastructure/courses/res/property.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PropertyListVM extends StateNotifier<List<PropertyVM>> {
  final PropertyService propertyService;
  PropertyListVM(this.propertyService) : super(const []) {
    fetchProperties();
  }
  Future<void> fetchProperties() async {
    final res = await propertyService.getAllProperties();
    state = [...res.map((property) => PropertyVM(property))];
  }

  Future<bool> addToProperties(
      {required String name, required String address}) async {
    if (await propertyService.addProperty(name, address)) {
      await fetchProperties();
      return true;
    }
    return false;
  }

  Future<bool> editProperty(
      int propertyId, Map<String, dynamic> updatedData) async {
    try {
      final success =
          await propertyService.editProperty(propertyId, updatedData);
      if (success) {
        await fetchProperties();
        return true;
      }
    } catch (e) {
      // Handle error, e.g., log it or update the state with an error message
    }
    return false;
  }
}

final propertyListVM = StateNotifierProvider<PropertyListVM, List<PropertyVM>>(
    (ref) => PropertyListVM(PropertyService()));
