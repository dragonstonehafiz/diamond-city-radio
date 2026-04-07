import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'audio/audio_handler_impl.dart';
import 'theme/pip_boy_settings_notifier.dart';
import 'theme/pip_boy_theme.dart';
import 'theme/pip_boy_colors.dart';
import 'theme/pip_boy_typography.dart';
import 'audio/sfx_player.dart';
import 'audio/radio_player_service.dart';
import 'radio/song_loader.dart';
import 'radio/song_bank.dart';
import 'radio/report_bank.dart';
import 'data/song_repository.dart';
import 'data/report_repository.dart';
import 'data/asset_paths.dart';
import 'models/app_config.dart';
import 'widgets/pip_boy_tab_bar.dart';
import 'widgets/pip_boy_button.dart';
import 'dart:convert';
import 'widgets/pip_boy_scanline_overlay.dart';
import 'widgets/pip_boy_status_bar.dart';
import 'widgets/pip_boy_divider.dart';
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

  runApp(
    DiamondCityRadioApp(
      audioHandler: audioHandler,
      songRepo: songRepo,
      reportRepo: reportRepo,
      appConfig: config,
      songBank: songBank,
      reportBank: reportBank,
    ),
  );
}

class DiamondCityRadioApp extends StatelessWidget {
  final AudioHandlerImpl audioHandler;
  final SongRepository songRepo;
  final ReportRepository reportRepo;
  final AppConfig appConfig;
  final SongBank songBank;
  final ReportBank reportBank;

  const DiamondCityRadioApp({
    required this.audioHandler,
    required this.songRepo,
    required this.reportRepo,
    required this.appConfig,
    required this.songBank,
    required this.reportBank,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => reportRepo),
        Provider(create: (_) => appConfig),
        ChangeNotifierProvider(
          create: (_) => PipBoySettingsNotifier(
            defaultAccent: appConfig.defaultAccentColor,
            defaultScanlinesEnabled: appConfig.defaultScanlinesEnabled,
            defaultScanlineWidth: appConfig.defaultScanlineWidth,
            defaultScanlineDistance: appConfig.defaultScanlineDistance,
            defaultScanlineSpeed: appConfig.scanlineSpeed,
            defaultSfxVolume: appConfig.defaultSfxVolume,
            defaultHumEnabled: appConfig.defaultHumEnabled,
            defaultHumVolume: appConfig.defaultHumVolume,
            defaultMainVolume: appConfig.defaultMainVolume,
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => RadioPlayerService()
            ..init(audioHandler, songRepo, reportRepo, songBank, reportBank, appConfig),
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
  static const double _desktopBreakpoint = 900;
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
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= _desktopBreakpoint) {
              return _buildDesktopShell(settings);
            }
            return _buildMobileShell(settings);
          },
        ),
      ),
    );
  }

  Widget _buildMobileShell(PipBoySettingsNotifier settings) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          children: [
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
                lineWidth: settings.scanlineWidth,
                lineSpacing: settings.scanlineDistance,
                scanSpeed: settings.scanlineSpeed,
                child: _buildTabContent(),
              ),
            ),
            // Bottom status bar
            const PipBoyStatusBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopShell(PipBoySettingsNotifier settings) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 220,
                      child: _DesktopSidebar(
                        tabLabels: _tabLabels,
                        selectedTabIndex: _selectedTabIndex,
                        onTabSelected: (index) {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PipBoyScanlineOverlay(
                        enabled: settings.scanlinesEnabled,
                        lineWidth: settings.scanlineWidth,
                        lineSpacing: settings.scanlineDistance,
                        scanSpeed: settings.scanlineSpeed,
                        child: _buildTabContent(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const PipBoyStatusBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return IndexedStack(
      index: _selectedTabIndex,
      children: [
        _buildPlayerTab(),
        _buildQueueTab(),
        _buildSettingsTab(),
      ],
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

class _DesktopSidebar extends StatelessWidget {
  final List<String> tabLabels;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;

  const _DesktopSidebar({
    required this.tabLabels,
    required this.selectedTabIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PipBoySettingsNotifier>();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: settings.dim,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'DIAMOND CITY RADIO',
              style: PipBoyTypography.subheading(settings.accent),
            ),
          ),
          const PipBoyDivider(margin: EdgeInsets.zero),
          const SizedBox(height: 8),
          for (int i = 0; i < tabLabels.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: PipBoyButton(
                label: tabLabels[i],
                width: double.infinity,
                isActive: i == selectedTabIndex,
                variant: PipBoyButtonVariant.outlined,
                onPressed: () => onTabSelected(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<AppConfig> _loadConfig() async {
  try {
    final jsonStr = await rootBundle.loadString(AppDataPaths.config);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return AppConfig.fromJson(json);
  } catch (e) {
    debugPrint('[main] Error loading config: $e');
    return AppConfig.fromJson({});
  }
}
