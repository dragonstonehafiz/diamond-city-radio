import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/asset_paths.dart';
import '../models/song_model.dart';
import '../models/report_model.dart';
import '../models/app_config.dart';

class LoadedData {
  final List<SongModel> songs;
  final List<ReportModel> reports;
  final AppConfig config;

  const LoadedData({
    required this.songs,
    required this.reports,
    required this.config,
  });
}

class SongLoader {
  Future<LoadedData> load() async {
    final results = await Future.wait([
      _loadConfig(),
      _loadReports(),
      _loadAllSongs(),
    ]);

    return LoadedData(
      config: results[0] as AppConfig,
      reports: results[1] as List<ReportModel>,
      songs: results[2] as List<SongModel>,
    );
  }

  Future<AppConfig> _loadConfig() async {
    try {
      final jsonStr = await rootBundle.loadString(AppDataPaths.config);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AppConfig.fromJson(json);
    } catch (e) {
      print('[SongLoader] Error loading config: $e');
      return const AppConfig(
        songsPerSet: 3,
        refillThreshold: 5,
        refillCount: 10,
      );
    }
  }

  Future<List<ReportModel>> _loadReports() async {
    try {
      final jsonStr = await rootBundle.loadString(AppDataPaths.reports);
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => ReportModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('[SongLoader] Error loading reports: $e');
      return [];
    }
  }

  Future<List<SongModel>> _loadAllSongs() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final keys = manifest
          .listAssets()
          .where((key) => key.startsWith(AppDataPaths.songsDir) && key.endsWith('.json'))
          .toList();

      final songs = await Future.wait(keys.map(_loadSong));
      return songs.whereType<SongModel>().toList();
    } catch (e) {
      print('[SongLoader] Error loading songs: $e');
      return [];
    }
  }

  Future<SongModel?> _loadSong(String assetKey) async {
    try {
      final jsonStr = await rootBundle.loadString(assetKey);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return SongModel.fromJson(json);
    } catch (e) {
      print('[SongLoader] Error loading song at $assetKey: $e');
      return null;
    }
  }
}
