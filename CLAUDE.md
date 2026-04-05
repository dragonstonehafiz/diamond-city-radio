# Diamond City Radio — Class Reference

## Theme Layer

**PipBoyColors** (`lib/theme/pip_boy_colors.dart`)
- Static color constants: `background`, `backgroundAlt`, `defaultAccent` (Fallout green)
- Utility: `dimmed(Color, factor)` — lerps accent toward black for muted/disabled states

**PipBoySettingsNotifier** (`lib/theme/pip_boy_settings_notifier.dart`)
- ChangeNotifier managing all app settings: accent color, scanlines enabled, hum enabled, SFX volume (0.0–1.0, default 0.8), hum volume (0.0–1.0, default 0.5), main audio volume (0.0–1.0, default 1.0)
- Persists to SharedPreferences with keys: `accent_color`, `scanlines_enabled`, `hum_enabled`, `sfx_volume`, `hum_volume`, `main_volume`
- Methods: `setAccent()`, `setScanlinesEnabled()`, `setHumEnabled()`, `setSfxVolume()`, `setHumVolume()`, `setMainVolume()`
- Accessed via `context.watch<PipBoySettingsNotifier>()`

**PipBoyTypography** (`lib/theme/pip_boy_typography.dart`)
- Static text style factories: `heading()`, `subheading()`, `body()`, `caption()`, `tabLabel()`, `statusBar()`
- All use VT323 Google Font
- Take `Color accent` parameter for dynamic theming

**PipBoyConstants** (`lib/theme/pip_boy_constants.dart`)
- Spacing tokens: `spacingXS` (4) through `spacingXL` (32)
- Border widths: `borderWidthThin` (1), `borderWidthNormal` (2), `borderWidthThick` (3)
- Bar heights, durations, animation timings

**buildPipBoyTheme()** (`lib/theme/pip_boy_theme.dart`)
- Function: `ThemeData buildPipBoyTheme(Color accent)`
- Builds MaterialApp theme with no ripple effects, transparent highlights, Pip-Boy colors

---

## Widgets

**PipBoyButton** (`lib/widgets/pip_boy_button.dart`)
- Only button widget in the app (replaces Material buttons)
- Constructor: `label`, `icon`, `onPressed`, `isActive`, `variant` (filled/outlined/ghost), `width`
- Plays `PipBoySfx.rotaryHorizontal` on tap, scales to 0.93

**PipBoyTabBar** (`lib/widgets/pip_boy_tab_bar.dart`)
- Top navigation: `labels`, `selectedIndex`, `onTabSelected`, `isSubBar` flag
- Active tab: accent color + underline; inactive: dimmed
- Plays `PipBoySfx.rotaryVertical` on change

**PipBoyProgressBar** (`lib/widgets/pip_boy_progress_bar.dart`)
- Progress indicator: `value` (0.0–1.0), optional `leftLabel`/`rightLabel`, `interactive`, `onSeek` callback
- CustomPaint: track + filled portion + position cursor

**PipBoyPanel** (`lib/widgets/pip_boy_panel.dart`)
- Framed content box: `child`, optional `title` (overlays top border), `padding`, `outlined`, `height`, `width`
- Background: `backgroundAlt`, border: `borderDim`

**PipBoyDivider** (`lib/widgets/pip_boy_divider.dart`)
- Ruled line separator: `axis` (horizontal/vertical), `extent`, `thickness`, `margin`
- Color always `borderDim` (enforces consistency, no color param)

**PipBoyScanlineOverlay** (`lib/widgets/pip_boy_scanline_overlay.dart`)
- CRT effect: wraps `child` with horizontal scanlines via CustomPaint
- Constructor: `child`, `enabled` boolean
- Wrapped in `IgnorePointer` so taps pass through

**PipBoyStatusBar** (`lib/widgets/pip_boy_status_bar.dart`)
- Bottom bar: displays live time, decorative system info
- Constructor: optional `customLeftText`/`customRightText`
- Updates every 30s via Timer

**PipBoyIcon** (`lib/widgets/pip_boy_icon.dart`)
- Icon wrapper: enforces monochrome tint from settings notifier
- Constructor: `icon`, `size`, `dimmed`, `disabled` flags

**PipBoyMarqueeText** (`lib/widgets/pip_boy_marquee_text.dart`)
- Scrolling text widget for display of long titles/labels on a single line
- Constructor: `text`, `style`, `height`
- Auto-detects overflow: if text fits within available width, displays static text; if overflow, animates marquee scroll
- Marquee settings: 40px/sec velocity, 2-second pause between loops, 64dp gap between repetitions, subtle fade at right edge
- Enables long song titles and artist names to remain on one line while scrolling smoothly

---

## Screens

**PlayerScreen** (`lib/screens/player_screen.dart`)
- Radio now-playing display: clip badge, dynamic image/icon, track name/artist, seekable progress bar, prev/play/next buttons
- Uses `RadioPlayerService` for playback state
- Progress bar: duration reactive via nested `StreamBuilder` on `player.durationStream`; `interactive: true` with `onSeek` callback to `player.seek()`
- Display logic via `_buildDisplayImage()`: shows report image if available, white icon (tinted with accent color) for intros/outros, music note icon for songs
- AppConfig `appIconPath` configures intro/outro icon path

**QueueScreen** (`lib/screens/queue_screen.dart`)
- Single panel showing the full flat queue from `RadioPlayerService.queue`
- Active item marked with `>`, dimmed accent for future items
- All items separated by dividers
- Uses `RadioPlayerService` for live queue data

**SettingsScreen** (`lib/screens/settings_screen.dart`)
- DISPLAY COLOR: 6 color circle presets (tappable, plays SFX)
- VISUAL panel: SCANLINES toggle (on/off)
- AUDIO panel:
  - AMBIENT HUM toggle (on/off)
  - SFX VOLUME slider (0.0–1.0) — controls UI sound effects volume, plays mapRollover SFX on release
  - HUM VOLUME slider (0.0–1.0) — controls ambient hum loop volume independently from SFX
  - AUDIO VOLUME slider (0.0–1.0) — controls main radio playback (songs, reports, intros/outros)
- All sliders apply changes in real time and persist to SharedPreferences via `PipBoySettingsNotifier` setter + audio player `setVolume()` call
- ABOUT: version info only (no credentials)

---

## Models

**SongModel** (`lib/models/song_model.dart`)
- Fields: `id`, `name`, `artist`, `songFile` (full asset path), `intros` (List of full asset paths), `outros` (List of full asset paths)
- Getters: `hasIntros`, `hasOutros`
- Factory: `fromJson()` — maps JSON `song` field to `songFile`, JSON arrays to lists
- Example paths: `songFile: "assets/audio/songs/bettyHutton_hesADemon.ogg"`, `intros: ["assets/audio/intros/bettyHutton_itsAMan1.ogg", ...]`
- Duration pulled at runtime from audio file via `just_audio`

**ReportModel** (`lib/models/report_model.dart`)
- Fields: `id`, `path` (full asset path to audio file), `title`, optional `image` (full asset path)
- Factory: `fromJson()`
- Example paths: `path: "assets/audio/reports/freedomTrail.ogg"`, `image: "assets/images/reports/FreedomTrail.png"`
- Duration pulled at runtime from audio file via `just_audio`

**AppConfig** (`lib/models/app_config.dart`)
- Fields: `songsPerSet` (default 3), `refillThreshold` (default 5), `refillCount` (default 10), `appIconPath` (default `images/icons/dcr_icon.png`)
- Factory: `fromJson()`

---

## Data Layer

**SongRepository** (`lib/data/song_repository.dart`)
- Holds all songs indexed by ID
- Methods: `getById(String id)`, `getAllSongs()`

**ReportRepository** (`lib/data/report_repository.dart`)
- Holds all reports indexed by ID
- Methods: `getById(String id)`, `getAllReports()`, `getRandom()` — returns random report using `Random().nextInt()`

**AppAudioPaths** (`lib/data/asset_paths.dart`)
- SFX paths (audioplayers, no `assets/` prefix): `sfxBase`, `sfxHum`, `sfxMapRollover`, `sfxRotaryHorizontal`, `sfxRotaryVertical`

**AppDataPaths** (`lib/data/asset_paths.dart`)
- JSON data paths: `config` (`assets/data/config.json`), `reports` (`assets/data/reports.json`), `songsDir` (`assets/data/songs/`)
- Song, intro, outro, and report audio file paths are stored as full asset paths within the JSON data (e.g., `"assets/audio/songs/..."`, `"assets/audio/intros/..."`, etc.)

---

## Android Setup

**MainActivity** (`android/app/src/main/kotlin/.../MainActivity.kt`)
- CRITICAL: Must extend `AudioServiceFragmentActivity` (not `FlutterFragmentActivity`)
- `audio_service` plugin validates `instanceof AudioServiceFragmentActivity` during init—using wrong base class causes platform exception

**AndroidManifest.xml** (`android/app/src/main/AndroidManifest.xml`)
- Service: `com.ryanheise.audioservice.AudioService` with `android:foregroundServiceType="mediaPlayback"`
- Intent filter: `android.media.browse.MediaBrowserService`
- Permissions: `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`
- Activity: `MainActivity` with `android:launchMode="singleTop"`, `android:taskAffinity=""`

---

## Audio Layer

**AudioHandlerImpl** (`lib/audio/audio_handler_impl.dart`)
- Extends `BaseAudioHandler` from `audio_service` package
- Owns the single `AudioPlayer` instance used by `RadioPlayerService`
- Manages Android media notifications, lock screen controls, and background playback
- Methods: `play()`, `pause()`, `stop()`, `seek()`, `skipToNext()`, `skipToPrevious()`
- Exposes player via `audioPlayer` getter
- Callbacks: `setSkipCallbacks()` for next/prev integration with `RadioPlayerService`
- Updates `mediaItem` stream when track changes (id, title, artist)
- Syncs `playbackState` from player events (position, duration, processing state)

**SfxPlayer** (`lib/audio/sfx_player.dart`)
- Singleton using `audioplayers` for UI sound effects (rotary clicks, etc.) and ambient hum loop
- Enum: `PipBoySfx` (hum, mapRollover, rotaryHorizontal, rotaryVertical)
- Fields: `_sfxVolume` (SFX only, default 0.8), `_humVolume` (hum loop only, default 0.5)
- Methods: `init()` (pre-cache all SFX, configure audio context), `play(sfx)`, `playLoop()`, `stopLoop()`, `setVolume()` (SFX only), `setHumVolume()` (hum only), `getVolume()`, `getHumVolume()`, `toggleHum()`
- **Critical**: Both `_player` (for SFX) and `_loopPlayer` (for hum) configured with `audioFocus: AndroidAudioFocus.none` to prevent audio focus conflicts with main radio audio
- `_player`: low-latency UI clicks at `_sfxVolume`
- `_loopPlayer`: separate instance for continuous ambient hum at `_humVolume`

**RadioPlayerService** (`lib/audio/radio_player_service.dart`)
- Main audio player using `just_audio` (audio playback) + `audio_service` (notifications/background)
- Owns reference to `AudioHandlerImpl` for playback control
- Enum: `RadioClipType` (intro, song, outro, report)
- Class: `RadioQueueItem` — stores only `itemId` and `clipType`, display info resolved at playback time
- Fields: `_queue` (flat list of all upcoming items), `_currentIndex`, `_audioHandler`
- Methods: `init(audioHandler, songs, reports, songBank, reportBank, config)` (builds initial queue from 3 sets), `play()`, `pause()`, `togglePlayPause()`, `next()`, `prev()`, `seek(Duration)`, `setVolume(double)` (controls main audio playback volume via `just_audio`)
- Getters: `queue`, `currentItem`, `currentIndex`, `isPlaying`, `duration`, `position`
- Streams: `durationStream`, `positionStream` — duration updates reactively as file loads
- Public methods for UI: `getTrackName(item)`, `getArtist(item)`, `seek(position)` for progress bar seeking
- **Key behavior**: When `next()` reaches the end of the queue (after 3 reports), the queue is cleared and rebuilt with 3 fresh sets. This prevents unbounded memory growth over time.
- **Path resolution** via `_resolveAssetPath()`: 
  - Songs: returns `songFile` from SongModel
  - Intros/outros: randomly selects from available list after validating each exists via `_assetExists()`; auto-skips to next track if none valid
  - Reports: returns `path` from ReportModel
- Audio files are loaded via `AudioSource.asset()` which expects full asset paths
- **Audio Service Integration**: After loading each track, calls `_audioHandler.updateMediaItem()` to sync Android notifications

---

## Radio Layer (Data Loading & Set Management)

**SongLoader** (`lib/radio/song_loader.dart`)
- Loads reports and all songs from JSON assets in parallel
- Dynamically enumerates song JSON files via `AssetManifest` — no hardcoded filenames
- Returns `LoadedData` container
- Includes fallback empty lists if loading fails

**LoadedData** (`lib/radio/song_loader.dart`)
- Container: `songs`, `reports`

**SongBank** (`lib/radio/song_bank.dart`)
- Rotating pool of songs for set building
- Fields: `_unplayedSongs` (pool), `_playedSongs` (recently-used), `_config`
- Persists state to SharedPreferences as ID lists (survives app restart)
- Methods: `init()`, `draw(int count)` (draw N random songs), `drawWithIntro(int count)` (draw N songs with intros), `drawWithOutro(int count)` (draw N songs with outros), `_refill()` (rotates old songs back when pool depletes)
- On first launch: shuffles all songs into bank
- On app restart: restores from SharedPreferences via `_loadFromState()`

**ReportBank** (`lib/radio/report_bank.dart`)
- Rotating pool of reports for set building (mirrors SongBank exactly)
- Fields: `_reportBank` (pool), `_playedReports` (recently-used), `_config`
- Persists state to SharedPreferences as ID lists (survives app restart)
- Methods: `init()`, `draw()` (removes from pool, adds to played), `_checkRefill()`, `_refill()` (rotates old reports back)
- On first launch: shuffles all reports into bank
- On app restart: restores from SharedPreferences

**SetBuilder** (`lib/radio/set_builder.dart`)
- Static method: `buildSet(songBank, reportBank, songs, reports, config)`
- Draws first song from `songBank.drawWithIntro(1)` (guaranteed to have intros)
- Draws middle songs from `songBank.draw(N)` (any songs)
- Draws last song from `songBank.drawWithOutro(1)` (guaranteed to have outros)
- Draws one report from `reportBank.draw()`
- Builds queue: [intro, ...songs, outro, report]
- Returns `List<RadioQueueItem>` with only `itemId` + `clipType` (no paths)

---

## Main

**main()** (`lib/main.dart`)
- Initialization order (critical):
  1. `AudioService.init()` with `AudioHandlerImpl` builder — must be before `runApp()` so background playback is ready
  2. `SfxPlayer().init()` — pre-caches UI sounds and configures audio context
  3. `Future.wait()` loads AppConfig and songs/reports in parallel via `_loadConfig()` and `SongLoader`
  4. Initialize SongBank and ReportBank
  5. Run app, passing `audioHandler`, `songRepo`, `reportRepo`, `appConfig`, `songBank`, `reportBank` to `DiamondCityRadioApp`
  6. `DiamondCityRadioApp` initializes `RadioPlayerService`, which builds its own initial queue from 3 sets

**DiamondCityRadioApp** (`lib/main.dart`)
- Root widget: provides `ReportRepository`, `AppConfig`, `PipBoySettingsNotifier`, and `RadioPlayerService` via MultiProvider
- Constructor: `audioHandler`, `songRepo`, `reportRepo`, `appConfig`, `songBank`, `reportBank`
- Passes all parameters to `RadioPlayerService.init()` so the service builds its own initial queue
- Uses `Consumer2<PipBoySettingsNotifier, RadioPlayerService>` to apply saved volumes on startup:
  - `SfxPlayer().setVolume(settingsNotifier.sfxVolume)`
  - `SfxPlayer().setHumVolume(settingsNotifier.humVolume)`
  - `radioPlayerService.setVolume(settingsNotifier.mainVolume)`
- Builds MaterialApp with dynamic theme from settings notifier

**HomeScreen** (`lib/main.dart`)
- Main layout: `PipBoyTabBar` (top) + `IndexedStack` (three tabs) + `PipBoyStatusBar` (bottom)
- All wrapped in `PipBoyScanlineOverlay`
- UI constrained to 360dp max width (phone aspect ratio)
- `initState()` starts ambient hum loop if enabled via `SfxPlayer().playLoop()`
