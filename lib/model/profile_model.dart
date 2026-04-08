import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';

class ProfileModel {
  final String id;
  final String userId;
  final String name;
  final String password;
  final String martialStatus;
  final String? dob;
  final String userType;
  final String mobileNumber;
  final String email;
  final String location;
  final List<String> images;
  final List<String> logoImages;
  final List<String> certificates;
  final Map<String, dynamic> address;
  final Map<String, dynamic> details;
  final bool isActive;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  List<ExperienceFieldModel> experienceDetails = [];

  ProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.password,
    required this.martialStatus,
    required this.dob,
    required this.userType,
    required this.mobileNumber,
    required this.email,
    required this.location,
    required this.images,
    required this.logoImages,
    required this.certificates,
    required this.address,
    required this.details,
    required this.isActive,
    this.createdDate,
    this.updatedDate,    this.experienceDetails = const [],

  });
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
   // final detailsMap = Map<String, dynamic>.from(json['details'] ?? {});
    final detailsMap = Map<String, dynamic>.from(json['details'] ?? {});

    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String && value.isNotEmpty) return [value];
      return [];
    }

    return ProfileModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      martialStatus: json['martialStatus']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      userType: json['userType']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      images: parseStringList(json['image']),
      logoImages: parseStringList(json['logoImages']),
      certificates: parseStringList(json['certificates']),
      address: (json['address'] ?? {}) as Map<String, dynamic>,
      details: detailsMap,
      isActive: json['isActive'] ?? false,
      createdDate: json['createdDate'] != null ? DateTime.tryParse(json['createdDate']) : null,
      updatedDate: json['updatedDate'] != null ? DateTime.tryParse(json['updatedDate']) : null,

      experienceDetails: (detailsMap['experienceDetails'] as List<dynamic>? ?? [])
          .map((e) => ExperienceFieldModel.fromJson(e))
          .toList(),
    );
  }

}


// {
// "details": {
// "collegeDetails": {
// "ugDegree": {
// "name": "abc college",
// "degree": "B.D.S",
// "percentage": ""
// },
// "pgDegree": {
// "name": "abc college",
// "degree": "B.D.S",
// "percentage": ""
// }
// },
// "experienceDetails": [
// {
// "companyName": "smile dental",
// "experience": "4 years",
// "jobDescription": "dSAD dffsd dfsdf s dfsd"
// },
// {
// "companyName": "happy dental clinic",
// "experience": "2 years",
// "jobDescription": "Performed dental procedures and patient care"
// }
// ]
// }
// }
