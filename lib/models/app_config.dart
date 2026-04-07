import 'package:flutter/material.dart';

class AppConfig {
  final int songsPerSet;
  final int refillThreshold;
  final int refillCount;
  final String songIconPath;
  final String introIconPath;
  final String outroIconPath;
  final Color defaultAccentColor;
  final bool defaultScanlinesEnabled;
  final double defaultScanlineWidth;
  final double defaultScanlineDistance;
  final double scanlineSpeed;
  final bool defaultHumEnabled;
  final double defaultSfxVolume;
  final double defaultHumVolume;
  final double defaultMainVolume;

  const AppConfig({
    required this.songsPerSet,
    required this.refillThreshold,
    required this.refillCount,
    required this.songIconPath,
    required this.introIconPath,
    required this.outroIconPath,
    required this.defaultAccentColor,
    required this.defaultScanlinesEnabled,
    required this.defaultScanlineWidth,
    required this.defaultScanlineDistance,
    required this.scanlineSpeed,
    required this.defaultHumEnabled,
    required this.defaultSfxVolume,
    required this.defaultHumVolume,
    required this.defaultMainVolume,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    const fallbackAccent = Color(0xFF59FF47);

    return AppConfig(
      songsPerSet: json['songs_per_set'] as int? ?? 3,
      refillThreshold: json['refill_threshold'] as int? ?? 5,
      refillCount: json['refill_count'] as int? ?? 10,
      songIconPath:
          json['song_icon_path'] as String? ?? 'assets/images/icons/song_icon.png',
      introIconPath:
          json['intro_icon_path'] as String? ?? 'assets/images/icons/dcr_icon.png',
      outroIconPath:
          json['outro_icon_path'] as String? ?? 'assets/images/icons/dcr_icon.png',
      defaultAccentColor: _parseColor(
        json['accent_color'],
        fallbackAccent,
      ),
      defaultScanlinesEnabled: json['scanlines_enabled'] as bool? ?? true,
      defaultScanlineWidth: (json['scanline_width'] as num?)?.toDouble() ?? 5.0,
      defaultScanlineDistance:
          (json['scanline_distance'] as num?)?.toDouble() ?? 7.0,
      scanlineSpeed: (json['scanline_speed'] as num?)?.toDouble() ?? 24.0,
      defaultHumEnabled: json['hum_enabled'] as bool? ?? true,
      defaultSfxVolume: (json['sfx_volume'] as num?)?.toDouble() ?? 0.8,
      defaultHumVolume: (json['hum_volume'] as num?)?.toDouble() ?? 0.5,
      defaultMainVolume: (json['main_volume'] as num?)?.toDouble() ?? 1.0,
    );
  }

  static Color _parseColor(dynamic rawValue, Color fallback) {
    if (rawValue is int) {
      return Color(rawValue);
    }
    if (rawValue is String) {
      final value = rawValue.trim();
      if (value.startsWith('0x') || value.startsWith('0X')) {
        final parsed = int.tryParse(value.substring(2), radix: 16);
        if (parsed != null) return Color(parsed);
      }
      if (value.startsWith('#')) {
        final hex = value.substring(1);
        if (hex.length == 6) {
          final parsed = int.tryParse('FF$hex', radix: 16);
          if (parsed != null) return Color(parsed);
        } else if (hex.length == 8) {
          final parsed = int.tryParse(hex, radix: 16);
          if (parsed != null) return Color(parsed);
        }
      }
    }
    return fallback;
  }
}
