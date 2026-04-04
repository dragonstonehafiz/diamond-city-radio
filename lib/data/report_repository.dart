import 'dart:math';
import '../models/report_model.dart';

class ReportRepository {
  final Map<String, ReportModel> _reportsById;
  final List<ReportModel> _allReports;
  final Random _random = Random();

  ReportRepository(List<ReportModel> reports)
      : _reportsById = {for (final report in reports) report.id: report},
        _allReports = reports;

  ReportModel? getById(String id) => _reportsById[id];

  List<ReportModel> getAllReports() => _allReports;

  ReportModel? getRandom() => _allReports.isEmpty ? null : _allReports[_random.nextInt(_allReports.length)];
}
