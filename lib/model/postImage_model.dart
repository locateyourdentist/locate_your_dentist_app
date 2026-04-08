class PostImagePlan {
  final String id;
  final String? postImagesPlanId;
  final String? postImagesPlanUserId;
  final String? postPlanName;
  final String userType;
  final String price;
  final List<String>? features;
  final Map<String, dynamic>? details;
  final String duration;
  final bool isActive;
  final DateTime createdDate;
  final DateTime updatedDate;

  PostImagePlan({
    required this.id,
    this.postImagesPlanId,
    this.postImagesPlanUserId,
    this.postPlanName,
    required this.userType,
    required this.price,
     this.features,
     this.details,
    required this.duration,
    required this.isActive,
    required this.createdDate,
    required this.updatedDate,
  });

  factory PostImagePlan.fromJson(Map<String, dynamic> json) {
    return PostImagePlan(
      id: json['_id'] ?? '',
      postImagesPlanId: json['postImagesPlanId'],
      postImagesPlanUserId:json['postImagesPlanUserId'],
      postPlanName:json['postPlanName'],
      userType: json['userType'] ?? '',
      price: json['price'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      details: json['details'] ?? {},
      duration: json['duration'] ?? '',
      isActive: json['isActive'] ?? false,
      createdDate: DateTime.parse(json['createdDate']),
      updatedDate: DateTime.parse(json['updatedDate']),
    );
  }
}
