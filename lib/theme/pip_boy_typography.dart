import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pip_boy_colors.dart';

class PipBoyTypography {
  static TextStyle heading(Color accent) => GoogleFonts.vt323(
        fontSize: 28,
        color: accent,
        letterSpacing: 2.0,
        height: 1.1,
        fontWeight: FontWeight.w400,
      );

  static TextStyle subheading(Color accent) => GoogleFonts.vt323(
        fontSize: 20,
        color: accent,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w400,
      );

  static TextStyle body(Color accent) => GoogleFonts.vt323(
        fontSize: 16,
        color: accent,
        letterSpacing: 1.0,
        fontWeight: FontWeight.w400,
      );

  static TextStyle caption(Color accent) => GoogleFonts.vt323(
        fontSize: 13,
        color: PipBoyColors.dimmed(accent, factor: 0.6),
        letterSpacing: 0.8,
        fontWeight: FontWeight.w400,
      );

  static TextStyle tabLabel(Color accent) => GoogleFonts.vt323(
        fontSize: 18,
        color: accent,
        letterSpacing: 3.0,
        fontWeight: FontWeight.w400,
      );

  static TextStyle statusBar(Color accent) => GoogleFonts.vt323(
        fontSize: 13,
        color: PipBoyColors.dimmed(accent, factor: 0.5),
        letterSpacing: 1.5,
        fontWeight: FontWeight.w400,
      );
}
