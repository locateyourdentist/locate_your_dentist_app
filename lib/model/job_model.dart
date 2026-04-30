

import 'dart:convert';

class JobModel {
  String? id;
  String? jobTitle;
  List<Map<String, dynamic>>? jobDescription;
  //String? jobDescription;
  String? companyDescription;
  String? jobType;
  Map<String, dynamic>? details;
  List<String>? jobImage;
  List<String>? jobCategory;
  DateTime? createdDate;
  DateTime? updatedDate;
  String? jobId;
  String? userId;
  String? salary;
  String? orgName;
  String? experience;
  String? qualification;
  String? userType;
  String? state;
  String? district;
  String? city;
  String? image;
  List<String>? logoImage;
  String? status;
  bool? isActive;
  int? v;
  int? totalApplicants;

  JobModel({
    this.id,
    this.jobTitle,
    this.jobDescription,
    this.companyDescription,
    this.jobType,
    this.details,
    this.jobImage,
    this.jobCategory,
    this.createdDate,
    this.updatedDate,
    this.jobId,
    this.userId,
    this.salary,
    this.orgName,
    this.experience,
    this.qualification,
    this.userType,
    this.state,
    this.district,
    this.city,
    this.image,
    this.logoImage,
    this.status,
    this.isActive,
    this.v,
    this.totalApplicants,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // List<String> parseToList(dynamic data) {
    //   if (data == null) return [];
    //   if (data is List) return data.map((e) => e.toString()).toList();
    //   return [data.toString()];
    // }
    List<String> parseToList(dynamic data) {
      if (data == null) return [];

      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }

      if (data is String) {
        try {
          if (data.startsWith("[")) {
            final decoded = jsonDecode(data);
            if (decoded is List) {
              return decoded.map((e) => e.toString()).toList();
            }
          }
          return [data];
        } catch (_) {
          return [data];
        }
      }

      return [data.toString()];
    }
    List<Map<String, dynamic>> parseJobDescription(dynamic data) {
      try {
        if (data == null) return [];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        if (data is String) {
          try {
            final decoded = jsonDecode(data);

            if (decoded is List) {
              return List<Map<String, dynamic>>.from(decoded);
            }
          } catch (_) {}
          return [
            {"insert": data}
          ];
        }
        return [
          {"insert": data.toString()}
        ];
      } catch (e) {
        return [];
      }
    }
    return JobModel(
      id: json["_id"]?.toString(),
      jobTitle: json["jobTitle"]?.toString(),
      jobDescription: parseJobDescription(json['jobDescription']),
      // jobDescription: json['jobDescription'] != null
      //     ? List<Map<String, dynamic>>.from(json['jobDescription'])
      //     : [],
      //jobDescription: json["jobDescription"]?.toString(),
      companyDescription: json["companyDescription"]?.toString(),
      jobType: json["jobType"]?.toString(),
      details: json["details"] != null ? Map<String, dynamic>.from(json["details"]) : null,
      jobImage: parseToList(json["jobImage"]),
     // jobCategory: parseToList(json["jobCategory"]),
     //  jobCategory: json['jobCategory'] != null
     //      ? List<String>.from(
     //      (json['jobCategory'] as List).map((e) => e.toString()))
     //      : [],
      jobCategory: parseToList(json["jobCategory"]),
      createdDate: json["createdDate"] != null ? DateTime.tryParse(json["createdDate"].toString()) : null,
      updatedDate: json["updatedDate"] != null ? DateTime.tryParse(json["updatedDate"].toString()) : null,
      jobId: json["jobId"]?.toString(),
      userId: json["userId"]?.toString(),
      salary: json["salary"]?.toString(),
      orgName: json["orgName"]?.toString(),
      experience: json["experience"]?.toString(),
      qualification: json["qualification"]?.toString(),
      userType: json["userType"]?.toString(),
      state: json["state"]?.toString(),
      district: json["district"]?.toString(),
      city: json["city"]?.toString(),
      image: json["image"]?.toString(),
      logoImage: parseToList(json["logoImage"]),
      status: json["status"]?.toString(),
      isActive: json["isActive"] as bool?,
      v: json["__v"] as int?,
      totalApplicants: json["totalApplicants"] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "jobTitle": jobTitle,
      "jobDescription": jobDescription,
      "companyDescription": companyDescription,
      "jobType": jobType,
      "details": details,
      "jobImage": jobImage,
      "jobCategory": jobCategory,
      "createdDate": createdDate?.toIso8601String(),
      "updatedDate": updatedDate?.toIso8601String(),
      "jobId": jobId,
      "userId": userId,
      "salary": salary,
      "orgName": orgName,
      "experience": experience,
      "qualification": qualification,
      "userType": userType,
      "state": state,
      "district": district,
      "city": city,
      "image": image,
      "logoImage": logoImage,
      "status": status,
      "isActive": isActive,
      "__v": v,
      "totalApplicants": totalApplicants,
    };
  }
}