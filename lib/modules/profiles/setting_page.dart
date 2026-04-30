import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import '../../common_widgets/common_bottom_navigation.dart';
import '../../common_widgets/common_textstyles.dart';
import '../../common_widgets/common_widget_all.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';

class SettingsPageMobile extends StatefulWidget {
  const SettingsPageMobile({super.key});

  @override
  State<SettingsPageMobile> createState() => _SettingsPageMobileState();
}

class _SettingsPageMobileState extends State<SettingsPageMobile> {
  late List<Map<String, dynamic>> settingList;
  final jobController = Get.put(JobController());
  String selectedUserType = Api.userInfo.read('userType') ?? "";
  final loginController = Get.put(LoginController());
  @override
  void initState() {
    super.initState();
    final String selectedUserType = Api.userInfo.read('userType') ?? "";
    print('type: $selectedUserType');
    loginController.getProfileByUserId(Api.userInfo.read('userId') ?? "", context);
    loginController.getBranchDetails(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      settingList = _getSettingsForUser(selectedUserType);
      setState(() {});
    });
  }
  List<Map<String, String>> _getSettingsForUser(String userType) {
    switch (userType) {
      case 'Dental Lab':
        return [
          {"title": "Lab Profile", "page": "/mechanicDashboard"},
          {"title": "Edit Profile", "page": "/clinicEditProfile"},
          {"title": "My Subscription", "page": "/viewPlanPage"},
          {"title": "Job/Webinars", "page": "/viewJobWebinarPage"},
          {"title": "Services", "page": "/viewServiceList"},
          {"title": "Change Password", "page": "/changePasswordPage"},
          {"title": "About Us", "page": "/aboutUsPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'superAdmin':
        return [
          {"title": "Dashboard", "page": "/superAdminDashboard"},
          {"title": "Add admin", "page": "/registerPage"},
          {"title": "User List", "page": "/userTypeListPage"},
          {"title": "My Subscription", "page": "/viewPlanPage"},
          {"title": "Reports", "page": "/viewReportPage"},
          {"title": "Create Scrolling Ads Post", "page": "/createPostImages"},
          {"title": "Create Notification", "page": "/createNotificationPage"},
          {"title": "Change Password", "page": "/changePasswordPage"},
          {"title": "AddGst", "page": "/addGSTPage"},
          {"title": "change Logo", "page": "/changLogoImagePage"},
          {"title": "Add JobCategory", "page": "/addJobCategoryPage"},
          {"title": "AddCompany", "page": "/addCompanyPage"},
          {"title": "Add Legal Pages", "page": "/addLegalPageMobile"},
          {"title": "About Us", "page": "/aboutUsPage"},
          {"title": "Contact Us", "page": "/contactUsMobilePage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'admin':
        return [
          {"title": "Dashboard", "page": "/superAdminDashboard"},
          {"title": "My Subscription", "page": "/viewPlanPage"},
          {"title": "User List", "page": "/userTypeListPage"},
          {"title": "Change Password", "page": "/changePasswordPage"},
          {"title": "About Us", "page": "/aboutUsPage"},
          {"title": "Contact Us", "page": "/contactUsMobilePage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'Dental Clinic':
        bool multipleBranches = loginController.userBranchesList.length > 1;
        return [
          {"title": "Clinic Profile", "page": "/clinicProfilePage"},
          multipleBranches
              ? {"title": "My Subscription", "page": "/branchListPage"}
              : {"title": "My Subscription", "page": "/viewPlanPage"},
          {"title": "My Purchases", "page": "/viewInvoiceListPage"},
          {"title": "Services", "page": "/viewServiceList"},
          {"title": "Contact Form", "page": "/viewSenderContactList"},
          {"title": "Change Password", "page": "/changePasswordPage"},
          {"title": "Add Branches", "page": "/addBranchesPage"},
          {"title": "About Us", "page": "/aboutUsPage"},
          {"title": "Contact Us", "page": "/contactUsMobilePage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'Dental Shop':
        return [
          {"title": "Shop Profile", "page": "/mechanicDashboard"},
          {"title": "My Subscription", "page": "/viewPlanPage"},
          {"title": "My Purchases", "page": "/viewInvoiceListPage"},
          {"title": "Job/Webinars", "page": "/viewJobWebinarPage"},
          {"title": "Products", "page": "/viewServiceList"},
          {"title": "Add Profile", "page": "/clinicEditProfile"},
          {"title": "Change Password", "page": "/changePasswordPage"},
          {"title": "About Us", "page": "/aboutUsPage"},
          {"title": "Contact Us", "page": "/contactUsMobilePage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'Dental Mechanic':
      case 'Dental Consultant':
        return [
          {"title": "Profile", "page": "/mechanicDashboard"},
          {"title": "Edit Profile", "page": "/clinicEditProfile"},
          {"title": "My Subscription", "page": "/viewPlanPage"},
          {"title": "My Purchases", "page": "/viewInvoiceListPage"},
          {"title": "Job/Webinars", "page": "/viewJobWebinarPage"},
          {"title": "Services", "page": "/viewServiceList"},
          {"title": "Change Password", "page": "/changePasswordPage"},
          {"title": "About Us", "page": "/aboutUsPage"},
          {"title": "Contact Us", "page": "/contactUsMobilePage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'Job Seekers':
        return [
          {"title": "Profile", "page": "/jobSeekerViewProfilePage"},
          {"title": "My Jobs", "page": "/appliedJobListPage"},
          {"title": "Edit Profile", "page": "/jobSeekerEditProfilePage"},
          {"title": "Jobs", "page": "/filterPageJobSeekersPage"},
          {"title": "Change Password", "page": "/changePasswordPage"},
          {"title": "About Us", "page": "/aboutUsPage"},
          {"title": "Contact Us", "page": "/contactUsMobilePage"},
          {"title": "Logout", "page": "/logout"},
        ];
      default:
        return []; // fallback
    }
  }
  @override
  Widget build(BuildContext context) {
    double s = MediaQuery.of(context).size.width;
    String userName = Api.userInfo.read('personName') ?? "";
    String userId = Api.userInfo.read('userId') ?? "";
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColors.black,
          size: s * 0.05,
        ),
        title: Text(
          "Settings",
          style: AppTextStyles.subtitle(context, color: AppColors.black),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: s * 0.06,
                    horizontal: 20,
                  ),
                  decoration:  BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [ AppColors.primary.withOpacity(0.9),
                            AppColors.secondary.withOpacity(0.6),],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  ),
                  child: Row(
                    children: [

                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: AppColors.white,
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: AssetImage(
                            "assets/images/doctor5.jpg",
                          ),
                        ),
                      ),

                      SizedBox(width: s * 0.05),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: AppTextStyles.subtitle(
                                context,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "UserID: $userId",
                              style: AppTextStyles.caption(
                                context,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child:  IconButton(
                          onPressed: (){
                            (Api.userInfo.read('userType')=='Job Seekers')?Get.toNamed('/jobSeekerEditProfilePage'): Get.toNamed('/clinicEditProfile');
                            },
                          icon:Icon(Icons.edit,
                          size: s*0.06,
                          color: AppColors.white,
                        ),)
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: s * 0.05),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimationLimiter(
                  child:AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: const Duration(milliseconds: 700),
                    child: SlideAnimation(
                      horizontalOffset: 80.0,
                      curve: Curves.easeOutCubic,
                      child: FadeInAnimation(
                        child: Column(
                          children: settingList.map((setting) {
                            return Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    _getIcon(setting['title']),
                                    color: AppColors.primary,size: s*0.06,
                                  ),
                                  title: Text(
                                    setting['title'],
                                    style: AppTextStyles.caption(
                                      context,fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 18),
                                  onTap: () async {
                                    final String title = setting['title'] ?? '';

                                    if (title == "Logout") {
                                      showLogoutDialog(context);
                                    } else if (title == "Jobs") {
                                      await jobController.getJobListJobSeekers(search: '',context: context);
                                      Get.toNamed(setting['page']);
                                    }
                                    else if (title == "User List") {
                                      if( Api.userInfo.read('userType')=="superAdmin") {
                                        await   loginController.getProfileDetails('', '', '', '', '','','','','',  context);
                                      }
                                      if( Api.userInfo.read('userType')=="admin") {
                                        await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", '', '', '','','','','', context);
                                      }
                                      Get.toNamed('/userTypeListPage');
                                    }
                                else if (title == "Profile") {
                                      Api.userInfo.write('selectUId',userId);
                                Get.toNamed(setting['page']);
                                     }
                                    else {
                                      Get.toNamed(setting['page']);
                                    }
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Divider(thickness: 0.3,color: Colors.grey,),
              ),
              Text('App Version 1.0.0',style: AppTextStyles.caption(context,color: AppColors.grey),)
              // Divider(thickness: 0.3,color: Colors.grey,)
            ],
          ),
        ),
      ),

      bottomNavigationBar:
      const CommonBottomNavigation(currentIndex: 0),
    );
  }
  IconData _getIcon(String title) {
    switch (title) {
      case "Profile":
      case "Clinic Profile":
      case "Lab Profile":
      case "Shop Profile":
        return Icons.person;

      case "Dashboard":
        return Icons.dashboard;

      case "Plans":
      case "My Plan":
      case "My Subscription":
        return Icons.workspace_premium;

      case "Services":
        return Icons.medical_services;
      case "Add Admin":
        return Icons.person;
      case "Reports":
        return Icons.list_alt_rounded;
      case "Jobs":
        return Icons.work;
      case "Create Notification":
        return Icons.notifications_none;
      case "Change Password":
        return Icons.lock;
        case "Logout":
        return Icons.logout;
    case "About Us":
        return Icons.info;
      case "AddCompany":
        return Icons.work_outline;
    case "AddGst":
    return Icons.monetization_on_outlined;
    case "Add JobCategory":
    return Icons.splitscreen;
      default:
        return Icons.settings;
    }
  }

}
