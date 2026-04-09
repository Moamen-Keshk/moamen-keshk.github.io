import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For formatting the last sync date
import 'package:lotel_pms/app/channel_manager/view_models/channel_connection_list.vm.dart';

class ChannelConnectionsView extends ConsumerWidget {
  const ChannelConnectionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(channelConnectionListVMProvider);

    return connectionState.when(
      data: (connections) {
        if (connections.isEmpty) {
          return const Center(
            child: Text('No channels connected. Tap + to connect an OTA.'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(channelConnectionListVMProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: connections.length,
            itemBuilder: (context, index) {
              final conn = connections[index];

              // Determine status color
              final statusColor = conn.status.toLowerCase() == 'active'
                  ? Colors.green
                  : Colors.orange;

              // Format the last successful sync time
              final lastSyncText = conn.lastSuccessAt != null
                  ? DateFormat('MMM dd, h:mm a').format(conn.lastSuccessAt!)
                  : 'Never synced';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.public, color: Colors.blue),
                  ),
                  title: Text(
                    conn.channelCode,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 10, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            conn.status.toUpperCase(),
                            style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Hotel ID: ${conn.hotelIdOnChannel}',
                          style: const TextStyle(fontSize: 12)),
                      Text('Last Sync: $lastSyncText',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'sync') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Syncing channel...')),
                        );
                        await ref
                            .read(channelConnectionListVMProvider.notifier)
                            .forceSync(conn.id);
                      } else if (value == 'disconnect') {
                        final success = await ref
                            .read(channelConnectionListVMProvider.notifier)
                            .disconnectChannel(conn.id);
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to disconnect channel')),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'sync',
                        child: ListTile(
                          leading: Icon(Icons.sync),
                          title: Text('Force Sync'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'disconnect',
                        child: ListTile(
                          leading: Icon(Icons.link_off, color: Colors.red),
                          title: Text('Disconnect',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading connections:\n$error',
                textAlign: TextAlign.center),
            TextButton(
              onPressed: () => ref.invalidate(channelConnectionListVMProvider),
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }
}
