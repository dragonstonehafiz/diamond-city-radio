import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';
import '../models/app_config.dart';
import '../data/song_repository.dart';

class SongBank {
  static const String _bankKey = 'song_bank_ids';
  static const String _playedKey = 'song_played_ids';

  List<SongModel> _unplayedSongs = [];
  List<SongModel> _playedSongs = [];
  late AppConfig _config;
  late SongRepository _songs;
  late SharedPreferences _prefs;

  Future<void> init(SongRepository songs, AppConfig config) async {
    _songs = songs;
    _config = config;
    _prefs = await SharedPreferences.getInstance();

    // Try to restore from SharedPreferences
    final savedBankIds = _prefs.getStringList(_bankKey);
    final savedPlayedIds = _prefs.getStringList(_playedKey);

    if (savedBankIds != null && savedBankIds.isNotEmpty) {
      // Restore from saved state
      _unplayedSongs = _loadFromState(savedBankIds);
      _playedSongs = _loadFromState(savedPlayedIds ?? []);
    } else {
      // First launch: initialize fresh
      _unplayedSongs = List.from(_songs.getAllSongs())..shuffle(Random());
      _playedSongs = [];
      await _saveToState();
    }
  }

    List<SongModel> draw(int drawCount) {
    assert(_unplayedSongs.isNotEmpty, 'SongBank.draw() called with empty bank');
    _unplayedSongs.shuffle(Random());
    List<SongModel> drawn = [];

    while (drawn.length < drawCount) {
      if (_unplayedSongs.isEmpty) break;
      final song = _unplayedSongs.removeAt(0);
      _playedSongs.add(song);
      drawn.add(song);
    }
    _refill();
    _saveToState(); // fire-and-forget
    return drawn;
  }

  List<SongModel> drawWithIntro(int drawCount) {
    assert(_unplayedSongs.isNotEmpty, 'SongBank.drawWithIntro() called with empty bank');
    _unplayedSongs.shuffle(Random());
    List<SongModel> drawn = [];

    int i = 0;
    while (drawn.length < drawCount && i < _unplayedSongs.length) {
      if (_unplayedSongs.isEmpty) break;
      SongModel song = _unplayedSongs[i];

      if (!song.hasIntros) ++i;
      else {
        drawn.add(song);
        _unplayedSongs.removeAt(i);
        _playedSongs.add(song);
      }
    }
    _refill();
    _saveToState(); // fire-and-forget
    return drawn;
  }

  List<SongModel> drawWithOutro(int drawCount) {
    assert(_unplayedSongs.isNotEmpty, 'SongBank.drawWithIntro() called with empty bank');
    _unplayedSongs.shuffle(Random());
    List<SongModel> drawn = [];

    int i = 0;
    while (drawn.length < drawCount && i < _unplayedSongs.length) {
      if (_unplayedSongs.isEmpty) break;
      SongModel song = _unplayedSongs[i];

      if (!song.hasOutros) ++i;
      else {
        drawn.add(song);
        _unplayedSongs.removeAt(i);
        _playedSongs.add(song);
      }

    }

    _refill();
    _saveToState(); // fire-and-forget
    return drawn;
  }

  void _refill() {
    if (_unplayedSongs.length > _config.refillThreshold) return;
    if (_playedSongs.isEmpty) return;

    final count = min(_config.refillCount, _playedSongs.length);
    final toMove = _playedSongs.sublist(0, count);
    _playedSongs = _playedSongs.sublist(count);
    _unplayedSongs.addAll(toMove);
    _unplayedSongs.shuffle(Random());
  }

  Future<void> _saveToState() async {
    try {
      final bankIds = _unplayedSongs.map((s) => s.id).toList();
      final playedIds = _playedSongs.map((s) => s.id).toList();
      await _prefs.setStringList(_bankKey, bankIds);
      await _prefs.setStringList(_playedKey, playedIds);
    } catch (e) {
      print('[SongBank] Error persisting state: $e');
    }
  }

  List<SongModel> _loadFromState(List<String> ids) {
    final result = <SongModel>[];
    for (final id in ids) {
      final song = _songs.getById(id);
      if (song != null) {
        result.add(song);
      }
    }
    return result;
  }

  int get bankLength => _unplayedSongs.length;
}
