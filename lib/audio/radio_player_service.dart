import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../data/asset_paths.dart';
import '../data/song_repository.dart';
import '../data/report_repository.dart';

enum RadioClipType { intro, song, outro, report }

extension RadioClipTypeLabel on RadioClipType {
  String get label {
    switch (this) {
      case RadioClipType.intro:
        return 'INTRO';
      case RadioClipType.song:
        return 'SONG';
      case RadioClipType.outro:
        return 'OUTRO';
      case RadioClipType.report:
        return 'REPORT';
    }
  }
}

class RadioQueueItem {
  final String itemId;
  final RadioClipType clipType;

  const RadioQueueItem({
    required this.itemId,
    required this.clipType,
  });
}

class RadioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  late List<List<RadioQueueItem>> _sets;
  late SongRepository _songs;
  late ReportRepository _reports;
  int _currentIndex = 0;
  late StreamSubscription _playerStateSubscription;
  late Function() _buildNextSet;

  RadioPlayerService() {
    _setupPlayerStateListener();
  }

  void _setupPlayerStateListener() {
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        next();
      }
      notifyListeners();
    });
  }

  Future<void> init(
    List<List<RadioQueueItem>> sets,
    SongRepository songs,
    ReportRepository reports,
    Function() buildNextSet,
  ) async {
    _sets = sets;
    _songs = songs;
    _reports = reports;
    _buildNextSet = buildNextSet;
    _currentIndex = 0;
    await _loadAndPlay(0, autoPlay: false);
  }

  List<List<RadioQueueItem>> get sets => _sets;
  List<RadioQueueItem> get _currentQueue => _sets[0];

  RadioQueueItem? get currentItem {
    if (_currentIndex >= 0 && _currentIndex < _currentQueue.length) {
      return _currentQueue[_currentIndex];
    }
    return null;
  }

  bool get isPlaying => _player.playing;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  int get currentIndex => _currentIndex;
  int get queueLength => _currentQueue.length;

  String getTrackName(RadioQueueItem item) => _getTrackName(item);
  String getArtist(RadioQueueItem item) => _getArtist(item);

  Future<String> _resolveAssetPath(RadioQueueItem item) async {
    switch (item.clipType) {
      case RadioClipType.song:
        final song = _songs.getById(item.itemId);
        return song != null ? '${AppAudioPaths.songsBase}${song.songFile}' : '';
      case RadioClipType.intro:
        final song = _songs.getById(item.itemId);
        if (song != null && song.intros.isNotEmpty) {
          // Try to find a valid intro file that exists
          for (final file in song.intros) {
            final path = '${AppAudioPaths.introsBase}$file';
            if (await _assetExists(path)) {
              return path;
            }
          }
        }
        return '';
      case RadioClipType.outro:
        final song = _songs.getById(item.itemId);
        if (song != null && song.outros.isNotEmpty) {
          // Try to find a valid outro file that exists
          for (final file in song.outros) {
            final path = '${AppAudioPaths.outrosBase}$file';
            if (await _assetExists(path)) {
              return path;
            }
          }
        }
        return '';
      case RadioClipType.report:
        final report = _reports.getById(item.itemId);
        return report != null ? '${AppAudioPaths.reportsBase}${report.path}' : '';
    }
  }

  Future<bool> _assetExists(String assetPath) async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      return manifest.listAssets().contains(assetPath);
    } catch (e) {
      return false;
    }
  }

  String _getTrackName(RadioQueueItem item) {
    switch (item.clipType) {
      case RadioClipType.song:
        return _songs.getById(item.itemId)?.name ?? '?';
      case RadioClipType.intro:
        return 'INTRO';
      case RadioClipType.outro:
        return 'OUTRO';
      case RadioClipType.report:
        return _reports.getById(item.itemId)?.title ?? '?';
    }
  }

  String _getArtist(RadioQueueItem item) {
    if (item.clipType == RadioClipType.song) {
      return _songs.getById(item.itemId)?.artist ?? '?';
    }
    return 'Diamond City Radio';
  }

  Future<void> _loadAndPlay(int index, {bool autoPlay = true}) async {
    if (index < 0 || index >= _currentQueue.length) {
      return;
    }

    _currentIndex = index;
    final item = _currentQueue[index];
    final assetPath = await _resolveAssetPath(item);

    if (assetPath.isEmpty) {
      if (kDebugMode) {
        print('[RadioPlayerService] Could not resolve path for item: ${item.itemId}, skipping');
      }
      // Skip to next track if intro/outro can't be found
      if (item.clipType == RadioClipType.intro || item.clipType == RadioClipType.outro) {
        await next();
      }
      return;
    }

    try {
      final trackName = _getTrackName(item);
      final artist = _getArtist(item);
      await _player.setAudioSource(
        AudioSource.asset(
          assetPath,
          tag: MediaItem(
            id: item.itemId,
            title: trackName,
            artist: artist,
          ),
        ),
      );
      if (autoPlay) {
        await _player.play();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RadioPlayerService] Error loading audio: $e');
      }
    }

    notifyListeners();
  }

  Future<void> play() async {
    await _player.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    if (_currentIndex + 1 < _currentQueue.length) {
      await _loadAndPlay(_currentIndex + 1);
    } else {
      _sets[0] = _sets[1];
      _sets[1] = _sets[2];
      _sets[2] = _buildNextSet();
      _currentIndex = 0;
      await _loadAndPlay(0);
    }
  }

  Future<void> prev() async {
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
    } else if (_currentIndex > 0) {
      await _loadAndPlay(_currentIndex - 1);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _player.dispose();
    super.dispose();
  }
}
