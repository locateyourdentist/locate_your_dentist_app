class PublicContactModel {
  String? id;
  String? name;
  String? email;
  String? mobile;
  String? message;
  DateTime? createdAt;

  PublicContactModel({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.message,
    this.createdAt,
  });

  factory PublicContactModel.fromJson(Map<String, dynamic> json) {
    return PublicContactModel(
      id: json['_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'message': message,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}