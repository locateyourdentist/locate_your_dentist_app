class JobCategoryModel {
  final String id;
  final String name;
  final String userType;

  JobCategoryModel({
    required this.id,
    required this.name,
    required this.userType,
  });

  factory JobCategoryModel.fromJson(Map<String, dynamic> json) {
    return JobCategoryModel(
      id: json['_id'],
      name: json['name'],
      userType: json['userType'],
    );
  }
}
