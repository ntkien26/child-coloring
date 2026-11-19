import 'package:flutter/material.dart';

class ScreenUtils {
  ScreenUtils._();

  static const double tabletBreakpoint = 600.0;
  static const double largeTabletBreakpoint = 960.0;

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletBreakpoint;
  }

  static bool isLargeTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= largeTabletBreakpoint;
  }

  static bool isPhone(BuildContext context) {
    return MediaQuery.sizeOf(context).width < tabletBreakpoint;
  }

  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height;
  }

  /// HomeScreen grid columns:
  /// - Phone (< 600dp): 2 columns
  /// - Tablet (600..959dp): 3 columns
  /// - Large Tablet (>= 960dp): 4 columns
  static int homeGridColumns(double width) {
    if (width >= largeTabletBreakpoint) return 4;
    if (width >= tabletBreakpoint) return 3;
    return 2;
  }

  static double horizontalPadding(double width) {
    if (width >= largeTabletBreakpoint) return 28;
    if (width >= tabletBreakpoint) return 20;
    return 14;
  }
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.phone,
    required this.tablet,
  });

  final WidgetBuilder phone;
  final WidgetBuilder tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ScreenUtils.tabletBreakpoint) {
          return tablet(context);
        }
        return phone(context);
      },
    );
  }
}
