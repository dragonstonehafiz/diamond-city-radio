import '../models/song_model.dart';

class SongRepository {
  final Map<String, SongModel> _songsById;
  final List<SongModel> _allSongs;

  SongRepository(List<SongModel> songs)
      : _songsById = {for (final song in songs) song.id: song},
        _allSongs = songs;

  SongModel? getById(String id) => _songsById[id];
  List<SongModel> getAllSongs() => _allSongs;
}
