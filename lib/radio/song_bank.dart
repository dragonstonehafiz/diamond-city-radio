import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';
import '../models/app_config.dart';
import '../data/song_repository.dart';

class SongBank {
  static const String _bankKey = 'song_bank_ids';
  static const String _playedKey = 'song_played_ids';

  List<SongModel> _songBank = [];
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
      _songBank = _restoreFromIds(savedBankIds);
      _playedSongs = _restoreFromIds(savedPlayedIds ?? []);
    } else {
      // First launch: initialize fresh
      _songBank = List.from(_songs.getAllSongs())..shuffle(Random());
      _playedSongs = [];
      await _persist();
    }
  }

  SongModel draw() {
    assert(_songBank.isNotEmpty, 'SongBank.draw() called with empty bank');
    final song = _songBank.removeAt(0);
    _playedSongs.add(song);
    _checkRefill();
    _persist(); // fire-and-forget
    return song;
  }

  void _checkRefill() {
    if (_songBank.length < _config.refillThreshold) {
      _refill();
    }
  }

  void _refill() {
    if (_playedSongs.isEmpty) return;

    final count = min(_config.refillCount, _playedSongs.length);
    final toMove = _playedSongs.sublist(0, count);
    _playedSongs = _playedSongs.sublist(count);
    _songBank.addAll(toMove);
    _songBank.shuffle(Random());
  }

  Future<void> _persist() async {
    try {
      final bankIds = _songBank.map((s) => s.id).toList();
      final playedIds = _playedSongs.map((s) => s.id).toList();
      await _prefs.setStringList(_bankKey, bankIds);
      await _prefs.setStringList(_playedKey, playedIds);
    } catch (e) {
      print('[SongBank] Error persisting state: $e');
    }
  }

  List<SongModel> _restoreFromIds(List<String> ids) {
    final result = <SongModel>[];
    for (final id in ids) {
      final song = _songs.getById(id);
      if (song != null) {
        result.add(song);
      }
    }
    return result;
  }

  int get bankLength => _songBank.length;
}
