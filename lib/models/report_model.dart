class ReportModel {
  final String id;
  final String path;
  final String title;
  final String? image;

  const ReportModel({
    required this.id,
    required this.path,
    required this.title,
    this.image,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? '',
      path: json['path'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['image'] as String?,
    );
  }
}
