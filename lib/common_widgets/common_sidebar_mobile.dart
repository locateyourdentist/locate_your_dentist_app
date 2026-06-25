import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';

class SettingsSidebarDrawer extends StatelessWidget {
  SettingsSidebarDrawer({super.key});

  final LoginController loginController = Get.find<LoginController>();
  final jobController = Get.put(JobController());
  void _showDeleteDialog(context) {
    showDeleteDialog(
      context: context, title: "Delete Account", message: "Do you want to Delete this Account?",
      onConfirm: () async {
        await loginController.deactivateUserAdmin(Api.userInfo.read('userId')??"", false, context);
        Get.toNamed('/loginPage');
        loginController.update();
      },
    );
  }
  IconData _getIcon(String title) {
    switch (title) {
      case "Dashboard":
        return Icons.dashboard;
      case "Profile":
      case "Clinic Profile":
      case "Shop Profile":
      case "Lab Profile":
        return Icons.person;
      case "Edit Profile":
        return Icons.edit;
      case "My Subscription":
        return Icons.workspace_premium;
      case "My Purchases":
        return Icons.receipt_long;
      case "User List":
        return Icons.group;
      case "Reports":
        return Icons.analytics;
      case "Services":
        return Icons.medical_services;
      case "Products":
        return Icons.shopping_bag;
      case "Jobs":
      case "My Jobs":
      case "Job/Webinars":
        return Icons.work;
      case "Webinars":
        return Icons.live_tv;
      case "Contact Form":
        return Icons.contact_mail;
      case "Change Password":
        return Icons.lock_reset;
      case "Delete Account":
        return Icons.delete_forever;
      case "About Us":
        return Icons.info;
      case "Contact Us":
        return Icons.call;
      case "Create Notification":
        return Icons.notifications;
      case "Create Scrolling Ads Post":
        return Icons.image;
      case "Add admin":
        return Icons.person_add;
      case "Add Branches":
        return Icons.account_tree;
      case "Feedback Forms":
        return Icons.feedback;
      case "Logout":
        return Icons.logout;
      default:
        return Icons.chevron_right;
    }
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
        bool multipleBranches =
            loginController.userBranchesList.length > 1;

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
  bool isMobile(BuildContext context) =>
      MediaQuery
          .of(context)
          .size
          .width < 600;

  bool isTablet(BuildContext context) =>
      MediaQuery
          .of(context)
          .size
          .width >= 600 &&
          MediaQuery
              .of(context)
              .size
              .width < 1024;
  double getSidebarWidth(BuildContext context) {
    double w = MediaQuery
        .of(context)
        .size
        .width;
    if (isMobile(context)) return w * 0.3;
    if (isTablet(context)) return w * 0.25;
    return w * 0.15;
  }
  double getAvatarSize(BuildContext context) {
    if (isMobile(context)) return 80;
    if (isTablet(context)) return 60;
    return 70;
  }

  double getIconSize(BuildContext context) {
    if (isMobile(context)) return 18;
    if (isTablet(context)) return 20;
    return 22;
  }

  @override
  Widget build(BuildContext context) {
    String userType = Api.userInfo.read('userType') ?? "";
    final String userId = Api.userInfo.read('userId') ?? "";
    Api.userInfo.write('selectUId',userId);
    final menuItems = _getSettingsForUser(userType);
    double sidebarWidth = getSidebarWidth(context);
    double avatarSize = getAvatarSize(context);
    double iconSize = getIconSize(context);

    return Drawer(
      child:  SafeArea(
        child: Container(
          width: sidebarWidth,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
         
            child: Column(
              children: [
                SizedBox(height: 10,),
                ClipOval(
                  child: Image.network(
                    Api.userInfo.read("profileImage") ?? "",
                    width: avatarSize,
                    height: avatarSize,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          color: Colors.grey,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                  ),
                ),
            
                const SizedBox(height: 8),
            
                Text(
                  Api.userInfo.read("orgName") ?? "",
                  style: AppTextStyles.body(
                    context,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            
                // Center(
                //   child: Text(
                //     userType,
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontSize: 22,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
             
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
        
                  return ListTile(
                    leading: Icon(
                      _getIcon(item['title']!),
                      color: AppColors.white,
                    ),
                    title: Text(item['title']!,style: AppTextStyles.caption(context,color: AppColors.white),),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final String title = item['title'] ?? '';
        
                      if (title == "Logout") {
                        showLogoutDialog(context);
                      } else if (title == "Jobs") {
                        await jobController.getJobListJobSeekers(search: '',context: context);
                        Get.toNamed(item['page']??"");
                      }
                      else if (title == "Webinars") {
                        await jobController.getWebinarListJobSeekers('','',context);
                        Get.toNamed(item['page']??"");
                      }
                      else if (title == "User List") {
                        if( Api.userInfo.read('userType')=="superAdmin") {
                          await   loginController.getProfileDetails('', '', '', '',[], '','','','','',  context);
                        }
                        if( Api.userInfo.read('userType')=="admin") {
                          await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", '', '',[], '','','','','', context);
                        }
                        Get.toNamed('/userTypeListPage');
                      }
                      else if (title == "Profile") {
                        Api.userInfo.write('selectUId',userId);
                        Get.toNamed(item['page']??"");
                      }
                      if (title == "Delete Account") {
                        _showDeleteDialog(context);
                      }
                      else {
                        Get.toNamed(item['page']??"");
                      }
                    },
        
                  );
                },
              ),
            ),
            ]  ),
        ),
      )
    );
  }
}