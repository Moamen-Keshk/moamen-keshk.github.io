import 'package:flutter/material.dart';
import 'package:lotel_pms/app/channel_manager/views/channel_room_mapping.view.dart';

class RoomMappingPage extends StatelessWidget {
  final String connectionId;

  const RoomMappingPage({super.key, required this.connectionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Rooms'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      // The View now handles the list, the data fetching, AND the Add Mapping button!
      body: ChannelRoomMappingView(connectionId: connectionId),
    );
  }
}
