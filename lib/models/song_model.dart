class SongModel {
  final String id;
  final String name;
  final String artist;
  final String songFile;
  final List<String> intros;
  final List<String> outros;

  const SongModel({
    required this.id,
    required this.name,
    required this.artist,
    required this.songFile,
    required this.intros,
    required this.outros,
  });

  bool get hasIntros => intros.isNotEmpty;
  bool get hasOutros => outros.isNotEmpty;

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      songFile: json['song'] as String? ?? '',
      intros: List<String>.from((json['intros'] as List<dynamic>?) ?? []),
      outros: List<String>.from((json['outros'] as List<dynamic>?) ?? []),
    );
  }
}
