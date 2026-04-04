class AppConfig {
  final int songsPerSet;
  final int refillThreshold;
  final int refillCount;
  final String appIconPath;

  const AppConfig({
    required this.songsPerSet,
    required this.refillThreshold,
    required this.refillCount,
    required this.appIconPath,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      songsPerSet: json['songs_per_set'] as int? ?? 3,
      refillThreshold: json['refill_threshold'] as int? ?? 5,
      refillCount: json['refill_count'] as int? ?? 10,
      appIconPath: json['app_icon_path'] as String? ?? 'images/icons/dcr_icon.png',
    );
  }
}
