import 'package:flutter/material.dart';

Axis getAxis(double width) {
  return width > ScreenSizes.md ? Axis.horizontal : Axis.vertical;
}

class ScreenSizes {
  static const double xs = 480.0;
  static const double sm = 640.0;
  static const double md = 768.0;
  static const double lg = 1024.0;
  static const double xl = 1280.0;
  static const double xxl = 1536.0;
}

enum ResponsiveWindowSize { compact, medium, expanded }

ResponsiveWindowSize getWindowSize(double width) {
  if (width < ScreenSizes.sm) {
    return ResponsiveWindowSize.compact;
  }
  if (width < ScreenSizes.lg) {
    return ResponsiveWindowSize.medium;
  }
  return ResponsiveWindowSize.expanded;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isCompact =>
      getWindowSize(screenWidth) == ResponsiveWindowSize.compact;

  bool get isMedium =>
      getWindowSize(screenWidth) == ResponsiveWindowSize.medium;

  bool get isExpanded =>
      getWindowSize(screenWidth) == ResponsiveWindowSize.expanded;

  bool get showCompactLayout => screenWidth < ScreenSizes.md;

  double get responsiveHorizontalPadding {
    final width = screenWidth;
    if (width < ScreenSizes.sm) {
      return 16;
    }
    if (width < ScreenSizes.lg) {
      return 24;
    }
    return 32;
  }

  double get responsiveVerticalPadding => showCompactLayout ? 16 : 24;

  double get responsiveContentMaxWidth {
    final width = screenWidth;
    if (width < ScreenSizes.md) {
      return width;
    }
    if (width < ScreenSizes.xl) {
      return 960;
    }
    return 1200;
  }
}
