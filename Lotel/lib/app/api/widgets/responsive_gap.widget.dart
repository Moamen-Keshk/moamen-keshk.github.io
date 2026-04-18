import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/res/responsive.res.dart';

class ResponsiveGap extends StatelessWidget {
  const ResponsiveGap({
    super.key,
    required this.gap,
  });

  final double gap;

  @override
  Widget build(BuildContext context) {
    return context.showCompactLayout
        ? SizedBox(height: gap)
        : SizedBox(width: gap);
  }
}
