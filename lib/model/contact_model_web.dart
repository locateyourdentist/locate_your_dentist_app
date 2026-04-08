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

  // Optional: Convert to JSON for sending to API
  Map<String, dynamic> toJson() => {
    "userId": userId,
    "name": name.text,
    "state": state.text,
    "mobile": mobile.text,
    "whatsapp": whatsapp.text,
    "email": email.text,
  };
}