import 'package:flutter/material.dart';

class ContactModel {
  String userId;
  TextEditingController name;
  TextEditingController state;
  TextEditingController mobile;
  TextEditingController whatsapp;
  TextEditingController email;

  ContactModel({
    required this.userId,
    required this.name,
    required this.state,
    required this.mobile,
    required this.whatsapp,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "name": name.text,
    "state": state.text,
    "mobile": mobile.text,
    "whatsapp": whatsapp.text,
    "email": email.text,
  };
}

class ContactApiModel {
  final String name;
  final String state;
  final String mobileNumber;
  final String whatsapp;
  final String email;

  ContactApiModel({
    required this.name,
    required this.state,
    required this.mobileNumber,
    required this.whatsapp,
    required this.email,
  });

  factory ContactApiModel.fromJson(Map<String, dynamic> json) {
    return ContactApiModel(
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      email: json['email'] ?? '',
    );
  }
}