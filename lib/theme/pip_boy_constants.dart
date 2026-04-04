import 'package:flutter/material.dart';

class PipBoyConstants {
  // Spacing tokens
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border widths
  static const double borderWidthThin = 1.0;
  static const double borderWidthNormal = 2.0;
  static const double borderWidthThick = 3.0;

  // Bar heights
  static const double tabBarHeight = 48.0;
  static const double subTabBarHeight = 36.0;
  static const double statusBarHeight = 28.0;

  // Scanlines
  static const double scanlineSpacing = 7.0; // px between dark bands
  static const double scanlineThickness = 5.0;

  // Button
  static const double buttonHeight = 44.0;
  static const double buttonMinWidth = 80.0;
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  // Progress bar
  static const double progressBarHeight = 12.0;

  // Animation durations
  static const Duration tapFeedbackDuration = Duration(milliseconds: 80);
  static const Duration tabSwitchDuration = Duration(milliseconds: 120);
  static const Duration glowPulseDuration = Duration(milliseconds: 1500);
}
