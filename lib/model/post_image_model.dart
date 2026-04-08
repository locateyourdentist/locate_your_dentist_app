class PosterImageModel {
  String? id;
  String? userId;
  String? path;
  int? preference;
  bool? isActive;
  String? startDate;
  String? endDate;
  DateTime? uploadedAt;

  PosterImageModel({
    this.id,
    this.userId,
    this.path,
    this.preference,
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.uploadedAt,
  });

  factory PosterImageModel.fromJson(Map<String, dynamic> json) {
    return PosterImageModel(
      id: json['_id'],
      userId: json['userId'],
      path: json['path'],
      preference: json['preference'],
      isActive: json['isActive'] ?? true,
      startDate: json['startDate'],
      endDate: json['endDate'],
      uploadedAt:
      json['uploadedAt'] != null ? DateTime.parse(json['uploadedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'path': path,
      'preference': preference,
      'isActive': isActive,
      'startDate': startDate,
      'endDate': endDate,
      'uploadedAt': uploadedAt?.toIso8601String(),
    };
  }
}
