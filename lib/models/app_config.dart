class AppConfig {
  final int songsPerSet;
  final int refillThreshold;
  final int refillCount;

  const AppConfig({
    required this.songsPerSet,
    required this.refillThreshold,
    required this.refillCount,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      songsPerSet: json['songs_per_set'] as int? ?? 3,
      refillThreshold: json['refill_threshold'] as int? ?? 5,
      refillCount: json['refill_count'] as int? ?? 10,
    );
  }
}
