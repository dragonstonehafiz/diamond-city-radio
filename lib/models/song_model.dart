class SongModel {
  final String id;
  final String name;
  final String artist;
  final String songFile;
  final List<String> intros;
  final List<String> outros;
  final bool excludeFromMiddle;
  final bool excludeFromIntro;
  final bool excludeFromOutro;

  const SongModel({
    required this.id,
    required this.name,
    required this.artist,
    required this.songFile,
    required this.intros,
    required this.outros,
    required this.excludeFromMiddle,
    required this.excludeFromIntro,
    required this.excludeFromOutro,
  });

  bool get hasIntros => intros.isNotEmpty;
  bool get hasOutros => outros.isNotEmpty;
  bool get isAllowedInMiddle => !excludeFromMiddle;
  bool get isAllowedForIntro => !excludeFromIntro && hasIntros;
  bool get isAllowedForOutro => !excludeFromOutro && hasOutros;

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      songFile: json['song'] as String? ?? '',
      intros: List<String>.from((json['intros'] as List<dynamic>?) ?? []),
      outros: List<String>.from((json['outros'] as List<dynamic>?) ?? []),
      excludeFromMiddle: json['exclude_from_middle'] as bool? ?? false,
      excludeFromIntro: json['exclude_from_intro'] as bool? ?? false,
      excludeFromOutro: json['exclude_from_outro'] as bool? ?? false,
    );
  }
}
