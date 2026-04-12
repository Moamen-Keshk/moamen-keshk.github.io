import 'package:lotel_pms/app/api/view_models/season.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/infrastructure/api/model/season.model.dart';
import 'package:lotel_pms/infrastructure/api/res/season.service.dart';
import 'package:flutter_riverpod/legacy.dart';

class SeasonListVM extends StateNotifier<List<SeasonVM>> {
  bool _disposed = false;
  final int? propertyId;

  SeasonListVM(this.propertyId) : super(const []) {
    fetchSeasons();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchSeasons() async {
    if (propertyId == null) return;
    final res = await SeasonService().getAllSeasons(propertyId!);
    if (_disposed) return;
    state = [...res.map((s) => SeasonVM(s))];
  }

  Future<List<Season>> getConflictingSeasons({
    required int propertyId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeSeasonId,
  }) async {
    final existing = await SeasonService().getAllSeasons(propertyId);

    return existing.where((season) {
      if (excludeSeasonId != null && season.id == excludeSeasonId) {
        return false;
      }

      return !(endDate.isBefore(season.startDate) ||
          startDate.isAfter(season.endDate));
    }).toList();
  }

  Future<bool> saveSeason({
    required int propertyId,
    required DateTime startDate,
    required DateTime endDate,
    String? label,
    String? seasonId, // null = new season
  }) async {
    final conflicts = await getConflictingSeasons(
      propertyId: propertyId,
      startDate: startDate,
      endDate: endDate,
      excludeSeasonId: seasonId,
    );

    if (conflicts.isNotEmpty) {
      return false;
    }

    final result = seasonId == null
        ? await SeasonService().addSeason(
            propertyId: propertyId,
            startDate: startDate,
            endDate: endDate,
            label: label,
          )
        : await SeasonService().updateSeason(
            propertyId: propertyId,
            seasonId: seasonId,
            startDate: startDate,
            endDate: endDate,
            label: label,
          );

    if (result) {
      await fetchSeasons();
      return true;
    }

    return false;
  }

  Future<bool> deleteSeason(String seasonId) async {
    if (propertyId == null) return false;
    final result = await SeasonService().deleteSeason(propertyId!, seasonId);
    if (result) {
      state = state.where((s) => s.id != seasonId).toList();
      return true;
    }
    return false;
  }
}

final seasonListVM = StateNotifierProvider<SeasonListVM, List<SeasonVM>>(
  (ref) => SeasonListVM(ref.watch(selectedPropertyVM)),
);
