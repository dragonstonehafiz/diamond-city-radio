import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pip_boy_colors.dart';

class PipBoyAccentNotifier extends ChangeNotifier {
  static const String _prefKey = 'accent_color';

  Color _accent = PipBoyColors.defaultAccent;

  Color get accent => _accent;

  // Derived colors — recomputed when accent changes
  Color get dim => PipBoyColors.dimmed(_accent, factor: 0.35);
  Color get muted => PipBoyColors.dimmed(_accent, factor: 0.15);
  Color get glow => _accent.withValues(alpha: 0.25);

  // Preset palette — the 6 canonical Pip-Boy display colors
  static const List<Color> presets = [
    Color(0xFF59FF47), // Fallout green (default)
    Color(0xFF4FC3F7), // Blue (Pip-Boy 3000A)
    Color(0xFFFFB300), // Amber (classic terminal)
    Color(0xFFFF5252), // Red alert
    Color(0xFFE040FB), // Purple
    Color(0xFFFFFFFF), // White
  ];

  /// Load the saved accent color from SharedPreferences on startup.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt(_prefKey);
      if (colorValue != null) {
        _accent = Color(colorValue);
        notifyListeners();
      }
    } catch (e) {
      // If SharedPreferences fails, stick with default
      debugPrint('Error loading accent color: $e');
    }
  }

  /// Set a new accent color and persist it to SharedPreferences.
  Future<void> setAccent(Color color) async {
    _accent = color;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKey, color.toARGB32());
    } catch (e) {
      debugPrint('Error saving accent color: $e');
    }
  }
}
