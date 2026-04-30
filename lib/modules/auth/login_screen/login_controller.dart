import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import '../../../common_widgets/color_code.dart';
import '../../../common_widgets/common_widget_all.dart';
import '../../../common_widgets/custom_toast.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../model/contact_model_web.dart';

class AppImage1 {
  File? file;
  String? url;
  String? imageId;
  String planId;
  String startDate;
  String endDate;
  bool isActive;

  AppImage1({
    this.file,
    this.url,
    this.imageId,
    this.planId = '',
    this.startDate = '',
    this.endDate = '',
    this.isActive = true,
  });
}
class AppImage {
  Uint8List? bytes;
  File? file;
  String? url;
  bool isVideo;

  AppImage({
    this.bytes,
    this.file,
    this.url,
    this.isVideo = false,
  });
}
class ExperienceFieldModel {
  TextEditingController companyName;
  TextEditingController experience;
  TextEditingController jobDescription;
  ExperienceFieldModel({
    TextEditingController? companyName,
    TextEditingController? experience,
    TextEditingController? jobDescription,
  })  : companyName = companyName ?? TextEditingController(),
        experience = experience ?? TextEditingController(),
        jobDescription = jobDescription ?? TextEditingController();
  factory ExperienceFieldModel.fromJson(Map<String, dynamic> json) {
    return ExperienceFieldModel(
      companyName: TextEditingController(text: json['companyName'] ?? ""),
      experience: TextEditingController(text: json['experience'] ?? ""),
      jobDescription: TextEditingController(text: json['jobDescription'] ?? ""),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "companyName": companyName.text,
      "experience": experience.text,
      "jobDescription": jobDescription.text,
    };
  }
}
class BranchModel {
  String? userId;
  TextEditingController branchName;
  TextEditingController state;
  TextEditingController district;
  TextEditingController city;
  TextEditingController area;
  TextEditingController pincode;
  TextEditingController location;

  BranchModel({
     this.userId,
    TextEditingController? branchName,
    TextEditingController? state,
    TextEditingController? district,
    TextEditingController? city,
    TextEditingController? area,
    TextEditingController? pincode,
    TextEditingController? location,
  })  : branchName = branchName ?? TextEditingController(),
        state = state ?? TextEditingController(),
        district = district ?? TextEditingController(),
        city = city ?? TextEditingController(),
        area = area ?? TextEditingController(),
        pincode = pincode ?? TextEditingController(),
        location = location ?? TextEditingController();

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      userId: json['userId'],
      branchName: TextEditingController(text: json['branchName'] ?? ""),
      state: TextEditingController(text: json['state'] ?? ""),
      district: TextEditingController(text: json['district'] ?? ""),
      city: TextEditingController(text: json['city'] ?? ""),
      area: TextEditingController(text: json['area'] ?? ""),
      pincode: TextEditingController(text: json['pincode'] ?? ""),
      location: TextEditingController(text: json['location'] ?? ""),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchName': branchName.text,
      'state': state.text,
      'district': district.text,
      'city': city.text,
      'area': area.text,
      'pincode': pincode.text,
      'location': location.text,
    };
  }
}

class PGDetailsModel {
  TextEditingController collegeName;
  TextEditingController degree;
  TextEditingController percentage;
  PGDetailsModel({
    TextEditingController? collegeName,
    TextEditingController? degree,
    TextEditingController? percentage,
  })  : collegeName = collegeName ?? TextEditingController(),
        degree = degree ?? TextEditingController(),
        percentage = percentage ?? TextEditingController();

  factory PGDetailsModel.fromJson(Map<String, dynamic> json) {
    return PGDetailsModel(
      collegeName: TextEditingController(text: json['collegeName'] ?? ""),
      degree: TextEditingController(text: json['degree'] ?? ""),
      percentage: TextEditingController(text: json['percentage'] ?? ""),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "collegeName": collegeName.text,
      "degree": degree.text,
      "percentage": percentage.text,
    };
  }
}
class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController clinicNameController= TextEditingController();
  final TextEditingController descriptionController= TextEditingController();
  final TextEditingController specialisationController= TextEditingController();
  final TextEditingController servicesOfferedController= TextEditingController();
  final TextEditingController locationController= TextEditingController();
  final TextEditingController websiteController= TextEditingController();
  final TextEditingController jobTitleController= TextEditingController();
  final TextEditingController jobDescController= TextEditingController();
  final TextEditingController qualificationJobController= TextEditingController();
  final TextEditingController webinarLinkController= TextEditingController();
  final TextEditingController webinarTitleJobController= TextEditingController();
  final TextEditingController webinarDescriptionJobController= TextEditingController();
  final TextEditingController webinarDateController= TextEditingController();
  final notificationController = Get.put(NotificationController());
  int selectedIndex = -1;
  //List<ContactModel> contactList = <ContactModel>[];
  List<ContactApiModel> contactListApi = [];
  final TextEditingController typeNameController = TextEditingController();
  TextEditingController ugCollege = TextEditingController();
  TextEditingController ugDegree = TextEditingController();
  TextEditingController ugPercentage = TextEditingController();
  TextEditingController pgCollege = TextEditingController();
  TextEditingController pgDegree = TextEditingController();
  TextEditingController pgPercentage = TextEditingController();
  bool showPGDetails = false;
  PGDetailsModel pgDetails = PGDetailsModel();
  String? branchUserId;
  List<String> selectedCategories = [];
  List<Map<String, dynamic>> descriptionData = [];

  void clearProfileData() {
    selectedUserType=null;
    descriptionController.clear();
    fullNameController.clear();
    emailController.clear();
    mobileController.clear();
    dobController.clear();
    passwordController.clear();
    descriptionController.clear();
    servicesOfferedController.clear();
    websiteController.clear();
    typeNameController.clear();
    stateController.clear();
    districtController.clear();
    cityController.clear();
    pinCodeController.clear();
    addressController.clear();
    locationController.clear();

    ugCollege.clear();
    ugDegree.clear();
    ugPercentage.clear();

    pgCollege.clear();
    pgDegree.clear();
    pgPercentage.clear();

    // Clear selected values
    selectedMartialStatus = "";
    selectUserId = "";
    experienceList.clear();
    editImages.clear();
    logoImage.clear();
    editCertificates.clear();
    _userData.clear();
  }
  int maxFilesImage=3;
  int maxFilesVideo=1;
  int filesImageSize=0;
  int filesVideoSize=0;
  void togglePGDetails() {
    showPGDetails = !showPGDetails;
    update();
    print('show pg $showPGDetails');
  }
  List<ExperienceFieldModel> experienceList = <ExperienceFieldModel>[];
  List<ContactModel> contactList = [];
  void addExperienceField() {
    experienceList.add(ExperienceFieldModel(
      companyName: TextEditingController(),
      experience: TextEditingController(),
      jobDescription: TextEditingController(),
    ));
  }
  List<BranchModel> branchList = <BranchModel>[];
  void addBranchList() {
    branchList.add(BranchModel(
         userId: branchUserId??"",
        branchName: TextEditingController(),
        state : TextEditingController(),
        district :TextEditingController(),
        city : TextEditingController(),
        area :TextEditingController(),
        pincode : TextEditingController(),
        location : TextEditingController(),
    ));
  }

  void removeExperienceField(int index) {
    experienceList.removeAt(index);
    update();
  }
  void removeBranchField(int index) {
    branchList.removeAt(index);
    update();
  }

  void removeContactListField(int index) {
    contactList.removeAt(index);
    update();
  }

  // void addContactField() {
  //   contactList.add(ContactModel(
  //     userId: Api.userInfo.read('userId'),
  //     name: TextEditingController(),
  //     state: TextEditingController(),
  //     mobile: TextEditingController(),
  //     whatsapp: TextEditingController(),
  //     email: TextEditingController(),
  //   ));
  // }
  //
  // final contactsJson = contactList.map((contact) => {
  //   "userId": contact.userId,
  //   "name": contact.name.text,
  //   "state": contact.state.text,
  //   "mobile": contact.mobile.text,
  //   "whatsapp": contact.whatsapp.text,
  //   "email": contact.email.text,
  // }).toList();

  void addContactField() {
    contactList.add(ContactModel(
      userId: Api.userInfo.read('userId'),
      name: TextEditingController(),
      state: TextEditingController(),
      mobile: TextEditingController(),
      whatsapp: TextEditingController(),
      email: TextEditingController(),
    ));
  }

  // Getter to convert contactList to JSON whenever needed
  // List<Map<String, dynamic>> get contactsJson => contactList.map((contact) => {
  //   "userId": contact.userId,
  //   "name": contact.name.text,
  //   "state": contact.state.text,
  //   "mobile": contact.mobile.text,
  //   "whatsapp": contact.whatsapp.text,
  //   "email": contact.email.text,
  // }).toList();

  String?searchText;
  var isLoading = false;
  List<File> images = [];
  List<AppImage2> webinarImages = [];
  List<AppImage2> jobImages = [];
  List<File> webinarImages1 = [];
  List<File> jobImages1 = [];
  List<File> logoImages = [];
  File? appLogoFile;
  String? appLogoUrl;
  List<File> postImages=[];
  List<String> imagesPaths = [];
  List<String> certificatePaths = [];
  List<File> certificates = [];

  // List<XFile> logoImages1 = [];
  // List<XFile> certificates1 = [];
  // List<XFile> images1 = [];

  List<AppImage2> logoImages1 = [];
  List<AppImage2> certificates1 = [];
  List<AppImage2> images1 = [];
  List<ProfileModel>_profileList=[];
  List<ProfileModel> get profileList=>_profileList;
  List<ProfileModel> _userData=[];
  List<ProfileModel>get userData=>_userData;
  List<ProfileModel> _userBranchesList=[];
  List<ProfileModel>get userBranchesList=>_userBranchesList;
  ProfileModel? selectedBranch;
  String?selectedUserType;
  String?selectedDistance;
  double selectedDistance1=0;
  String? selectedArea;
  String? selectedJobType;
  String? selectedSalary;
  String? selectedExperience;
  String? startHour;
  String? startMinutes;
  String? startPeriod;
  String? endPeriod;
  String? endHour;
  String? endMinutes;
  String? selectedMartialStatus;
  final Api api = Api();
  String ? selectUserId;
  List<AppImage> editImages = [];
  List<AppImage2> webinarFileImages = [];
  List<AppImage2> jobFileImages = [];
  //List<AppImage> logoImage = [];
  List<String> logoImage = [];

  List<AppImage> editCertificates = [];
  List<AppImage2> serviceFileImages = [];
  List<File> serviceImage=[];
  List<AppImage2> contactImages = [];
  Map<String, dynamic> data = {};

  //static const String baseUrl = "https://india-location-hub.in/api";
  double ?latitude;
  double ?longitude;

  List states = [];
  List districts = [];
  List talukas = [];
  List villages = [];

  String? selectedState;
  String? selectedDistrict;
  String? selectedTaluka;
  String? selectedVillage;
  void setAppLogo(File file) {
    appLogoFile = file;
    update();
  }

  Future<void> fetchStates() async {
    try {
      const url = '${AppConstants.baseUrl}${AppConstants.notificationUrl}${AppConstants.stateUrl}';
       print('state url$url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        states = List<String>.from(
          decoded is List ? decoded : decoded["states"] ?? decoded["data"] ?? [],
        );

        print("Loaded States: $states");
        update();
      } else {
        print("Failed loading states: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching states: $e");
    }
  }
  Future<void> fetchDistricts(String state) async {
    try {
      final url = '${AppConstants.baseUrl}${AppConstants.notificationUrl}districts/$state';
      print('dist url$url');
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        districts = List<String>.from(
          decoded is List ? decoded : decoded["districts"] ?? decoded["data"] ?? [],
        );
        print('Districts: $districts');
        update();
        selectedDistrict = null;
        selectedTaluka = null;
        talukas = [];
        villages = [];
        selectedVillage = null;
      }
    } catch (e) {
      print("Error fetching districts: $e");
    }
  }
  Future<void> fetchTalukas(String district) async {
    try {
      final url = '${AppConstants.baseUrl}${AppConstants.notificationUrl}subdistricts/$district';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        talukas = List<String>.from(
          decoded is List ? decoded : decoded["subDistricts"] ?? decoded["data"] ?? [],
        );
        print('talukas: $talukas');
        update();
      }
    } catch (e) {
      print("Error fetching talukas: $e");
    }
  }

  Future<void> fetchVillages(String subDistrict) async {
    try {
      final url = '${AppConstants.baseUrl}${AppConstants.notificationUrl}villages/$subDistrict';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        villages = List<String>.from(
          decoded is List ? decoded : decoded["villages"] ?? decoded["data"] ?? [],);
        print('villages: $villages');
        update();
      }
    } catch (e) {
      print("Error fetching villages: $e");
    }
  }
  Future<void> login(String email,String password,String platform,context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('$email pas$password');
      final response = await api.loginUser(email, password);
      var data = jsonDecode(response.body);
      if (data["status"].toString().toLowerCase() == "success") {
        print("Login Success");
        final user = (data["data"] ?? {}) as Map<String, dynamic>;
        Api.userInfo.write("token", data["authToken"] ?? "");
         String userType1=user["userType"]?.toString() ?? "";
        String userId1=user["userId"]?.toString() ?? "";
        String personName=user["name"]?.toString() ?? "";
        Api.userInfo.write("userType", user["userType"]?.toString() ?? "");
        Api.userInfo.write("password", user["password"]?.toString() ?? "");
        Api.userInfo.write("personName", personName);

        Api.userInfo.write("userId", user["userId"]?.toString() ?? "");
        Api.userInfo.write("email", user["email"]?.toString() ?? "");
        String userType = Api.userInfo.read("userType") ?? "";

        if (user["image"] is List && (user["image"] as List).isNotEmpty) {
          Api.userInfo.write("profileImage", user["image"][0].toString());
        } else {
          Api.userInfo.write("profileImage", "");
        }
        Api.userInfo.write("mobileNumber", user["mobileNumber"]?.toString() ?? "");

        final address = (user["address"] ?? {}) as Map<String, dynamic>;
        String state = address["state"]?.toString() ?? "";
        Api.userInfo.write("state", state);
        String district = address["district"]?.toString() ?? "";
        Api.userInfo.write("district", district);
        String city = address["city"]?.toString() ?? "";
        Api.userInfo.write("city", city);
        String area = address["area"]?.toString() ?? "";
        Api.userInfo.write("area", area);

        final details = (user["details"] ?? {}) as Map<String, dynamic>;
        String name = details["name"]?.toString() ?? "";
        Api.userInfo.write("orgName", name);

        print("STATE: $state");
        print("NAME: $name");
        print(Api.userInfo.read("profileImage"));
        // String fcmToken=Api.userInfo.read('fcmToken')??"";
        // print("read fcm token${Api.userInfo.read('fcmToken')}");
        // final token = await FirebaseMessaging.instance.getToken();
        // print('userid$userId1 usertype$userType1 token$fcmToken');
        //await saveFcmToken(userId1,userType1,fcmToken,context);
        showCustomToast(context, "Login successful", backgroundColor: AppColors.secondary);

        platform != "Web"
            ? Get.offAllNamed("/${pageUserType(userType)}")
            : Get.offAllNamed("/${pageUserTypeWeb(userType)}");
      }
      else {
        showCustomToast(context,  "Login Failed, ${data["message"] ?? "error"}",);
        //I/flutter (12546): api job response {"status":"error","message":"jwt expired"}
        //Get.snackbar("Login Failed", data["message"] ?? "error");
      }
    } catch (error) {
      showCustomToast(context,  "error $error",backgroundColor: AppColors.secondary);
      print('login error$error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> _refresh() async {
    Api.userInfo.erase();
  }
  Future<void> switchAccountLogin(String userId,String platform,context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _refresh();
//Api.userInfo.erase();
      final response = await api.switchAccountLogin(userId,);
      var data = jsonDecode(response.body);
      if (data["status"].toString().toLowerCase() == "success") {
        print("Login Success");
        final user = (data["data"] ?? {}) as Map<String, dynamic>;
        Api.userInfo.write("token", data["authToken"] ?? "");
        String userType1=user["userType"]?.toString() ?? "";
        String userId1=user["userId"]?.toString() ?? "";
        String personName=user["name"]?.toString() ?? "";
        Api.userInfo.write("userType", user["userType"]?.toString() ?? "");
        Api.userInfo.write("password", user["password"]?.toString() ?? "");
        Api.userInfo.write("personName", personName);

        Api.userInfo.write("userId", user["userId"]?.toString() ?? "");
        Api.userInfo.write("email", user["email"]?.toString() ?? "");
        String userType = Api.userInfo.read("userType") ?? "";

        if (user["image"] is List && (user["image"] as List).isNotEmpty) {
          Api.userInfo.write("profileImage", user["image"][0].toString());
        } else {
          Api.userInfo.write("profileImage", "");
        }
        Api.userInfo.write("mobileNumber", user["mobileNumber"]?.toString() ?? "");

        final address = (user["address"] ?? {}) as Map<String, dynamic>;
        String state = address["state"]?.toString() ?? "";
        Api.userInfo.write("state", state);
        String district = address["district"]?.toString() ?? "";
        Api.userInfo.write("district", district);
        String city = address["city"]?.toString() ?? "";
        Api.userInfo.write("city", city);
        String area = address["area"]?.toString() ?? "";
        Api.userInfo.write("area", area);

        final details = (user["details"] ?? {}) as Map<String, dynamic>;
        String name = details["name"]?.toString() ?? "";
        Api.userInfo.write("orgName", name);

        print("STATE: $state");
        print("NAME: $name");
        print(Api.userInfo.read("profileImage"));
        String fcmToken=Api.userInfo.read('fcmToken')??"";
        print("read fcm token${Api.userInfo.read('fcmToken')}");
        //final token = await FirebaseMessaging.instance.getToken();
        print('userid$userId1 usertype$userType1 token$fcmToken');
        await saveFcmToken(userId1,userType1,fcmToken,context);
        showCustomToast(context, "Account Switched successfully", backgroundColor: AppColors.secondary);
                 Navigator.pop(context);
        platform != "Web"
            ? Get.offAllNamed("/${pageUserType(userType)}")
            : Get.offAllNamed("/${pageUserTypeWeb(userType)}");
      }
      else {
        showCustomToast(context,  "Account not switched error, ${data["message"] ?? "error"}",);
        //I/flutter (12546): api job response {"status":"error","message":"jwt expired"}
        //Get.snackbar("Login Failed", data["message"] ?? "error");
      }
    } catch (error) {
      showCustomToast(context,  "error $error",backgroundColor: AppColors.secondary);
      print('login error$error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> deactivateUserAdmin(String userId,bool isActive, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      final response = await api.deactivateUserAdmin( userId,isActive);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        isActive==false?  showCustomToast(context,  "user deactivated successfully"):showCustomToast(context,  "user activated successfully");
      } else {
        showCustomToast(context, "user not deactivated: ${data["message"]}");
      }
    } catch (e) {
      print('_jobId List Admin error $e');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> deleteAwsFile(String fileUrl, String name,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      final response = await api.deleteAwsFile( fileUrl,name);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showCustomToast(context,  "File deleted successfully");
      } else {
        showCustomToast(context, "File not deleted: ${data["message"]}");
      }
    } catch (e) {
      print('File not deleted $e');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> saveFcmToken(String userId, String userType,String fcmToken,context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.saveFcmToken( userId,  userType, fcmToken);
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
        print( "token saved successful",);
      }
      else {
        print("token save error, ${data["message"] ?? "error"}");
      }
    } catch (error) {
      print('fcm token error$error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getProfileDetails(String? userType,
      String? state,
      String? district,
      String? city,String? isActive,String?latitude,String? longitude,String distance,String? searchText, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _profileList=[];
      final response = await api.getUserDetails(userType: userType,state:state,district:district,city:city,latitude:latitude, longitude:longitude, distance:distance,searchText:searchText,isActive:isActive,);
      var data = jsonDecode(response.body);
      if ( data["status"] == "Success") {
        List<dynamic> users = data["data"];
         String excludedUserId = Api.userInfo.read('userId')??"";
         //_profileList = users.where((e) => e["userId"] != excludedUserId).map((e) => ProfileModel.fromJson(e)).toList();
       // String userType = Api.userInfo.read('userType') ?? '';
        final currentUserType = Api.userInfo.read("userType") ?? "";
        _profileList = users.where((e) {
          final userId = e["userId"];
          final userType = e["userType"];
          if (userId == excludedUserId) return false;
          if (currentUserType != "superAdmin") {
            if (userType == "admin" || userType == "superAdmin") {
              return false;
            }
          }
          return true;
        }).map((e) => ProfileModel.fromJson(e)).toList();
        print('Total profiles: ${_profileList.length}');
      } else {
        showCustomToast(context,  "Profile data error, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('get profile error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getBranchDetails( dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _userBranchesList=[];
      final response = await api.getBranchDetails();
      var data = jsonDecode(response.body);
      if (data["status"].toString().toLowerCase() == "success") {
        List<dynamic> users = data["data"];
        _userBranchesList = users.map((e) => ProfileModel.fromJson(e)).toList();
        print('Total profiles: ${_userBranchesList.length}');
        branchList.clear();
       // _userBranchesList=[];
        for (var e in users) {
          branchList.add(
            BranchModel(
              userId: e['userId']?.toString() ?? '',
              branchName: TextEditingController(text: e['details']?['name'] ?? ''),
              state: TextEditingController(text: e['address']?['state'] ?? ''),
              district: TextEditingController(text: e['address']?['district'] ?? ''),
              city: TextEditingController(text: e['address']?['city'] ?? ''),
              area: TextEditingController(text: e['address']?['area'] ?? ''),
              pincode: TextEditingController(text: e['address']?['pincode'] ?? ''),
              location: TextEditingController(text: e['location']?.toString() ?? '',
              ),
            ),
          );
        }

      } else {
        print("getBranchDetails, ${data["message"] ?? "error"}");
      }
    } catch (error) {
      print('get profile error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getProfileByUserId(String userId, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    try {
      isLoading = true;
      final response = await api.getProfileByUserId(userId);
      var data = jsonDecode(response.body);
      if (data["status"] == "Success") {
        final user = ProfileModel.fromJson(data["data"]);
        _userData = [user];
        fullNameController.text = user.name ?? "";
        emailController.text = user.email;
        print(user.name);
        mobileController.text = user.mobileNumber;
        dobController.text=user.dob??"";
        selectedMartialStatus=user.martialStatus??"";
        selectUserId=user.userId??"";
        selectedUserType=user.userType??"";
        passwordController.text=user.details["password"]??"";
       // descriptionController.text = user.details["description"] ?? "";
        descriptionData = user.details["description"] ?? "";

        print("namw${user.details["name"] ?? ""}");
        servicesOfferedController.text = user.details["services"] ?? "";
        websiteController.text = user.details["website"] ?? "";
        typeNameController.text = user.details["name"] ?? "";
        selectedState = user.address["state"] ?? "";
        selectedDistrict = user.address["district"] ?? "";
        print('district $selectedDistrict');
        selectedTaluka = user.address["city"] ?? "";
        print('city $selectedTaluka');
        selectedVillage = user.address["area"] ?? "";
        print('area $selectedVillage');
        pinCodeController.text = user.address["pincode"] ?? "";
        addressController.text = user.address["address"] ?? "";
        selectedMartialStatus=user.martialStatus??"";
        locationController.text=user.location??"";


        // if (user.details["jobCategory"] != null) {
        //   final jc = user.details["jobCategory"];
        //   if (jc is List) {
        //     selectedCategories = jc.map((e) => e.toString()).toList();
        //   } else if (jc is String && jc.isNotEmpty) {
        //     selectedCategories = [jc];
        //   } else {
        //     selectedCategories = [];
        //   }
        // } else {
        //   selectedCategories = [];
        // }
        // print('categoryy$selectedCategories');
        String normalize(String value) => value.trim().toLowerCase();

        if (user.details["jobCategory"] != null) {
          final jc = user.details["jobCategory"];
          if (jc is List) {
            selectedCategories = jc.map((e) => normalize(e.toString())).toList();
          } else if (jc is String && jc.isNotEmpty) {
            selectedCategories = [normalize(jc)];
          } else {
            selectedCategories = [];
          }
        } else {
          selectedCategories = [];
        }

        print('categoryy $selectedCategories');
        void setSelectedCategoriesFromUser(List<dynamic>? jc) {
          String normalize(String v) => v.trim().toLowerCase();

          if (jc == null) {
           selectedCategories = [];
          } else {
        selectedCategories = jc.map((e) => normalize(e.toString())).toList();
          }

         update();
        }
        setSelectedCategoriesFromUser(user.details["jobCategory"]);
        final college = user.details["collegeDetails"] ?? {};
        final ug = college["ugDegree"] ?? {};
        final pg = college["pgDegree"] ?? {};

        ugCollege.text = ug["name"] ?? "";
        ugDegree.text = ug["degree"] ?? "";
        ugPercentage.text = ug["percentage"] ?? "";

        pgCollege.text = pg["name"] ?? "";
        pgDegree.text = pg["degree"] ?? "";
        pgPercentage.text = pg["percentage"] ?? "";

        experienceList.clear();
        for (var e in user.experienceDetails) {
          experienceList.add(
            ExperienceFieldModel(
              companyName: TextEditingController(text: e.companyName.text),
              experience: TextEditingController(text: e.experience.text),
              jobDescription:
              TextEditingController(text: e.jobDescription.text),
            ),
          );
        }
        List<String> parseStringList(dynamic value) {
          if (value == null) return [];
          if (value is List) return value.map((e) => e.toString()).toList();
          if (value is String && value.isNotEmpty) return [value];
          return [];
        }
        editImages = user.images.map((e) {
          final url = e.replaceAll("\\", "/");
          final isVideo = url.toLowerCase().endsWith(".mp4");
          return AppImage(
            url: url,
            isVideo: isVideo,
          );
        }).toList();
        // logoImage = parseStringList(user.logoImages)
        //     .map((e) => AppImage(url: e.replaceAll("\\", "/")))
        //     .toList();
        logoImage = parseStringList(user.logoImages)
            .map((e) => e.replaceAll("\\", "/"))
            .toList();
        print('lodo$logoImage');
        editCertificates = parseStringList(user.certificates)
            .map((e) => AppImage(url: e.replaceAll("\\", "/")))
            .toList();
        // editImages = user.images.map((e) {
        //   final url = e.replaceAll("\\", "/");
        //   final isVideo = url.toLowerCase().endsWith(".mp4");
        //   return AppImage(
        //     url: url,
        //     isVideo: isVideo,
        //   );
        // }).toList();
        // logoImage = parseStringList(user.logoImages)
        //     .map((e) => AppImage(url: e.replaceAll("\\", "/")))
        //     .toList();
        //
        // editCertificates = parseStringList(user.certificates)
        //     .map((e) => AppImage(url: e.replaceAll("\\", "/")))
        //     .toList();




        // editImages = user.images.map((e) {
        //   final url = e.replaceAll("\\", "/");
        //   final isVideo = url.toLowerCase().endsWith(".mp4");
        //   return AppImage(
        //     url: url,
        //     isVideo: isVideo,
        //   );
        // }).toList();
        // logoImage = parseStringList(user.logoImages)
        //     .map((e) => AppImage(url: e.replaceAll("\\", "/")))
        //     .toList();
        //
        // editCertificates = parseStringList(user.certificates)
        //     .map((e) => AppImage(url: e.replaceAll("\\", "/")))
        //     .toList();
        print("Profile Loaded: ${user.name}");

      } else {
      }
    } catch (error) {
      print("get profile error: $error");
    } finally {
      isLoading = false;
      update();
      print('loading$isLoading');
    }
  }

  Future<void> registerUser({
    required String userId,
    required String userType,
    required String fullName,
     String? martialStatus,
    required String dob,
    required String mobile,
    required String email,
    String? confirmPassword,
    required String taluk,
    required String district,
    required String city,
    required String area,
    required String pinCode,
    String? typeName,List<String>? jobCategory,
    // List<Uint8List>? logoImage,
    // List<Uint8List>? image,
    // List<Uint8List>? certificate,
    logoImage,
    image,
    certificate,
    List<String>? oldImageUrl,
    List<String>? oldCertificatesUrl, List<String>? logoUrl,Map<String, dynamic>? details,
    required BuildContext context,
    String? description,
    // String? services,
    String? location,String? website,String? latitude,String? longitude,String? adminId,String? isAdmin
  }) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      showCustomToast(context,  "No Internet.Please check your connection",);
      return;
    }
    isLoading=true;
    try {
      final response = await api.registerUser( userId, userType,fullName,martialStatus,dob, mobile, email, confirmPassword, taluk, district, city,area, pinCode, typeName, jobCategory,logoImage, image,certificate,
           oldImageUrl, oldCertificatesUrl,  logoUrl,details,description, location,website, latitude, longitude,adminId,isAdmin);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        print('update status ${data["status"]}$userId uid');
      (userId=="0")?
      await showSuccessDialog(context, title:"Success",message :"User Registered successfully.Please check your mail", onOkPressed: () {
        kIsWeb? Get.offAllNamed('/webLoginPage'):Get.offAllNamed('/loginPage') ;
      }):
     await showSuccessDialog(context, title:"Success",message :"User updated successfully!", onOkPressed: () {
        Get.back();});
      String userId1=data["data"]["userId"];
      String userType=data["data"]["userType"];
        selectedCategories.clear();
        fullNameController.clear();
         mobileController.clear();
         addressController.clear();
         dobController.clear();
         confirmPasswordController.clear();
         passwordController.clear();
         selectedVillage=null;
         selectedTaluka=null;
         selectedDistrict=null;
         selectedState=null;
         selectedMartialStatus=null;
         logoImages.clear();
         pinCodeController.clear();
         typeNameController.clear();
         locationController.clear();
         servicesOfferedController.clear();
         emailController.clear();
         websiteController.clear();
         descriptionController.clear();
         images = [];
         certificates = [];
         selectedUserType=null;
         image==null;
        // selectedPlace=='';
       // (userId=="0")?   await sentMailUser(userId1, "register", "New User Register From LYD", "your Registered successfully", context):"";
      (userId=="0")?   await notificationController.createNotification(userId1,userType, 'new', '$userId1 Registered successfully ',Api.userInfo.read('state')??"",Api.userInfo.read('district')??"",Api.userInfo.read('city')??"",Api.userInfo.read('area')??"", context):"";
        //kIsWeb? Get.offAllNamed('/webLoginPage'):Get.offAllNamed('/loginPage') ;
      } else {
        await showSuccessDialog(context, title:"Error",message :"${data["message"] ?? "error"}",
            onOkPressed: () {
          Get.back();
        });
      }
    } catch (e, st) {
      print("Register Exception: $e");
      print("Stack Trace: $st");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> changePassword(String userId,String oldPassword, String newPassword, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.changePassword(  userId, oldPassword,  newPassword);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        await showSuccessDialog(context, title:"Success",message :"Password changed successfully",
            onOkPressed: () {
              Get.back();
            });
        oldPasswordController.clear();
        confirmPasswordController.clear();
        passwordController.clear();
      } else {
        showCustomToast(context,"password not changed, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('get mail error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> forgotChangePassword(String mail, String newPassword, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.forgotChangePassword( mail, newPassword);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context, title:"Success",message :"Password Changed Successfully ",onOkPressed: (){
          kIsWeb? Get.offAllNamed('/webLoginPage'):Get.offAllNamed('/loginPage') ;
        });
        confirmPasswordController.clear();
        passwordController.clear();
      } else {
        showCustomToast(context,"password not changed, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('get mail error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> forgotPassword(String mail,  dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.forgotPassword( mail  );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        if (!context.mounted) return;
        showSuccessDialog(context, title:"Success",message :"Otp Sent to mail successfully to ${Api.userInfo.read('otpMail')??""} ${data["message"] ??""} ",
            onOkPressed: (){
          kIsWeb? Get.offAllNamed('/verifyPasswordWeb'):Get.offAllNamed('/verifyPasswordPage') ;

            });
        emailController.clear();
      } else {
        showSuccessDialog(context, title:"Error",message :"${data["message"] ?? "error"} ",
            onOkPressed: (){  Get.back();
        });
      }
    } catch (error) {
      print('get mail error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  //Future<void> addAppLogoImage(XFile ?logoImage1,dynamic context) async {
    Future<void> addAppLogoImage(Uint8List bytes,  context) async {
      var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.addAppLogo(bytes  );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        if (!context.mounted) return;
        showSuccessDialog(context, title:"Success",message :"${data["message"] ??""} ",
            onOkPressed: (){
             // Get.toNamed('/verifyPasswordPage');
            });
        emailController.clear();
      } else {
        showSuccessDialog(context, title:"Error",message :"${data["message"] ?? "error"} ",
            onOkPressed: (){
          //    Get.toNamed('/forgotPasswordPage');
        });
      }
    } catch (error) {
      print('get mail error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getAppLogoImage(dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.getAppLogo( );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> urls = data['data'];
        appLogoUrl = urls.isNotEmpty ? urls[0] : null;
        print('get image$appLogoUrl');
      } else {
        print("${data["message"] ?? "error"} ");
      }
    } catch (error) {
      print('get mail error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getAllContacts(dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.getAllContacts( );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        //List<dynamic> contacts = data['data'][0]['details'];
        var rawDetails = data['data'][0]['details'];

        List<dynamic> contacts = [];

        if (rawDetails is List) {
          contacts = rawDetails;
        } else if (rawDetails is Map) {
          contacts = [rawDetails];
        }
        contactListApi = contacts
            .map((e) => ContactApiModel.fromJson(e))
            .toList();

        update();
        contactList.clear();

        for (var item in contacts) {
          contactList.add(ContactModel(
            userId: data['data'][0]['userId'],
            name: TextEditingController(text: item['name'] ?? ""),
            state: TextEditingController(text: item['state'] ?? ""),
            mobile: TextEditingController(text: item['mobileNumber'] ?? ""),
            whatsapp: TextEditingController(text: item['whatsapp'] ?? ""),
            email: TextEditingController(text: item['email'] ?? ""),
          ));
        }

        update();

      } else {
        print("${data["message"] ?? "error"} ");
      }
    } catch (error) {
      print('get mail error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> verifyOtpPassword(String mail,String otp,  dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.verifyOtpPassword( mail,otp  );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context, title:"Success",message :"mail verified successfully ${data["message"] ??""} ",
          onOkPressed: () {
          kIsWeb? Get.offAllNamed('/forgotPasswordWebScreen'):Get.offAllNamed('/forgotChangePasswordPage') ;
          },);
        emailController.clear();
      //  Get.toNamed('/verifyPasswordPage');
      } else {
        showCustomToast(context,"password not changed, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('get mail error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> sentMailUser(String userId,String? title, String? Subject, String? message, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createMail( userId,title!,Subject,message);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
       // showCustomToast(context,"mail sent successfully",);
      } else {
        print("error${data["message"] ?? "error"}");
        showCustomToast(context,"mail not get error, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('get mail error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> sentMailPlan(String userId,String? title, String? Subject, String? planType, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createPlanMail(userId,title!,Subject,planType);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        //showCustomToast(context,"mail sent successfully",);
      } else {
        print("mail not sent error, ${data["message"] ?? "error"}");
        //showCustomToast(context,"mail not sent error, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('get mail error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
}
