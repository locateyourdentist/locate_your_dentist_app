class PlanModel {
  String? id;
  int? planId;
  String? userType;
  String? planName;
  String? price;
  Details? details;
  List<String>? features;
  String? duration;
  bool? isActive;
  DateTime? createdDate;
  DateTime? updatedDate;
  int? v;

  PlanModel({
    this.id,
    this.planId,
    this.userType,
    this.planName,
    this.price,
    this.details,
    this.features,
    this.duration,
    this.isActive,
    this.createdDate,
    this.updatedDate,
    this.v,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
    id: json["_id"],
    planId: json["planId"],
    userType: json["userType"],
    planName: json["planName"],
    price: json["price"],
    details: json["details"] == null ? null : Details.fromJson(json["details"]),
    features: json["features"] is List
        ? List<String>.from(json["features"])
        : [],
    duration: json["duration"],
    isActive: json["isActive"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "planId": planId,
    "userType":userType,
    "planName": planName,
    "price": price,
    "details": details?.toJson(),
    "features": features ?? [],
    "duration": duration,
    "isActive": isActive,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
    "__v": v,
  };
}

class Details {
  bool? images;
  bool? location;
  bool? jobs;
  bool? mobileNumber;
  bool? services;
  bool? video;
  String?imageCount;
  String? imageSize;
  String? videoCount;
  String? videoSize;
  String? markPrice;
  Details({
    this.images,
    this.location,
    this.jobs,
    this.mobileNumber,
    this.services,
    this.video,
    this.imageCount,
    this.imageSize,
    this.videoCount,
    this.videoSize,
    this.markPrice
  });

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    images: json["images"],
    location: json["location"],
    jobs: json["jobs"],
    mobileNumber:json["mobileNumber"],
    services: json["services"],
    video: json["video"],
    imageCount: json["imageCount"],
    imageSize: json["imageSize"],
    videoCount: json["videoCount"],
    videoSize: json["videoSize"],
      markPrice:json["markPrice"]
  );

  Map<String, dynamic> toJson() => {
    "images": images,
    "location": location,
       "jobs": jobs,
    "mobileNumber":mobileNumber,
    "services":services,
    "video": video,
    "imageCount":imageCount,
    "imageSize": imageSize,
    "videoCount": videoCount,
    "videoSize": videoSize,


  };
}
