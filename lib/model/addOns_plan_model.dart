class AddOnsPlanModel {
  String? addOnsPlanId;
  String? addOnsPlanName;
  String? price;
  List<String>? features;
  AddOnsDetails? details;
  String? duration;
  String? userType;
  bool? isActive;
  String? id;
  DateTime? createdDate;
  DateTime? updatedDate;
  int? v;

  AddOnsPlanModel({
    this.addOnsPlanId,
    this.addOnsPlanName,
    this.price,
    this.features,
    this.details,
    this.duration,
    this.userType,
    this.isActive,
    this.id,
    this.createdDate,
    this.updatedDate,
    this.v,
  });

  factory AddOnsPlanModel.fromJson(Map<String, dynamic> json) =>
      AddOnsPlanModel(
        addOnsPlanId: json["addOnsPlanId"],
        addOnsPlanName: json["addOnsPlanName"],
        price: json["price"],
        features: json["features"] == null
            ? []
            : List<String>.from(json["features"].map((x) => x)),
        details: json["details"] == null
            ? null
            : AddOnsDetails.fromJson(json["details"]),
        duration: json["duration"],
        userType: json["userType"],
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
    "addOnsPlanId": addOnsPlanId,
    "addOnsPlanName": addOnsPlanName,
    "price": price,
    "features": features == null
        ? []
        : List<dynamic>.from(features!.map((x) => x)),
    "details": details?.toJson(),
    "userType":userType,
    "duration": duration,
    "isActive": isActive,
    "_id": id,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
    "__v": v,
  };
}

class AddOnsDetails {
  bool? state;
  bool? district;
  bool? city;
  bool? area;
  bool? markPrice;

  AddOnsDetails({
    this.state,
    this.district,
    this.city,
    this.area,
    this.markPrice
  });

  factory AddOnsDetails.fromJson(Map<String, dynamic> json) => AddOnsDetails(
    state: json["state"],
    district: json["district"],
    city: json["city"],
    area: json["area"],
    markPrice: json['markPrice']
  );

  Map<String, dynamic> toJson() => {
    "state": state,
    "district": district,
    "city": city,
    "area": area,
    "markPrice":markPrice
  };
}
