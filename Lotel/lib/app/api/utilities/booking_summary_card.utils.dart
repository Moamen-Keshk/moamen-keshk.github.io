import 'package:flutter/material.dart';

class BookingSummaryCards extends StatelessWidget {
  final int arrivals, inHouse, departures;
  final void Function(String) onTap;

  const BookingSummaryCards({
    required this.arrivals,
    required this.inHouse,
    required this.departures,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _summaryCard(context, 'Arrivals', arrivals, Colors.green, 'Arrivals'),
        _summaryCard(context, 'In House', inHouse, Colors.blue, 'InHouse'),
        _summaryCard(
            context, 'Departures', departures, Colors.red, 'Departures'),
      ],
    );
  }

  Widget _summaryCard(BuildContext context, String title, int count,
      Color color, String groupKey) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(groupKey),
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1.5,
        child: SizedBox(
          width: 110,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
