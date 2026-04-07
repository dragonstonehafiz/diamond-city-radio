class AppConfig {
  final int songsPerSet;
  final int refillThreshold;
  final int refillCount;
  final String songIconPath;
  final String introIconPath;
  final String outroIconPath;
  final double scanlineSpeed;

  const AppConfig({
    required this.songsPerSet,
    required this.refillThreshold,
    required this.refillCount,
    required this.songIconPath,
    required this.introIconPath,
    required this.outroIconPath,
    required this.scanlineSpeed,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
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
      scanlineSpeed: (json['scanline_speed'] as num?)?.toDouble() ?? 24.0,
    );
  }
}
