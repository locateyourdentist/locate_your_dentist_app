class WebinarPlan {
  final String id;
  final String webinarPlanId;
  final String ?webinarPlanUserId;
  final String userType;
  final String webinarPlanName;
  final String price;
  final Map<String, dynamic> details;
  final String duration;
  final bool isActive;
  final DateTime createdDate;
  final DateTime updatedDate;

  WebinarPlan({
    required this.id,
    required this.webinarPlanId,
     this.webinarPlanUserId,
    required this.userType,
    required this.webinarPlanName,
    required this.price,
    required this.details,
    required this.duration,
    required this.isActive,
    required this.createdDate,
    required this.updatedDate,
  });

  factory WebinarPlan.fromJson(Map<String, dynamic> json) {
    return WebinarPlan(
      id: json['_id'] ?? '',
      webinarPlanId: json['webinarPlanId'] ?? '',
      webinarPlanUserId:json['webinarPlanUserId'] ?? '',
      userType: json['userType'] ?? '',
      webinarPlanName: json['webinarPlanName'] ?? '',
      price: json['price'] ?? '',
      details: json['details'] ?? {},
      duration: json['duration'] ?? '',
      isActive: json['isActive'] ?? false,
      createdDate: DateTime.parse(json['createdDate']),
      updatedDate: DateTime.parse(json['updatedDate']),
    );
  }
}
