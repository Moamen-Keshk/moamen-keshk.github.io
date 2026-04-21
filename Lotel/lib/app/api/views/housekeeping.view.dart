import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';

import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/app/api/view_models/lists/housekeeping_list.vm.dart';
import 'package:lotel_pms/infrastructure/api/model/housekeeping.model.dart';

// Status Configuration Helpers
const Map<int, String> cleaningStatusNames = {
  1: 'Dirty',
  2: 'Waiting',
  3: 'Clean',
  4: 'Refresh',
  5: 'Service',
  6: 'Occupied',
  7: 'Ready',
};

const Map<int, Color> cleaningStatusColors = {
  1: Colors.red,
  2: Colors.orange,
  3: Colors.green,
  4: Colors.blue,
  5: Colors.purple,
  6: Colors.grey,
  7: Colors.teal,
};

// Define the priority order (Most work to least work)
const List<int> statusPriority = [
  1, // Dirty
  5, // Service
  2, // Waiting (will be dirty soon)
  4, // Refresh
  7, // Ready
  3, // Clean
  6, // Occupied
];

const List<int> manualCleaningStatusIds = [
  1, // Dirty
  3, // Clean
  4, // Refresh
  5, // Service
  7, // Ready
];

class HousekeepingView extends ConsumerWidget {
  const HousekeepingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(housekeepingDateProvider);
    final propertyId = ref.watch(selectedPropertyVM) ?? 0;

    final now = DateTime.now();
    final isToday =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
            .isAtSameMomentAs(DateTime(now.year, now.month, now.day));

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CompactViewHeader(
                    title: 'Housekeeping',
                  ),
                  _HousekeepingDatePicker(
                    selectedDate: selectedDate,
                    propertyId: propertyId,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (isToday)
            _buildInteractiveTodayList(context, ref, propertyId)
          else
            _buildDateSpecificList(context, ref, propertyId, selectedDate),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  // --- UI: TODAY (Interactive & Grouped) ---
  Widget _buildInteractiveTodayList(
      BuildContext context, WidgetRef ref, int propertyId) {
    final roomsAsync = ref.watch(housekeepingRoomsProvider(propertyId));

    return roomsAsync.when(
      data: (rooms) {
        if (rooms.isEmpty) {
          return const SliverToBoxAdapter(
              child: Center(child: Text("No rooms found.")));
        }

        // Flatten the grouped data into a single list of headers (int) and rooms.
        List<dynamic> listItems = [];

        for (int statusId in statusPriority) {
          // Find rooms with this status and sort them by room number
          final groupRooms = rooms
              .where((r) => r.cleaningStatusId == statusId)
              .toList()
            ..sort((a, b) =>
                a.roomNumber.toString().compareTo(b.roomNumber.toString()));

          if (groupRooms.isNotEmpty) {
            listItems.add(statusId); // Add the status ID as a header marker
            listItems.addAll(groupRooms); // Add the rooms under this header
          }
        }

        // Catch any rooms that might have an undefined status ID
        final unknownRooms = rooms
            .where((r) => !statusPriority.contains(r.cleaningStatusId))
            .toList();
        if (unknownRooms.isNotEmpty) {
          listItems.add(0); // 0 represents Unknown
          listItems.addAll(unknownRooms);
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = listItems[index];
              if (item is int) {
                return _GroupHeader(statusId: item);
              } else if (item is HousekeepingRoom) {
                return _InteractiveRoomRow(room: item, propertyId: propertyId);
              }
              return const SizedBox();
            },
            childCount: listItems.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator())),
      error: (e, st) =>
          SliverToBoxAdapter(child: Center(child: Text("Error: $e"))),
    );
  }

  // --- UI: PAST OR FUTURE (Read-Only) ---
  Widget _buildDateSpecificList(
      BuildContext context, WidgetRef ref, int propertyId, DateTime date) {
    final dataAsync = ref.watch(
        housekeepingDateDataProvider(HousekeepingParams(propertyId, date)));

    return dataAsync.when(
      data: (payload) {
        if (payload['type'] == 'past') {
          final logs = (payload['data'] as List)
              .map((e) => CleaningLog.fromMap(e))
              .toList();
          return _buildPastLogs(logs);
        } else if (payload['type'] == 'future') {
          final forecasts = (payload['data'] as List)
              .map((e) => Forecast.fromMap(e))
              .toList();
          return _buildFutureForecasts(forecasts);
        }
        return const SliverToBoxAdapter(child: SizedBox());
      },
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator())),
      error: (e, st) =>
          SliverToBoxAdapter(child: Center(child: Text("Error: $e"))),
    );
  }

  Widget _buildPastLogs(List<CleaningLog> logs) {
    if (logs.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
              child: Text("No cleaning status changes recorded on this date.",
                  style: TextStyle(color: Colors.grey))),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final log = logs[index];
        final timeStr = DateFormat('hh:mm a').format(log.timestamp);
        final oldStat = cleaningStatusNames[log.oldStatusId] ?? 'Unknown';
        final newStat = cleaningStatusNames[log.newStatusId] ?? 'Unknown';

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

  Widget _buildFutureForecasts(List<Forecast> forecasts) {
    if (forecasts.isEmpty) {
      return const SliverToBoxAdapter(child: Center(child: Text("No data.")));
    }

    // Grouping the future forecasts with 'Clean' added
    const List<String> forecastPriority = [
      'To be cleaned',
      'To be refreshed',
      'Ready',
      'Expected Occupied',
      'Clean'
    ];
    List<dynamic> listItems = [];

    for (String status in forecastPriority) {
      final group = forecasts.where((f) => f.forecastStatus == status).toList()
        ..sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
      if (group.isNotEmpty) {
        listItems.add(status); // Header marker (String)
        listItems.addAll(group);
      }
    }

    final unknownForecasts = forecasts
        .where(
            (forecast) => !forecastPriority.contains(forecast.forecastStatus))
        .toList()
      ..sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
    if (unknownForecasts.isNotEmpty) {
      listItems.add('Other');
      listItems.addAll(unknownForecasts);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = listItems[index];

        if (item is String) {
          // Headers
          Color color = Colors.grey;
          if (item == 'To be cleaned') {
            color = Colors.red;
          }
          if (item == 'To be refreshed') {
            color = Colors.blue;
          }
          if (item == 'Clean') {
            color = Colors.green;
          }
          if (item == 'Ready') {
            color = Colors.teal;
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Container(
                    width: 14,
                    height: 14,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(item.toUpperCase(),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          );
        } else if (item is Forecast) {
          // Cards
          Color badgeColor = Colors.grey;
          if (item.forecastStatus == 'To be cleaned') {
            badgeColor = Colors.red;
          }
          if (item.forecastStatus == 'To be refreshed') {
            badgeColor = Colors.blue;
          }
          if (item.forecastStatus == 'Clean') {
            badgeColor = Colors.green;
          }
          if (item.forecastStatus == 'Ready') {
            badgeColor = Colors.teal;
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: badgeColor, width: 5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.event, color: Colors.blueGrey),
                title: Text('Room ${item.roomNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Chip(
                  label: Text(item.forecastStatus,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: badgeColor,
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      }, childCount: listItems.length),
    );
  }
}

// --- WIDGETS ---

class _GroupHeader extends StatelessWidget {
  final int statusId;
  const _GroupHeader({required this.statusId});

  @override
  Widget build(BuildContext context) {
    final name = statusId == 0
        ? 'Unknown Status'
        : cleaningStatusNames[statusId] ?? 'Unknown';
    final color = statusId == 0
        ? Colors.grey
        : cleaningStatusColors[statusId] ?? Colors.grey;

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
            name.toUpperCase(),
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
    final statusId = room.cleaningStatusId;
    final statusName = room.cleaningStatus;
    final statusColor = cleaningStatusColors[statusId] ?? Colors.grey;
    final subtitleParts = <String>['Current Status: $statusName'];
    if (room.isOccupied) {
      subtitleParts.add('Occupied');
    }
    if (room.baseCleaningStatus != null &&
        room.baseCleaningStatus!.isNotEmpty &&
        room.baseCleaningStatus != room.cleaningStatus) {
      subtitleParts.add('Base: ${room.baseCleaningStatus}');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Container(
        // Colored left accent border to match the grouping color
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: statusColor, width: 6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text('Room ${room.roomNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitleParts.join(' • ')),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: statusColor),
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
              itemCount: manualCleaningStatusIds.length,
              itemBuilder: (context, index) {
                final key = manualCleaningStatusIds[index];
                String name = cleaningStatusNames[key]!;

                return ListTile(
                  title: Text(name),
                  leading: CircleAvatar(
                      backgroundColor: cleaningStatusColors[key], radius: 10),
                  onTap: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final dialogNavigator = Navigator.of(dialogContext);

                    // Start Update
                    scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Updating to $name...')));

                    final roomService = ref.read(roomServiceProvider);
                    final success = await roomService.updateCleaningStatus(
                        propertyId, room.id, key);

                    if (!dialogNavigator.mounted ||
                        !scaffoldMessenger.mounted) {
                      return;
                    }

                    if (success) {
                      // Refresh the specific provider
                      ref.invalidate(housekeepingRoomsProvider(propertyId));
                      dialogNavigator.pop();
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                            content: Text('Status updated successfully'),
                            backgroundColor: Colors.green),
                      );
                    } else {
                      dialogNavigator.pop();
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                            content: Text('Failed to update status'),
                            backgroundColor: Colors.red),
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
  final int propertyId;
  const _HousekeepingDatePicker(
      {required this.selectedDate, required this.propertyId});

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
        const SizedBox(width: 16),
        // REFRESH BUTTON
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.blue),
          tooltip: "Refresh Data",
          onPressed: () {
            // Force refresh both the Today provider and the Future/Past provider
            ref.invalidate(housekeepingRoomsProvider(propertyId));
            ref.invalidate(housekeepingDateDataProvider(
                HousekeepingParams(propertyId, selectedDate)));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Data refreshed'),
                  duration: Duration(seconds: 1)),
            );
          },
        ),
      ],
    );
  }
}
