class JobSeekerAppliedModel {
  final String id;
  final int jobId;
  final String jobSeekerId;
  final bool isViewed;
  final bool isApplied;
  final bool isActive;
  final String createdDate;
  final String updatedDate;
  final String email;
  final String mobileNumber;
  final String name;
  final String image;
  final String status;
  final String totalApplicants;

  JobSeekerAppliedModel({
    required this.id,
    required this.jobId,
    required this.jobSeekerId,
    required this.isViewed,
    required this.isApplied,
    required this.isActive,
    required this.createdDate,
    required this.updatedDate,
    required this.email,
    required this.mobileNumber,
    required this.name,
    required this.image,
    required this.status,
    required this.totalApplicants
  });

  factory JobSeekerAppliedModel.fromJson(Map<String, dynamic> json) {
    return JobSeekerAppliedModel(
      id: json["_id"] ?? "",
      jobId: json["jobId"] ?? 0,
      jobSeekerId: json["jobSeekerId"] ?? "",
      isViewed: json["isViewed"] ?? false,
      isApplied: json["isApplied"] ?? false,
      isActive: json["isActive"] ?? false,
      createdDate: json["createdDate"] ?? "",
      updatedDate: json["updatedDate"] ?? "",
      email: json["email"] ?? "",
      mobileNumber: json["mobileNumber"] ?? "",
      name: json["name"] ?? "",
      image: json["image"] ?? "",
      status: json["status"] ?? "",
        totalApplicants:json["totalApplicants"]??""
    );
  }
}
