class ReportModel {
  final String id;
  final String path;

  const ReportModel({
    required this.id,
    required this.path,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? '',
      path: json['path'] as String? ?? '',
    );
  }
}
