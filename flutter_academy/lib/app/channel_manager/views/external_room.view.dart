import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_academy/app/channel_manager/models/external_room.dart';

// 1. ADD THIS IMPORT: Point this to wherever you saved the ViewModel
import 'package:flutter_academy/app/channel_manager/view_models/external_room.vm.dart';

class ExternalRoomSelector extends ConsumerWidget {
  final int channelId;
  final ExternalRoom? selectedRoom;
  final ValueChanged<ExternalRoom?> onChanged;

  const ExternalRoomSelector({
    super.key,
    required this.channelId,
    this.selectedRoom,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. UPDATED WATCH CALL: Using the updated provider name
    final externalRoomsAsync = ref.watch(externalRoomVMProvider);

    return externalRoomsAsync.when(
      data: (rooms) {
        // 3. CRASH PREVENTION: Ensure the selected room still exists in the OTA's list
        final validInitialValue =
            rooms.contains(selectedRoom) ? selectedRoom : null;

        return DropdownButtonFormField<ExternalRoom>(
          // 4. FIX: Use 'value' instead of 'initialValue'
          initialValue: validInitialValue,
          decoration: const InputDecoration(
            labelText: 'Select Channel Room',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.bed),
          ),
          items: rooms.map((room) {
            // Display capacity if the OTA provided it
            final capacityText =
                room.capacity != null ? ' (Max: ${room.capacity})' : '';

            return DropdownMenuItem(
              value: room,
              child: Text('${room.name}$capacityText'),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) =>
              value == null ? 'Please select a room from the channel' : null,
        );
      },
      // Show a loading indicator styled like a text field while fetching
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Loading Channel Rooms...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.downloading),
        ),
        child: LinearProgressIndicator(),
      ),
      // Handle errors gracefully inside the form
      error: (err, stack) => InputDecorator(
        decoration: InputDecoration(
          labelText: 'Error Loading Rooms',
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          prefixIcon: const Icon(Icons.error, color: Colors.red),
        ),
        child: Text(
          'Could not fetch rooms. Check connection.',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
