# Diamond City Radio — Class Reference

## Theme Layer

**PipBoyColors** (`lib/theme/pip_boy_colors.dart`)
- Static color constants: `background`, `backgroundAlt`, `defaultAccent` (Fallout green)
- Utility: `dimmed(Color, factor)` — lerps accent toward black for muted/disabled states

**PipBoySettingsNotifier** (`lib/theme/pip_boy_settings_notifier.dart`)
- ChangeNotifier managing all app settings (accent color, scanlines, hum, SFX volume)
- Persists to SharedPreferences
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

---

## Screens

**PlayerScreen** (`lib/screens/player_screen.dart`)
- Radio now-playing display: clip badge, dynamic image/icon, track name/artist, seekable progress bar, prev/play/next buttons
- Uses `RadioPlayerService` for playback state
- Progress bar: duration reactive via nested `StreamBuilder` on `player.durationStream`; `interactive: true` with `onSeek` callback to `player.seek()`
- Display logic via `_buildDisplayImage()`: shows report image if available, white icon (tinted with accent color) for intros/outros, music note icon for songs
- AppConfig `appIconPath` configures intro/outro icon path

**QueueScreen** (`lib/screens/queue_screen.dart`)
- Three panels: CURRENT SET (active item marked with `>`), NEXT SET, AFTER NEXT SET
- All dividers between items
- Uses `RadioPlayerService` for live queue data

**SettingsScreen** (`lib/screens/settings_screen.dart`)
- DISPLAY COLOR: 6 color circle presets (tappable, plays SFX)
- UI OPTIONS: SCANLINES toggle, AMBIENT HUM toggle, SFX VOLUME slider
- ABOUT: static version/credits info

---

## Models

**SongModel** (`lib/models/song_model.dart`)
- Fields: `id`, `name`, `artist`, `songFile`, `intros` (List), `outros` (List)
- Getters: `hasIntros`, `hasOutros`
- Factory: `fromJson()`
- Duration pulled at runtime from audio file via `just_audio`

**ReportModel** (`lib/models/report_model.dart`)
- Fields: `id`, `path`, `title`, optional `image`
- Factory: `fromJson()`
- `image` path relative to `assets/` (e.g., `images/reports/BlindBetrayal.png`)
- Duration pulled at runtime from audio file via `just_audio`

**AppConfig** (`lib/models/app_config.dart`)
- Fields: `songsPerSet` (default 3), `refillThreshold` (default 5), `refillCount` (default 10), `appIconPath` (default `images/icons/icon_white.png`)
- Factory: `fromJson()`

---

## Data Layer

**SongRepository** (`lib/data/song_repository.dart`)
- Holds all songs indexed by ID
- Methods: `getById(String id)`, `getAllSongs()`

**ReportRepository** (`lib/data/report_repository.dart`)
- Holds all reports indexed by ID
- Methods: `getById(String id)`, `getRandom()` — returns random report using `Random().nextInt()`

**AppAudioPaths** (`lib/data/asset_paths.dart`)
- SFX paths (audioplayers, no `assets/` prefix): `sfxBase`, `sfxHum`, `sfxMapRollover`, `sfxRotaryHorizontal`, `sfxRotaryVertical`
- Audio paths (just_audio, full `assets/...` prefix): `songsBase`, `introsBase`, `outrosBase`, `reportsBase`

**AppDataPaths** (`lib/data/asset_paths.dart`)
- JSON data paths: `config`, `reports`, `songsDir`

---

## Audio Layer

**SfxPlayer** (`lib/audio/sfx_player.dart`)
- Singleton using `audioplayers` for UI sound effects
- Enum: `PipBoySfx` (hum, mapRollover, rotaryHorizontal, rotaryVertical)
- Methods: `init()` (pre-cache), `play(sfx)`, `playLoop()`, `stopLoop()`, `setVolume()`, `toggleHum()`
- Separate player for ambient hum loop

**RadioPlayerService** (`lib/audio/radio_player_service.dart`)
- Main audio player using `just_audio` + `just_audio_background`
- Enum: `RadioClipType` (intro, song, outro, report)
- Class: `RadioQueueItem` — stores only `itemId` and `clipType`, display info resolved at playback time
- Fields: `_sets` (3-set buffer: [current, next, after-next]), `_currentIndex`
- Methods: `init()`, `play()`, `pause()`, `togglePlayPause()`, `next()`, `prev()`, `seek(Duration)`
- Getters: `sets`, `currentItem`, `currentIndex`, `isPlaying`, `duration`, `position`
- Streams: `durationStream`, `positionStream` — duration updates reactively as file loads
- Public methods for UI: `getTrackName(item)`, `getArtist(item)`, `seek(position)` for progress bar seeking
- **Key behavior**: When current set ends, rotates sets and builds new set 3 via `_buildNextSet()` callback
- **Intro/outro handling**: Randomly selects from all valid files (checked via `_assetExists()`) each playback; auto-skips to next track if none found
- **Report audio path**: Resolved from `report.path` field

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
- Fields: `_songBank` (pool), `_playedSongs` (recently-used), `_config`
- Persists state to SharedPreferences as ID lists (survives app restart)
- Methods: `init()`, `draw()` (removes from pool, adds to played), `_checkRefill()`, `_refill()` (rotates old songs back)
- On first launch: shuffles all songs into bank
- On app restart: restores from SharedPreferences

**SetBuilder** (`lib/radio/set_builder.dart`)
- Static method: `buildSet(bank, songs, reports, config)`
- Draws N songs from bank, ensures first has intros + last has outros (swaps if needed)
- Builds queue: [intro, ...songs, outro, report]
- Returns `List<RadioQueueItem>` with only `itemId` + `clipType` (no paths)

---

## Main

**main()** (`lib/main.dart`)
- Initializes JustAudioBackground, SfxPlayer, then loads AppConfig and songs/reports in parallel via `Future.wait()`
- AppConfig loaded via `_loadConfig()` helper; songs/reports loaded via `SongLoader`
- Initializes SongBank, builds initial 3 sets, then runs app

**DiamondCityRadioApp** (`lib/main.dart`)
- Root widget: provides `ReportRepository`, `AppConfig`, `PipBoySettingsNotifier`, and `RadioPlayerService` via MultiProvider
- Builds MaterialApp with dynamic theme from settings notifier
- Constructor: `initialSets`, `songRepo`, `reportRepo`, `appConfig`, `buildNextSet` callback

**HomeScreen** (`lib/main.dart`)
- Main layout: `PipBoyTabBar` (top) + `IndexedStack` (three tabs) + `PipBoyStatusBar` (bottom)
- All wrapped in `PipBoyScanlineOverlay`
- UI constrained to 360dp max width (phone aspect ratio)
