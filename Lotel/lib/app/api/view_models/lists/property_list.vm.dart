import 'package:lotel_pms/app/api/view_models/property.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/property.service.dart';
import 'package:flutter_riverpod/legacy.dart';

class PropertyListVM extends StateNotifier<List<PropertyVM>> {
  final PropertyService propertyService;

  PropertyListVM(this.propertyService) : super(const []) {
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    final res = await propertyService.getAllProperties();
    state = [...res.map((property) => PropertyVM(property))];
  }

  // 👉 UPDATED: Accepts the new parameters from the New Property Wizard
  Future<PropertyVM?> addToProperties({
    required String name,
    required String address,
    String? phone,
    String? email,
    String? timezone,
    String? currency,
    double? taxRate,
    String? defaultCheckInTime,
    String? defaultCheckOutTime,
    List<int>? floors,
    List<int>? amenityIds,
  }) async {
    // 👉 UPDATED: Uses named parameters to pass data cleanly to the service
    final createdProperty = await propertyService.addProperty(
      name: name,
      address: address,
      phone: phone,
      email: email,
      timezone: timezone,
      currency: currency,
      taxRate: taxRate,
      defaultCheckInTime: defaultCheckInTime,
      defaultCheckOutTime: defaultCheckOutTime,
      floors: floors,
      amenityIds: amenityIds,
    );
    if (createdProperty != null) {
      await fetchProperties();
      for (final property in state) {
        if (property.id == createdProperty.id) {
          return property;
        }
      }
      return PropertyVM(createdProperty);
    }
    return null;
  }

  Future<bool> editProperty(
      int propertyId, Map<String, dynamic> updatedData) async {
    try {
      final updatedProperty =
          await propertyService.editProperty(propertyId, updatedData);
      if (updatedProperty != null) {
        await fetchProperties();
        return true;
      }
    } catch (e) {
      // Handle error, e.g., log it or update the state with an error message
    }
    return false;
  }

  Future<bool> deleteProperty(int propertyId) async {
    try {
      final success = await propertyService.deleteProperty(propertyId);
      if (success) {
        // Remove the property from the local state list immediately
        state = state.where((p) => p.id != propertyId.toString()).toList();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }
}

final propertyListVM = StateNotifierProvider<PropertyListVM, List<PropertyVM>>(
    (ref) => PropertyListVM(PropertyService()));
