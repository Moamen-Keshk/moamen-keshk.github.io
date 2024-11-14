import 'package:flutter/material.dart';

class FloorCard extends StatefulWidget {
  const FloorCard({super.key});

  @override
  State<FloorCard> createState() => _FloorCardState();
}

class _FloorCardState extends State<FloorCard> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 0,
            ),
            child: Column(
              children: [],
            )));
  }
}
