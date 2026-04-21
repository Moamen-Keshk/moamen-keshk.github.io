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
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 16) / 3;

        return Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                'Arrivals',
                arrivals,
                Colors.green,
                'Arrivals',
                width: cardWidth,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _summaryCard(
                context,
                'In House',
                inHouse,
                Colors.blue,
                'InHouse',
                width: cardWidth,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _summaryCard(
                context,
                'Departures',
                departures,
                Colors.red,
                'Departures',
                width: cardWidth,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard(BuildContext context, String title, int count,
      Color color, String groupKey,
      {required double width}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(groupKey),
      child: Card(
        margin: EdgeInsets.zero,
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1.5,
        child: SizedBox(
          width: width,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
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
