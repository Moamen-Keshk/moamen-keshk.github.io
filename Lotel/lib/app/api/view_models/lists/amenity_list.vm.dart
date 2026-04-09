import 'package:lotel_pms/app/api/view_models/amenity.vm.dart';
import 'package:lotel_pms/infrastructure/api/res/amenity.service.dart';
import 'package:flutter_riverpod/legacy.dart';

class AmenityListVM extends StateNotifier<List<AmenityVM>> {
  bool _disposed = false;
  final AmenityService amenityService;

  // Amenities are usually global rather than tied to a single property ID
  // when fetching the master list to pick from.
  AmenityListVM(this.amenityService) : super(const []) {
    fetchAmenities();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchAmenities() async {
    final res = await amenityService.getAllAmenities();
    if (_disposed) return;
    state = [...res.map((amenity) => AmenityVM(amenity))];
  }

  Future<bool> addAmenity({required String name, String? icon}) async {
    if (await amenityService.addAmenity(name, icon)) {
      await fetchAmenities();
      return true;
    }
    return false;
  }

  Future<bool> editAmenity(
      String amenityId, Map<String, dynamic> updatedData) async {
    try {
      final success = await amenityService.editAmenity(amenityId, updatedData);
      if (success) {
        await fetchAmenities();
        return true;
      }
    } catch (e) {
      // Handle error, e.g., log it or update the state with an error message
    }
    return false;
  }

  Future<bool> deleteAmenity(String amenityId) async {
    try {
      final success = await amenityService.deleteAmenity(amenityId);
      if (success) {
        await fetchAmenities(); // Refresh state
        return true;
      }
    } catch (e) {
      // Optionally log or show an error message
    }
    return false;
  }
}

final amenityListVM = StateNotifierProvider<AmenityListVM, List<AmenityVM>>(
    (ref) => AmenityListVM(AmenityService()));
