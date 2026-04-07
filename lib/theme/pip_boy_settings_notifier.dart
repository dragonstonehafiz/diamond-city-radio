import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pip_boy_constants.dart';

class PipBoySettingsNotifier extends ChangeNotifier {
  static const String _prefKeyAccent = 'accent_color';
  static const String _prefKeyScanlinesEnabled = 'scanlines_enabled';
  static const String _prefKeyScanlineWidth = 'scanline_width';
  static const String _prefKeyScanlineDistance = 'scanline_distance';
  static const String _prefKeyScanlineSpeed = 'scanline_speed';
  static const String _prefKeySfxVolume = 'sfx_volume';
  static const String _prefKeyHumEnabled = 'hum_enabled';
  static const String _prefKeyHumVolume = 'hum_volume';
  static const String _prefKeyMainVolume = 'main_volume';

  static const double minScanlineWidth = 1.0;
  static const double maxScanlineWidth = 10.0;
  static const double minScanlineDistance = 2.0;
  static const double maxScanlineDistance = 18.0;
  static const double minScanlineSpeed = 0.0;
  static const double maxScanlineSpeed = 80.0;

  final Color _defaultAccent;
  final bool _defaultScanlinesEnabled;
  final double _defaultScanlineWidth;
  final double _defaultScanlineDistance;
  final double _defaultScanlineSpeed;
  final double _defaultSfxVolume;
  final bool _defaultHumEnabled;
  final double _defaultHumVolume;
  final double _defaultMainVolume;

  Color _accent;
  bool _scanlinesEnabled;
  double _scanlineWidth;
  double _scanlineDistance;
  double _scanlineSpeed;
  double _sfxVolume;
  bool _humEnabled;
  double _humVolume;
  double _mainVolume;

  PipBoySettingsNotifier({
    Color defaultAccent = const Color(0xFF59FF47),
    bool defaultScanlinesEnabled = true,
    double defaultScanlineWidth = PipBoyConstants.scanlineThickness,
    double defaultScanlineDistance = PipBoyConstants.scanlineSpacing,
    double defaultScanlineSpeed = 24.0,
    double defaultSfxVolume = 0.8,
    bool defaultHumEnabled = true,
    double defaultHumVolume = 0.5,
    double defaultMainVolume = 1.0,
  })  : _defaultAccent = defaultAccent,
        _defaultScanlinesEnabled = defaultScanlinesEnabled,
        _defaultScanlineWidth =
            defaultScanlineWidth.clamp(minScanlineWidth, maxScanlineWidth),
        _defaultScanlineDistance =
            defaultScanlineDistance.clamp(minScanlineDistance, maxScanlineDistance),
        _defaultScanlineSpeed =
            defaultScanlineSpeed.clamp(minScanlineSpeed, maxScanlineSpeed),
        _defaultSfxVolume = defaultSfxVolume.clamp(0.0, 1.0),
        _defaultHumEnabled = defaultHumEnabled,
        _defaultHumVolume = defaultHumVolume.clamp(0.0, 1.0),
        _defaultMainVolume = defaultMainVolume.clamp(0.0, 1.0),
        _accent = defaultAccent,
        _scanlinesEnabled = defaultScanlinesEnabled,
        _scanlineWidth = defaultScanlineWidth.clamp(minScanlineWidth, maxScanlineWidth),
        _scanlineDistance =
            defaultScanlineDistance.clamp(minScanlineDistance, maxScanlineDistance),
        _scanlineSpeed = defaultScanlineSpeed.clamp(minScanlineSpeed, maxScanlineSpeed),
        _sfxVolume = defaultSfxVolume.clamp(0.0, 1.0),
        _humEnabled = defaultHumEnabled,
        _humVolume = defaultHumVolume.clamp(0.0, 1.0),
        _mainVolume = defaultMainVolume.clamp(0.0, 1.0);

  Color get accent => _accent;
  Color get dim => Color.lerp(Colors.black, _accent, 0.35)!;
  Color get muted => Color.lerp(Colors.black, _accent, 0.15)!;
  Color get glow => _accent.withValues(alpha: 0.25);

  bool get scanlinesEnabled => _scanlinesEnabled;
  double get scanlineWidth => _scanlineWidth;
  double get scanlineDistance => _scanlineDistance;
  double get scanlineSpeed => _scanlineSpeed;
  double get sfxVolume => _sfxVolume;
  bool get humEnabled => _humEnabled;
  double get humVolume => _humVolume;
  double get mainVolume => _mainVolume;

  // Preset palette - the 6 canonical Pip-Boy display colors
  static const List<Color> presets = [
    Color(0xFF59FF47), // Fallout green (default)
    Color(0xFF4FC3F7), // Blue (Pip-Boy 3000A)
    Color(0xFFFFB300), // Amber (classic terminal)
    Color(0xFFFF5252), // Red alert
    Color(0xFFE040FB), // Purple
    Color(0xFFFFFFFF), // White
  ];

  /// Load all settings from SharedPreferences on startup.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt(_prefKeyAccent);
      if (colorValue != null) {
        _accent = Color(colorValue);
      } else {
        _accent = _defaultAccent;
      }
      _scanlinesEnabled =
          prefs.getBool(_prefKeyScanlinesEnabled) ?? _defaultScanlinesEnabled;
      _scanlineWidth = (prefs.getDouble(_prefKeyScanlineWidth) ??
              _defaultScanlineWidth)
          .clamp(minScanlineWidth, maxScanlineWidth);
      _scanlineDistance = (prefs.getDouble(_prefKeyScanlineDistance) ??
              _defaultScanlineDistance)
          .clamp(minScanlineDistance, maxScanlineDistance);
      _scanlineSpeed = (prefs.getDouble(_prefKeyScanlineSpeed) ??
              _defaultScanlineSpeed)
          .clamp(minScanlineSpeed, maxScanlineSpeed);
      _sfxVolume = prefs.getDouble(_prefKeySfxVolume) ?? _defaultSfxVolume;
      _humEnabled = prefs.getBool(_prefKeyHumEnabled) ?? _defaultHumEnabled;
      _humVolume = prefs.getDouble(_prefKeyHumVolume) ?? _defaultHumVolume;
      _mainVolume = prefs.getDouble(_prefKeyMainVolume) ?? _defaultMainVolume;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// Set accent color and persist to SharedPreferences.
  Future<void> setAccent(Color color) async {
    _accent = color;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKeyAccent, color.toARGB32());
    } catch (e) {
      debugPrint('Error saving accent color: $e');
    }
  }

  /// Set scanlines enabled and persist to SharedPreferences.
  Future<void> setScanlinesEnabled(bool enabled) async {
    _scanlinesEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyScanlinesEnabled, enabled);
    } catch (e) {
      debugPrint('Error saving scanlines setting: $e');
    }
  }

  /// Set scanline line width and persist to SharedPreferences.
  Future<void> setScanlineWidth(double width) async {
    _scanlineWidth = width.clamp(minScanlineWidth, maxScanlineWidth);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefKeyScanlineWidth, _scanlineWidth);
    } catch (e) {
      debugPrint('Error saving scanline width: $e');
    }
  }

  /// Set scanline spacing and persist to SharedPreferences.
  Future<void> setScanlineDistance(double distance) async {
    _scanlineDistance = distance.clamp(minScanlineDistance, maxScanlineDistance);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefKeyScanlineDistance, _scanlineDistance);
    } catch (e) {
      debugPrint('Error saving scanline distance: $e');
    }
  }

  /// Set scanline movement speed and persist to SharedPreferences.
  Future<void> setScanlineSpeed(double speed) async {
    _scanlineSpeed = speed.clamp(minScanlineSpeed, maxScanlineSpeed);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefKeyScanlineSpeed, _scanlineSpeed);
    } catch (e) {
      debugPrint('Error saving scanline speed: $e');
    }
  }

  /// Set SFX volume and persist to SharedPreferences.
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefKeySfxVolume, _sfxVolume);
    } catch (e) {
      debugPrint('Error saving SFX volume: $e');
    }
  }

  /// Set hum enabled and persist to SharedPreferences.
  Future<void> setHumEnabled(bool enabled) async {
    _humEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyHumEnabled, enabled);
    } catch (e) {
      debugPrint('Error saving hum setting: $e');
    }
  }

  /// Set hum volume and persist to SharedPreferences.
  Future<void> setHumVolume(double volume) async {
    _humVolume = volume.clamp(0.0, 1.0);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefKeyHumVolume, _humVolume);
    } catch (e) {
      debugPrint('Error saving hum volume: $e');
    }
  }

  /// Set main audio volume and persist to SharedPreferences.
  Future<void> setMainVolume(double volume) async {
    _mainVolume = volume.clamp(0.0, 1.0);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefKeyMainVolume, _mainVolume);
    } catch (e) {
      debugPrint('Error saving main volume: $e');
    }
  }
}
