import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../data/asset_paths.dart';
import '../models/song_model.dart';
import '../models/report_model.dart';

class LoadedData {
  final List<SongModel> songs;
  final List<ReportModel> reports;

  const LoadedData({
    required this.songs,
    required this.reports,
  });
}

class SongLoader {
  Future<LoadedData> load() async {
    final results = await Future.wait([
      _loadReports(),
      _loadAllSongs(),
    ]);

    return LoadedData(
      reports: results[0] as List<ReportModel>,
      songs: results[1] as List<SongModel>,
    );
  }

  Future<List<ReportModel>> _loadReports() async {
    try {
      final jsonStr = await rootBundle.loadString(AppDataPaths.reports);
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => ReportModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[SongLoader] Error loading reports: $e');
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
      debugPrint('[SongLoader] Error loading songs: $e');
      return [];
    }
  }

  Future<SongModel?> _loadSong(String assetKey) async {
    try {
      final jsonStr = await rootBundle.loadString(assetKey);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return SongModel.fromJson(json);
    } catch (e) {
      debugPrint('[SongLoader] Error loading song at $assetKey: $e');
      return null;
    }
  }
}
