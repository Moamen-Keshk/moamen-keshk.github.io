import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/channel_manager/models/channel_connection.dart';
import 'package:flutter_academy/app/channel_manager/view_models/channel_connection_list.vm.dart';

// Assuming these pages exist
import 'package:flutter_academy/app/channel_manager/pages/room_mapping.page.dart';
import 'package:flutter_academy/app/channel_manager/pages/rate_plan_mapping.page.dart';

class ChannelManagerView extends ConsumerWidget {
  ChannelManagerView({super.key});

  final List<Map<String, String>> _supportedChannels = [
    {"name": "Booking.com", "logo": "🏨"},
    {"name": "Expedia", "logo": "✈️"},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyId = ref.watch(selectedPropertyVM);

    if (propertyId == null || propertyId == 0) {
      return const Center(child: Text("Please select a property first."));
    }

    final connectionState = ref.watch(channelConnectionListVMProvider);

    return connectionState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading channels: $error')),
      data: (activeConnections) {
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _supportedChannels.length,
          itemBuilder: (context, index) {
            final channelInfo = _supportedChannels[index];

            final matchedConnections = activeConnections.where((conn) =>
                conn.channelName.toLowerCase() ==
                channelInfo['name']!.toLowerCase());

            final ChannelConnection? connection =
                matchedConnections.isNotEmpty ? matchedConnections.first : null;

            final isConnected = connection != null;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(channelInfo['logo']!,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            channelInfo['name']!,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        _buildStatusBadge(connection?.status),

                        // NEW: Added a menu for Sync and Disconnect actions!
                        if (isConnected)
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'sync') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Force sync started...')),
                                );
                                await ref
                                    .read(channelConnectionListVMProvider
                                        .notifier)
                                    .forceSync(connection.id.toString());
                              } else if (value == 'disconnect') {
                                // Usually you'd want to show a confirmation dialog here first
                                await ref
                                    .read(channelConnectionListVMProvider
                                        .notifier)
                                    .disconnectChannel(
                                        connection.id.toString());
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(
                                value: 'sync',
                                child: Row(
                                  children: [
                                    Icon(Icons.sync, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Force Sync'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'disconnect',
                                child: Row(
                                  children: [
                                    Icon(Icons.link_off, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Disconnect',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const Divider(height: 30),
                    if (isConnected) ...[
                      const Text(
                        "Sync is currently active. Any changes to PMS inventory will automatically push to this channel.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.bed),
                            label: const Text("Map Rooms"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoomMappingPage(
                                      connectionId: connection.id),
                                ),
                              );
                            },
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.attach_money),
                            label: const Text("Map Rates"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RatePlanMappingPage(
                                      connectionId: connection.id),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    ] else ...[
                      const Text(
                        "Not connected. Click below to enter your OTA credentials and begin syncing.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.link),
                          label: const Text("Connect Account"),
                          onPressed: () {
                            _showConnectDialog(
                              context,
                              channelInfo['name'] ?? 'Channel',
                            );
                          },
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showConnectDialog(
    BuildContext context,
    String channelName,
  ) async {
    final hotelIdController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var obscurePassword = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: Text('Connect $channelName'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter your $channelName credentials to begin syncing.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: hotelIdController,
                        decoration: const InputDecoration(
                          labelText: 'Hotel ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Hotel ID is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$channelName credentials captured for hotel ${hotelIdController.text.trim()}.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Connect'),
                ),
              ],
            );
          },
        );
      },
    );

    hotelIdController.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }

  Widget _buildStatusBadge(String? status) {
    Color bgColor;
    String text;
    switch (status?.toLowerCase()) {
      case 'active':
        bgColor = Colors.green;
        text = "ACTIVE";
        break;
      case 'error':
        bgColor = Colors.red;
        text = "ERROR";
        break;
      case 'pending':
        bgColor = Colors.orange;
        text = "PENDING";
        break;
      default:
        bgColor = Colors.grey;
        text = "DISCONNECTED";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withAlpha(25), // Updated for newer Flutter versions
        border: Border.all(color: bgColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: bgColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
