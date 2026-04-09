import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lotel_pms/app/channel_manager/models/channel_room_map.dart';
import 'package:lotel_pms/app/channel_manager/models/external_room.dart';
import 'package:lotel_pms/app/channel_manager/view_models/channel_connection_list.vm.dart';
import 'package:lotel_pms/app/channel_manager/view_models/channel_room_mapping.vm.dart';
import 'package:lotel_pms/app/channel_manager/view_models/external_room.vm.dart';
import 'package:lotel_pms/app/api/view_models/lists/room_list.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';

// Assuming this is where your ExternalRoomSelector is located!
import 'package:lotel_pms/app/channel_manager/views/external_room.view.dart';

class ChannelRoomMappingView extends ConsumerStatefulWidget {
  final String connectionId;

  const ChannelRoomMappingView({super.key, required this.connectionId});

  @override
  ConsumerState<ChannelRoomMappingView> createState() =>
      _ChannelRoomMappingViewState();
}

class _ChannelRoomMappingViewState
    extends ConsumerState<ChannelRoomMappingView> {
  @override
  void initState() {
    super.initState();
    // The moment this view loads, tell our global state which channel we are mapping!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parsedId = int.tryParse(widget.connectionId);
      if (parsedId != null) {
        ref.read(selectedChannelIdVM.notifier).setChannel(parsedId);
      } else {
        debugPrint(
            "Warning: Could not parse connection ID to int: ${widget.connectionId}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // We use a nested Scaffold with a transparent background to natively support
    // the FloatingActionButton without needing a parent Scaffold!
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildList(context, ref),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMappingModal(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Mapping'),
      ),
    );
  }

  // Extracted the list rendering logic to keep the build method clean
  Widget _buildList(BuildContext context, WidgetRef ref) {
    final mappingState = ref.watch(channelRoomMappingVMProvider);

    return mappingState.when(
      data: (mappings) {
        if (mappings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No rooms mapped yet.\nTap + to link a local room to the OTA.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(channelRoomMappingVMProvider),
          child: ListView.builder(
            padding:
                const EdgeInsets.only(top: 16, bottom: 80), // Padding for FAB
            itemCount: mappings.length,
            itemBuilder: (context, index) {
              final map = mappings[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    'Local Room ID: ${map.internalRoomId} ↔ ${map.externalRoomName ?? "Unknown OTA Room"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('OTA Room ID: ${map.externalRoomId}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Remove Mapping',
                    onPressed: () async {
                      final success = await ref
                          .read(channelRoomMappingVMProvider.notifier)
                          .deleteRoomMapping(map.id.toString());

                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Failed to remove mapping. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
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
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Failed to load mappings:\n$error',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () => ref.invalidate(channelRoomMappingVMProvider),
            )
          ],
        ),
      ),
    );
  }

  // Your exact Form logic, moved securely into the state class!
  void _showAddMappingModal(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String? selectedInternalRoomId;
    String? selectedInternalRoomName;
    ExternalRoom? selectedExternalRoom;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Consumer(
              builder: (context, ref, _) {
                final propertyId = ref.watch(selectedPropertyVM) ?? 0;
                final localRooms = ref.watch(roomListVM);
                final channelConnectionsAsync =
                    ref.watch(channelConnectionListVMProvider);
                final parsedConnectionId = int.tryParse(widget.connectionId);

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 24,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Room Mapping',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedInternalRoomId,
                          decoration: const InputDecoration(
                            labelText: 'Select Local Room',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.meeting_room_outlined),
                          ),
                          items: localRooms.map((room) {
                            return DropdownMenuItem<String>(
                              value: room.id,
                              child: Text('Room ${room.roomNumber}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            dynamic matchedRoom;
                            for (final room in localRooms) {
                              if (room.id == value) {
                                matchedRoom = room;
                                break;
                              }
                            }
                            setModalState(() {
                              selectedInternalRoomId = value;
                              selectedInternalRoomName = matchedRoom == null
                                  ? null
                                  : 'Room ${matchedRoom.roomNumber}';
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a local room'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        if (parsedConnectionId != null)
                          ExternalRoomSelector(
                            channelId: parsedConnectionId,
                            selectedRoom: selectedExternalRoom,
                            onChanged: (value) {
                              setModalState(() {
                                selectedExternalRoom = value;
                              });
                            },
                          )
                        else
                          const InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Channel Room',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.error_outline),
                            ),
                            child: Text('Invalid connection ID'),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: parsedConnectionId == null
                                ? null
                                : () async {
                                    if (!(formKey.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }

                                    if (selectedExternalRoom == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please select a channel room'),
                                        ),
                                      );
                                      return;
                                    }

                                    final channelConnections =
                                        channelConnectionsAsync.value ?? [];
                                    dynamic matchingConnection;
                                    for (final connection
                                        in channelConnections) {
                                      if (connection.id ==
                                          widget.connectionId) {
                                        matchingConnection = connection;
                                        break;
                                      }
                                    }

                                    final channelCode = matchingConnection ==
                                            null
                                        ? ''
                                        : matchingConnection.channelCode
                                            .toLowerCase()
                                            .replaceAll(
                                                RegExp(r'[^a-z0-9]+'), '_')
                                            .replaceAll(RegExp(r'^_+|_+$'), '');

                                    final success = await ref
                                        .read(channelRoomMappingVMProvider
                                            .notifier)
                                        .addRoomMapping(
                                          ChannelRoomMap(
                                            id: '',
                                            propertyId: propertyId,
                                            channelCode: channelCode,
                                            internalRoomId:
                                                selectedInternalRoomId!,
                                            internalRoomName:
                                                selectedInternalRoomName,
                                            externalRoomId:
                                                selectedExternalRoom!.id,
                                            externalRoomName:
                                                selectedExternalRoom!.name,
                                          ),
                                        );

                                    if (!context.mounted) return;

                                    if (success) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Room mapping added successfully'),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Failed to add room mapping'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            child: const Text('Save Mapping'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
