import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotel_pms/app/api/utilities/housekeeping_logic.dart';

import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/app/api/view_models/lists/housekeeping_list.vm.dart';
import 'package:lotel_pms/infrastructure/api/model/housekeeping.model.dart';

class HousekeepingView extends ConsumerWidget {
  const HousekeepingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(housekeepingDateProvider);
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;
    final dataAsync = ref.watch(
      housekeepingDayVMProvider(HousekeepingParams(propertyId, selectedDate)),
    );

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: RefreshIndicator(
        onRefresh: () => _refreshHousekeepingData(
          ref,
          propertyId,
          selectedDate,
        ),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HousekeepingDatePicker(
                      selectedDate: selectedDate,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            ...dataAsync.when(
              data: (data) =>
                  _buildSliversForData(context, ref, propertyId, data),
              loading: () => const [
                SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text('Error: $error')),
                  ),
                ),
              ],
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSliversForData(
    BuildContext context,
    WidgetRef ref,
    int propertyId,
    HousekeepingDayData data,
  ) {
    switch (data.kind) {
      case HousekeepingDayKind.today:
        return _buildTodaySections(data.roomSections, propertyId);
      case HousekeepingDayKind.past:
        return [_buildPastLogs(data.logs, data.emptyMessage)];
      case HousekeepingDayKind.future:
        return [_buildFutureForecasts(data.forecastSections, data.emptyMessage)];
      case HousekeepingDayKind.empty:
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(data.emptyMessage)),
            ),
          ),
        ];
    }
  }

  List<Widget> _buildTodaySections(
    List<HousekeepingSection<HousekeepingRoom>> sections,
    int propertyId,
  ) {
    if (sections.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No rooms found.')),
          ),
        ),
      ];
    }

    return [
      SliverList(
        delegate: SliverChildListDelegate([
          for (final section in sections) ...[
            _GroupHeader(title: section.title, color: section.color),
            for (final room in section.items)
              _InteractiveRoomRow(room: room, propertyId: propertyId),
          ],
        ]),
      ),
    ];
  }

  Widget _buildPastLogs(List<CleaningLog> logs, String emptyMessage) {
    if (logs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              emptyMessage,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final log = logs[index];
        final timeStr = DateFormat('hh:mm a').format(log.timestamp);
        final oldStat = housekeepingStatusFor(log.oldStatusId).label;
        final newStat = housekeepingStatusFor(log.newStatusId).label;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.blueGrey),
            title: Text('Room ${log.roomNumber} updated to $newStat',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Changed from $oldStat by ${log.userName}'),
            trailing: Text(timeStr,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
        );
      }, childCount: logs.length),
    );
  }

  Widget _buildFutureForecasts(
    List<HousekeepingSection<Forecast>> sections,
    String emptyMessage,
  ) {
    if (sections.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(emptyMessage)),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        for (final section in sections) ...[
          _GroupHeader(title: section.title, color: section.color),
          for (final forecast in section.items)
            _ForecastRoomRow(
              forecast: forecast,
              color: section.color,
            ),
        ],
      ]),
    );
  }
}

Future<void> _refreshHousekeepingData(
  WidgetRef ref,
  int propertyId,
  DateTime selectedDate,
) async {
  if (propertyId <= 0) {
    return;
  }

  final params = HousekeepingParams(propertyId, selectedDate);
  await ref.read(housekeepingDayVMProvider(params).notifier).refresh();
}

// --- WIDGETS ---

class _GroupHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _GroupHeader({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _InteractiveRoomRow extends ConsumerWidget {
  final HousekeepingRoom room;
  final int propertyId;

  const _InteractiveRoomRow({required this.room, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = housekeepingStatusFor(room.cleaningStatusId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Container(
        // Colored left accent border to match the grouping color
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: status.color, width: 6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text('Room ${room.roomNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(housekeepingRoomSubtitle(room)),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: status.color),
            onPressed: () =>
                _showStatusUpdateDialog(context, ref, room, propertyId),
            child: const Text("Change Status",
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, WidgetRef ref,
      HousekeepingRoom room, int propertyId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Update Room ${room.roomNumber} Status'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: manualHousekeepingStatuses.length,
              itemBuilder: (context, index) {
                final status = manualHousekeepingStatuses[index];

                return ListTile(
                  enabled: status.id != room.cleaningStatusId,
                  title: Text(status.label),
                  leading: CircleAvatar(
                    backgroundColor: status.color,
                    radius: 10,
                  ),
                  onTap: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final dialogNavigator = Navigator.of(dialogContext);

                    // Start Update
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Updating to ${status.label}...')),
                    );

                    final selectedDate = ref.read(housekeepingDateProvider);
                    final success = await ref
                        .read(
                          housekeepingDayVMProvider(
                            HousekeepingParams(propertyId, selectedDate),
                          ).notifier,
                        )
                        .updateRoomStatus(
                          room.id,
                          status.id,
                        );

                    if (!dialogNavigator.mounted ||
                        !scaffoldMessenger.mounted) {
                      return;
                    }

                    if (success) {
                      dialogNavigator.pop();
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Status updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      dialogNavigator.pop();
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update status'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(dialogContext).pop()),
          ],
        );
      },
    );
  }
}

class _HousekeepingDatePicker extends ConsumerWidget {
  final DateTime selectedDate;

  const _HousekeepingDatePicker({
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () {
            ref.read(housekeepingDateProvider.notifier).state =
                selectedDate.subtract(const Duration(days: 1));
          },
        ),
        Text(
          DateFormat('dd MMM yyyy').format(selectedDate),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () {
            ref.read(housekeepingDateProvider.notifier).state =
                selectedDate.add(const Duration(days: 1));
          },
        ),
      ],
    );
  }
}

class _ForecastRoomRow extends StatelessWidget {
  final Forecast forecast;
  final Color color;

  const _ForecastRoomRow({
    required this.forecast,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: const Icon(Icons.event, color: Colors.blueGrey),
          title: Text(
            'Room ${forecast.roomNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Chip(
            label: Text(
              normalizeForecastStatus(forecast.forecastStatus),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: color,
          ),
        ),
      ),
    );
  }
}
