class PublicContactModel {
  String? name;
  String? email;
  String? mobile;
  String? message;

  PublicContactModel({
    this.name,
    this.email,
    this.mobile,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "mobile": mobile,
      "message": message,
    };
  }
}