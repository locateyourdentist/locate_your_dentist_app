class ContactModel {
  String? id;
  String? userId;
  String? userType;
  String? senderUserId;
  String? orgName;
  String? Name;
  String? email;
  String? mobileNumber;
  String? materialDescription;
  String? status;
  String? address;
  Map<String, dynamic>? clinicAddress;
  List<String>? contactImage;
  DateTime? createdAt;

  ContactModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    userType = json['userType'];
    orgName = json['orgName'];
    Name = json['name'];
    email = json['email'];
    mobileNumber = json['mobileNumber'];
    materialDescription = json['materialDescription'];
    address = json['address'];
    status = json['status'];
    clinicAddress = json['clinicAddress'];
    contactImage = List<String>.from(json['contactImage'] ?? []);
    createdAt = DateTime.tryParse(json['createdAt'] ?? '');
  }
}
