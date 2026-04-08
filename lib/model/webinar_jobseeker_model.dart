class WebinarJobSeekers {
  String? id;
  String? webinarTitle;
  String? webinarDescription;
  String? orgName;
  int? webinarId;
  String? webinarImage;
  DateTime? createdDate;
  String? place;
  final bool? isActive;

  WebinarJobSeekers({
    this.id,
    this.webinarTitle,
    this.webinarDescription,
    this.orgName,
    this.webinarId,
    this.webinarImage,
    this.createdDate,
    this.place,
    this.isActive,
  });

  factory WebinarJobSeekers.fromJson(Map<String, dynamic> json) => WebinarJobSeekers(
    id: json["_id"],
    webinarTitle: json["webinarTitle"],
    webinarDescription: json["webinarDescription"],
    orgName: json["orgName"],
    webinarId: json["webinarId"],
    webinarImage: json["webinarImage"],
    createdDate: json["createdDate"] != null
        ? DateTime.parse(json["createdDate"])
        : null,
    place: json["place"],
    isActive: json["isActive"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "webinarTitle": webinarTitle,
    "webinarDescription": webinarDescription,
    "orgName": orgName,
    "webinarId": webinarId,
    "webinarImage": webinarImage,
    "createdDate": createdDate?.toIso8601String(),
    "place": place,
    "isActive":isActive
  };
}