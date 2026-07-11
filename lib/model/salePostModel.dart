class SalePostModel {
  String? id;
  String? userId;
  String? userType;
  String? mobileNumber;
  String? message;
  String? price;
  List<String>? images;
  bool? isActive;
  DateTime? createdDate;
  DateTime? updatedDate;

  SalePostModel({
    this.id,
    this.userId,
    this.userType,
    this.mobileNumber,
    this.message,
    this.price,
    this.images,
    this.isActive,
    this.createdDate,
    this.updatedDate,
  });

  factory SalePostModel.fromJson(Map<String, dynamic> json) {
    List<String> images = [];

    if (json["images"] != null && json["images"].toString().isNotEmpty) {
      if (json["images"] is String) {
        images = [json["images"]];
      } else if (json["images"] is List) {
        images = List<String>.from(json["images"]);
      }
    }

    return SalePostModel(
      id: json["_id"],
      userId: json["userId"],
      userType: json["userType"],
      mobileNumber: json["mobileNumber"],
      message: json["message"],
      price: json["price"],
      images: images,
      isActive: json["isActive"],
      createdDate: json["createdDate"] != null
          ? DateTime.parse(json["createdDate"])
          : (json["createdAt"] != null
              ? DateTime.parse(json["createdAt"])
              : null),
      updatedDate: json["updatedDate"] != null
          ? DateTime.parse(json["updatedDate"])
          : (json["updatedAt"] != null
              ? DateTime.parse(json["updatedAt"])
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "userId": userId,
      "userType": userType,
      "mobileNumber": mobileNumber,
      "message": message,
      "price": price,
      "images": images,
      "isActive": isActive,
      "createdDate": createdDate?.toIso8601String(),
      "updatedDate": updatedDate?.toIso8601String(),
    };
  }
}
