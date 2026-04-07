import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../data/song_repository.dart';
import '../data/report_repository.dart';
import '../models/app_config.dart';
import '../radio/song_bank.dart';
import '../radio/report_bank.dart';
import '../radio/set_builder.dart';
import 'audio_handler_impl.dart';

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
  late AudioHandlerImpl _audioHandler;
  late AudioPlayer _player;
  late List<RadioQueueItem> _queue;
  late SongRepository _songs;
  late ReportRepository _reports;
  int _currentIndex = 0;
  late StreamSubscription _playerStateSubscription;
  late Function() _buildNextSet;

  RadioPlayerService();

  void _setupPlayerStateListener() {
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        next();
      }
      notifyListeners();
    });
  }

  Future<void> init(
    AudioHandlerImpl audioHandler,
    SongRepository songs,
    ReportRepository reports,
    SongBank songBank,
    ReportBank reportBank,
    AppConfig config,
  ) async {
    _audioHandler = audioHandler;
    _player = audioHandler.audioPlayer;
    _songs = songs;
    _reports = reports;
    _buildNextSet = () => SetBuilder.buildSet(songBank, reportBank, songs, reports, config);
    _currentIndex = 0;

    // Build initial queue from 3 sets
    _queue = [
      ..._buildNextSet(),
      ..._buildNextSet(),
      ..._buildNextSet(),
    ];

    _setupPlayerStateListener();

    // Wire up skip callbacks for the audio service
    _audioHandler.setSkipCallbacks(
      onSkipToNext: next,
      onSkipToPrevious: prev,
    );

    await _loadAndPlay(0, autoPlay: false);
  }

  List<RadioQueueItem> get queue => _queue;

  RadioQueueItem? get currentItem {
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      return _queue[_currentIndex];
    }
    return null;
  }

  bool get isPlaying => _player.playing;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  int get currentIndex => _currentIndex;

  String getTrackName(RadioQueueItem item) => _getTrackName(item);
  String getArtist(RadioQueueItem item) => _getArtist(item);

  Future<String> _resolveAssetPath(RadioQueueItem item) async {
    switch (item.clipType) {
      case RadioClipType.song:
        final song = _songs.getById(item.itemId);
        return song != null ? song.songFile : '';
      case RadioClipType.intro:
        final song = _songs.getById(item.itemId);
        if (song != null && song.intros.isNotEmpty) {
          // Find all valid intro files that exist
          final validPaths = <String>[];
          for (final file in song.intros) {
            if (await _assetExists(file)) {
              validPaths.add(file);
            }
          }
          if (validPaths.isNotEmpty) {
            return validPaths[Random().nextInt(validPaths.length)];
          }
        }
        return '';
      case RadioClipType.outro:
        final song = _songs.getById(item.itemId);
        if (song != null && song.outros.isNotEmpty) {
          // Find all valid outro files that exist
          final validPaths = <String>[];
          for (final file in song.outros) {
            if (await _assetExists(file)) {
              validPaths.add(file);
            }
          }
          if (validPaths.isNotEmpty) {
            return validPaths[Random().nextInt(validPaths.length)];
          }
        }
        return '';
      case RadioClipType.report:
        final report = _reports.getById(item.itemId);
        return report != null ? report.path : '';
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
    return 'Travis Miles';
  }

  Future<void> _loadAndPlay(int index, {bool autoPlay = true}) async {
    if (index < 0 || index >= _queue.length) {
      return;
    }

    _currentIndex = index;
    final item = _queue[index];
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
      final mediaItem = MediaItem(
        id: item.itemId,
        title: trackName,
        artist: artist,
      );
      await _player.setAudioSource(
        AudioSource.asset(
          assetPath,
          tag: mediaItem,
        ),
      );
      // Update audio service with the current media item
      await _audioHandler.updateMediaItem(mediaItem);
      if (autoPlay) {
        await _player.play();
      }
    } catch (e) {
      debugPrint('[RadioPlayerService] Error loading audio: $e');
      rethrow;
    }

    notifyListeners();
  }

  Future<void> play() async {
    await _audioHandler.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioHandler.pause();
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
    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _queue.length) {
      // Queue exhausted, clear and rebuild with 3 new sets
      _queue.clear();
      _queue.addAll(_buildNextSet());
      _queue.addAll(_buildNextSet());
      _queue.addAll(_buildNextSet());
      await _loadAndPlay(0);
    } else {
      await _loadAndPlay(nextIndex);
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

  /// Set the volume for main audio playback (0.0 to 1.0).
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    // Don't dispose the player or handler - they're managed by AudioService
    super.dispose();
  }
}
