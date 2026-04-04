import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_model.dart';
import '../models/app_config.dart';
import '../data/report_repository.dart';

class ReportBank {
  static const String _bankKey = 'report_bank_ids';
  static const String _playedKey = 'report_played_ids';

  List<ReportModel> _reportBank = [];
  List<ReportModel> _playedReports = [];
  late AppConfig _config;
  late ReportRepository _reports;
  late SharedPreferences _prefs;

  Future<void> init(ReportRepository reports, AppConfig config) async {
    _reports = reports;
    _config = config;
    _prefs = await SharedPreferences.getInstance();

    // Try to restore from SharedPreferences
    final savedBankIds = _prefs.getStringList(_bankKey);
    final savedPlayedIds = _prefs.getStringList(_playedKey);

    if (savedBankIds != null && savedBankIds.isNotEmpty) {
      // Restore from saved state
      _reportBank = _restoreFromIds(savedBankIds);
      _playedReports = _restoreFromIds(savedPlayedIds ?? []);
    } else {
      // First launch: initialize fresh
      _reportBank = List.from(_reports.getAllReports())..shuffle(Random());
      _playedReports = [];
      await _persist();
    }
  }

  ReportModel draw() {
    assert(_reportBank.isNotEmpty, 'ReportBank.draw() called with empty bank');
    final report = _reportBank.removeAt(0);
    _playedReports.add(report);
    _checkRefill();
    _persist(); // fire-and-forget
    return report;
  }

  void _checkRefill() {
    if (_reportBank.length < _config.refillThreshold) {
      _refill();
    }
  }

  void _refill() {
    if (_playedReports.isEmpty) return;

    final count = min(_config.refillCount, _playedReports.length);
    final toMove = _playedReports.sublist(0, count);
    _playedReports = _playedReports.sublist(count);
    _reportBank.addAll(toMove);
    _reportBank.shuffle(Random());
  }

  Future<void> _persist() async {
    try {
      final bankIds = _reportBank.map((r) => r.id).toList();
      final playedIds = _playedReports.map((r) => r.id).toList();
      await _prefs.setStringList(_bankKey, bankIds);
      await _prefs.setStringList(_playedKey, playedIds);
    } catch (e) {
      print('[ReportBank] Error persisting state: $e');
    }
  }

  List<ReportModel> _restoreFromIds(List<String> ids) {
    final result = <ReportModel>[];
    for (final id in ids) {
      final report = _reports.getById(id);
      if (report != null) {
        result.add(report);
      }
    }
    return result;
  }

  int get bankLength => _reportBank.length;
}
