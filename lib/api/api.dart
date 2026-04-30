import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart'as http;
import 'package:get_storage/get_storage.dart';
import 'package:locate_your_dentist/model/company_invoice_model.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Api {
  static final userInfo = GetStorage();

  // Future<List<dynamic>> getStates() async {
  //   try {
  //     final headers = {
  //       "X-CSCAPI-KEY": AppConstants.stateCityApiKey,
  //     };
  //
  //     final uri = Uri.parse(
  //       "https://api.countrystatecity.in/v1/countries/IN/states",
  //     );
  //
  //     final response = await http.get(uri, headers: {  "X-CSCAPI-KEY": AppConstants.stateCityApiKey,});
  //
  //     print("STATUS CODE: ${response.statusCode}");
  //     print("BODY: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body) as List<dynamic>;
  //     } else {
  //       throw Exception("API error ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("API ERROR: $e");
  //     rethrow;
  //   }
  // }
  //
  //
  // Future<List<dynamic>> getCities(String stateCode) async {
  //   try {
  //     final headers = {
  //       "X-CSCAPI-KEY": AppConstants.stateCityApiKey,
  //     };
  //
  //     final uri = Uri.parse(
  //       "https://api.countrystatecity.in/v1/countries/IN/states/$stateCode/cities",
  //     );
  //
  //     final response = await http.get(uri, headers: headers);
  //
  //     print("CITY API STATUS: ${response.statusCode}");
  //     print("CITY API BODY: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body) as List<dynamic>;
  //     } else {
  //       throw Exception(
  //         "City API failed ${response.statusCode}: ${response.body}",
  //       );
  //     }
  //   } catch (e) {
  //     print("CITY API ERROR: $e");
  //     rethrow;
  //   }
  // }
  Future<List<Map<String, String>>> fetchCountries() async {
    final response = await http.get(
      Uri.parse('https://api.countrystatecity.in/v1/countries'),
      headers: {'X-CSCAPI-KEY': AppConstants.stateCityApiKey,},
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data
          .map<Map<String, String>>((item) =>
      {
        'name': item['name'],
        'iso2': item['iso2'],
      })
          .toList();
    } else {
      throw Exception('Failed to load countries');
    }
  }

  Future<List<Map<String, String>>> fetchStatesForCountries(
      List<String> selectedCountryNames,
      List<Map<String, String>> countryList,) async {
    List<Map<String, String>> allStates = [];

    for (String countryName in selectedCountryNames) {
      final country = countryList.firstWhere(
            (c) => c['name'] == countryName,
        orElse: () => {},
      );
      if (country.isNotEmpty) {
        String iso2 = country['iso2']!;
        final states = await fetchStates(iso2);
        allStates.addAll(states);
      }
    }
    return allStates;
  }

  Future<List<Map<String, String>>> fetchStates(String countryCode) async {
    final response = await http.get(
      Uri.parse(
          'https://api.countrystatecity.in/v1/countries/$countryCode/states'),
      headers: {'X-CSCAPI-KEY': AppConstants.stateCityApiKey},
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data
          .map<Map<String, String>>((item) =>
      {
        'name': item['name'],
        'iso2': item['iso2'],
      })
          .toList();
    } else {
      throw Exception('Failed to load states');
    }
  }

  Future<List<String>> fetchCities(String countryCode, String stateCode) async {
    final response = await http.get(
      Uri.parse(
          'https://api.countrystatecity.in/v1/countries/$countryCode/states/$stateCode/cities'),
      headers: {'X-CSCAPI-KEY': AppConstants.stateCityApiKey},
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map<String>((item) => item['name'].toString()).toList();
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<http.Response> loginUser(String email, String password) async {
    String url = "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants
        .loginUrl}";
    print('api login url $url');
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'email': email,
          'password': password,
        },
      );
      print('api response ${response.body}');
      print('$email password$password');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw "Login failed: Unable to communicate with the server";
      }
    } catch (e) {
      throw "Login failed: $e";
    }
  }
  Future<http.Response> switchAccountLogin(String userId) async {
    String url = "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants.switchAccountUrl}";
    print('api login url $url');
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'userId': userId,
        },
      );
      print('api response ${response.body}');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw "switch Account error: Unable to communicate with the server";
      }
    } catch (e) {
      throw "switch Account error: $e";
    }
  }

  Future<http.Response> saveFcmToken(String userId, String userType,
      String fcmToken) async {
    String url = "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants.saveFcmTokenUrl}";
    print('api login url $url');
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'userId': userId,
          'userType': userType,
          'fcmToken': fcmToken
        },
      );
      print('save token ${response.body}');
      print('$userId userType$userType token$fcmToken');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw "save token failed: Unable to communicate with the server";
      }
    } catch (e) {
      throw "save token failed: $e";
    }
  }

  // Future<http.Response> registerUser(String userId, String userType,
  //     String fullName, String? martialStatus, String dob,
  //     String mobile,
  //     String email,
  //     // String address,
  //     String? confirmPassword,
  //     String taluk,
  //     String district,
  //     String city,
  //     String area,
  //     String pinCode,
  //     String? typeName, List<String>? jobCategory,
  //     // List<Uint8List>? logoImage,
  //     // List<Uint8List>? image,
  //     // List<Uint8List>? certificate,
  //     List<Uint8List>? logoImage,
  //     List<Uint8List>? image,
  //     List<Uint8List>? certificate,
  //     List<String>? oldImageUrl,
  //     List<String>? oldCertificatesUrl, List<String>? logoUrl,
  //     final Map<String, dynamic>? details, String? description,
  //     String? location, String? website, String? latitude, String? longitude,
  //     String? adminId, String? isAdmin) async {
  //   var url = Uri.parse(
  //       "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants
  //           .registerUrl}");
  //   print('url$url');
  //   var request = http.MultipartRequest('POST', url);
  //
  //   // Fields
  //   request.fields['userId'] = userId;
  //   request.fields['name'] = fullName;
  //   request.fields['dob'] = dob;
  //   //request.fields['martialStatus']=martialStatus??"";
  //   request.fields['description'] = description ?? "";
  //   request.fields['password'] = confirmPassword ?? "";
  //   request.fields['userType'] = userType;
  //   request.fields['email'] = email;
  //   request.fields['mobileNumber'] = mobile;
  //   request.fields['location'] = location ?? "";
  //   request.fields['adminId'] = adminId ?? "";
  //   request.fields['isAdmin'] = isAdmin ?? 'false';
  //   request.fields['address'] = jsonEncode({
  //     "state": taluk ?? "",
  //     "district": district ?? "",
  //     "city": city ?? "",
  //     "area": area ?? "",
  //     "pincode": pinCode ?? "",
  //     "latitude": latitude,
  //     "longitude": longitude,
  //     // "address": address??"",
  //   });
  //   request.fields['details'] = jsonEncode({
  //     "name": typeName ?? "",
  //     "description": description ?? "",
  //     "website": website ?? "",
  //     "jobCategory": jobCategory ?? "",
  //     ...?details?["details"] as Map<String, dynamic>?,
  //   });
  //   request.fields['oldImageUrl'] = jsonEncode(oldImageUrl);
  //   request.fields['oldCertificatesUrl'] = jsonEncode(oldCertificatesUrl);
  //   request.fields['logoImageUrl'] = jsonEncode(logoUrl);
  //   // request.fields['details'] = jsonEncode({
  //   //   "name": typeName??"",
  //   //    "description":description??"",
  //   //   // "services":services??"",
  //   //   "website":website??"",
  //   //   // "specialisation":specialisation??"",
  //   //    ...details!["details"]
  //   // });
  //   // if (image != null) {
  //   //   for (var img in image) {
  //   //     request.files.add(await http.MultipartFile.fromPath('image', img.path));
  //   //   }
  //   // }
  //   // if (logoImage != null) {
  //   //   for (var logo in logoImage) {
  //   //     request.files.add(
  //   //         await http.MultipartFile.fromPath('logoImage', logo.path));
  //   //   }
  //   // }
  //   // if (certificate != null) {
  //   //   for (var cert in certificate) {
  //   //     request.files.add(
  //   //         await http.MultipartFile.fromPath('certificates', cert.path));
  //   //   }
  //   // }
  //   if (image != null) {
  //     for (int i = 0; i < image.length; i++) {
  //       request.files.add(
  //         http.MultipartFile.fromBytes(
  //           'image',
  //           image[i],
  //           filename: 'image_$i.jpg', // provide a name
  //         ),
  //       );
  //     }
  //   }
  //
  //   if (logoImage != null) {
  //     for (int i = 0; i < logoImage.length; i++) {
  //       request.files.add(
  //         http.MultipartFile.fromBytes(
  //           'logoImage',
  //           logoImage[i],
  //           filename: 'logo_$i.jpg',
  //         ),
  //       );
  //     }
  //   }
  //
  //   if (certificate != null) {
  //     for (int i = 0; i < certificate.length; i++) {
  //       request.files.add(
  //         http.MultipartFile.fromBytes(
  //           'certificates',
  //           certificate[i],
  //           filename: 'cert_$i.jpg',
  //         ),
  //       );
  //     }
  //   }
  //   request.fields.forEach((key, value) {
  //     print("$key : $value");
  //   });
  //   request.files.forEach((file) {
  //     print("Field: ${file.field}, Filename: ${file.filename}, Path: ${file
  //         .filename}");
  //   });
  //   try {
  //     var streamedResponse = await request.send();
  //
  //     var response = await http.Response.fromStream(streamedResponse);
  //     print("REGISTER RESPONSE = ${response.body}");
  //
  //     if (response.statusCode != 200) {
  //       throw "Registration failed: Server returned ${response.statusCode}";
  //     }
  //
  //     return response;
  //   } catch (e) {
  //     throw "Registration failed: $e";
  //   }
  // }
  Future<http.Response> registerUser(
      String userId,
      String userType,
      String fullName,
      String? martialStatus,
      String dob,
      String mobile,
      String email,
      String? confirmPassword,
      String taluk,
      String district,
      String city,
      String area,
      String pinCode,
      String? typeName,
      List<String>? jobCategory,
      List<Uint8List>? logoImage,
      List<Uint8List>? image,
      List<Uint8List>? certificate,
      List<String>? oldImageUrl,
      List<String>? oldCertificatesUrl,
      List<String>? logoUrl,
      final Map<String, dynamic>? details,
      String? description,
      String? location,
      String? website,
      String? latitude,
      String? longitude,
      String? adminId,
      String? isAdmin,
      ) async {
    var url = Uri.parse(
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants.registerUrl}");

    var request = http.MultipartRequest('POST', url);
    request.fields['userId'] = userId;
    request.fields['name'] = fullName;
    request.fields['dob'] = dob.toString().trim();
    request.fields['description'] = description ?? "";
    request.fields['password'] = confirmPassword ?? "";
    request.fields['userType'] = userType;
    request.fields['email'] = email;
    request.fields['mobileNumber'] = mobile;
    request.fields['location'] = location ?? "";
    request.fields['adminId'] = adminId ?? "";
    request.fields['isAdmin'] = isAdmin ?? 'false';

    request.fields['address'] = jsonEncode({
      "state": taluk ?? "",
      "district": district ?? "",
      "city": city ?? "",
      "area": area ?? "",
      "pincode": pinCode ?? "",
      "latitude": latitude ?? "",
      "longitude": longitude ?? "",
    });

    request.fields['details'] = jsonEncode({
      "name": typeName ?? "",
      "description": description ?? "",
      "website": website ?? "",
      "jobCategory": jobCategory ?? [],
    });


    request.fields['oldImageUrl'] = jsonEncode(oldImageUrl ?? []);
    request.fields['oldCertificatesUrl'] = jsonEncode(oldCertificatesUrl ?? []);
    request.fields['logoImageUrl'] = jsonEncode(logoUrl ?? []);


    if (image != null) {
      for (int i = 0; i < image.length; i++) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          image[i],
        ));
      }
    }

    if (logoImage != null) {
      for (int i = 0; i < logoImage.length; i++) {
        request.files.add(http.MultipartFile.fromBytes(
          'logoImage',
          logoImage[i],
          filename: 'logo_$userId$i.jpg',
        ));
      }
    }

    if (certificate != null) {
      for (int i = 0; i < certificate.length; i++) {
        request.files.add(http.MultipartFile.fromBytes(
          'certificates',
          certificate[i],
          filename: 'cert_$userId$i.jpg',
        ));
      }
    }
    print("FIELDS: ${request.fields}");
    print("FILES COUNT: ${request.files.length}");

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("REGISTER RESPONSE = ${response.body}");

      if (response.statusCode != 200) {
        throw "Registration failed: ${response.statusCode}";
      }

      return response;
    } catch (e) {
      throw "Registration failed: $e";
    }
  }

  Future<http.Response> getUserDetails({String? userType,
    String? state,
    String? district,
    String? city, String? latitude, String? longitude, String? distance, String? isActive, String? searchText}) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants
        .getProfileListUrl}";
    print('API getProfileListUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // if (token != null) {
      //   headers['Authorization'] = 'Bearer $token';
      // }

      Map<String, String?> filters = {
        'userType': userType,
        'state': state,
        'district': district,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'distance': distance,
        'isActive': isActive
      };
      Map<String, String> cleanedFilters = {};
      filters.forEach((key, value) {
        if (value != null && value.isNotEmpty) {
          cleanedFilters[key] = value;
        }
      });
      final body = jsonEncode(
          {'search': searchText, 'filters': cleanedFilters});
      print('req body$body');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,);
      print('API response: ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch user details: $e";
    }
  }

  Future<http.Response> getBranchDetails() async {
    String url = "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants
        .getBranchesUrl}";
    print('API getBranchesUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      final body = jsonEncode(
          {'email': Api.userInfo.read('email') ?? "",});
      print('req body$body');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,);
      print('API response: ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch branch details: $e";
    }
  }

  Future<http.Response> changePassword(String userId, String oldPassword,
      String newPassword) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants
        .changePasswordUrl}";
    print('API create Mail $url');
    String? token = Api.userInfo.read('token');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'userId': userId,
          'oldPassword': oldPassword,
          'newPassword': newPassword
        }),
      );
      print('api response ${response.body}');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw " unable to change password";
      }
    } catch (e) {
      throw " password change failed: $e";
    }
  }

  Future<http.Response> forgotChangePassword(String mail,
      String newPassword) async {
    String url = "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants
        .forgotChangePasswordUrl}";
    print('API create Mail $url');
    String? token = Api.userInfo.read('token');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'mail': mail,
          'newPassword': newPassword
        }),
      );
      print('api response ${response.body}');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw " unable to change password";
      }
    } catch (e) {
      throw " password change failed: $e";
    }
  }

  Future<http.Response> forgotPassword(String mail) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants
        .forgotPasswordUrl}";
    print('API create Mail $url');
    String? token = Api.userInfo.read('token');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'mail': mail
        }),
      );
      print('api response ${response.body}');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw " unable to change password";
      }
    } catch (e) {
      throw " password change failed: $e";
    }
  }

  Future<http.Response> verifyOtpPassword(String mail, String otp) async {
    String url = "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants
        .verifyOtpPasswordUrl}";
    print('API create Mail $url');
    String? token = Api.userInfo.read('token');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'mail': mail,
          'otp': otp
        }),
      );
      print('api response ${response.body}');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw " unable to change password";
      }
    } catch (e) {
      throw " password change failed: $e";
    }
  }

  Future<http.Response> createMail(String userId, String title,
      String? Subject,
      String? message) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants
        .createMail}";
    print('API create Mail $url');
    String? token = Api.userInfo.read('token');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'userId': userId,
          'Subject': Subject,
          'title': title
        }),
      );
      print('api response ${response.body}');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw " mail failed: Unable to communicate with the server";
      }
    } catch (e) {
      throw " mail failed: $e";
    }
  }

  Future<http.Response> createPlanMail(String userId, String title,
      String? Subject,
      String? planType) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants
        .planEmailUrl}";
    print('API create Mail $url');
    String? token = Api.userInfo.read('token');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'userId': userId,
          'subject': Subject,
          'title': title,
          'planType': planType
        }),
      );
      print('title$title');
      print('api plan email response ${response.body}');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw " mail failed: Unable to communicate with the server";
      }
    } catch (e) {
      throw " mail failed: $e";
    }
  }

  Future<http.Response> createJobMail(String userId, String title,
      List<String> jobCategory, String jobId,
      String? Subject,
      String? jobStatus) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants
        .jobEmailUrl}";
    print('API create Mail $url');
    String? token = Api.userInfo.read('token');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'userId': userId,
          'subject': Subject,
          'jobId': jobId,
          'jobStatus': jobStatus,
          'title': title,
          'jobCategory': jobCategory
        }),
      );
      //print('titlr${title}');
      print('api plan email response ${response.body}');
      if (response.statusCode == 200) {
        return response;
      } else {
        throw " mail failed: Unable to communicate with the server";
      }
    } catch (e) {
      throw " mail failed: $e";
    }
  }

  Future<http.Response> getJobListAdmin() async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants
        .getJobListAdmin}";
    print('API getJobListAdmin $url');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        //body: jsonEncode(body),
      );
      print('api job response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }

  Future<http.Response> getNotificationListAdmin() async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.notificationUrl}${AppConstants
        .getNotificationUrl}";
    print('API getJobListAdmin $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        //body: jsonEncode(body),
      );
      print('api job response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }

  Future<http.Response> saveInvoicePdf({
    required String userId,
    required String planId,
    required String planName,
    required String planType,
    required String startDate,
    required String endDate,
    required double amount,
    required TaxSummary taxSummary,
    required Company company,
  }) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.saveInvoiceUrl}";
    print('API getJobListAdmin $url');
    try {
      String? token = Api.userInfo.read('token');
      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "userId": userId,
            "planId": planId,
            "planName": planName,
            "planType":planType,
             "startDate":startDate,
              "endDate":endDate,
            "amount": amount,
            "taxSummary": {
              "cgst": taxSummary.cgst,
              "sgst": taxSummary.sgst,
              "igst": taxSummary.igst,
              "totalAmount": taxSummary.totalAmount,
              "baseAmount": taxSummary.baseAmount,
            },
            "company": {
              "companyName": company.companyName,
              "gstin": company.gstin,
              "address": company.address,
              "email": company.email,
              "phone": company.phone,
            }
          }));
      return response;
    } catch (e) {
      throw "Failed to save invoice details: $e";
    }
  }
  Future<http.Response> getBasePlanList(String userType,) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.getBasePlanUrl}";
    print('API getBasePlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body:jsonEncode({"userType":userType})
      );
      print("dffg$userType");
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch base plan details: $e";
    }
  }
  Future<http.Response> getGstDetailsList() async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.getGstDetailsUrl}";
    print('API getGstDetailsUrl $url');
    String? userId = Api.userInfo.read('userId');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({"userId":userId})
      );
      print("dffg$userId");
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch base plan details: $e";
    }
  }
  Future<http.Response> getInvoiceList() async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.getInvoiceUrl}";
    print('API getInvoiceUrl $url');
    String? userId = Api.userInfo.read('userId');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      print('invoice userId$userId');
      final Uri uri = Uri.parse(url).replace(queryParameters: {"userId": userId});
      print('API getInvoiceUrl $uri');

      final response = await http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          // body:jsonEncode({"userId":userId})
      );
      print("dffg$userId");
      print('api getInvoiceUrl ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch base plan details: $e";
    }
  }
  Future<http.Response> getInvoiceById(String invoiceId) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.getInvoiceByIdUrl}";
    print('API getInvoiceUrl $url');
    String? userId = Api.userInfo.read('userId');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      print('invoice userId$userId');
      final Uri uri = Uri.parse(url).replace(queryParameters: {"invoiceId": invoiceId});
      print('API getInvoiceUrl $uri');

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        // body:jsonEncode({"userId":userId})
      );
      print("dffg$userId");
      print('api getInvoiceUrl ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch base plan details: $e";
    }
  }
  Future<http.Response> getIncomeDetails({String?state,String? fromDate,String? toDate}) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.getIncomeDetailsUrl}";
    print('API getBasePlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({"State":state,"fromDate":fromDate,"toDate":toDate})
      );
      print("State: $state");
      print("From Date: $fromDate");
      print("To Date: $toDate");
      print('api getIncomeDetails response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch base plan details: $e";
    }
  }
  Future<http.Response> getExpenseDetails({ String?state,String? month,String? year}) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.getExpenseDetailsUrl}";
    print('API getBasePlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      print("Stateexpense: $state");
      print(" month: $month");
      print("To tyear: $year");
      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({"month":month,"year":year,"state":state})
      );

      print('api getExpenseDetails response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch base plan details: $e";
    }
  }
  Future<http.Response> getAddOnsPlanList(String userType) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.getAddOnsPlanUrl}";
    print('API getBasePlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
          body:jsonEncode({"userType":userType})
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch base plan details: $e";
    }
  }
  Future<http.Response> getJobPlanList(String userType) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.getJobsPlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
          body:jsonEncode({"userType":userType})
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> getWebinarPlanList(String userType) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.getWebinarPlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({"userType":userType})
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> getPostImagePlanList(String userType) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.getPostImagePlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({"userType":userType})
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> getUploadImages({String? userId,required String userType}) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants.getUploadImagesUrl}";
    print('API getJobsPlanUrl $url');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({"userType":userType,"userId":userId})
      );
      print('api plan response ${response.body}');
      print('userid$userId typee$userType');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> checkPlansStatus(String userId) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.checkPlanStatusUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({"userId":userId})
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> uploadImagesUserType(
      String userId, String userType,String imageId,String preference,String startDate,String endDate,String isActive, List<Uint8List> images) async {
    String url = "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants.uploadImagesUrl}";
    print('API uploadImagesUrl $url');
    String token = Api.userInfo.read('token') ?? "";

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll({
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    request.fields['userId'] = userId;
    request.fields['userType'] = userType;
    request.fields['imageId'] = imageId;
    request.fields['preference'] = preference;
    request.fields['startDate'] = startDate;
    request.fields['endDate'] = endDate;
    request.fields['isActive'] = isActive;

    // for (int i = 0; i < images.length; i++) {
    //   request.files.add(await http.MultipartFile.fromPath(
    //     'posterImages',
    //     images[i].path,
    //   ));
    // }

    if (images.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'posterImages',
          images.first,
         // filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
    }
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print('API uploadImages response: ${response.body}');

      return response;
    } catch (e) {
      print('Upload error: $e');
      return http.Response('{"status":"error","message":"$e"}', 500);
    }
  }
  Future<http.Response> contactFilterSearch(String receiverUserId,String senderUserId,String state,String district,String city,String status, String search,String fromDate,String toDate,) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.contactUrl}${AppConstants.contactFilterSearchUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({
            'receiverUserId':receiverUserId,
            'senderUserId':senderUserId,
            'state':state,
            'district':district,
            'city':city,
            'search':search,
            'status':status,
            'fromDate':fromDate,
            'toDate':toDate
          })
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> createBasePlan(String userType,String planId,String planName,String price,String markPrice,String duration,bool isImageAndroid,bool isVideoAndroid,bool isLocationAndroid,bool isMobileNumber,bool isServices,String imageCount,String imageSize,String videoCount,String videoSize,List<String> features) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.createBasePlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({
            'userType':userType,
            'planId':planId,
            'planName':planName,
            'price':price,
            'duration':duration,
            'details':{
              'images':isImageAndroid,
              'video':isVideoAndroid,
              'location':isLocationAndroid,
              'mobileNumber':isMobileNumber,
              'services':isServices,
              'imageCount':imageCount,
              'imageSize':imageSize,
              'videoCount':videoCount,
              'videoSize':videoSize,
              'markPrice':markPrice
            },
            'features':features
          })
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> createUserBasePlan(String userId,String planId,String planName,String price,String startDate,String endDate) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.createUserBasePlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({
            'userId':userId,
            'planId':planId,
            'planName':planName,
            'price': price,
            'startDate':startDate,
            'endDate':endDate
          })
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> addExpenseDetail(String state,String title,String amount,String category,String month,String year) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.addExpenseDetailsUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      final String userId = Api.userInfo.read('userId') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({
            'userId':userId,
            'title':title,
            'amount':amount,
            'category':category,
            'month':month,
            'year':year,
            'state':state
          })
      );
      print('api expense response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get expense: $e";
    }
  }

  Future<http.Response> createJobPlans(String userType,String jobPlansId,String jobPlanName,String price,String markPrice,String duration,bool isStateWise,bool isDistrictWise,bool isCityWise,bool isAreaWise,String count,List<String> features,) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.createJobPlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      final body = {
        'userType': userType,
        "jobPlansId":jobPlansId,
        'jobPlanName': jobPlanName,
        'price': price,
        'duration': duration,
        'count': {
          'jobCount': count,
        },
        'details': {
          'state': isStateWise,
          'district': isDistrictWise,
          'city': isCityWise,
          'area': isAreaWise,
          'markPrice':markPrice
        },
        'features': features,
      };
      print("Request Body: ${jsonEncode(body)}");
      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        body: jsonEncode(body),

      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> createWebinarPlan(String userType, String webinarPlanId, String webinarPlanName, String price, String markPrice, String duration, bool isStateWise1, bool isDistrictWise1, bool isCityWise1, bool isAreaWise1) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.createWebinarPlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      final body = {
        'userType': userType,
        "webinarPlanId":webinarPlanId,
        'webinarPlanName': webinarPlanName,
        'price': price,
        'duration': duration,
        'details': {
          'state': isStateWise1,
          'district': isDistrictWise1,
          'city': isCityWise1,
          'area': isAreaWise1,
          'markPrice':markPrice
        },
      };
      print("Request Body: ${jsonEncode(body)}");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }

  Future<http.Response> createWebinarUserPlan(String userId,String webinarPlanId,String webinarUserPlansName,String price, String startDate,String endDate) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.createWebinarUserPlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      final body = {
        'userId': userId,
        "webinarPlanId":webinarPlanId,
        // "webinarPlanUserId":webinarPlanUserId,
        'webinarUserPlansName': webinarUserPlansName,
        'price':price,
        'startDate': startDate,
        'endDate': endDate
      };
      print("Request Body: ${jsonEncode(body)}");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }

  Future<http.Response> createPostImagePlans(String userType,String postImagesPlanId,String postPlanName,String price, String markPrice,String duration) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.createPostImagePlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      final body = {
        'userType': userType,
        "postImagesPlanId":postImagesPlanId,
        'postPlanName': postPlanName,
        'price': price,
        'duration': duration,
        'details': {
           markPrice:markPrice,
          // 'state': isStateWise1,
          // 'district': isDistrictWise1,
          // 'city': isCityWise1,
          // 'area': isAreaWise1,
        },
      };

      print("Request Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),

      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> createPostImageUserPlans(String userId,String postImagesPlanId,String postPlanName,String price,String startDate,String endDate) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.createPostImageUserPlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      final body = {
        'userId': userId,
        "postImagesPlanId":postImagesPlanId,
        // 'postImagesPlanUserId': postImagesPlanUserId,
        'postPlanName':postPlanName,
        'price':price,
        'startDate':startDate,
         'endDate':endDate
      };
      print("Request Body: ${jsonEncode(body)}");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> createAddonsPlans(String userType,String addOnsPlanId,String addOnsPlanName,String price, String markPrice,String duration,
      bool isStateWise,bool isDistrictWise,bool isCityWise,bool isAreaWise,List<String> features) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.createAddOnsPlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({
            'userType':userType,
            'addOnsPlanId':addOnsPlanId,
            // 'addOnsId':addOnsId,
            'addOnsPlanName':addOnsPlanName,
            'price':price,
            'duration':duration,
            'details':{
              "state":isStateWise,
              "district":isDistrictWise,
              "city":isCityWise,
              "area":isAreaWise,
               markPrice:markPrice,
            },
            'features':features
          })
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> createAddonsUserPlans(String userId,String addOnsPlanId,String addOnsPlanName,String price,String startDate,String endDate, ) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.createUserAddOnsPlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({
            'userId':userId,
            'addOnsPlanId':addOnsPlanId,
            'addOnsPlanName':addOnsPlanName,
            'price':price,
            "startDate":startDate,
            "endDate":endDate,
          })
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }
  Future<http.Response> createJobUserPlans(String userId,String jobPlansId,String jobPlansUserName,String price,String startDate,String endDate, ) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.createUserJobPlanUrl}";
    print('API getJobsPlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({
            'userId':userId,
            'jobPlansId':jobPlansId,
            'jobPlansName':jobPlansUserName,
            'price':price,
            "startDate":startDate,
            "endDate":endDate,
          })
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch get jobsPlanUrl: $e";
    }
  }

  Future<http.Response> createNotification(String userId,String userType,String title,String message,String state,String district,String city,String area,
      // List<File> ?notificationImage1,
      Uint8List? notificationImage1
      ) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.notificationUrl}${AppConstants.createNotificationUrl}";
    print('API getJobListAdmin $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['userId'] = userId;
      request.fields['userType'] = userType;
      request.fields['title'] = title;
      request.fields['message'] = message;
      request.fields['state'] = state;
      request.fields['district'] = district;
      request.fields['city'] = city;
      request.fields['area'] = area;

      if (notificationImage1 != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'notificationImage',
            notificationImage1,
             //filename: notificationImage1!,
          ),
        );
      }
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
      print("=== MultipartRequest Fields ===");
      request.fields.forEach((key, value) {
        print("$key: $value");
      });

      if (request.files.isNotEmpty) {
        print("=== MultipartRequest Files ===");
        for (var f in request.files) {
          print(
              "field: ${f.field}, filename: ${f.filename}, length: ${f.length}");
        }
      }
      print("Sending job request with image...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("API Response: ${response.body}");
      if (response.statusCode != 200) {
        throw "job post admin failed: Server returned ${response.statusCode}";
      }
      return response;

    } catch (e) {
      throw "Failed to job post admin  details: $e";
    }
  }
  Future<http.Response> addAppLogo(Uint8List? logoBytes, ) async {
    final String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants.changeAppLogoUrl}";
    print('API changeAppLogo $url');

    final String token = Api.userInfo.read('token') ?? "";
    final String userId = Api.userInfo.read('userId') ?? "";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add file if it exists
      if (logoBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'appLogo',
            logoBytes,
            filename: userId,
          ),
        );
      }

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      print("=== MultipartRequest Files ===");
      for (var f in request.files) {
        print("field: ${f.field}, filename: ${f.filename}, length: ${f.length}");
      }

      print("Sending logo request...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("API Response: ${response.body}");

      if (response.statusCode != 200) {
        throw "Server returned ${response.statusCode}";
      }

      return response;
    } catch (e) {
      throw "Failed to upload logo: $e";
    }
  }
  Future<http.Response> getAppLogo() async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants.getAppLogoUrl}";
    print('API getJobListAdmin $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        //body: jsonEncode(body),
      );
      print('api job response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> getAllContacts() async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.contactUrl}${AppConstants.getAllContacts}";
    print('API getJobListAdmin $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      final String userId = Api.userInfo.read('userId') ?? "";
          print('fgfh$userId');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
       // body: jsonEncode({"userId":userId}),
      );
      print('api getAllContacts ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch getAllContacts details: $e";
    }
  }
  Future<http.Response> updateNotificationListAdmin() async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.notificationUrl}${AppConstants.updateNotificationUrl}";
    print('API getJobListAdmin $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        //body: jsonEncode(body),
      );
      print('api job response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> getServiceListAdmin(String userId) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.serviceURL}${AppConstants.getServiceListUrl}";
    print('API getJobListAdmin $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "userId":userId
        }),
      );
      print('api job response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> getCompanyDetails() async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.getCompanyDetailsUrl}";
    print('API getBasePlanUrl $url');
    try {
      final String token = Api.userInfo.read('token') ?? "";
       String userId = Api.userInfo.read('userId') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
         body:jsonEncode({"userId":userId})
      );
      print('api compaeny response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch base plan details: $e";
    }
  }
  Future<http.Response> getPrivacyPolicyDetails( category) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.contactUrl}${AppConstants.getPrivacyPolicyUrl}";
    print('API getBasePlanUrl $url');
    try {
      final body = {
        "category": category,
      };

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            //"Authorization": "Bearer $token",
          },
        body: jsonEncode(body),
      );
      print("REQUEST BODY: ${jsonEncode(body)}");

      print('api getPrivacyPolicyDetails ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch base plan details: $e";
    }
  }
  Future<http.Response> addCompanyDetails(String userId,String companyName,String gst,
      Map<String, dynamic> address,
      String email,String phone,) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.addCompanyDetailsUrl}";
    print('API getBasePlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({"userId":userId,"companyName":companyName,"gstin":gst,"address":address,"email":email,"phone":phone})
      );
      print("dffg$userId");
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch base plan details: $e";
    }
  }
  Future<http.Response> addContactDetailsStateWise( final Map<String, dynamic>? details,) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.contactUrl}${AppConstants.addContactDetailsStateWiseUrl}";
    print('API addContactDetailsStateWise $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      print(details.runtimeType);
      print(({"details": details}).runtimeType);
      final bodyString = jsonEncode(details);

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:bodyString
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to addContactDetailsStateWise details: $e";
    }
  }
  Future<http.Response> addPrivacyPolicyContent(  String category,String details,) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.contactUrl}${AppConstants.addPrivacyPolicyUrl}";
    print('API addPrivacyPolicyContent $url');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      print(({"details": details}).runtimeType);
      final Map<String, dynamic> requestBody = {
        'category': category,
        'details': details,
      };

      print("REQUEST BODY: ${jsonEncode(requestBody)}");
      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({
            'category':category,
            'details':details,
          })
      );

      print('api addPrivacyPolicyContent ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to addPrivacyPolicyContent details: $e";
    }
  }
  Future<http.Response> addGstDetails(String userId,String state,String cgst,
      String sgst,String igst, bool showGst,) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.addGstDetailsUrl}";
    print('API getGst PlanUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body:jsonEncode({"userId":userId,"state":state,"cgst":cgst,"sgst":sgst,"igst":igst,'isShowGst':showGst})
      );
      print('api plan response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch base plan details: $e";
    }
  }
  Future<http.Response> getServiceDetailAdmin(String serviceId) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.serviceURL}${AppConstants.getServiceDetailsUrl}";
    print('API getJobListAdmin $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "serviceId":int.parse(serviceId)
        }),
      );
      print('api service response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> deactivateService(String serviceId) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.serviceURL}${AppConstants.deactivateServiceUrl}";
    print('API deactivate Service Url $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "serviceId":serviceId
        }),
      );
      print('api job response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> getJobListJobSeekers({required String search,
    String? state,
    String? district,
    String? city,String? jobType,  List<String>? jobCategory,
    String? salary} ) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.getJobListJobSeekers}";
    print('API getJobListAdmin $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      Map<String, dynamic> filters = {};
      if (state != null && state.isNotEmpty) filters['state'] = state;
      if (district != null && district.isNotEmpty) filters['district'] = district;
      if (city != null && city.isNotEmpty) filters['city'] = city;
      if (jobType != null && jobType.isNotEmpty) filters['jobType'] = jobType;
      if (salary != null && salary.isNotEmpty) filters['salary'] = salary;
      if (jobCategory != null && jobCategory.isNotEmpty) {
        filters['jobCategory'] = jobCategory; // send as array
      }
      print("Filters being sent: $filters");
      final body = jsonEncode({
        'search': search.trim(),
        'filters': filters,
      });
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body
      );
      print('api getJobListJobSeekers ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> getWebinarListJobSeekers(String state,String district,String city, ) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.getWebinarListJobSeekers}";
    print('API getWebinarListJobSeekers $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'state': state,
          'district':district,
          'city':city
        }),
      );
      print('api getWebinarListJobSeekers ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }

  Future<http.Response> checkJobPlanStatus(String userId) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.planUrl}${AppConstants.jobPlanStatusUrl}";
    print('API getJobListAdmin $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'userId': userId,

        }),
      );
      print('api checkJobPlanStatus ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> getAppliedJobsAdmin(String jobId) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.appliedJobsListAdminUrl}";
    print('API appliedJobsListAdminUrl  $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'jobId': jobId,

        }),
      );
      print('api getJobListJobSeekers ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> getAppliedWebinarsAdmin(String webinarId) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.appliedWebinarsListAdminUrl}";
    print('API appliedWebinarsListAdminUrl  $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'webinarId': webinarId,

        }),
      );
      print('api appliedWebinarsListAdminUrl ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch appliedWebinarsList details: $e";
    }
  }
  Future<http.Response> updateJobStatusAdmin(String jobSeekerId,String jobId,String status) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.updateJobStatusUrl}";
    print('API updateJobStatusUrl  $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'jobSeekerId': jobSeekerId,
          'jobId':jobId,
          'status':status

        }),
      );
      print('api getJobListJobSeekers ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> updateApplicationStatusAdmin(String jobId,String isActive) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.updateJobApplicationStatusUrl}";
    print('API updateJobApplicationStatusUrl  $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'jobId': jobId,
          'isActive':isActive,

        }),
      );
      print('api getJobListJobSeekers ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> createJobCategoryAdmin(String userType,String jobCategory,) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.createJobCategoryUrl}";
    print('API updateJobApplicationStatusUrl  $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      final String userId = Api.userInfo.read('userId') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'userType': userType,
          'name':jobCategory,

        }),
      );
      print('api createJobCategoryAdmin ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> updateJobCategoryAdmin(String id,String name,String isActive ) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.updateJobCategoryUrl}";
    print('API updateJobApplicationStatusUrl  $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      final String userId = Api.userInfo.read('userId') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'id': id,
          'name':name,
          'isActive':isActive

        }),
      );
      print('api createJobCategoryAdmin ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> getJobCategoryLists(String? userType) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.getJobCategoryUrl}";
    print('API getJobListAdmin $url');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'userType':userType
        }),
      );
      print('api getJobCategoryLists ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job get JobCategoryLists: $e";
    }
  }
  Future<http.Response> deleteJobCategoryLists(String? id) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.deleteJobCategoryUrl}";
    print('API updateJobApplicationStatusUrl  $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'id': id,
        }),
      );
      print('api deactivateUserAdmin ${response.body}');
      return response;
    } catch (e) {
      throw "Failed deactivateUserAdmin details: $e";
    }
  }
  Future<http.Response> deactivateUserAdmin(String userId,bool isActive) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants.deactivateUserUrl}";
    print('API updateJobApplicationStatusUrl  $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'userId': userId,
          'isActive':isActive
        }),
      );
      print('api deactivateUserAdmin ${response.body}');
      return response;
    } catch (e) {
      throw "Failed deactivateUserAdmin details: $e";
    }
  }
  Future<http.Response> deleteAwsFile(String fileUrl,String name) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants.deleteFileUrl}";
    print('API deleteFileUrl  $url');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'fileUrl': fileUrl,
          'name':name
        }),
      );
      print('file$fileUrl name$name');
      print('api deleteFile ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> updateWebinarStatusAdmin(String webinarId,String isActive) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.updateWebinarStatusUrl}";
    print('API updateWebinarStatusUrl  $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'webinarId': webinarId,
          'isActive':isActive,

        }),
      );
      print('api updateWebinarStatusUrl ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to updateWebinarStatusUrl details: $e";
    }
  }
  Future<http.Response> getJobSeekersAppliedLists(String jobSeekerId) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.getJobSeekersAppliedLists}";
    print('API getJobListAdmin $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'jobSeekerId':jobSeekerId
        }),
      );
      print('api getJobListJobSeekers ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> getSenderContactLists(String senderId,String fromDate,String toDate,String search) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.contactUrl}${AppConstants.senderContactListUrl}";
    print('API senderContactListUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'senderUserId':senderId,
          'fromDate':fromDate,
          'toDate':toDate,
          'search':search
        }),
      );
      print('api sender Receiver Contact Form ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> getReceiverContactFormLists(String receiverId,String fromDate,String toDate,String search,) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.contactUrl}${AppConstants.receiverContactListUrl}";
    print('API senderContactListUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'receiverUserId':receiverId,
          'fromDate':fromDate,
          'toDate':toDate,
          'search':search
        }),
      );
      print('api get Receiver Contact Form ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> applyJobsJobseekers(String jobId,String jobSeekersId,String userType) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.applyJobsJobSeekers}";
    print('API applyJobsJobSeekers $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'jobId': jobId,
          'jobSeekerId': jobSeekersId,
          'userType': userType,
        }),
      );
      print('api applyJobsJobSeekers ${response.body}');
      print('api applyJobsJob $jobId $jobSeekersId $userType');

      return response;
    } catch (e) {
      throw "Failed to applyJobsJobSeekers job details: $e";
    }
  }

  Future<http.Response> applyWebinarsJobseekers(String jobId,String jobSeekersId,String userType) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.applyWebinarsJobSeekers}";
    print('API applyWebinarsJobSeekers $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'webinarId': jobId,
          'jobSeekerId': jobSeekersId,
          'userType': userType,
        }),
      );
      print('api applyWebinarsJobSeekers ${response.body}');
      print('api applyJobsJob $jobId $jobSeekersId $userType');

      return response;
    } catch (e) {
      throw "Failed to applyJobsJobSeekers job details: $e";
    }
  }
  Future<http.Response> postJobsAdmin(String jobId,String userId,String userType,String jobType,List<String> jobCategory,String orgName, String jobTitle,String jobDescription,String salary,
      String qualification,String experience,String state,String district,String city,String startTime,String endTime,List<Uint8List> ?jobImage1,) async {
    String url = "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.postJobsAdminUrl}";
    print('API applyJobsJobSeekers $url');
   // String? userId=Api.userInfo.read('userId');
    //String? userType=Api.userInfo.read('userType');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['jobId'] = jobId;
      request.fields['jobType'] = jobType;
      request.fields['userId'] = userId;
      request.fields['userType'] = userType;
      request.fields['orgName'] = orgName;
      request.fields['jobTitle'] = jobTitle;
      request.fields['jobCategory'] = jsonEncode(jobCategory);
      request.fields['jobDescription'] = jobDescription;
      request.fields['qualification'] = qualification;
      request.fields['experience'] = experience;
      request.fields['salary'] = salary;
      request.fields['state'] = state;
      request.fields['city'] = city;
      request.fields['district'] = district;

      request.fields['details'] = jsonEncode({
        "startTime": startTime,
        "endTime": endTime,
      });
      // if (jobImage1 != null) {
      //   for (int i = 0; i < jobImage1.length; i++) {
      //     request.files.add(http.MultipartFile.fromBytes(
      //       'jobImage',
      //       jobImage1[i],
      //    //   filename: 'job_$userId$i.jpg',
      //     ));
      //   }
      // }
      if (jobImage1 != null && jobImage1.isNotEmpty) {
        for (int i = 0; i < jobImage1.length; i++) {
          request.files.add(http.MultipartFile.fromBytes(
            'jobImage',
            jobImage1[i],
         //   filename: 'job_${userId}_$i.jpg',
          ));
        }
      }

      // if (jobImage1 != null) {
      //   for (var img in jobImage1) {
      //     request.files.add(await http.MultipartFile.fromPath('jobImage', img));
      //   }
      // }
      // if (jobImage1 != null) {
      //   for (var img in jobImage1) {
      //     request.files.add(
      //       http.MultipartFile.fromBytes(
      //         'jobImage',
      //         img,
      //         //filename: 'job_$userId$jobId$DateTime.jpg',
      //       ),
      //     );
      //   }
      // }
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
      print("=== MultipartRequest Fields ===");
      request.fields.forEach((key, value) {
        print("$key: $value");
      });
      if (request.files.isNotEmpty) {
        print("=== MultipartRequest Files ===");
        for (var f in request.files) {
          print(
              "field: ${f.field}, filename: ${f.filename}, length: ${f.length}");
        }
      }
      print("Sending job request with image...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("API Response: ${response.body}");
      if (response.statusCode != 200) {
        throw "job post admin failed: Server returned ${response.statusCode}";
      }
      return response;

    } catch (e) {
      throw "Failed to job post admin  details: $e";
    }
  }

  Future<http.Response> postContactDetail(String senderUserId,String receiverUserId,String email,String mobileNumber,String clinicName,String doctorName, String materialDescription,String state,String district,String city,List<Uint8List> ?contactImage1) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.contactUrl}${AppConstants.postContactFormUrl}";
    print('API applyJobsJobSeekers $url');
    // String? userId=Api.userInfo.read('userId');
    //String? userType=Api.userInfo.read('userType');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['senderUserId'] = senderUserId;
      request.fields['receiverUserId'] = receiverUserId;
      request.fields['userType'] = Api.userInfo.read('userType');

      request.fields['email'] = email;
      request.fields['mobileNumber'] = mobileNumber;
      request.fields['clinicName'] = clinicName;
      request.fields['doctorName'] = doctorName;
      request.fields['materialDescription'] = materialDescription;
      request.fields['state'] = state;
      request.fields['city'] = city;
      request.fields['district'] = district;

      // request.fields['details'] = jsonEncode({
      //   "startTime": startTime,
      //   "endTime": endTime,
      // });

      // if (contactImage1 != null) {
      //   for (var img in contactImage1) {
      //     request.files.add(await http.MultipartFile.fromPath('contactImage', img));
      //   }
      // }
      if (contactImage1 != null) {
        for (int i = 0; i < contactImage1.length; i++) {
          request.files.add(http.MultipartFile.fromBytes(
            'contactImage',
            contactImage1[i],
          ));
        }
      }

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
      print("=== MultipartRequest Fields ===");
      request.fields.forEach((key, value) {
        print("$key: $value");
      });

      if (request.files.isNotEmpty) {
        print("=== MultipartRequest Files ===");
        for (var f in request.files) {
          print(
              "field: ${f.field}, filename: ${f.filename}, length: ${f.length}");
        }
      }
      print("Sending job request with image...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("API Response: ${response.body}");
      if (response.statusCode != 200) {
        throw "contact post failed: Server returned ${response.statusCode}";
      }
      return response;

    } catch (e) {
      throw "Failed to contact post details: $e";
    }
  }

  Future<http.Response> postPublicContactDetail(String email,String mobileNumber,String name, String description) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.contactUrl}${AppConstants.postPublicContactFormUrl}";
    print('API postPublicContactDetail $url');
    try {
      final body = {
        'email': email,
        "mobile":mobileNumber,
        'name': name,
        'message': description,
      };
      print("Request Body: ${jsonEncode(body)}");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );
      print('api postPublicContactDetail response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch postPublicContactDetail: $e";
    }
  }
  Future<http.Response> createServiceAdmin(
      String serviceId,
      String userId,
      String userType,
      String serviceTitle,
      String serviceDescription,
      String serviceCost,
      List<Uint8List>? serviceImages,
      List<String>? serviceImageUrl,
      ) async {
    final url = "${AppConstants.baseUrl}${AppConstants.serviceURL}${AppConstants.createServiceUrl}";
    final token = Api.userInfo.read('token') ?? "";
    final userId = Api.userInfo.read('userId') ?? "";

    var request = http.MultipartRequest('POST', Uri.parse(url));
       print('add service url$url');
    request.fields['serviceId'] = serviceId;
    request.fields['userId'] = userId;
    request.fields['userType'] = userType;
    request.fields['serviceTitle'] = serviceTitle;
    request.fields['serviceDescription'] = serviceDescription;
    request.fields['serviceCost'] = serviceCost;
    // request.fields['existingImages'] = jsonEncode(serviceImageUrl ?? []);
    // if (serviceImageUrl != null) {
    //   for (int i = 0; i < serviceImageUrl.length; i++) {
    //     request.fields['existingImages[$i]'] = serviceImageUrl[i];
    //   }
    // }
    request.fields['existingImages'] = jsonEncode(serviceImageUrl ?? []);
    print("Sending existingImages: ${jsonEncode(serviceImageUrl ?? [])}");
    final now = DateTime.now();

    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    String formattedTime =
        "${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";

    if (serviceImages != null && serviceImages.isNotEmpty) {
      for (int i = 0; i < serviceImages.length; i++) {

        final fileName = "${userId}_${formattedDate}_${formattedTime}_$i.jpg";

        request.files.add(
          http.MultipartFile.fromBytes(
            'serviceImage',
            serviceImages[i],
            filename: fileName,
          ),
        );
      }
    }
    // if (serviceImages != null) {
    //   for (int i = 0; i < serviceImages.length; i++) {
    //     request.files.add(http.MultipartFile.fromBytes(
    //       'serviceImage',
    //       serviceImages[i],
    //       filename: "$userId$i.jpg",
    //     ));
    //   }
    // }
    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print("add service Response: ${response.body}");
    return response;
  }
  Future<http.Response> postWebinarAdmin(
     String webinarId,
     String userId,
     String userType,
     String orgName,
     String webinarTitle,
     String webinarDescription,
     String webinarLink,
     String webinarDate,
     String startTime,
     String endTime,
     List<Uint8List> ? webinarImage1,
  ) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.postWebinarAdminUrl}";
    print('API postWebinarAdmin $url');
    try {
      final String token = Api.userInfo.read('token') ?? "";
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['webinarId'] = webinarId;
      request.fields['userId'] = userId;
      request.fields['userType'] = userType;
      request.fields['orgName'] = orgName;
      request.fields['webinarTitle'] = webinarTitle;
      request.fields['webinarDescription'] = webinarDescription;

      request.fields['details'] = jsonEncode({
        "webinarLink": webinarLink,
        "webinarDate": webinarDate,
        "startTime": startTime,
        "endTime": endTime,
      });

      // if (webinarImage1 != null) {
      //   var imageLength = await webinarImage1.length();
      //   var multipartFile = http.MultipartFile(
      //     'webinarImage',
      //     webinarImage1.openRead(),
      //     imageLength,
      //     filename: webinarImage1.path.split('/').last,
      //   );
      //   request.files.add(multipartFile);
      // }
      // if (webinarImage1 != null) {
      //   for (var img in webinarImage1) {
      //     request.files.add(await http.MultipartFile.fromPath('webinarImage', img));
      //   }
      // }
      if (webinarImage1 != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < webinarImage1.length; i++) {
          request.files.add(http.MultipartFile.fromBytes(
            'webinarImage',
            webinarImage1[i],
            filename: 'webinar_${userId}_${timestamp}_$i.jpg',
          ));
        }
      }

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
      print("=== MultipartRequest Fields ===");
      request.fields.forEach((key, value) {
        print("$key: $value");
      });

      if (request.files.isNotEmpty) {
        print("=== MultipartRequest Files ===");
        for (var f in request.files) {
          print(
              "field: ${f.field}, filename: ${f.filename}, length: ${f.length}");
        }
      }
      print("Sending webinar request with image...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("API Response: ${response.body}");
      if (response.statusCode != 200) {
        throw "Registration failed: Server returned ${response.statusCode}";
      }
      return response;

    } catch (e) {
      throw "Failed to post webinar: $e";
    }
  }

  Future<http.Response> getWebinarListAdmin() async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.getWebinarListAdmin}";
    print('API getJobListAdmin $url');
    String? token = Api.userInfo.read('token');
    try {
      final String token = Api.userInfo.read('token') ?? "";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        //body: jsonEncode(body),
      );
      print('api job response ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }
  Future<http.Response> getProfileByUserId(
      String userId,
        ) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.userUrl}${AppConstants.getProfileById}";
    print('API getProfileListUrl $url');
    String? token = Api.userInfo.read('token');
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // if (token != null) {
      //   headers['Authorization'] = 'Bearer $token';
      // }
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'userId':userId}),);
      print('request$userId');
      print('API response: ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch user details: $e";
    }
  }

  Future<http.Response> getJobByJobId(
      String jobId,
      ) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.getJobById}";
    print('API getJob id Url $url');
    String? token = Api.userInfo.read('token');
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      Uri uri = Uri.parse("$url/$jobId");
      print('Full API URL: $uri');

      final response = await http.get(uri, headers: headers);

      print('request$jobId');
      print('API response: ${response.body}');
      return response;
    } catch (e) {
      throw "Failed to fetch job details: $e";
    }
  }

  // Future<http.Response> getWebinarById(
  //     String webinarId,String isActive
  //     ) async {
  //   String url =
  //       "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.getWebinarById}";
  //   print('API getJob id Url $url');
  //   String? token = Api.userInfo.read('token');
  //   try {
  //     final headers = <String, String>{
  //       'Content-Type': 'application/json',
  //     };
  //
  //     if (token != null) {
  //       headers['Authorization'] = 'Bearer $token';
  //     }
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: jsonEncode({'webinarId':int.parse(webinarId),'isActive':isActive}),);
  //     print('request$webinarId');
  //     print(jsonEncode({'webinarId': webinarId, 'isActive': isActive}));
  //     print('API response: ${response.body}');
  //     return response;
  //   } catch (e) {
  //     throw "Failed to fetch job details: $e";
  //   }
  // }
  Future<http.Response> getWebinarById(String webinarId, String isActive) async {
    String url =
        "${AppConstants.baseUrl}${AppConstants.jobUrl}${AppConstants.getWebinarById}";
     String? token = Api.userInfo.read('token');
     print('webinar url$url');
     final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    // bool activeFlag;
    // if (isActive.toLowerCase() == "true") {
    //   activeFlag = true;
    // } else if (isActive.toLowerCase() == "false") {
    //   activeFlag = false;
    // } else {
    //   activeFlag = false;
    // }
    bool activeFlag = (isActive == true || isActive.toString().toLowerCase() == "true");
    final body = {
      'webinarId': int.tryParse(webinarId) ?? 0,
      'isActive': activeFlag,
    };

    print("Sending BODY → ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    print("API Response: ${response.body}");
    return response;
  }

}

