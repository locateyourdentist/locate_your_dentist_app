// import 'dart:convert';
// class Company {
//   final String companyName;
//   final String gstin;
//   final String address;
//   final String email;
//   final String phone;
//
//   Company({required this.companyName, required this.gstin, required this.address, required this.email, required this.phone});
//
//   factory Company.fromJson(Map<String, dynamic> json) {
//     final addr = json['address'];
//     final fullAddress = "${addr['line1']}, ${addr['line2']}, ${addr['city']} - ${addr['pincode']}";
//     return Company(
//       companyName: json['companyName'],
//       gstin: json['gstin'],
//       address: fullAddress,
//       email: json['email'],
//       phone: json['phone'],
//     );
//   }
// }
//
// class TaxSummary {
//   final double baseAmount;
//   final double cgst;
//   final double sgst;
//   final double igst;
//   final double cgstPercentage;
//   final double sgstPercentage;
//   final double igstPercentage;
//   final double totalAmount;
//
//   TaxSummary(
//       {required this.baseAmount, required this.cgst, required this.sgst, required this.igst, required this.cgstPercentage, required this.sgstPercentage, required this.igstPercentage, required this.totalAmount});
//
//   factory TaxSummary.fromJson(Map<String, dynamic> json) {
//     return TaxSummary(
//       baseAmount: json['baseAmount']?.toDouble() ?? 0,
//       cgst: json['cgst']?['amount']?.toDouble() ?? 0,
//       sgst: json['sgst']?['amount']?.toDouble() ?? 0,
//       igst: json['igst']?['amount']?.toDouble() ?? 0,
//       cgstPercentage: json['cgstPercentage']?['amount']?.toDouble() ?? 0,
//       sgstPercentage: json['sgstPercentage']?['amount']?.toDouble() ?? 0,
//       igstPercentage: json['igstPercentage']?['amount']?.toDouble() ?? 0,
//       totalAmount: json['finalAmount']?.toDouble() ?? 0,
//     );
//   }
// }
//
// class InvoiceModel {
//   final String id;
//   final String userId;
//   final String planId;
//   final String planName;
//   final double amount;
//   final String invoiceId;
//   final TaxSummary taxSummary;
//   final Company company;
//   final DateTime createdAt;
//
//   InvoiceModel({
//     required this.id,
//     required this.userId,
//     required this.planId,
//     required this.planName,
//     required this.amount,
//     required this.invoiceId,
//     required this.taxSummary,
//     required this.company,
//     required this.createdAt,
//   });
//
//   factory InvoiceModel.fromJson(Map<String, dynamic> json) {
//     // Handle _id being either a map with $oid or a string
//     String idValue = "";
//     if (json['_id'] is Map && json['_id']['\$oid'] != null) {
//       idValue = json['_id']['\$oid'];
//     } else if (json['_id'] is String) {
//       idValue = json['_id'];
//     }
//
//     return InvoiceModel(
//       id: idValue,
//       userId: json['userId'] ?? "",
//       planId: json['planId'] ?? "",
//       planName: json['planName'] ?? "",
//       amount: (json['amount'] ?? 0).toDouble(),
//       invoiceId: json['invoiceId'] ?? "",
//       taxSummary: TaxSummary.fromJson(json['taxSummary'] ?? {}),
//       company: Company.fromJson(json['company'] ?? {}),
//       createdAt: DateTime.tryParse(json['createdAt'] is Map
//           ? json['createdAt']['\$date'] ?? DateTime.now().toIso8601String()
//           : json['createdAt'].toString()) ??
//           DateTime.now(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     '_id': {'\$oid': id},
//     'userId': userId,
//     'planId': planId,
//     'planName': planName,
//     'amount': amount,
//     'invoiceId': invoiceId,
//     'taxSummary': taxSummary,
//     'company': company,
//     'createdAt': {'\$date': createdAt.toIso8601String()},
//   };
// }
import 'dart:convert';

class Company {
  final String companyName;
  final String gstin;
  final String address;
  final String email;
  final String phone;

  Company({
    required this.companyName,
    required this.gstin,
    required this.address,
    required this.email,
    required this.phone,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    // Address is flat in API, no nested line1/line2
    return Company(
      companyName: json['companyName'] ?? "",
      gstin: json['gstin'] ?? "",
      address: json['address'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'gstin': gstin,
    'address': address,
    'email': email,
    'phone': phone,
  };
}

class TaxSummary {
  final double baseAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double cgstPercentage;
  final double sgstPercentage;
  final double igstPercentage;
  final double totalAmount;

  TaxSummary(
      {required this.baseAmount, required this.cgst, required this.sgst, required this.igst, required this.cgstPercentage, required this.sgstPercentage, required this.igstPercentage, required this.totalAmount});

  factory TaxSummary.fromJson(Map<String, dynamic> json) {
    return TaxSummary(
      baseAmount: (json['baseAmount'] ?? 0).toDouble(),
      cgst: (json['cgst'] ?? 0).toDouble(),
      sgst: (json['sgst'] ?? 0).toDouble(),
      igst: (json['igst'] ?? 0).toDouble(),
      cgstPercentage: json['cgstPercentage']?['amount']?.toDouble() ?? 0,
      sgstPercentage: json['sgstPercentage']?['amount']?.toDouble() ?? 0,
      igstPercentage: json['igstPercentage']?['amount']?.toDouble() ?? 0,
      totalAmount: json['totalAmount']?.toDouble() ?? 0,
    );
  }
}

class InvoiceModel {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final String planType;
  final String startDate;
  final String endDate;
  final double amount;
  final String invoiceId;
  final TaxSummary taxSummary;
  final Company company;
  final DateTime createdAt;

  InvoiceModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.planType,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.invoiceId,
    required this.taxSummary,
    required this.company,
    required this.createdAt,
  });
  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    String idValue = "";
    if (json['_id'] is Map && json['_id']['\$oid'] != null) {
      idValue = json['_id']['\$oid'];
    } else if (json['_id'] is String) {
      idValue = json['_id'];
    }
    return InvoiceModel(
      id: idValue,
      userId: json['userId'] ?? "",
      planId: json['planId'] ?? "",
      planName: json['planName'] ?? "",
      planType: json['planType'] ?? "",
      startDate: json['startDate'] ?? "",
      endDate: json['endDate'] ?? "",
      amount: (json['amount'] ?? 0).toDouble(),
      invoiceId: json['invoiceId'] ?? "",
      taxSummary: TaxSummary.fromJson(json['taxSummary'] ?? {}),
      company: Company.fromJson(json['company'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'planId': planId,
    'planName': planName,
    'planType': planType,
    'startDate': startDate,
    'endDate': endDate,
    'amount': amount,
    'invoiceId': invoiceId,
    'taxSummary': taxSummary,
    'company': company.toJson(),
    'createdAt': createdAt.toIso8601String(),
  };
}