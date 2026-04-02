import 'package:flutter/material.dart';

class PipBoyColors {
  // Main colors
  static const Color background = Color(0xFF0A0F0A); // near-black with green tint
  static const Color backgroundAlt = Color(0xFF111811); // slightly lighter for panels
  static const Color defaultAccent = Color(0xFF59FF47); // CRT phosphor green

  // Static fallback accent variants
  static const Color accentDim = Color(0xFF2A7A22); // ~30% brightness of accent
  static const Color accentMuted = Color(0xFF1A4A14); // ~15% brightness, for disabled
  static const Color accentGlow = Color(0x4059FF47); // 25% opacity, for glow effects

  // Derived colors
  static const Color textPrimary = defaultAccent;
  static const Color textDisabled = accentMuted;
  static const Color borderColor = accentDim;
  static const Color scanlineColor = Color(0x18000000); // near-transparent black bands

  /// Derives a dimmed/muted version of the accent color via lerp to black.
  /// factor: 0.0 = pure black, 1.0 = pure accent, 0.35 = typical dimmed shade
  static Color dimmed(Color accent, {double factor = 0.35}) {
    return Color.lerp(Colors.black, accent, factor)!;
  }
}
