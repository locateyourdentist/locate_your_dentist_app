import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/model/addOns_plan_model.dart';
import 'package:locate_your_dentist/model/company_invoice_model.dart';
import 'package:locate_your_dentist/model/expense_model.dart';
import 'package:locate_your_dentist/model/income_model.dart';
import 'package:locate_your_dentist/model/jobPlan_model.dart';
import 'package:locate_your_dentist/model/plan_model.dart';
import 'package:locate_your_dentist/model/postImage_model.dart';
import 'package:locate_your_dentist/model/post_image_model.dart';
import 'package:locate_your_dentist/model/webinarPlan_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AppImage2 {
  Uint8List? bytes;
  String? url;
  String? name;
  String? id;
  final File? file;
  bool? isActive;
  final bool isVideo;
  AppImage2({this.bytes, this.url,this.name,this.id,this.file, this.isActive = true,this.isVideo=false});
}


  class PlanController extends GetxController{
  bool isLoading=false;
  Api api =Api();
  List<PlanModel>_basePlanList=[];
  List<PlanModel> get basePlanList=>_basePlanList;
  IncomeDashboardModel? _income;
  IncomeDashboardModel? get income => _income;
  List<AddOnsPlanModel>_addOnsPlanList=[];
  List<AddOnsPlanModel> get addOnsPlanList=>_addOnsPlanList;
  List<JobPlanModel>_jobPlanList=[];
  List<JobPlanModel> get jobPlanList=>_jobPlanList;
  List<WebinarPlan>_webinarPlanList=[];
  List<WebinarPlan> get webinarPlanList=>_webinarPlanList;
  List<PostImagePlan>_postImagePlanList=[];
  List<PostImagePlan> get postImagePlanList=>_postImagePlanList;
  List<AppImage> editUploadImage = [];
  List<AppImage2> editUploadImage1 = [];
  List<Map<String, dynamic>> _getGstList = [];
  List<Map<String, dynamic>> get getGstList => _getGstList;
  List<InvoiceModel>  _invoiceList=[];
  List<InvoiceModel> get invoiceList=>_invoiceList;

  List<InvoiceModel>  _invoiceDetails=[];
  List<InvoiceModel> get invoiceDetails=>_invoiceDetails;

  List<Map<String, dynamic>> _checkPlanList = [];
  List<Map<String, dynamic>> get checkPlanList => _checkPlanList;
  TextEditingController userTypeController=TextEditingController();
  TextEditingController planNameController=TextEditingController();
  TextEditingController priceController=TextEditingController();
  TextEditingController markPriceController=TextEditingController();
  TextEditingController featuresController=TextEditingController();
  TextEditingController durationDaysController=TextEditingController();
  TextEditingController durationMonthsController=TextEditingController();
  TextEditingController imageCountController=TextEditingController();
  TextEditingController videoCountController=TextEditingController();
  TextEditingController imageSizeController=TextEditingController();
  TextEditingController videoSizeController=TextEditingController();

  TextEditingController countDaysController=TextEditingController();
  TextEditingController titleController=TextEditingController();
  TextEditingController amountController=TextEditingController();
  TextEditingController categoryController=TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController cgstController = TextEditingController();
  final TextEditingController sgstController = TextEditingController();
  final TextEditingController igstController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipController = TextEditingController();


  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController1 = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();


  final loginController=LoginController();
  final notificationController=NotificationController();
  String? selectedUserType;
  String? selectedCategory;
  String? selectedState;
  String? selectedPosterPlan;
  String? selectedPlanId;

  String? selectedPlanType;
  List<String> userList=[];
  String? selectedItem;
  bool isVideoAndroid=false;
  bool isImageAndroid=false;
  bool isLocationAndroid=false;
  bool isShowGst=false;
  bool isMobileNumber=false;
  bool isServices=false;
 // List<String> selectedFeatures = [];
  List<String> selectedFeatures = [];
  bool isDropdownOpen = false;
  String selectedString="Base Plan";
  bool isStateWise=false;
  bool isDistrictWise=false;
  bool isCityWise=false;
  bool isAreaWise=false;
  String? selectPlanId;
  String? selectAddOnsId;
  String? selectJobId;
  String? selectPostImageId;
  String? selectId;
  String? selectWebinarId;
  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> get expenses => _expenses;
  List<PosterImageModel> _posterImage = [];
  List<PosterImageModel> get posterImage => _posterImage;
  String? currentLocation;
  double get total => _expenses.fold(0, (sum, e) => sum + e.amount);
  String? selectedMonthName;
  //String selectedYear = DateTime.now().year.toString();
  String? selectedYear;
  late Razorpay _razorpay;
  PostImagePlan? selectedPlan;
  String? invoiceId;
  void _handleExternalWallet(ExternalWalletResponse response,dynamic context) {
    debugPrint('External Wallet selected: ${response.walletName}');
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('External Wallet: ${response.walletName}')),
    // );
  }

  void openCheckout({
    required double amount,
    required String name,
    required String description,
    required String contact,
    required String email,
    Function(PaymentSuccessResponse)? onPaymentSuccess,
    Function(PaymentFailureResponse)? onPaymentError,dynamic context
  }) {
    var options = {
      'key': 'YOUR_RAZORPAY_KEY',
      'amount': (amount * 100).toInt(), // Razorpay expects paise
      'name': name,
      'description': description,
      'prefill': {'contact': contact, 'email': email},
      'external': {'wallets': ['paytm']},
    };

    try {
      _razorpay.open(options);

      if (onPaymentSuccess != null) {
        _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
        showCustomToast(context,  "plan activated successfully",);
      }
      if (onPaymentError != null) {
        _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentError);
      }
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
  Future<Company?> getCompanyDetails() async {
    try {
     // await Future.delayed(Duration.zero);

      isLoading = true;
     // update();

      final response = await api.getCompanyDetails();
      final data = jsonDecode(response.body);

      if (data["status"]?.toString().toLowerCase() == "success" &&
          data["data"] != null) {

        final companyData = data["data"];

        // Map API values to controllers
        companyNameController.text = companyData['companyName'] ?? '';
        gstinController.text = companyData['gstin'] ?? '';
        emailController.text = companyData['email'] ?? '';
        phoneController.text = companyData['phone'] ?? '';
        streetController.text = companyData['address']?['street'] ?? '';

        cityController.text = companyData['address']?['city'] ?? '';
        stateController.text = companyData['address']?['state'] ?? '';
        zipController.text = companyData['address']?['pincode'] ?? '';

        isLoading = false;
        update();

        return Company(
          companyName: companyData['companyName'],
          gstin: companyData['gstin'],
          address:
          "${companyData['address']?['city']}, ${companyData['address']?['state']}",
          email: companyData['email'],
          phone: companyData['phone'],
        );
      }

      isLoading = false;
      update();
      return null;
    } catch (e) {
      debugPrint(e.toString());
      isLoading = false;
      update();
      return null;
    }
  }
  Future<void> addCompanyDetails(String userId,String companyName,String gst,
   Map<String, dynamic> address,String email,String phone,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.addCompanyDetails(  userId, companyName, gst,
            address, email, phone,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showCustomToast(context,  "Company Details Saved Successfully",);

      } else {
        showCustomToast(context,  "company details can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('company details can not get error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> addContactDetailsStateWise({ required Map<String, dynamic>? details,
    required BuildContext context,}) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.addContactDetailsStateWise( details);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        await showSuccessDialog(context, title:"Success",message :"Contact Details Saved Successfully",
            onOkPressed: () {
              Get.back();
            });
      } else {
        showCustomToast(context,  "Contact details can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('Contact details can not get error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> addGstDetails(String userId,String state,String cgst,
     String sgst,String igst,bool showGst,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.addGstDetails(userId, state, cgst, sgst,igst, showGst,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showCustomToast(context,  "Gst Details Saved Successfully",);

      } else {
        showCustomToast(context,  "company details can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('company details can not get error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> saveInvoicePdf({
  required String userId,
  required String planId,
  required String planName,
    required String planType,
    required String startDate,
    required String endDate,
  required double amount,
  required TaxSummary taxSummary,
  required Company company,context})async{
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.saveInvoicePdf(userId:  userId,planId: planId,planName: planName,planType:planType,startDate:startDate,endDate:endDate,amount: amount,taxSummary: taxSummary, company: company);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        invoiceId = data['data']?['invoiceId']?.toString() ?? "";
        showCustomToast(context,  "Invoice Details Saved Successfully",);
      } else {
        showCustomToast(context,  "save Invoice details  error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('save Invoice details error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getGstDetails(dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _getGstList=[];
      final response = await api.getGstDetailsList( );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        _getGstList = List<Map<String, dynamic>>.from(data["data"]);
        _getGstList = List<Map<String, dynamic>>.from(data["data"]);

        if (_getGstList.isNotEmpty) {
          final gstData = _getGstList.first;
          cgstController.text = gstData["cgst"]?.toString() ?? "";
          sgstController.text = gstData["sgst"]?.toString() ?? "";
          igstController.text = gstData["igst"]?.toString() ?? "";
        }
      } else {
        showCustomToast(context,  "can not get gst error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getInvoiceDetails(dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _invoiceList=[];
      final response = await api.getInvoiceList( );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        final List<dynamic> invoicesJson = data["data"] ?? [];
        _invoiceList = invoicesJson.map((e) => InvoiceModel.fromJson(e)).toList();
      } else {
        print('getInvoice ${data["message"]}');
      }
    } catch (error) {
      print('getInvoice  list  error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getInvoiceById(String invoiceId,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _invoiceDetails=[];
      final response = await api.getInvoiceById(invoiceId);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        final rawData = data["data"];
        if (rawData is List) {
          _invoiceDetails = rawData
              .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (rawData is Map) {
          // Single invoice
          _invoiceDetails = [InvoiceModel.fromJson(rawData.cast<String, dynamic>())];
        } else {
          _invoiceDetails = [];
        }
        update();
      } else {
        print('getInvoice ${data["message"]}');
      }
    } catch (error) {
      print('getInvoice  list  error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getBasePlanList(String userType,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _basePlanList=[];
      final response = await api.getBasePlanList( userType,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> basePlans = data["data"];
        Api.userInfo.read('userType')=='admin';
        Api.userInfo.read('userType')=='superAdmin';
        final userType = Api.userInfo.read('userType');

        // _basePlanList = basePlans
        //     .map((e) => PlanModel.fromJson(e))
        //     .where((plan) {
        //   if (userType == 'admin' || userType == 'superAdmin') {
        //     return true; // allow all plans
        //   } else {
        //     return plan.planName.toString().toLowerCase() != 'free';
        //   }
        // }).toList();
        _basePlanList = basePlans.map((e) => PlanModel.fromJson(e)).toList();
        update();
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getIncomeDetailsByPlan({String? state,String? fromDate,String? toDate,dynamic context}) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.getIncomeDetails(state:state,fromDate: fromDate,
        toDate: toDate, );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
       // _incomeList = income.map((e) => IncomeDashboardModel.fromJson(e)).toList();
        _income = IncomeDashboardModel.fromJson(data["data"]);

        update();
      } else {
        showCustomToast(context,  "income details can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getExpense({String? state,String? month,String? year,dynamic context}) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _expenses=[];
      final response = await api.getExpenseDetails(state:state,month: month,
        year: year, );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        // _incomeList = income.map((e) => IncomeDashboardModel.fromJson(e)).toList();
        // List<dynamic> expenseList = data["data"]["total"];
        // _expenses = expenseList.map((e) => ExpenseModel.fromJson(e)).toList();
        // update();
        List<dynamic> expenseList = data["data"]["expenses"] ?? [];
        _expenses = expenseList.map((e) => ExpenseModel.fromJson(e)).toList();

        update();
      } else {
        showCustomToast(context,  "expense details can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getAddOnPlansList( String userType,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _addOnsPlanList=[];
      final response = await api.getAddOnsPlanList( userType,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> addOnsPlans = data["data"];
        update();
        _addOnsPlanList = addOnsPlans.map((e) => AddOnsPlanModel.fromJson(e)).toList();
      } else {
        showCustomToast(context,  "Plan can not get error ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getJobPlansList(String userType, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _jobPlanList=[];
      final response = await api.getJobPlanList( userType,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> jobPlans = data["data"];
        _jobPlanList = jobPlans.map((e) => JobPlanModel.fromJson(e)).toList();
        update();
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getWebinarPlansList(String userType, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _webinarPlanList=[];
      final response = await api.getWebinarPlanList( userType,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> webinarPlans = data["data"];
        update();
        _webinarPlanList = webinarPlans.map((e) => WebinarPlan.fromJson(e)).toList();
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getPostImagePlanList(String userType, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _postImagePlanList=[];
      final response = await api.getPostImagePlanList( userType,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success"){
        List<dynamic> postImagePlanList = data["data"];
        update();
        _postImagePlanList = postImagePlanList.map((e) => PostImagePlan.fromJson(e)).toList();
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getPostImageList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> checkPlansStatus(String userId, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _checkPlanList=[];
      final response = await api.checkPlansStatus( userId,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        _checkPlanList = List<Map<String, dynamic>>.from(data["data"]);
        update();
        if (_checkPlanList.isNotEmpty) {
          showPlanAlerts(userId, (_checkPlanList as List).map((e) => e as Map<String, dynamic>).toList(), context,);
        }
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('check plan status list error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> createPlans( String userType,String planId,String planName,String price,String markPrice,String duration,bool isImageAndroid1,bool isVideoAndroid1,
      bool isLocationAndroid1,bool isMobileNumber1,bool isServices1,String imageCount,String imageSize,String videoCount,String videoSize,List<String> features,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createBasePlan(userType,planId,planName,price, markPrice,duration, isImageAndroid1,isVideoAndroid1, isLocationAndroid1, isMobileNumber1, isServices1, imageCount, imageSize, videoCount, videoSize,features);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context,title: 'Success',message: "Plan added successfully");
        selectedUserType="";
        selectPlanId="";
        planNameController.clear();
        durationMonthsController.clear();
        markPriceController.clear();
        priceController.clear();
        durationDaysController.clear();
        imageSizeController.clear();
        imageCountController.clear();
        videoSizeController.clear();
        videoCountController.clear();
        isImageAndroid=false;
        isLocationAndroid=false;
        isMobileNumber=false;
        isVideoAndroid=false;
        isServices=false;
        selectedFeatures.clear();
        //showCustomToast(context,  "Plan added successfully",);
      } else {
        showCustomToast(context,  "Plan not added error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<bool> createUserPlans( String userId,String planId,String planName,String price,String startDate,String endDate,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return false;
    }
    isLoading=true;
    try {
      final response = await api.createUserBasePlan( userId, planId, planName,price, startDate, endDate);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
       await loginController.sentMailPlan(userId, "Plan", "Base Plan Purchased ", "basePlan", context);
       showSuccessDialog(context,title: 'Success',message: "Plan added successfully");

       selectedUserType="";
        selectPlanId="";
        planNameController.clear();
        priceController.clear();
        durationDaysController.clear();
        isImageAndroid=false;
        isLocationAndroid=false;
        isMobileNumber=false;
        isServices=false;
        selectedFeatures.clear();
        return true;
        //showCustomToast(context,  "Plan added successfully",);
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
        return false;
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> addExpenseDetail( String state,String title,String amount,String category,String month,String year,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.addExpenseDetail( state,title, amount, category, month, year);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context,title: 'Success',message: "Expense details added successfully");
      titleController.clear();
      amountController.clear();
      categoryController.clear();
      selectedMonthName='';
       selectedYear='';
      } else {
        showCustomToast(context,  "Expense can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('Expense list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
    Future<void> createAddonsPlans( String userType,String addOnsPlanId,String addOnsPlanName,String price,String markPrice,String duration,bool isStateWise1,
      bool isDistrictWise1,bool isCityWise1,bool isAreaWise1,List<String> features,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createAddonsPlans( userType, addOnsPlanId, addOnsPlanName, price, markPrice, duration, isStateWise1, isDistrictWise1, isCityWise1, isAreaWise1, features);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context,title: 'Success',message: "Plan added successfully");
        selectedUserType="";
        selectAddOnsId="";
        planNameController.clear();
        priceController.clear();
        durationDaysController.clear();
        durationMonthsController.clear();
        markPriceController.clear();
        isStateWise=false;
        isDistrictWise=false;
        isCityWise=false;
        isAreaWise=false;
        selectedFeatures.clear();
        //showCustomToast(context,  "Plan added successfully",);
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> createUserAddonsPlans( String userId,String addOnsPlanId,String addOnsPlanName,String price,String startDate,String endDate, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createAddonsUserPlans(userId, addOnsPlanId, addOnsPlanName,price, startDate, endDate,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context,title: 'Success',message: "Plan added successfully");
        loginController.sentMailPlan(userId, "Plan", "AddOns Plan Purchased ", "addonsPlan", context);
        notificationController.createNotification( userId,Api.userInfo.read('userType')??"",'Plan',"AddOns Plan Purchased ",Api.userInfo.read('state'),Api.userInfo.read('district'),Api.userInfo.read('city'),Api.userInfo.read('area'),context);
        //showCustomToast(context,  "Plan added successfully",);
      } else {
        showCustomToast(context,  "plan not added,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> createJobPlans( String userType,String jobPlansId,String jobPlanName,String price,String markPrice,String duration,bool isStateWise1,
  bool isDistrictWise1,bool isCityWise1,bool isAreaWise1,String count,List<String> features,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createJobPlans(userType, jobPlansId, jobPlanName, price, markPrice,duration, isStateWise,
       isDistrictWise, isCityWise, isAreaWise, count, features);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context,title: 'Success',message: "Plan added successfully");
        selectedUserType='';
        planNameController.clear();
        selectJobId='';
        priceController.clear();
        durationDaysController.clear();
        durationMonthsController.clear();
        markPriceController.clear();
        isStateWise=false;
        isDistrictWise=false;
        isCityWise=false;
        isAreaWise=false;
        selectedFeatures.clear();
        //showCustomToast(context,  "Plan added successfully",);
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> createWebinarPlans(String userType,String webinarPlanId,String webinarPlanName,String price,String markPrice,String duration,bool isStateWise1,
  bool isDistrictWise1,bool isCityWise1,bool isAreaWise1,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createWebinarPlan(userType, webinarPlanId, webinarPlanName, price, duration, markPrice, isStateWise1, isDistrictWise1, isCityWise1, isAreaWise1);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context,title: 'Success',message: "Plan added successfully");
        selectedUserType='';
        planNameController.clear();
        selectJobId='';
        priceController.clear();
        durationDaysController.clear();
        durationMonthsController.clear();
        markPriceController.clear();
        isStateWise=false;
        isDistrictWise=false;
        isCityWise=false;
        isAreaWise=false;
        selectedFeatures.clear();
        //showCustomToast(context,  "Plan added successfully",);
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  // Future<void> createPostImagesPlans(String userType,String postImagesPlanId,String postPlanName,String price,String duration,bool isStateWise1,
  // bool isDistrictWise1,bool isCityWise1,bool isAreaWise1,dynamic context) async {
  Future<void> createPostImagesPlans(String userType,String postImagesPlanId,String postPlanName,String price,String markPrice,String duration,dynamic context) async {
  var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createPostImagePlans(  userType, postImagesPlanId, postPlanName, price,markPrice, duration);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context,title: 'Success',message: "Plan added successfully");
        selectedUserType='';
        planNameController.clear();
        selectJobId='';
        priceController.clear();
        durationDaysController.clear();
        durationMonthsController.clear();
        markPriceController.clear();
        isStateWise=false;
        isDistrictWise=false;
        isCityWise=false;
        isAreaWise=false;
        selectedFeatures.clear();
        //showCustomToast(context,  "Plan added successfully",);
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> createUserJobPlans( String userId,String jobPlansId,String jobPlanName,String price,String startDate,String endDate,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createJobUserPlans(userId, jobPlansId, jobPlanName,price,startDate, endDate);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context,title: 'Success',message: "Plan added successfully");
        loginController.sentMailPlan(userId, "Plan", "Job Plan Purchased", "jobPlan", context);
        notificationController.createNotification( userId,Api.userInfo.read('userType')??"",'Plan',"Job Plan Purchased",Api.userInfo.read('state'),Api.userInfo.read('district'),Api.userInfo.read('city'),Api.userInfo.read('area'),context);
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> createUserWebinarPlans( String userId,String webinarPlanId,String webinarUserPlansName,String price,String startDate,String endDate,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createWebinarUserPlan( userId, webinarPlanId, webinarUserPlansName, price,startDate, endDate);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context,title: 'Success',message: "Plan added successfully");
        loginController.sentMailPlan(userId, "Plan", "Webinar Plan Purchased", "jobPlan", context);
        notificationController.createNotification( userId,Api.userInfo.read('userType')??"",'Plan',"Webinar Plan Purchased",Api.userInfo.read('state'),Api.userInfo.read('district'),Api.userInfo.read('city'),Api.userInfo.read('area'),context);
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> createUserPostImagePlans( String userId,String postImagesPlanId,String postPlanName,String price,String startDate,String endDate,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createPostImageUserPlans( userId, postImagesPlanId, postPlanName,price,startDate, endDate);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context,title: 'Success',message: "Plan added successfully");
        loginController.sentMailPlan(userId, "Plan", "Scrolling Ads Purchased", "jobPlan", context);
        notificationController.createNotification( userId,Api.userInfo.read('userType')??"",'Plan',"Scrolling Ads Plan Purchased",Api.userInfo.read('state'),Api.userInfo.read('district'),Api.userInfo.read('city'),Api.userInfo.read('area'),context);
      } else {
        showCustomToast(context,  "Plan can not get error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('getBasePlanList list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getUploadImages(
  {String? userId,required  String userType,dynamic context}) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    _posterImage=[];
    editUploadImage1=[];
    try {
      final response = await api.getUploadImages( userId:userId, userType:userType);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        // String cleanUrl( String path) {
        //   return replaceAll(RegExp(r'\/$'), '') + '/' + path.replaceAll("\\", "/");
        // }
        // editUploadImage = (data["data"] as List).map((u) => AppImage(
        //   url: cleanUrl(AppConstants.baseUrl, u["path"]),
        // )).toList();
        editUploadImage1 = (data["data"] as List).map((u) => AppImage2(
          url:  u["path"],
        )).toList();
        _posterImage = (data["data"] as List).map((e) => PosterImageModel.fromJson(e)).toList();

        //  _posterImage = (data["data"] as List).map((e) => PosterImageModel.fromJson(e)).toList();
        update();
      } else {
        showCustomToast(context,  "can not get image error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('get image upload list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> uploadImagesUserType(String userId, String userType,String imageId,String preference,String startDate,String endDate,String isActive,
      List<Uint8List>posterImage,
      dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _checkPlanList=[];
      final response = await api.uploadImagesUserType( userId,userType, imageId, preference, startDate, endDate,isActive,posterImage);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        await showSuccessDialog(context, title:"Success",message :"image uploaded", onOkPressed: () {
          Navigator.pop(context);
        });
      } else {
        showCustomToast(context, "image not upload error,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('check plan status list error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
}