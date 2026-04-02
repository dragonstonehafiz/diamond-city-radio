import '../models/report_model.dart';

class ReportRepository {
  final Map<String, ReportModel> _reportsById;
  final List<ReportModel> _allReports;

  ReportRepository(List<ReportModel> reports)
      : _reportsById = {for (final report in reports) report.id: report},
        _allReports = reports;

  ReportModel? getById(String id) => _reportsById[id];

  ReportModel? getRandom() => _allReports.isEmpty ? null : _allReports[(DateTime.now().millisecond) % _allReports.length];
}
