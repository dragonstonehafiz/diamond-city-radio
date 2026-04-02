import 'package:audioplayers/audioplayers.dart';
import 'asset_paths.dart';

enum PipBoySfx {
  hum,
  mapRollover,
  rotaryHorizontal,
  rotaryVertical,
}

class SfxPlayer {
  static final SfxPlayer _instance = SfxPlayer._internal();

  factory SfxPlayer() => _instance;

  SfxPlayer._internal();

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer? _loopPlayer; // separate player for ambient hum loop

  double _sfxVolume = 0.8;
  bool _humPlaying = false;

  /// Map enum values to asset paths
  static String _getAssetPath(PipBoySfx sfx) {
    switch (sfx) {
      case PipBoySfx.hum:
        return AppAudioPaths.sfxHum;
      case PipBoySfx.mapRollover:
        return AppAudioPaths.sfxMapRollover;
      case PipBoySfx.rotaryHorizontal:
        return AppAudioPaths.sfxRotaryHorizontal;
      case PipBoySfx.rotaryVertical:
        return AppAudioPaths.sfxRotaryVertical;
    }
  }

  /// Pre-cache all SFX files into the audio engine.
  /// Call this once during app startup before runApp().
  Future<void> init() async {
    try {
      await _player.setSourceAsset(AppAudioPaths.sfxHum);
      await _player.setSourceAsset(AppAudioPaths.sfxMapRollover);
      await _player.setSourceAsset(AppAudioPaths.sfxRotaryHorizontal);
      await _player.setSourceAsset(AppAudioPaths.sfxRotaryVertical);
      await _player.setVolume(_sfxVolume);
    } catch (e) {
      debugPrint('Error initializing SFX player: $e');
    }
  }

  /// Play an SFX once, fire-and-forget.
  Future<void> play(PipBoySfx sfx) async {
    try {
      final assetPath = _getAssetPath(sfx);
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing SFX: $e');
    }
  }

  /// Start playing the ambient hum loop (PipBoySfx.hum).
  /// Only one loop can be active at a time; subsequent calls restart it.
  Future<void> playLoop() async {
    try {
      _loopPlayer ??= AudioPlayer();
      await _loopPlayer!.setReleaseMode(ReleaseMode.loop);
      await _loopPlayer!.setVolume(_sfxVolume * 0.5); // hum is quieter
      await _loopPlayer!.play(AssetSource(AppAudioPaths.sfxHum));
      _humPlaying = true;
    } catch (e) {
      debugPrint('Error starting hum loop: $e');
    }
  }

  /// Stop the ambient hum loop.
  Future<void> stopLoop() async {
    try {
      if (_loopPlayer != null) {
        await _loopPlayer!.stop();
      }
      _humPlaying = false;
    } catch (e) {
      debugPrint('Error stopping hum loop: $e');
    }
  }

  /// Check if the hum loop is currently playing.
  bool get isHumPlaying => _humPlaying;

  /// Toggle the hum loop on/off.
  Future<void> toggleHum() async {
    if (_humPlaying) {
      await stopLoop();
    } else {
      await playLoop();
    }
  }

  /// Set the volume for all SFX (0.0 to 1.0).
  /// The loop runs at 50% of this volume.
  Future<void> setVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    try {
      await _player.setVolume(_sfxVolume);
      if (_loopPlayer != null) {
        await _loopPlayer!.setVolume(_sfxVolume * 0.5);
      }
    } catch (e) {
      debugPrint('Error setting SFX volume: $e');
    }
  }

  double getVolume() => _sfxVolume;

  /// Cleanup on app shutdown.
  Future<void> dispose() async {
    try {
      await _player.dispose();
      if (_loopPlayer != null) {
        await _loopPlayer!.dispose();
      }
    } catch (e) {
      debugPrint('Error disposing SFX player: $e');
    }
  }
}

// ignore: avoid_print
void debugPrint(String message) => print('[SfxPlayer] $message');
