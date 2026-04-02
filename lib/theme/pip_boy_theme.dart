import 'package:flutter/material.dart';
import 'pip_boy_colors.dart';
import 'pip_boy_typography.dart';

ThemeData buildPipBoyTheme(Color accent) {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: PipBoyColors.background,
    colorScheme: ColorScheme.dark(
      primary: accent,
      secondary: accent,
      surface: PipBoyColors.backgroundAlt,
      onPrimary: PipBoyColors.background,
      onSurface: accent,
    ),
    textTheme: TextTheme(
      displayLarge: PipBoyTypography.heading(accent),
      titleMedium: PipBoyTypography.subheading(accent),
      bodyMedium: PipBoyTypography.body(accent),
      bodySmall: PipBoyTypography.caption(accent),
      labelSmall: PipBoyTypography.statusBar(accent),
    ),
    // Suppress all Material ink splashes — Pip-Boy has no ripple
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    dividerColor: PipBoyColors.dimmed(accent, factor: 0.35),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
