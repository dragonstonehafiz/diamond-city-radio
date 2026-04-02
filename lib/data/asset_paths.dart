class AppAudioPaths {
  // SFX: audioplayers auto-prepends 'assets/', so don't include it
  static const String sfxBase = 'audio/sfx/';
  // Audio: just_audio needs full path with 'assets/'
  static const String songsBase = 'assets/audio/songs/';
  static const String introsBase = 'assets/audio/intros/';
  static const String outrosBase = 'assets/audio/outros/';
  static const String reportsBase = 'assets/audio/reports/';

  static const String sfxHum = '${sfxBase}UI_PipBoy_Hum_LP.wav';
  static const String sfxMapRollover =
      '${sfxBase}UI_PipBoy_Map_Rollover_01.wav';
  static const String sfxRotaryHorizontal =
      '${sfxBase}UI_PipBoy_RotaryHorizontal_01.wav';
  static const String sfxRotaryVertical =
      '${sfxBase}UI_PipBoy_RotaryVertical_01.wav';
}

class AppDataPaths {
  // For other asset types, include 'assets/' as they may use different loaders
  static const String config = 'assets/data/config.json';
  static const String reports = 'assets/data/reports.json';
  static const String songsDir = 'assets/data/songs/';
}
