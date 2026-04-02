import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'theme/pip_boy_settings_notifier.dart';
import 'theme/pip_boy_theme.dart';
import 'theme/pip_boy_colors.dart';
import 'audio/sfx_player.dart';
import 'audio/radio_player_service.dart';
import 'radio/song_loader.dart';
import 'radio/song_bank.dart';
import 'radio/set_builder.dart';
import 'data/song_repository.dart';
import 'data/report_repository.dart';
import 'widgets/pip_boy_tab_bar.dart';
import 'widgets/pip_boy_scanline_overlay.dart';
import 'widgets/pip_boy_status_bar.dart';
import 'screens/player_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background audio (must be before any audio operations)
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.diamondcityradio.channel.audio',
    androidNotificationChannelName: 'Diamond City Radio',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  // Initialize SFX player before running the app
  await SfxPlayer().init();

  // Load songs, reports, and config
  final loader = SongLoader();
  final data = await loader.load();

  // Create repositories
  final songRepo = SongRepository(data.songs);
  final reportRepo = ReportRepository(data.reports);

  // Initialize song bank
  final bank = SongBank();
  await bank.init(songRepo, data.config);

  // Build initial 3 sets
  final set1 = SetBuilder.buildSet(bank, songRepo, reportRepo, data.config);
  final set2 = SetBuilder.buildSet(bank, songRepo, reportRepo, data.config);
  final set3 = SetBuilder.buildSet(bank, songRepo, reportRepo, data.config);

  runApp(
    DiamondCityRadioApp(
      initialSets: [set1, set2, set3],
      songRepo: songRepo,
      reportRepo: reportRepo,
      buildNextSet: () => SetBuilder.buildSet(bank, songRepo, reportRepo, data.config),
    ),
  );
}

class DiamondCityRadioApp extends StatelessWidget {
  final List<List<RadioQueueItem>> initialSets;
  final SongRepository songRepo;
  final ReportRepository reportRepo;
  final List<RadioQueueItem> Function() buildNextSet;

  const DiamondCityRadioApp({
    required this.initialSets,
    required this.songRepo,
    required this.reportRepo,
    required this.buildNextSet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PipBoySettingsNotifier()..load()),
        ChangeNotifierProvider(
          create: (_) => RadioPlayerService()
            ..init(initialSets, songRepo, reportRepo, buildNextSet),
        ),
      ],
      child: Consumer<PipBoySettingsNotifier>(
        builder: (context, settingsNotifier, _) {
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
