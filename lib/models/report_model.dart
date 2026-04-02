class ReportModel {
  final String id;
  final String path;
  final double length;

  const ReportModel({
    required this.id,
    required this.path,
    required this.length,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? '',
      path: json['path'] as String? ?? '',
      length: (json['length'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
