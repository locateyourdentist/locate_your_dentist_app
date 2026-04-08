class NotificationModel {
  String? id;
  String? userId;
  String? userType;
  String? title;
  String? message;
  List<String>? notificationImage;
  String? state;
  String? district;
  String? city;
  String? area;
  String? read;
  bool? isActive;
  DateTime? createdDate;
  DateTime? updatedDate;
  int? v;

  NotificationModel({
    this.id,
    this.userId,
    this.userType,
    this.title,
    this.message,
    this.notificationImage,
    this.state,
    this.district,
    this.city,
    this.area,
    this.read,
    this.isActive,
    this.createdDate,
    this.updatedDate,
    this.v,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    List<String> images = [];

    if (json["notificationImage"] != null) {
      if (json["notificationImage"] is String) {
        images = [json["notificationImage"]];
      } else if (json["notificationImage"] is List) {
        images = List<String>.from(json["notificationImage"]);
      }
    }

    return NotificationModel(
      id: json["_id"],
      userId: json["userId"],
      userType: json["userType"],
      title: json["title"],
      message: json["message"],
      notificationImage: images,
      state: json["state"],
      district: json["district"],
      city: json["city"],
      area: json["area"],
      read: json["read"],
      isActive: json["isActive"],
      createdDate: json["createdDate"] == null
          ? null
          : DateTime.parse(json["createdDate"]),
      updatedDate: json["updatedDate"] == null
          ? null
          : DateTime.parse(json["updatedDate"]),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "userType": userType,
    "title": title,
    "message": message,
    "notificationImage": notificationImage,
    "state": state,
    "district": district,
    "city": city,
    "area": area,
    "read": read,
    "isActive": isActive,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
    "__v": v,
  };
}
