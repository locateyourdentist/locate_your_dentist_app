
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';

class AdminSideBar extends StatefulWidget {
  const AdminSideBar({super.key});

  @override
  State<AdminSideBar> createState() => _AdminSideBarState();
}

class _AdminSideBarState extends State<AdminSideBar> {
  final loginController = Get.find<LoginController>();

  late List<Map<String, String>> settingList;

  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
    loginController.getBranchDetails(context);

    String userType = Api.userInfo.read('userType') ?? "";
    settingList = _getSettingsForUser(userType);
  }

  void _showDeleteDialog() {
    showDeleteDialog(
      context: context,
      title: "Delete Account",
      message: "Do you want to Delete this Account?",
      onConfirm: () async {
        await loginController.deactivateUserAdmin(
            Api.userInfo.read('userId') ?? "", false, context);
        Get.toNamed('/loginPage');
        loginController.update();
      },
    );
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

  bool isDesktop(BuildContext context) =>
      MediaQuery
          .of(context)
          .size
          .width >= 1024;

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
    if (isMobile(context)) return 50;
    if (isTablet(context)) return 60;
    return 70;
  }

  // 🔹 Icon size
  double getIconSize(BuildContext context) {
    if (isMobile(context)) return 18;
    if (isTablet(context)) return 20;
    return 22;
  }

  List<Map<String, String>> _getSettingsForUser(String userType) {
    switch (userType) {
      case 'Dental Lab':
        return [
          {"title": "Dashboard", "page": "/dentalMechanicDashboardWebPage"},
          {"title": "Edit Profile", "page": "/viewProfilePageWeb"},
          {"title": "My Subscription", "page": "/viewPlanPageWeb"},
          {"title": "Job/Webinars", "page": "/viewJobWebinarWebPage"},
          {"title": "Products", "page": "/myServicesListWebPage"},
          {"title": "Add Branches", "page": "/addBranchesWeb"},
          {"title": "Change Password", "page": "/changePasswordWeb"},
          {"title": "Delete Account", "page": "/DeleteAccount"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Contact Us", "page": "/contactWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'superAdmin':
        return [
          {"title": "Dashboard", "page": "/superAdminWebDashboard"},
          {"title": "Edit Profile", "page": "/viewProfilePageWeb"},
          {"title": "User List", "page": "/userTypeListWeb"},
          {"title": "Add User", "page": "/registerPageWeb"},
          {"title": "My Subscription", "page": "/viewPlanPageWeb"},
          {"title": "Reports", "page": "/reportPageWeb"},
          {
            "title": "Create Scrolling Ads Post",
            "page": "/scrollingAdsWebPage"
          },
          {"title": "Create Notification", "page": "/notificationWebPage"},
          {"title": "Create Plan", "page": "/createPlanPageWeb"},
          {"title": "Add JobCategory", "page": "/jobCategoryWeb"},
          {"title": "Settings", "page": "/settingsWebPage"},
          {"title": "Feedback Forms", "page": "/ViewFeedbackFormsPage"},
          {"title": "Add Legal Pages", "page": "/addPrivacyPolicyPage"},
          {"title": "Delete Account", "page": "/DeleteAccount"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Contact Us", "page": "/contactWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'admin':
        return [
          {"title": "Dashboard", "page": "/superAdminWebDashboard"},
          {"title": "Edit Profile", "page": "/viewProfilePageWeb"},
          {"title": "User List", "page": "/userTypeListWeb"},
          {"title": "Add User", "page": "/registerPageWeb"},
          {"title": "My Subscription", "page": "/viewPlanPageWeb"},
          {"title": "Reports", "page": "/reportPageWeb"},
          {"title": "Delete Account", "page": "/DeleteAccount"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Contact Us", "page": "/contactWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'Dental Clinic':
        bool multipleBranches = loginController.userBranchesList.length > 1;
        return [
          {"title": "Dashboard", "page": "/dentalClinicDashboardWeb"},
          {"title": "Edit Profile", "page": "/viewProfilePageWeb"},
          {"title": "My Subscription", "page": "/viewPlanPageWeb"},
          {"title": "My Purchases", "page": "/myInvoiceListWebPage"},
          {"title": "Services", "page": "/myServicesListWebPage"},
          // {"title": "Text Editor", "page": "/myServicesListWebPage1"},
          {"title": "Job/Webinars", "page": "/viewJobWebinarWebPage"},
          {"title": "Contact Form", "page": "/contactFormListWebPage"},
          {"title": "Add Branches", "page": "/addBranchesWeb"},
          {"title": "Change Password", "page": "/changePasswordWeb"},
          {"title": "Delete Account", "page": "/DeleteAccount"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Contact Us", "page": "/contactWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'Dental Shop':
        return [
          {"title": "Dashboard", "page": "/dentalMechanicDashboardWebPage"},
          {"title": "Edit Profile", "page": "/viewProfilePageWeb"},
          {"title": "My Subscription", "page": "/viewPlanPageWeb"},
          {"title": "My Purchases", "page": "/myInvoiceListWebPage"},
          {"title": "Jobs/Webinars", "page": "/viewJobWebinarWebPage"},
          {"title": "Products", "page": "/myServicesListWebPage"},
          {"title": "Add Profile", "page": "/clinicEditProfile"},
          {"title": "Add Branches", "page": "/addBranchesWeb"},
          {"title": "Change Password", "page": "/changePasswordWeb"},
          {"title": "Delete Account", "page": "/DeleteAccount"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Contact Us", "page": "/contactWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'Dental Mechanic':
        return [
          {"title": "Dashboard", "page": "/dentalMechanicDashboardWebPage"},
          {"title": "Edit Profile", "page": "/viewProfilePageWeb"},
          // {"title": "Edit Profile", "page": "/clinicEditProfile"},
          {"title": "My Subscription", "page": "/viewPlanPageWeb"},
          {"title": "My Purchases", "page": "/myInvoiceListWebPage"},
          {"title": "Jobs/Webinars", "page": "/viewJobWebinarWebPage"},
          {"title": "Products", "page": "/myServicesListWebPage"},
          {"title": "Add Branches", "page": "/addBranchesWeb"},
          {"title": "Change Password", "page": "/changePasswordWeb"},
          {"title": "Delete Account", "page": "/DeleteAccount"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Contact Us", "page": "/contactWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'Dental Consultant':
        return [
          {"title": "Dashboard", "page": "/dentalClinicDashboardWeb"},
          {"title": "Edit Profile", "page": "/viewProfilePageWeb"},
          {"title": "My Subscription", "page": "/viewPlanPageWeb"},
          {"title": "My Purchases", "page": "/myInvoiceListWebPage"},
          {"title": "Jobs/Webinars", "page": "/viewJobWebinarWebPage"},
          {"title": "Products", "page": "/myServicesListWebPage"},
          {"title": "Contact Form", "page": "/contactFormListWebPage"},
          {"title": "Add Branches", "page": "/addBranchesWeb"},
          {"title": "Change Password", "page": "/changePasswordWeb"},
          {"title": "Delete Account", "page": "/DeleteAccount"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Contact Us", "page": "/contactWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'Job Seekers':
        return [
          {"title": "Dashboard", "page": "/jobSeekerDashboardWeb"},
          {"title": "Edit Profile", "page": "/viewProfilePageWeb"},
          {"title": "My Jobs", "page": "/appliedJobsListWeb"},
          {"title": "Jobs", "page": "/jobListJobSeekersWebPage"},
          {"title": "Webinars", "page": "/webinarListWebPage"},
          {"title": "Change Password", "page": "/changePasswordWeb"},
          {"title": "Delete Account", "page": "/DeleteAccount"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Contact Us", "page": "/contactWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double sidebarWidth = getSidebarWidth(context);
    double avatarSize = getAvatarSize(context);
    double iconSize = getIconSize(context);

    return GetBuilder<LoginController>(
      builder: (controller) {
        return Container(
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
              const SizedBox(height: 20),

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

              const Divider(color: Colors.white30),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: settingList.length,
                  itemBuilder: (context, index) {
                    final setting = settingList[index];
                    final isSelected = index == controller.selectedIndex;

                    return ListTile(
                      leading: Icon(
                        _getIcon(setting['title'] ?? ""),
                        size: iconSize,
                        color:
                        isSelected ? Colors.redAccent : Colors.white,
                      ),
                      title: Text(
                        setting['title'] ?? "",
                        style: TextStyle(
                          color:
                          isSelected ? Colors.redAccent : Colors.white,
                          fontSize:
                          isMobile(context) ? 14 : 16,
                        ),
                      ),
                      tileColor: isSelected
                          ? Colors.white
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () async {
                        controller.selectedIndex = index;
                        controller.update();

                        if (setting['title'] == "Logout") {
                          showLogoutDialog(context);
                          return;
                        }

                        if (setting['title'] == "Delete Account") {
                          _showDeleteDialog();
                          return;
                        }

                        if (setting['title'] == "Edit Profile") {
                          String userId = Api.userInfo.read('userId') ?? "";
                          Api.userInfo.write('selectUId', userId);
                          loginController.getProfileByUserId(userId , context);
                          Get.offAllNamed("/viewProfilePageWeb");
                          return;
                        }

                        if (setting['title'] == "Add User") {
                          String userId = Api.userInfo.read('userId') ?? "";
                          Api.userInfo.write('selectUId', userId);
                          Get.offAllNamed(
                            "/registerPageWeb",
                            arguments: {"userId": 0},
                          );
                          return;
                        }

                        Get.toNamed(setting['page'] ?? "");
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIcon(String title) {
    switch (title) {
      case "Dashboard":
        return Icons.dashboard_rounded;

      case "Edit Profile":
        return Icons.person_outline;

      case "User List":
        return Icons.groups;

      case "Add User":
        return Icons.person_add_alt_1;

      case "My Subscription":
        return Icons.workspace_premium;

      case "My Purchases":
        return Icons.shopping_bag_outlined;

      case "Services":
        return Icons.medical_services_outlined;

      case "Products":
        return Icons.inventory_2_outlined;

      case "Job/Webinars":
      case "Jobs/Webinars":
        return Icons.work_outline;

      case "Jobs":
        return Icons.badge_outlined;

      case "My Jobs":
        return Icons.assignment_outlined;

      case "Webinars":
        return Icons.video_camera_front_outlined;

      case "Contact Form":
        return Icons.contact_mail_outlined;

      case "Add Branches":
        return Icons.account_tree_outlined;

      case "Reports":
        return Icons.analytics_outlined;

      case "Settings":
        return Icons.settings_outlined;

      case "Create Plan":
        return Icons.card_membership_outlined;

      case "Create Notification":
        return Icons.notifications_active_outlined;

      case "Create Scrolling Ads Post":
        return Icons.campaign_outlined;

      case "Add JobCategory":
        return Icons.category_outlined;

      case "Add Legal Pages":
        return Icons.gavel_outlined;

      case "Change Password":
        return Icons.lock_outline;

      case "Delete Account":
        return Icons.delete_forever_outlined;

      case "About Us":
        return Icons.info_outline;

      case "Contact Us":
        return Icons.support_agent_outlined;

      case "Logout":
        return Icons.logout_rounded;

      default:
        return Icons.circle_outlined;
    }
  }
}