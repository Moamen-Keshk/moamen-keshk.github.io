import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_academy/app/global/selected_property.global.dart';
import 'package:flutter_academy/app/channel_manager/models/channel_connection.dart';
import 'package:flutter_academy/app/channel_manager/view_models/channel_connection_list.vm.dart';

// NEW: Import the Supported Channels Model and ViewModel
import 'package:flutter_academy/app/channel_manager/models/supported_channel.dart';
import 'package:flutter_academy/app/channel_manager/view_models/supported_channels.vm.dart';

import 'package:flutter_academy/app/channel_manager/pages/room_mapping.page.dart';
import 'package:flutter_academy/app/channel_manager/pages/rate_plan_mapping.page.dart';

class ChannelManagerView extends ConsumerWidget {
  const ChannelManagerView({super.key});

  // REMOVED: The hardcoded _supportedChannels list is gone!

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyId = ref.watch(selectedPropertyVM);

    if (propertyId == null || propertyId == 0) {
      return const Center(child: Text("Please select a property first."));
    }

    final connectionState = ref.watch(channelConnectionListVMProvider);
    // NEW: Watch the database-driven channels list
    final channelsState = ref.watch(supportedChannelsVMProvider);

    return Scaffold(
      body: channelsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading channels: $error')),
        data: (supportedChannels) {
          if (supportedChannels.isEmpty) {
            return const Center(
                child: Text('No supported channels available. Add one!'));
          }

          return connectionState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Error loading connections: $error')),
            data: (activeConnections) {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: supportedChannels.length,
                itemBuilder: (context, index) {
                  // NEW: Use the SupportedChannel object from the DB
                  final SupportedChannel channelInfo = supportedChannels[index];

                  // Match by channel name to align with the current connection model
                  final matchedConnections = activeConnections.where((conn) =>
                      conn.channelName.toLowerCase() ==
                      channelInfo.name.toLowerCase());

                  final ChannelConnection? connection =
                      matchedConnections.isNotEmpty
                          ? matchedConnections.first
                          : null;

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
                              // Updated to use the DB model properties
                              Text(channelInfo.logo,
                                  style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  channelInfo.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              _buildStatusBadge(connection?.status),

                              if (isConnected)
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'sync') {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Force sync started...')),
                                      );
                                      await ref
                                          .read(channelConnectionListVMProvider
                                              .notifier)
                                          .forceSync(connection.id.toString());
                                    } else if (value == 'disconnect') {
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
                                          Icon(Icons.link_off,
                                              color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Disconnect',
                                              style:
                                                  TextStyle(color: Colors.red)),
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
                                        builder: (context) =>
                                            RatePlanMappingPage(
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
                                  // Pass the entire channel info for future dynamic fields
                                  _showConnectDialog(context, ref, channelInfo);
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
        },
      ),
      // NEW: Floating Action Button to Add a Channel
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChannelDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add OTA'),
      ),
    );
  }

  // NEW: Dialog to Post a new Supported Channel to the backend
  Future<void> _showAddChannelDialog(
      BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final logoController = TextEditingController(text: '🌐');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Supported Channel'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'Channel Name (e.g. Airbnb)',
                        border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                        labelText: 'Channel Code (e.g. airbnb)',
                        border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: logoController,
                    decoration: const InputDecoration(
                        labelText: 'Logo (Emoji or Icon)',
                        border: OutlineInputBorder()),
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final success = await ref
                      .read(supportedChannelsVMProvider.notifier)
                      .addChannel(
                        nameController.text.trim(),
                        codeController.text.trim(),
                        logoController.text.trim(),
                      );

                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(success
                              ? 'Channel added successfully!'
                              : 'Failed to add channel. Check if code already exists.')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // UPDATED: Now accepts the SupportedChannel object to easily read .name and .code
  Future<void> _showConnectDialog(
    BuildContext context,
    WidgetRef ref,
    SupportedChannel channel,
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
              title: Text('Connect ${channel.name}'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter your ${channel.name} credentials to begin syncing.',
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
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final propertyId = ref.read(selectedPropertyVM);
                    if (propertyId == null || propertyId == 0) return;

                    final success = await ref
                        .read(channelConnectionListVMProvider.notifier)
                        .connectChannel(
                          propertyId: propertyId,
                          channelId: channel.id,
                          channelName: channel.name,
                          hotelIdOnChannel: hotelIdController.text.trim(),
                          username: usernameController.text.trim(),
                          password: passwordController.text.trim(),
                        );

                    if (!context.mounted) return;
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? '${channel.name} connected for hotel ${hotelIdController.text.trim()}.'
                              : 'Failed to connect ${channel.name}. Please try again.',
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
        color: bgColor.withAlpha(25),
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
