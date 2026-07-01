// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:locate_your_dentist/api/api.dart';
// import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
// import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
// import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
// import '../../common_widgets/common_bottom_navigation.dart';
// import '../../common_widgets/common_textstyles.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import 'package:locate_your_dentist/common_widgets/color_code.dart';
//
// class SettingsPageMobile extends StatefulWidget {
//   const SettingsPageMobile({super.key});
//
//   @override
//   State<SettingsPageMobile> createState() => _SettingsPageMobileState();
// }
//
// class _SettingsPageMobileState extends State<SettingsPageMobile> {
//   List<Map<String, dynamic>> settingList = [];
//   final jobController = Get.put(JobController());
//   String selectedUserType = Api.userInfo.read('userType') ?? "";
//   final loginController = Get.put(LoginController());
//   void _showDeleteDialog() {
//     showDeleteDialog(
//       context: context, title: "Delete Account", message: "Do you want to Delete this Account?",
//       onConfirm: () async {
//         await loginController.deactivateUserAdmin(Api.userInfo.read('userId')??"", false, context);
//         Get.toNamed('/loginPage');
//         loginController.update();
//       },
//     );
//   }
//   @override
//   void initState() {
//     super.initState();
//     final String selectedUserType = Api.userInfo.read('userType') ?? "";
//     print('type: $selectedUserType');
//     final String userId = Api.userInfo.read('userId') ?? "";
//     Api.userInfo.write('selectUId',userId);
//     settingList = _getSettingsForUser(selectedUserType);
//     //loginController.getProfileByUserId(Api.userInfo.read('userId') ?? "", context);
//      loginController.getBranchDetails(context);
//   }
//   List<Map<String, String>> _getSettingsForUser(String userType) {
//     switch (userType) {
//       case 'Dental Lab':
//         return [
//           {"title": "Lab Profile", "page": "/mechanicDashboard"},
//           {"title": "Edit Profile", "page": "/clinicEditProfile"},
//           {"title": "My Subscription", "page": "/viewPlanPage"},
//           {"title": "Job/Webinars", "page": "/viewJobWebinarPage"},
//           {"title": "Services", "page": "/viewServiceList"},
//           {"title": "Change Password", "page": "/changePasswordPage"},
//           {"title": "Delete Account", "page": "/DeleteAccount"},
//           {"title": "About Us", "page": "/aboutUsPage"},
//           {"title": "Logout", "page": "/logout"},
//         ];
//       case 'superAdmin':
//         return [
//           {"title": "Dashboard", "page": "/superAdminDashboard"},
//           {"title": "Add admin", "page": "/registerPage"},
//           {"title": "User List", "page": "/userTypeListPage"},
//           {"title": "My Subscription", "page": "/viewPlanPage"},
//           {"title": "Reports", "page": "/viewReportPage"},
//           {"title": "Create Scrolling Ads Post", "page": "/createPostImages"},
//           {"title": "Create Notification", "page": "/createNotificationPage"},
//           {"title": "Change Password", "page": "/changePasswordPage"},
//           {"title": "AddGst", "page": "/addGSTPage"},
//           {"title": "change Logo", "page": "/changLogoImagePage"},
//           {"title": "Add JobCategory", "page": "/addJobCategoryPage"},
//           {"title": "AddCompany", "page": "/addCompanyPage"},
//           {"title": "Feedback Forms", "page": "/ViewFeedbackFormsPage"},
//           {"title": "Add Legal Pages", "page": "/addLegalPageMobile"},
//           {"title": "Delete Account", "page": "/DeleteAccount"},
//           {"title": "About Us", "page": "/aboutUsPage"},
//           {"title": "Contact Us", "page": "/contactUsMobilePage"},
//           {"title": "Logout", "page": "/logout"},
//         ];
//       case 'admin':
//         return [
//           {"title": "Dashboard", "page": "/superAdminDashboard"},
//           {"title": "My Subscription", "page": "/viewPlanPage"},
//           {"title": "User List", "page": "/userTypeListPage"},
//           {"title": "Change Password", "page": "/changePasswordPage"},
//           {"title": "Delete Account", "page": "/DeleteAccount"},
//           {"title": "About Us", "page": "/aboutUsPage"},
//           {"title": "Contact Us", "page": "/contactUsMobilePage"},
//           {"title": "Logout", "page": "/logout"},
//         ];
//       case 'Dental Clinic':
//         bool multipleBranches = loginController.userBranchesList.length > 1;
//         return [
//           {"title": "Clinic Profile", "page": "/clinicProfilePage"},
//           multipleBranches
//               ? {"title": "My Subscription", "page": "/branchListPage"}
//               : {"title": "My Subscription", "page": "/viewPlanPage"},
//           {"title": "My Purchases", "page": "/viewInvoiceListPage"},
//           {"title": "Services", "page": "/viewServiceList"},
//           {"title": "Contact Form", "page": "/viewSenderContactList"},
//           {"title": "Change Password", "page": "/changePasswordPage"},
//           {"title": "Add Branches", "page": "/addBranchesPage"},
//           {"title": "Delete Account", "page": "/DeleteAccount"},
//           {"title": "About Us", "page": "/aboutUsPage"},
//           {"title": "Contact Us", "page": "/contactUsMobilePage"},
//           {"title": "Logout", "page": "/logout"},
//         ];
//       case 'Dental Shop':
//         return [
//           {"title": "Shop Profile", "page": "/mechanicDashboard"},
//           {"title": "My Subscription", "page": "/viewPlanPage"},
//           {"title": "My Purchases", "page": "/viewInvoiceListPage"},
//           {"title": "Job/Webinars", "page": "/viewJobWebinarPage"},
//           {"title": "Products", "page": "/viewServiceList"},
//           {"title": "Add Profile", "page": "/clinicEditProfile"},
//           {"title": "Delete Account", "page": "/DeleteAccount"},
//           {"title": "Change Password", "page": "/changePasswordPage"},
//           {"title": "About Us", "page": "/aboutUsPage"},
//           {"title": "Contact Us", "page": "/contactUsMobilePage"},
//           {"title": "Logout", "page": "/logout"},
//         ];
//       case 'Dental Mechanic':
//       case 'Dental Consultant':
//         return [
//           {"title": "Profile", "page": "/mechanicDashboard"},
//           {"title": "Edit Profile", "page": "/clinicEditProfile"},
//           {"title": "My Subscription", "page": "/viewPlanPage"},
//           {"title": "My Purchases", "page": "/viewInvoiceListPage"},
//           {"title": "Job/Webinars", "page": "/viewJobWebinarPage"},
//           {"title": "Services", "page": "/viewServiceList"},
//           {"title": "Delete Account", "page": "/DeleteAccount"},
//           {"title": "Change Password", "page": "/changePasswordPage"},
//           {"title": "About Us", "page": "/aboutUsPage"},
//           {"title": "Contact Us", "page": "/contactUsMobilePage"},
//           {"title": "Logout", "page": "/logout"},
//         ];
//       case 'Job Seekers':
//         return [
//           {"title": "Profile", "page": "/jobSeekerViewProfilePage"},
//           {"title": "My Jobs", "page": "/appliedJobListPage"},
//           {"title": "Edit Profile", "page": "/jobSeekerEditProfilePage"},
//           {"title": "Jobs", "page": "/filterPageJobSeekersPage"},
//           {"title": "Webinars", "page": "/viewWebinarListJobseekersPage"},
//           {"title": "Change Password", "page": "/changePasswordPage"},
//           {"title": "Delete Account", "page": "/DeleteAccount"},
//           {"title": "About Us", "page": "/aboutUsPage"},
//           {"title": "Contact Us", "page": "/contactUsMobilePage"},
//           {"title": "Logout", "page": "/logout"},
//         ];
//       default:
//         return [];
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     double s = MediaQuery.of(context).size.width;
//     String userName = Api.userInfo.read('personName') ?? "";
//     String userId = Api.userInfo.read('userId') ?? "";
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: AppColors.primary,
//         centerTitle: true,
//         iconTheme: IconThemeData(
//           color: AppColors.white,
//           size: s * 0.05,
//         ),
//         title: Text(
//           "Settings",
//           style: AppTextStyles.subtitle(context, color: AppColors.white),
//         ),
//       ),
//
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(
//                     vertical: s * 0.06,
//                     horizontal: 20,
//                   ),
//                   decoration:  BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                         gradient: LinearGradient(
//                           colors: [ AppColors.primary.withOpacity(0.9),
//                             AppColors.secondary.withOpacity(0.6),],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                   ),
//                   child: Row(
//                     children: [
//
//                       CircleAvatar(
//                         radius: 35,
//                         backgroundColor: AppColors.white,
//                         child: CircleAvatar(
//                           radius: 32,
//                           backgroundImage:
//                           (Api.userInfo.read("profileImage") != null &&
//                               Api.userInfo.read("profileImage").toString().isNotEmpty)
//                               ? NetworkImage(Api.userInfo.read("profileImage"))
//                               : const AssetImage("assets/images/doctor5.jpg")
//                           as ImageProvider,
//                         ),
//                       ),
//
//                       SizedBox(width: s * 0.05),
//
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               userName,
//                               style: AppTextStyles.subtitle(
//                                 context,
//                                 color: AppColors.white,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               "UserID: $userId",
//                               style: AppTextStyles.caption(
//                                 context,
//                                 color: AppColors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child:  IconButton(
//                           onPressed: (){
//                             Api.userInfo.write('selectUId',Api.userInfo.read('userId')??"");
//                             (Api.userInfo.read('userType')=='Job Seekers')?Get.toNamed('/jobSeekerEditProfilePage'): Get.toNamed('/clinicEditProfile');
//                             },
//                           icon:Icon(Icons.edit,
//                           size: s*0.06,
//                           color: AppColors.white,
//                         ),)
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: s * 0.05),
//
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: AnimationLimiter(
//                   child:AnimationConfiguration.staggeredList(
//                     position: 0,
//                     duration: const Duration(milliseconds: 700),
//                     child: SlideAnimation(
//                       horizontalOffset: 80.0,
//                       curve: Curves.easeOutCubic,
//                       child: FadeInAnimation(
//                         child: Column(
//                           children: settingList.map((setting) {
//                             return Column(
//                               children: [
//                                 ListTile(
//                                   leading: Icon(
//                                     _getIcon(setting['title']),
//                                     color: AppColors.primary,size: s*0.06,
//                                   ),
//                                   title: Text(
//                                     setting['title'],
//                                     style: AppTextStyles.caption(
//                                       context,fontWeight: FontWeight.bold,
//                                       color: AppColors.black,
//                                     ),
//                                   ),
//                                   trailing: const Icon(Icons.arrow_forward_ios_rounded,
//                                       size: 18),
//                                   onTap: () async {
//                                     final String title = setting['title'] ?? '';
//
//                                     if (title == "Logout") {
//                                       showLogoutDialog(context);
//                                     } else if (title == "Jobs") {
//                                       await jobController.getJobListJobSeekers(search: '',context: context);
//                                       Get.toNamed(setting['page']);
//                                     }
//                                     else if (title == "Webinars") {
//                                       await jobController.getWebinarListJobSeekers('','',context);
//                                       Get.toNamed(setting['page']);
//                                     }
//                                     else if (title == "User List") {
//                                       if( Api.userInfo.read('userType')=="superAdmin") {
//                                         await   loginController.getProfileDetails('', '', '','', [], '','','','','',  context);
//                                       }
//                                       if( Api.userInfo.read('userType')=="admin") {
//                                         await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", '', '', [],'','','','','', context);
//                                       }
//                                       Get.toNamed('/userTypeListPage');
//                                     }
//                                 else if (title == "Profile") {
//                                       Api.userInfo.write('selectUId',userId);
//                                 Get.toNamed(setting['page']);
//                                      }
//                                     if (title == "Delete Account") {
//                                       _showDeleteDialog();
//                                     }
//                                     else {
//                                       Get.toNamed(setting['page']);
//                                     }
//                                   },
//                                 ),
//                               ],
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const Padding(
//                 padding: EdgeInsets.all(15.0),
//                 child: Divider(thickness: 0.3,color: Colors.grey,),
//               ),
//               Text('App Version 1.0.0',style: AppTextStyles.caption(context,color: AppColors.grey),)
//               // Divider(thickness: 0.3,color: Colors.grey,)
//             ],
//           ),
//         ),
//       ),
//
//       bottomNavigationBar:
//       const CommonBottomNavigation(currentIndex: 0),
//     );
//   }
//   IconData _getIcon(String title) {
//     switch (title) {
//       case "Profile":
//       case "Clinic Profile":
//       case "Lab Profile":
//       case "Shop Profile":
//         return Icons.person_outline;
//
//       case "Edit Profile":
//         return Icons.edit_outlined;
//
//       case "Dashboard":
//         return Icons.dashboard_customize_outlined;
//
//       case "My Subscription":
//         return Icons.workspace_premium_outlined;
//
//       case "My Purchases":
//         return Icons.receipt_long_outlined;
//
//       case "Services":
//         return Icons.medical_services_outlined;
//
//       case "Products":
//         return Icons.inventory_2_outlined;
//
//       case "Job/Webinars":
//         return Icons.campaign_outlined;
//
//       case "Jobs":
//         return Icons.work_outline;
//
//       case "Webinars":
//         return Icons.video_camera_front_outlined;
//
//       case "My Jobs":
//         return Icons.assignment_outlined;
//
//       case "Applicants List":
//         return Icons.groups_outlined;
//
//       case "User List":
//         return Icons.people_alt_outlined;
//
//       case "Add admin":
//         return Icons.admin_panel_settings_outlined;
//
//       case "Add Branches":
//         return Icons.account_tree_outlined;
//
//       case "Contact Form":
//         return Icons.contact_mail_outlined;
//
//       case "Contact Us":
//         return Icons.support_agent_outlined;
//
//       case "Feedback Forms":
//         return Icons.feedback_outlined;
//
//       case "Reports":
//         return Icons.analytics_outlined;
//
//       case "Create Notification":
//         return Icons.notifications_active_outlined;
//
//       case "Create Scrolling Ads Post":
//         return Icons.slideshow_outlined;
//
//       case "Add Legal Pages":
//         return Icons.gavel_outlined;
//
//       case "Add JobCategory":
//         return Icons.category_outlined;
//
//       case "AddCompany":
//         return Icons.business_outlined;
//
//       case "AddGst":
//         return Icons.receipt_outlined;
//
//       case "change Logo":
//         return Icons.image_outlined;
//
//       case "Change Password":
//         return Icons.lock_outline;
//
//       case "Delete Account":
//         return Icons.delete_forever_outlined;
//
//       case "About Us":
//         return Icons.info_outline;
//
//       case "Logout":
//         return Icons.logout_outlined;
//
//       default:
//         return Icons.settings_outlined;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import '../../common_widgets/common_bottom_navigation.dart';
import '../../common_widgets/common_textstyles.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';

class SettingsPageMobile extends StatefulWidget {
  const SettingsPageMobile({super.key});

  @override
  State<SettingsPageMobile> createState() => _SettingsPageMobileState();
}

class _SettingsPageMobileState extends State<SettingsPageMobile> {
  List<Map<String, dynamic>> settingList = [];
  final jobController = Get.put(JobController());
  final loginController = Get.put(LoginController());
  String selectedUserType = Api.userInfo.read('userType') ?? "";

  void _showDeleteDialog() {
    showDeleteDialog(
      context: context,
      title: "Delete Account",
      message:
          "Are you sure you want to permanently delete your account? This action cannot be undone.",
      onConfirm: () async {
        await loginController.deactivateUserAdmin(
          Api.userInfo.read('userId') ?? "",
          false,
          context,
        );
        Get.toNamed('/loginPage');
        loginController.update();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final String userId = Api.userInfo.read('userId') ?? "";
    Api.userInfo.write('selectUId', userId);
    settingList = _getSettingsForUser(selectedUserType);
    loginController.getBranchDetails(context);
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
          {"title": "Delete Account", "page": "/DeleteAccount"},
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
          {"title": "Feedback Forms", "page": "/ViewFeedbackFormsPage"},
          {"title": "Add Legal Pages", "page": "/addLegalPageMobile"},
          {"title": "Delete Account", "page": "/DeleteAccount"},
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
          {"title": "Delete Account", "page": "/DeleteAccount"},
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
          {"title": "Delete Account", "page": "/DeleteAccount"},
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
          {"title": "Delete Account", "page": "/DeleteAccount"},
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
          {"title": "Delete Account", "page": "/DeleteAccount"},
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
          {"title": "Webinars", "page": "/viewWebinarListJobseekersPage"},
          {"title": "Change Password", "page": "/changePasswordPage"},
          {"title": "Delete Account", "page": "/DeleteAccount"},
          {"title": "About Us", "page": "/aboutUsPage"},
          {"title": "Contact Us", "page": "/contactUsMobilePage"},
          {"title": "Logout", "page": "/logout"},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName = Api.userInfo.read('personName') ?? "User Profile";
    String userId = Api.userInfo.read('userId') ?? "N/A";
    String userImg = Api.userInfo.read("profileImage")?.toString() ?? "";
    final accountSettings = settingList
        .where(
          (e) => [
            "Profile",
            "Clinic Profile",
            "Lab Profile",
            "Shop Profile",
            "Edit Profile",
            "Add Profile",
            "Change Password",
          ].contains(e['title']),
        )
        .toList();
    final managementSettings = settingList
        .where(
          (e) => ![
            "Profile",
            "Clinic Profile",
            "Lab Profile",
            "Shop Profile",
            "Edit Profile",
            "Add Profile",
            "Change Password",
            "About Us",
            "Contact Us",
            "Logout",
            "Delete Account",
          ].contains(e['title']),
        )
        .toList();
    final supportSettings = settingList
        .where(
          (e) => [
            "About Us",
            "Contact Us",
            "Delete Account",
            "Logout",
          ].contains(e['title']),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // appBar: AppBar(
      // elevation: 0,
      // backgroundColor: AppColors.primary, iconTheme: const IconThemeData(
      //   color: Colors.white,
      // ),
      // centerTitle: true,
      // title: const Text(
      // "",
      // style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
      // ),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 12,
                  top: 16,
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    // 2. Centered Profile Content Block
                    SizedBox(
                      width: double
                          .infinity, // Forces the column space to occupy full width for absolute centering
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Centers internal text & image layout elements
                        children: [
                          // Large Centered Circular Avatar
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: const Color(0xFFF1F5F9),
                              backgroundImage: userImg.isNotEmpty
                                  ? NetworkImage(userImg)
                                  : const AssetImage(
                                          "assets/images/doctor5.jpg",
                                        )
                                        as ImageProvider,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Details Stacked Below Avatar
                          Text(
                            userName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "User ID: $userId",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Edit Action Button centered at the bottom
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.15,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Api.userInfo.write(
                                'selectUId',
                                Api.userInfo.read('userId') ?? "",
                              );
                              (selectedUserType == 'Job Seekers')
                                  ? Get.toNamed('/jobSeekerEditProfilePage')
                                  : Get.toNamed('/clinicEditProfile');
                            },
                            icon: const Icon(
                              Icons.mode_edit_outline_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              "Edit Profile",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimationLimiter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (accountSettings.isNotEmpty) ...[
                        _buildSectionTitle("Account Settings"),
                        _buildSettingsGroup(accountSettings),
                        const SizedBox(height: 20),
                      ],
                      if (managementSettings.isNotEmpty) ...[
                        _buildSectionTitle("Management & Features"),
                        _buildSettingsGroup(managementSettings),
                        const SizedBox(height: 20),
                      ],
                      if (supportSettings.isNotEmpty) ...[
                        _buildSectionTitle("Support & Actions"),
                        _buildSettingsGroup(supportSettings),
                      ],

                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'App Version 1.0.0',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Locate Your Dentist © 2026',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Map<String, dynamic>> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.shade100, indent: 54),
        itemBuilder: (context, index) {
          final item = items[index];
          final String title = item['title'] ?? '';
          final bool isDestructive = [
            "Delete Account",
            "Logout",
          ].contains(title);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 200),
            child: FadeInAnimation(
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? (title == "Logout"
                              ? Colors.orange.shade50
                              : Colors.red.shade50)
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIcon(title),
                    color: isDestructive
                        ? (title == "Logout" ? Colors.orange : Colors.red)
                        : AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDestructive
                        ? (title == "Logout"
                              ? Colors.orange.shade800
                              : Colors.red.shade800)
                        : const Color(0xFF1E293B),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDestructive
                      ? Colors.grey.shade300
                      : const Color(0xFF94A3B8),
                ),
                onTap: () async {
                  if (title == "Logout") {
                    showLogoutDialog(context);
                  } else if (title == "Delete Account") {
                    _showDeleteDialog();
                  } else if (title == "Jobs") {
                    await jobController.getJobListJobSeekers(
                      search: '',
                      context: context,
                    );
                    Get.toNamed(item['page']);
                  } else if (title == "Webinars") {
                    await jobController.getWebinarListJobSeekers(
                      '',
                      '',
                      context,
                    );
                    Get.toNamed(item['page']);
                  } else if (title == "User List") {
                    if (Api.userInfo.read('userType') == "superAdmin") {
                      await loginController.getProfileDetails(
                        '',
                        '',
                        '',
                        '',
                        [],
                        '',
                        '',
                        '',
                        '',
                        '',
                        context,
                      );
                    } else if (Api.userInfo.read('userType') == "admin") {
                      await loginController.getProfileDetails(
                        '',
                        Api.userInfo.read('state') ?? "",
                        '',
                        '',
                        [],
                        '',
                        '',
                        '',
                        '',
                        '',
                        context,
                      );
                    }
                    Get.toNamed('/userTypeListPage');
                  } else if (title == "Profile") {
                    Api.userInfo.write(
                      'selectUId',
                      Api.userInfo.read('userId') ?? "",
                    );
                    Get.toNamed(item['page']);
                  } else {
                    Get.toNamed(item['page']);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String title) {
    switch (title) {
      case "Profile":
      case "Clinic Profile":
      case "Lab Profile":
      case "Shop Profile":
        return Icons.person_outline_rounded;
      case "Edit Profile":
      case "Add Profile":
        return Icons.badge_outlined;
      case "Dashboard":
        return Icons.grid_view_rounded;
      case "My Subscription":
        return Icons.card_membership_rounded;
      case "My Purchases":
        return Icons.receipt_long_rounded;
      case "Services":
        return Icons.vaccines_rounded;
      case "Products":
        return Icons.local_mall_outlined;
      case "Job/Webinars":
        return Icons.all_inclusive_rounded;
      case "Jobs":
        return Icons.business_center_outlined;
      case "Webinars":
        return Icons.ondemand_video_rounded;
      case "My Jobs":
        return Icons.assignment_turned_in_outlined;
      case "User List":
        return Icons.supervised_user_circle_outlined;
      case "Add admin":
        return Icons.admin_panel_settings_outlined;
      case "Add Branches":
        return Icons.account_tree_outlined;
      case "Contact Form":
        return Icons.quick_contacts_mail_outlined;
      case "Contact Us":
        return Icons.headset_mic_outlined;
      case "Feedback Forms":
        return Icons.rate_review_outlined;
      case "Reports":
        return Icons.bar_chart_rounded;
      case "Create Notification":
        return Icons.notification_add_outlined;
      case "Create Scrolling Ads Post":
        return Icons.featured_video_outlined;
      case "Add Legal Pages":
        return Icons.gavel_rounded;
      case "Add JobCategory":
        return Icons.rule_folder_outlined;
      case "AddCompany":
        return Icons.storefront_rounded;
      case "AddGst":
        return Icons.percent_rounded;
      case "change Logo":
        return Icons.insert_photo_outlined;
      case "Change Password":
        return Icons.password_rounded;
      case "Delete Account":
        return Icons.delete_sweep_rounded;
      case "About Us":
        return Icons.help_outline_rounded;
      case "Logout":
        return Icons.power_settings_new_rounded;
      default:
        return Icons.settings_suggest_rounded;
    }
  }
}
