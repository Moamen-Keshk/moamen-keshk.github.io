import 'package:flutter_academy/app/courses/view_models/season.vm.dart';
import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/infrastructure/courses/model/season.model.dart';
import 'package:flutter_academy/infrastructure/courses/res/season.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    bool overrideConflicts = false,
  }) async {
    final conflicts = await getConflictingSeasons(
      propertyId: propertyId,
      startDate: startDate,
      endDate: endDate,
      excludeSeasonId: seasonId,
    );

    if (conflicts.isNotEmpty && !overrideConflicts) {
      return false;
    }

    if (overrideConflicts) {
      for (final conflict in conflicts) {
        await SeasonService().deleteSeason(conflict.id);
      }
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
    final result = await SeasonService().deleteSeason(seasonId);
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
