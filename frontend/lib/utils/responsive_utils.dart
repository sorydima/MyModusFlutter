import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileBreakpoint &&
           MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getResponsiveValue({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static int getGridCrossAxisCount(BuildContext context, {int maxColumns = 4}) {
    if (isDesktop(context)) {
      return maxColumns.clamp(3, 4);
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = getScreenWidth(context);
    final scaleFactor = screenWidth / 375.0; // iPhone 6/7/8 width as baseline
    return baseSize * scaleFactor.clamp(0.8, 1.5);
  }

  static EdgeInsets getResponsivePadding(BuildContext context, {
    double mobileHorizontal = 16.0,
    double mobileVertical = 8.0,
    double? tabletHorizontal,
    double? tabletVertical,
    double? desktopHorizontal,
    double? desktopVertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: getResponsiveValue(
        context: context,
        mobile: mobileHorizontal,
        tablet: tabletHorizontal,
        desktop: desktopHorizontal,
      ),
      vertical: getResponsiveValue(
        context: context,
        mobile: mobileVertical,
        tablet: tabletVertical,
        desktop: desktopVertical,
      ),
    );
  }

  static double getResponsiveHeight(BuildContext context, double percentage) {
    return getScreenHeight(context) * percentage;
  }

  static double getResponsiveWidth(BuildContext context, double percentage) {
    return getScreenWidth(context) * percentage;
  }

  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    return getResponsiveValue(
      context: context,
      mobile: baseSpacing,
      tablet: baseSpacing * 1.2,
      desktop: baseSpacing * 1.5,
    );
  }

  static double getChildAspectRatio(BuildContext context, {
    double mobile = 0.75,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.1,
      desktop: desktop ?? mobile * 1.2,
    );
  }

  static int getResponsiveItemCount(BuildContext context, int totalItems) {
    if (isDesktop(context)) {
      return totalItems.clamp(6, 12);
    } else if (isTablet(context)) {
      return totalItems.clamp(4, 8);
    } else {
      return totalItems.clamp(2, 6);
    }
  }

  static BoxConstraints getResponsiveConstraints(BuildContext context, {
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);

    return BoxConstraints(
      minWidth: minWidth ?? 0,
      maxWidth: maxWidth ?? screenWidth * 0.9,
      minHeight: minHeight ?? 0,
      maxHeight: maxHeight ?? screenHeight * 0.8,
    );
  }

  static BorderRadius getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    return BorderRadius.circular(
      getResponsiveValue(
        context: context,
        mobile: baseRadius,
        tablet: baseRadius * 1.2,
        desktop: baseRadius * 1.5,
      ),
    );
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    return getResponsiveValue(
      context: context,
      mobile: baseSize,
      tablet: baseSize * 1.1,
      desktop: baseSize * 1.2,
    );
  }

  static double getResponsiveElevation(BuildContext context, double baseElevation) {
    return getResponsiveValue(
      context: context,
      mobile: baseElevation,
      tablet: baseElevation * 1.2,
      desktop: baseElevation * 1.5,
    );
  }
}
