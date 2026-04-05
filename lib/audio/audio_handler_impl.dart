import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioHandlerImpl extends BaseAudioHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late Function() _onSkipToNext;
  late Function() _onSkipToPrevious;

  AudioHandlerImpl() {
    // Initialize default no-op callbacks
    _onSkipToNext = () {};
    _onSkipToPrevious = () {};

    // Connect audio player state to audio service playback state
    _audioPlayer.playbackEventStream.listen(_updatePlaybackState);
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  void setSkipCallbacks({
    required Function() onSkipToNext,
    required Function() onSkipToPrevious,
  }) {
    _onSkipToNext = onSkipToNext;
    _onSkipToPrevious = onSkipToPrevious;
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
  }

  void _updatePlaybackState(PlaybackEvent event) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (_audioPlayer.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.playPause,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.stop,
      },
      processingState: _processingStateToAudioProcessingState(
        _audioPlayer.processingState,
      ),
      playing: _audioPlayer.playing,
      updatePosition: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
    ));
  }

  AudioProcessingState _processingStateToAudioProcessingState(
    ProcessingState state,
  ) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    _onSkipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    _onSkipToPrevious();
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
