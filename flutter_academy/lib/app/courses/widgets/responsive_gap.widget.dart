import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/res/responsive.res.dart';

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
