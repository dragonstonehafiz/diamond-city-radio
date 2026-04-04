import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'audio/audio_handler_impl.dart';
import 'theme/pip_boy_settings_notifier.dart';
import 'theme/pip_boy_theme.dart';
import 'theme/pip_boy_colors.dart';
import 'audio/sfx_player.dart';
import 'audio/radio_player_service.dart';
import 'radio/song_loader.dart';
import 'radio/song_bank.dart';
import 'radio/report_bank.dart';
import 'radio/set_builder.dart';
import 'data/song_repository.dart';
import 'data/report_repository.dart';
import 'data/asset_paths.dart';
import 'models/app_config.dart';
import 'radio/song_loader.dart' show LoadedData;
import 'widgets/pip_boy_tab_bar.dart';
import 'dart:convert';
import 'widgets/pip_boy_scanline_overlay.dart';
import 'widgets/pip_boy_status_bar.dart';
import 'screens/player_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio service for background playback and media notifications
  final audioHandler = await AudioService.init(
    builder: () => AudioHandlerImpl(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.diamondcityradio.channel.audio',
      androidNotificationChannelName: 'Diamond City Radio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  // Initialize SFX player before running the app
  await SfxPlayer().init();

  // Load songs, reports, and config in parallel
  final results = await Future.wait([
    _loadConfig(),
    SongLoader().load(),
  ]);

  final config = results[0] as AppConfig;
  final data = results[1] as LoadedData;

  // Create repositories
  final songRepo = SongRepository(data.songs);
  final reportRepo = ReportRepository(data.reports);

  // Initialize song and report banks
  final songBank = SongBank();
  await songBank.init(songRepo, config);
  final reportBank = ReportBank();
  await reportBank.init(reportRepo, config);

  // Build initial 3 sets
  final set1 = SetBuilder.buildSet(songBank, reportBank, songRepo, reportRepo, config);
  final set2 = SetBuilder.buildSet(songBank, reportBank, songRepo, reportRepo, config);
  final set3 = SetBuilder.buildSet(songBank, reportBank, songRepo, reportRepo, config);

  runApp(
    DiamondCityRadioApp(
      audioHandler: audioHandler,
      initialSets: [set1, set2, set3],
      songRepo: songRepo,
      reportRepo: reportRepo,
      appConfig: config,
      songBank: songBank,
      reportBank: reportBank,
      buildNextSet: () => SetBuilder.buildSet(songBank, reportBank, songRepo, reportRepo, config),
    ),
  );
}

class DiamondCityRadioApp extends StatelessWidget {
  final AudioHandlerImpl audioHandler;
  final List<List<RadioQueueItem>> initialSets;
  final SongRepository songRepo;
  final ReportRepository reportRepo;
  final AppConfig appConfig;
  final SongBank songBank;
  final ReportBank reportBank;
  final List<RadioQueueItem> Function() buildNextSet;

  const DiamondCityRadioApp({
    required this.audioHandler,
    required this.initialSets,
    required this.songRepo,
    required this.reportRepo,
    required this.appConfig,
    required this.songBank,
    required this.reportBank,
    required this.buildNextSet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => reportRepo),
        Provider(create: (_) => appConfig),
        ChangeNotifierProvider(create: (_) => PipBoySettingsNotifier()..load()),
        ChangeNotifierProvider(
          create: (_) => RadioPlayerService()
            ..init(audioHandler, initialSets, songRepo, reportRepo, buildNextSet),
        ),
      ],
      child: Consumer2<PipBoySettingsNotifier, RadioPlayerService>(
        builder: (context, settingsNotifier, radioPlayerService, _) {
          // Apply saved volumes on startup
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SfxPlayer().setVolume(settingsNotifier.sfxVolume);
            SfxPlayer().setHumVolume(settingsNotifier.humVolume);
            radioPlayerService.setVolume(settingsNotifier.mainVolume);
          });

          return MaterialApp(
            title: 'Diamond City Radio',
            theme: buildPipBoyTheme(settingsNotifier.accent),
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabLabels = ['PLAYER', 'QUEUE', 'SETTINGS'];

  @override
  void initState() {
    super.initState();
    // Start hum loop if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<PipBoySettingsNotifier>();
      if (settings.humEnabled) {
        SfxPlayer().playLoop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PipBoySettingsNotifier>();
    return Scaffold(
      backgroundColor: PipBoyColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              // Top navigation tabs
              PipBoyTabBar(
                labels: _tabLabels,
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
              ),
              // Main content area with scanline overlay
              Expanded(
                child: PipBoyScanlineOverlay(
                  enabled: settings.scanlinesEnabled,
                  child: IndexedStack(
                    index: _selectedTabIndex,
                    children: [
                      _buildPlayerTab(),
                      _buildQueueTab(),
                      _buildSettingsTab(),
                    ],
                  ),
                ),
              ),
              // Bottom status bar
              const PipBoyStatusBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerTab() {
    return const PlayerScreen();
  }

  Widget _buildQueueTab() {
    return const QueueScreen();
  }

  Widget _buildSettingsTab() {
    return const SettingsScreen();
  }
}

Future<AppConfig> _loadConfig() async {
  try {
    final jsonStr = await rootBundle.loadString(AppDataPaths.config);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return AppConfig.fromJson(json);
  } catch (e) {
    print('[main] Error loading config: $e');
    return AppConfig.fromJson({});
  }
}
