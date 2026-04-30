import 'dart:convert';

class WebinarJobSeekers {
  String? id;
  String? webinarTitle;
  List<Map<String, dynamic>>? webinarDescription;
  String? orgName;
  int? webinarId;
  String? webinarImage;
  DateTime? createdDate;
  String? place;
  bool? isActive;

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

  /// ✅ Make it static
  static List<Map<String, dynamic>> parseJobDescription(dynamic data) {
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

  factory WebinarJobSeekers.fromJson(Map<String, dynamic> json) {
    return WebinarJobSeekers(
      id: json["_id"],
      webinarTitle: json["webinarTitle"],
      webinarDescription:
      parseJobDescription(json["webinarDescription"]), // ✅ fixed
      orgName: json["orgName"],
      webinarId: json["webinarId"],
      webinarImage: json["webinarImage"],
      createdDate: json["createdDate"] != null
          ? DateTime.tryParse(json["createdDate"])
          : null,
      place: json["place"],
      isActive: json["isActive"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "webinarTitle": webinarTitle,
      "webinarDescription": webinarDescription,
      "orgName": orgName,
      "webinarId": webinarId,
      "webinarImage": webinarImage,
      "createdDate": createdDate?.toIso8601String(),
      "place": place,
      "isActive": isActive,
    };
  }
}