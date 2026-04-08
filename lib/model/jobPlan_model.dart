class JobPlanModel {
  String? jobPlansId;
  String? jobPlanName;
  String? userType;
  String? price;
  Count? count;
  List<String>? features;
  JobPlanDetails? details;
  String? duration;
  bool? isActive;
  String? id;
  DateTime? createdDate;
  DateTime? updatedDate;
  int? v;

  JobPlanModel({
    this.jobPlansId,
    this.jobPlanName,
    this.userType,
    this.price,
    this.count,
    this.features,
    this.details,
    this.duration,
    this.isActive,
    this.id,
    this.createdDate,
    this.updatedDate,
    this.v,
  });

  factory JobPlanModel.fromJson(Map<String, dynamic> json) => JobPlanModel(
    jobPlansId: json["jobPlansId"],
    jobPlanName: json["jobPlanName"],
    userType: json["userType"],
    price: json["price"],
    count: json["count"] == null ? null : Count.fromJson(json["count"]),
    features: json["features"] == null
        ? []
        : List<String>.from(json["features"].map((x) => x)),
    details:
    json["details"] == null ? null : JobPlanDetails.fromJson(json["details"]),
    duration: json["duration"],
    isActive: json["isActive"],
    id: json["_id"],
    createdDate: json["createdDate"] == null
        ? null
        : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null
        ? null
        : DateTime.parse(json["updatedDate"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "jobPlansId": jobPlansId,
    "jobPlanName": jobPlanName,
    "userType":userType,
    "price": price,
    "count": count?.toJson(),
    "features": features == null
        ? []
        : List<dynamic>.from(features!.map((x) => x)),
    "details": details?.toJson(),
    "duration": duration,
    "isActive": isActive,
    "_id": id,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
    "__v": v,
  };
}

class Count {
  String? jobs;
  String? webinars;

  Count({this.jobs, this.webinars});

  factory Count.fromJson(Map<String, dynamic> json) => Count(
    jobs: json["jobs"],
    webinars: json["webinars"],
  );

  Map<String, dynamic> toJson() => {
    "jobs": jobs,
    "webinars": webinars,
  };
}

class JobPlanDetails {
  bool? state;
  bool? district;
  bool? city;
  bool? area;
  String? markPrice;

  JobPlanDetails({
    this.state,
    this.district,
    this.city,
    this.area,
    this.markPrice
  });

  factory JobPlanDetails.fromJson(Map<String, dynamic> json) => JobPlanDetails(
    state: json["state"],
    district: json["district"],
    city: json["city"],
    area: json["area"],
      markPrice:json["markPrice"]
  );

  Map<String, dynamic> toJson() => {
    "state": state,
    "district": district,
    "city": city,
    "area": area,
    "markPrice":markPrice
  };
}
