// lib/core/utils/responsive.dart
import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  // Get responsive value based on device
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  // Get responsive padding
  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.all(
      responsive(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
      ),
    );
  }

  // Get responsive font size
  static double fontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.5,
    );
  }

  // Get responsive icon size
  static double iconSize(BuildContext context) {
    return responsive(
      context,
      mobile: 24.0,
      tablet: 32.0,
      desktop: 40.0,
    );
  }

  // Get responsive ghost size
  static double ghostSize(BuildContext context) {
    return responsive(
      context,
      mobile: 140.0,
      tablet: 200.0,
      desktop: 280.0,
    );
  }

  // Get bottom nav height (your tablet issue)
  static double navHeight(BuildContext context) {
    return responsive(
      context,
      mobile: 70.0,
      tablet: 90.0, // Fixed for tablet
      desktop: 100.0,
    );
  }

  // Get gesture detection sensitivity
  static double gestureThreshold(BuildContext context) {
    return responsive(
      context,
      mobile: 50.0,
      tablet: 80.0, // Larger for tablet
      desktop: 100.0,
    );
  }
}

// Extension for easy access
extension ResponsiveContext on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  
  double responsiveValue({
    required double mobile,
    double? tablet,
    double? desktop,
  }) =>
      Responsive.responsive(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}