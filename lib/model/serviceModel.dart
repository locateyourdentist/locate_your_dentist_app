class ServiceModel {
  String? id;
  int? serviceId;
  String? serviceTitle;
  String? serviceDescription;
  String? serviceCost;
  String? userType;
  List<String>? image;
  String? userId;
  bool? isActive;
  DateTime? createdDate;
  DateTime? updatedDate;

  ServiceModel({
    this.id,
    this.serviceId,
    this.serviceTitle,
    this.serviceDescription,
    this.serviceCost,
    this.userType,
    this.image,
    this.userId,
    this.isActive,
    this.createdDate,
    this.updatedDate,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    List<String> image = [];

    if (json["image"] != null && json["image"].toString().isNotEmpty) {
      if (json["image"] is String) {
        image = [json["image"]];
      } else if (json["image"] is List) {
        image = List<String>.from(json["image"]);
      }
    }

    return ServiceModel(
      id: json["_id"],
      serviceId: json["serviceId"],
      serviceTitle: json["serviceTitle"],
      serviceDescription: json["serviceDescription"],
      serviceCost: json["serviceCost"],
      userType: json["userType"],
      image: image,
      userId: json["userId"],
      isActive: json["isActive"],
      createdDate: json["createdDate"] != null
          ? DateTime.parse(json["createdDate"])
          : null,
      updatedDate: json["updatedDate"] != null
          ? DateTime.parse(json["updatedDate"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "serviceId": serviceId,
      "serviceTitle": serviceTitle,
      "serviceDescription": serviceDescription,
      "serviceCost": serviceCost,
      "userType": userType,
      "image": image,
      "userId": userId,
      "isActive": isActive,
      "createdDate": createdDate?.toIso8601String(),
      "updatedDate": updatedDate?.toIso8601String(),
    };
  }
}
