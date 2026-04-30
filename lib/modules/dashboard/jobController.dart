import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:locate_your_dentist/model/AppliedJobSeekerList_model.dart';
import 'package:locate_your_dentist/model/job_category_model.dart';
import 'package:locate_your_dentist/model/job_model.dart';
import 'package:locate_your_dentist/model/webinar_jobseeker_model.dart';
import 'package:locate_your_dentist/model/webinar_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

class JobController extends GetxController{
  var isLoading = false;
  List<JobModel>_jobList=[];
  List<JobModel> get jobList=>_jobList;
  List<JobModel>_jobListJobSeekers=[];
  List<JobModel> get jobListJobSeekers=>_jobListJobSeekers;
  List<WebinarJobSeekers>_webinarListJobSeekers=[];
  List<WebinarJobSeekers> get webinarListJobSeekers=>_webinarListJobSeekers;
  List<JobSeekerAppliedModel>_jobIdListAdmin=[];
  List<JobSeekerAppliedModel> get jobIdListAdmin=>_jobIdListAdmin;
  List<Map<String, dynamic>> jobDescriptionData = [];
  List<Map<String, dynamic>> webDescriptionData = [];

  String? isActive;
  List<JobCategoryModel>_jobCategoryAdmin=[];
  List<JobCategoryModel> get jobCategoryAdmin=>_jobCategoryAdmin;
 // dynamic jobDescriptionData;
  List<JobModel>_jobSeekersAppliedLists=[];
  List<JobModel> get jobSeekersAppliedLists=>_jobSeekersAppliedLists;
  List<WebinarModel>_webinarList=[];
  List<WebinarModel> get webinarList=>_webinarList;
  List<JobModel>_job=[];
  List<JobModel> get job=>_job;
  List<WebinarModel>_webinar=[];
  List<WebinarModel> get webinar=>_webinar;
  List<WebinarModel>_appliedWebinarList=[];
  List<WebinarModel> get appliedWebinarList=>_appliedWebinarList;
  final Api api = Api();
  String? selectedUserType;
  String? selectedTitle;

  String? alert;
  final loginController=Get.put(LoginController());
  final notificationController=Get.put(NotificationController());
  String? webinarImage;
  String? jobImage;
  String? selectedJobId;
  String? selectedWebinarId;
  int? jobCount;
  String? startHour;
  String? startMinutes;
  String? startPeriod;
  String? endPeriod;
  String? endHour;
  String? endMinutes;
  bool? planActive;

  RxList<File> images = <File>[].obs;
  RxList<int> preferences = <int>[].obs;
  RxString userType = ''.obs;



// Assign to your controller
//   _controller = QuillController(
//   document: document,
//   selection: const TextSelection.collapsed(offset: 0),
//   );
  Future<void> getJobListAdmin( dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _jobList=[];
      final response = await api.getJobListAdmin();
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> jobs = data["data"];

        _jobList = jobs.map((e) => JobModel.fromJson(e)).toList();
        // showCustomToast(context,  "Profile details fetched",);
      } else {
        showCustomToast(context,  "job Failed,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('job list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getJobListJobSeekers({required String search,
      String? state,
      String? district,
      String? city,String? jobType, List<String>? jobCategory,String? salary, dynamic context}) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _jobListJobSeekers=[];
      final response = await api.getJobListJobSeekers(search: search, state:state, district:district, city:city, jobType:jobType,jobCategory: jobCategory,salary: salary );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> jobs = data["data"];
        _jobListJobSeekers = jobs.map((e) => JobModel.fromJson(e)).toList();
        print("Total job profiles: ${_jobListJobSeekers.length}");
      } else {
        showCustomToast(context, "Job failed: ${data["message"]}");
      }
    } catch (e) {
      print('jobseeker list error $e');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getWebinarListJobSeekers(String state,String district,String city, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _webinarListJobSeekers=[];
      final response = await api.getWebinarListJobSeekers(  state, district, city, );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> webinars = data["data"];
        _webinarListJobSeekers = webinars.map((e) => WebinarJobSeekers.fromJson(e)).toList();
        print("Total getWebinarListJobSeekers: ${_webinarListJobSeekers.length}");
      } else {
        showCustomToast(context, "webinar failed: ${data["message"]}");
      }
    } catch (e) {
      print('jobseeker list error $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> checkJobPlanStatus(String userId, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.checkJobPlanStatus( userId);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        jobCount=data["counts"]??0;
        print('jobcount $jobCount');
        planActive=data["planActive"];
        print('ddl$planActive');
        update();
      } else {
        showCustomToast(context, "no Job plan found: ${data["message"]}");
      }
    } catch (e) {
      print('jobseeker list error $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getAppliedJobsAdmin(String jobId, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _jobIdListAdmin=[];
      final response = await api.getAppliedJobsAdmin( jobId);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> jobs = data["data"];
        _jobIdListAdmin = jobs.map((e) => JobSeekerAppliedModel.fromJson(e)).toList();
        print("Total _jobIdListAdmin profiles: ${_jobIdListAdmin.length}");
      } else {
        print("Job list get error: ${data["message"]}");
       // showCustomToast(context, "Job failed: ${data["message"]}");
      }
    } catch (e) {
      print('_jobId List Admin error $e');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getAppliedWebinarsAdmin(String webinarId, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _appliedWebinarList=[];
      final response = await api.getAppliedWebinarsAdmin( webinarId);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> webinars = data["data"];
        _appliedWebinarList = webinars.map((e) => WebinarModel.fromJson(e)).toList();
        print("Total _appliedWebinarList profiles: ${_appliedWebinarList.length}");
      } else {
        showCustomToast(context, "Job failed: ${data["message"]}");
      }
    } catch (e) {
      print('_jobId List Admin error $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> updateJobStatusAdmin(String jobSeekerId,String jobId,String status,String orgName, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _jobIdListAdmin=[];
      final response = await api.updateJobStatusAdmin( jobSeekerId, jobId,status);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showCustomToast(context,  "Status Updated successfully");
        await sentMailJob( jobSeekerId,'update',[], jobId ?? "", "your Job application status was updated", status,context);
        await notificationController.createNotification(jobSeekerId,Api.userInfo.read('userType') ?? '', 'job', 'your status of job application was changed', '','','','',context);
      } else {
        showCustomToast(context, "status not  updated: ${data["message"]}");
      }
    } catch (e) {
      print('jobId List Admin error $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> updateApplicationStatusAdmin(String jobId,String isActive, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _jobIdListAdmin=[];
      final response = await api.updateApplicationStatusAdmin( jobId, isActive);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showCustomToast(context,  "Status Updated successfully");
      } else {
        showCustomToast(context, "status not  updated: ${data["message"]}");
      }
    } catch (e) {
      print('_jobId List Admin error $e');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> createJobCategoryAdmin(String userType,String jobCategory,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _jobIdListAdmin=[];
      final response = await api.createJobCategoryAdmin( userType, jobCategory );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showCustomToast(context,  "Added category successfully");
      } else {
        showCustomToast(context, "category not added error: ${data["message"]}");
      }
    } catch (e) {
      print('_jobId List Admin error $e');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> updateJobCategoryAdmin(String id,String name,String isActive ,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _jobIdListAdmin=[];
      final response = await api.updateJobCategoryAdmin(  id, name, isActive );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showCustomToast(context,  "Added category successfully");
      } else {
        showCustomToast(context, "category not added error: ${data["message"]}");
      }
    } catch (e) {
      print('_jobId List Admin error $e');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getJobCategoryLists(String? userType,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _jobCategoryAdmin=[];
      final response = await api.getJobCategoryLists( userType );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> jobs = data["data"];
        _jobCategoryAdmin = jobs.map((e) => JobCategoryModel.fromJson(e)).toList();
      } else {
        showCustomToast(context, "category not get error: ${data["message"]}");
      }
    } catch (e) {
      print('_jobId List Admin error $e');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> deleteJobCategoryLists(String? id,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _jobCategoryAdmin=[];
      final response = await api.deleteJobCategoryLists( id );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showCustomToast(context, "Category Deleted Successfully");

      } else {
        showCustomToast(context, "Category not deleted error: ${data["message"]}");
      }
    } catch (e) {
      print('_jobId List Admin error $e');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> updateWebinarStatusAdmin(String webinarId,String isActive, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _jobIdListAdmin=[];
      final response = await api.updateWebinarStatusAdmin( webinarId, isActive);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showCustomToast(context,  "Status Updated successfully");
      } else {
        showCustomToast(context, "status not  updated: ${data["message"]}");
      }
    } catch (e) {
      print('_jobId List Admin error $e');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getJobSeekersAppliedLists(String jobSeekerId,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _jobSeekersAppliedLists=[];
      final response = await api.getJobSeekersAppliedLists( jobSeekerId);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> jobs = data["data"];
        _jobSeekersAppliedLists = jobs.map((e) => JobModel.fromJson(e)).toList();
      } else {
        print('view Jobs failed: ${data["message"]}');
       // showCustomToast(context, "view Jobs failed: ${data["message"]}");
      }
    } catch (e) {
      print('view Jobs  list error $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getWebinarListAdmin( dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _webinarList=[];
      final response = await api.getWebinarListAdmin();
      var data = jsonDecode(response.body);
      if ( data["status"] == "Success") {
        List<dynamic> jobs = data["data"];

        _webinarList = jobs.map((e) => WebinarModel.fromJson(e)).toList();
        print('Total job profiles: ${_webinarList.length}');
        // showCustomToast(context,  "Profile details fetched",);
      } else {
        showCustomToast(context,  "job  Failed, ${data["message"] ?? "error"}",);
        //Get.snackbar("Login Failed", data["message"] ?? "error");
      }
    } catch (error) {
      print('webinar list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
    Future<void> applyJobsJobSeekers( String jobId,String jobSeekersId,String userType,String orgName,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      final response = await api.applyJobsJobseekers(jobId,jobSeekersId,userType);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        String appliedKey = "${jobId}_${jobSeekersId}";
        Api.userInfo.write(appliedKey, true);
        bool alert = data['alert'] == true;
        update();
       alert ? showSuccessDialog(context, title:"Success",message :"Applied Job Successfully", onOkPressed: () {}):
        showCustomToast(context,  "Already applied for this Job",backgroundColor: AppColors.primary);
        await sentMailJob(Api.userInfo.read('userId') ?? '', 'update',[],jobId ?? '', "your Job application is submitted successfully", "Applied", context);
         notificationController.createNotification(Api.userInfo.read('userId') ?? '',Api.userInfo.read('userType') ?? '', 'job', 'Your application to ${orgName ?? ""} was submitted successfully','','','','', context);
      } else {
        showCustomToast(context,  "job application Failed, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('job application error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> applyWebinarJobSeekers( String webinarId,String jobSeekersId,String userType,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      final response = await api.applyWebinarsJobseekers(webinarId,jobSeekersId,userType);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        bool alert = data['alert'] == true;
        update();
        alert ? showSuccessDialog(context, title:"Success",message :"Applied Webinar Successfully", onOkPressed: () {
        }):
        showCustomToast(context,  "Already applied for this Webinar",backgroundColor: AppColors.primary);
        showCustomToast(context,  "Already applied for this Webinar",backgroundColor: AppColors.primary);
      } else {
        showCustomToast(context,  "webinar apply error, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('job application error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> postJobsAdmin(String jobId,String userId,String userType,String jobType,List<String> jobCategory,String orgName, String jobTitle,String jobDescription,
      String salary,String qualification, String experience,String state,String district,
      String city,String startTime,String endTime,jobImage1,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {

   // final response = await api.postJobsAdmin( jobId, userId, userType, jobType,jobCategory, orgName,  jobTitle, jobDescription, salary, qualification, experience, state, district, city, startTime, endTime,jobImage1);
    final response = await api.postJobsAdmin(
        jobId,
        userId,
        userType,
        jobType,
        jobCategory,
        orgName,
        jobTitle,
        jobDescription,
        salary,
        qualification,
        experience,
        state,
        district,
        city,
        startTime,
        endTime,
        jobImage1
    );
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
       // if (!context.mounted) return;
        await sentMailJob( userId,'new',jobCategory, jobId ?? '', "New Job Opening from ${orgName}", "", context);
        await notificationController.createNotification(userId,Api.userInfo.read('userType') ?? '', 'job', 'New Job Opening from ${orgName}', '','','','',context);

        showSuccessDialog(context, title:"Success",message :"Posted Job Successfully", onOkPressed: () {
        });
        loginController.selectedJobType="";
    loginController.typeNameController.clear();
    loginController.jobTitleController.clear();
    loginController.jobDescController.clear();
    loginController.selectedSalary="";
    loginController.qualificationJobController.clear();
    loginController.selectedExperience="";
    loginController.selectedJobType="";
    loginController.selectedExperience="";
    loginController.selectedSalary="";
         startHour='';
         startMinutes="";
         startPeriod="";
         endHour="";
         endMinutes="";
         endPeriod="";
         jobImage="";
         //Get.toNamed('/viewJobWebinarPage');
      } else {
        showCustomToast(context,  "Job post Failed, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('job application error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> postWebinarAdmin(String webinarId, String userId,String userType,String orgName,String webinarTitle,String webinarDescription,String webinarLink,String webinarDate,String startTime,String endTime, webinarImage1,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.postWebinarAdmin(  webinarId,  userId, userType, orgName, webinarTitle, webinarDescription, webinarLink, webinarDate, startTime, endTime,webinarImage1);

      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context, title:"Success",message :"Posted Webinar Successfully", onOkPressed: () {
        });
        loginController.webinarTitleJobController.clear();
        loginController.webinarDescriptionJobController.clear();
        loginController.webinarLinkController.clear();
        loginController.webinarDateController.clear();
        loginController.startHour='';
        loginController.startMinutes="";
        loginController.startPeriod="";
        loginController.endHour="";
        loginController.endMinutes="";
        loginController.endPeriod="";
        webinarImage="";
        getWebinarListAdmin(context);
      } else {
        showCustomToast(context,  "Job post Failed, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('job application error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getJobsById(String jobId, context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }

    isLoading = true;

    try {
      print('API request for jobId: $jobId');
      _job = [];
      final response = await api.getJobByJobId(jobId, );
      var data = jsonDecode(response.body);
      print("API Response: $data");
      if (data["status"].toString().toLowerCase() == "success") {
        List<dynamic> list = data["data"];
        if (list.isEmpty) {
          print(" No job found — list is empty");
          _job = [];
          update();
          return;
        }
        _job = list.map((job) => JobModel.fromJson(job)).toList();
        loginController.jobTitleController.text=_job.first.jobTitle??"";
        selectedJobId=_job.first.jobId??"";
        //jobDescriptionData = _job.first.jobDescription;
        //loginController.jobDescController.text=_job.first.jobDescription??"";
        // jobDescriptionData =
        // List<Map<String, dynamic>>.from(_job.first.jobDescription ?? []);
        jobDescriptionData = _job.first.jobDescription ?? [];
       // jobDescriptionData = _job.first.jobDescription??"";
        // final List<dynamic> delta =
        // List<Map<String, dynamic>>.from(job['jobDescription']);
        loginController.selectedSalary=_job.first.salary??"";
        loginController.qualificationJobController.text=_job.first.qualification??"";
        loginController.selectedExperience=_job.first.experience??"";
        loginController.selectedJobType=_job.first.jobType??"";
        String startTime = _job.first.details?["startTime"]?.toString() ?? "";
        String endTime = _job.first.details?["endTime"]?.toString() ?? "";

        final images = _job.first.jobImage ?? [];
        // if (_job.first.jobCategory != null) {
        //   loginController.selectedCategories =
        //   List<String>.from(_job.first.jobCategory! );
        //   print('categoryy${loginController.selectedCategories}');
        // } else {
        //   loginController.selectedCategories = [];
        // }
        List<String> parseCategory(dynamic data) {
          if (data == null) return [];

          if (data is List) {
            return data.map((e) => e.toString().trim()).toList();
          }

          if (data is String && data.isNotEmpty) {
            return [data.trim()];
          }
          return [];
        }
       //  final rawCategory = data["data"][0]["jobCategory"];
       //  loginController.selectedCategories =
       //  (rawCategory is List)
       //      ? rawCategory.map((e) => e.toString().trim()).toList()
       //      : [];
       // // loginController.selectedCategories = parseCategory(_job.first.jobCategory);
       //  print("Selected Categories: ${loginController.selectedCategories}");
        final rawCategory = data["data"][0]["jobCategory"];

        String normalize(String v) => v.trim().toLowerCase();

        if (rawCategory is List) {
          loginController.selectedCategories =
              rawCategory.map((e) => normalize(e.toString())).toList();

        } else if (rawCategory is String && rawCategory.isNotEmpty) {
          try {
            final decoded = jsonDecode(rawCategory);
            if (decoded is List) {
              loginController.selectedCategories =
                  decoded.map((e) => normalize(e.toString())).toList();
            } else {
              loginController.selectedCategories = [];
            }
          } catch (e) {
            loginController.selectedCategories = [];
          }

        } else {
          loginController.selectedCategories = [];
        }

        print("FINAL SELECTED: ${loginController.selectedCategories}");
        loginController.jobFileImages = images
            .map((u) => AppImage2(url:  u.replaceAll("\\", "/")))
            .toList();

        void splitStartTime(String time) {
          if (time.isEmpty) return;
          time = time.trim().toLowerCase();
          String period = time.contains("am") ? "am" : "pm";
          String cleanTime = time.replaceAll("am", "").replaceAll("pm", "").trim();
          List<String> hm = cleanTime.contains(":")
              ? cleanTime.split(":")
              : cleanTime.split(".");
          if (hm.length == 2) {
            startHour = hm[0];
            startMinutes = hm[1];
            startPeriod = period;
          }
        }
        void splitEndTime(String time) {
          if (time.isEmpty) return;
          time = time.trim().toLowerCase();
          String period = time.contains("am") ? "am" : "pm";
          String cleanTime = time.replaceAll("am", "").replaceAll("pm", "").trim();
          List<String> hm = cleanTime.contains(":")
              ? cleanTime.split(":")
              : cleanTime.split(".");
          if (hm.length == 2) {
            endHour = hm[0];
            endMinutes = hm[1];
            endPeriod = period;
          }
        }
        splitStartTime( startTime);
        splitEndTime( endTime);
        print(startTime);
        print("Total job profiles: ${_job.length}");
        loginController.update();
//   final jobDescriptionJson = _job.first.jobDescription ?? "[]";
//   List<dynamic> jobDescriptionDelta = jsonDecode(jobDescriptionJson);
//
// // Create a Quill document from the delta
//   final document = Document.fromJson(jobDescriptionDelta);

  } else {
        showCustomToast(
          context,
          "Job not found error: ${data["message"] ?? "error"}",
        );
      }
    } catch (e) {
      print('job by id  error $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getWebinarById(String webinarId, String isActive, context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading = true;
    try {
      print('API request for jobId: $webinarId');
      _webinar = [];

      final response = await api.getWebinarById(webinarId, isActive);
      var data = jsonDecode(response.body);
      print("API Response:$isActive $data");
      if (data["status"].toString().toLowerCase() == "success") {
        List<dynamic> list = data["data"];
        if (list.isEmpty) {
          print(" No webinar found  list is empty");
          _webinar = [];
          update();
          return;
        }
        _webinar = list.map((job) => WebinarModel.fromJson(job)).toList();
        loginController.webinarTitleJobController.text=_webinar.first.webinarTitle??"";
        selectedWebinarId = _webinar.first.webinarId?.toString() ?? "";
        webDescriptionData=_webinar.first.webinarDescription??[];
        //loginController.webinarDescriptionJobController.text=_webinar.first.webinarDescription??"";
        loginController.webinarDateController.text=_webinar.first.webinarDate??"";
        loginController.webinarLinkController.text=_webinar.first.webinarLink??"";
        //webinarImage=_webinar.first.webinarImage??"";
        String startTime=_webinar.first.startTime??"";
        String endTime=_webinar.first.endTime??"";
        // final images = _webinar.first.webinarImage ?? [];
        //
        // loginController.webinarFileImages = images
        //     .map((u) => AppImage2(url: u.replaceAll("\\", "/")))
        //     .toList();
        final images = _webinar.first.webinarImage ?? [];

        loginController.webinarImages = images
            .map((u) => AppImage2(
          url: u.replaceAll("\\", "/"),
        ))
            .toList();

        loginController.update();
        void splitTime(String startTime) {
          final parts = startTime.split(" ");

          final hm = parts[0].split(":");
          final hour = hm[0];
          final minute = hm[1];
          final period = parts[1];

          loginController.startHour = hour;
          loginController.startMinutes = minute;
          loginController.startPeriod = period;
        }
        void splitTime1(String endTime) {
          final parts = startTime.split(" ");

          final hm = parts[0].split(":");
          final hour = hm[0];
          final minute = hm[1];
          final period = parts[1];

          loginController.endHour = hour;
          loginController.endMinutes = minute;
          loginController.endPeriod = period;
        }
        splitTime( startTime);
        splitTime1( endTime);
        print("Total webinar profiles: ${_webinar.length}");
      } else {
        showCustomToast(
          context,
          "webinar not found error: ${data["message"] ?? "error"}",
        );
      }

    } catch (e) {
      print('job by id  error $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> sentMailJob(String userId,String title,List<String> jobCategory,String? jobId, String? Subject, String? jobStatus, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.
      createJobMail(userId, title,jobCategory,jobId!,Subject,jobStatus);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showCustomToast(context,"mail sent successfully",);
      } else {
        showCustomToast(context,"mail not get error, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('get mail error ${error}');
    } finally {
      isLoading = false;
      update();
    }
  }
}