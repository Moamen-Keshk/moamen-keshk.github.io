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
    return MediaQuery.of(context).size.width > ScreenSizes.md
        ? SizedBox(width: gap)
        : SizedBox(height: gap);
  }
}
