import 'dart:convert';

class WebinarModel {
  String? id;
  String? webinarTitle;
  //String? webinarDescription;
  List<Map<String, dynamic>>? webinarDescription;
  String? orgName;
  String? createdDate;
  String? updatedDate;
  int? webinarId;
  List<String>? webinarImage;
  bool? isActive;
  String? place;
  String? webinarDate;
  String? startTime;
  String? endTime;
  String? webinarLink;
  String? description;
  String? userId;
  String? userType;
  String? image;
  String? name;
  String? email;
  String? mobileNumber;
  String? jobSeekerId;
  int? totalApplicants;

  WebinarModel({
    this.id,
    this.webinarTitle,
    this.webinarDescription,
    this.orgName,
    this.createdDate,
    this.updatedDate,
    this.webinarId,
    this.webinarImage,
    this.isActive,
    this.place,
    this.webinarDate,
    this.startTime,
    this.endTime,
    this.webinarLink,
    this.description,
    this.userId,
    this.userType,
    this.image,
    this.name,
    this.email,
    this.mobileNumber,
    this.jobSeekerId,
    this.totalApplicants
  });
  factory WebinarModel.fromJson(Map<String, dynamic> json) {
    List<String> images = [];

    if (json["webinarImage"] != null) {
      if (json["webinarImage"] is String) {
        images = [json["webinarImage"]];
      } else if (json["webinarImage"] is List) {
        images = List<String>.from(json["webinarImage"]);
      }
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
    return WebinarModel(
      id: json["_id"],
      webinarTitle: json["webinarTitle"],
      webinarDescription: parseJobDescription(json["webinarDescription"]),
      orgName: json["orgName"],
      createdDate: json["createdDate"],
      updatedDate: json["updatedDate"],
      webinarId: json["webinarId"] == null ? null : int.tryParse(
          json["webinarId"].toString()),
      webinarImage: images,
      isActive: json["isActive"],
      place: json["place"],
      webinarDate: json["webinarDate"],
      startTime: json["startTime"],
      endTime: json["endTime"],
      webinarLink: json["webinarLink"],
      description: json["description"],
      userId: json["userId"],
      userType: json["userType"],
      image: json["image"],
      name: json["name"],
      email: json["email"],
      mobileNumber: json["mobileNumber"],
      jobSeekerId: json["jobSeekerId"],
        totalApplicants: json["totalApplicants"]
    );
  }
}