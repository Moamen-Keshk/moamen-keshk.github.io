import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';
import 'package:lotel_pms/app/api/widgets/hotel_calendar.widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final showFooter = !context.showCompactLayout;

    return Column(
      children: [
        const Expanded(
          child: FloorRooms(),
        ),
        if (showFooter) const _DashboardFooter(),
      ],
    );
  }
}

class _DashboardFooter extends StatelessWidget {
  const _DashboardFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 24,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Text(
        'Lotel PMS',
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade600,
          fontSize: 11,
          height: 1,
        ),
      ),
    );
  }
}
