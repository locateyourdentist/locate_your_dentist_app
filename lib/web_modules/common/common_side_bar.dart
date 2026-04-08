import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/web_modules/common/test_text_editor.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/branch_list_web.dart';

class AdminSideBar extends StatefulWidget {
  const AdminSideBar({super.key});

  @override
  State<AdminSideBar> createState() => _AdminSideBarState();
}

class _AdminSideBarState extends State<AdminSideBar> {
  final loginController = Get.put(LoginController());

  late List<Map<String, String>> settingList;
  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
    //loginController.getProfileByUserId(Api.userInfo.read('userId') ?? "", context);
    loginController.getBranchDetails(context);
    String userType = Api.userInfo.read('userType') ?? "";
    settingList = _getSettingsForUser(userType);
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
          {"title": "Change Password", "page": "/changePasswordWeb"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'superAdmin':
        return [
          {"title": "Dashboard", "page": "/superAdminWebDashboard"},
          {"title": "User List", "page": "/userTypeListWeb"},
          {"title": "Add admin", "page": "/registerPageWeb"},
          {"title": "My Subscription", "page": "/viewPlanPageWeb"},
          {"title": "Reports", "page": "/reportPageWeb"},
          {"title": "Create Scrolling Ads Post", "page": "/scrollingAdsWebPage"},
          {"title": "Create Notification", "page": "/notificationWebPage"},
          {"title": "Create Plan", "page": "/createPlanPageWeb"},
          {"title": "Add JobCategory", "page": "/jobCategoryWeb"},
          {"title": "Settings", "page": "/settingsWebPage"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'admin':
        return [
          {"title": "Dashboard", "page": "/superAdminDashboard"},
          {"title": "My Subscription", "page": "/viewPlanPage"},
          {"title": "My Purchases", "page": "/viewInvoiceListPage"},
          {"title": "Change Password", "page": "/changePasswordWeb"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
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
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'Dental Shop':
        return [
          {"title": "Dashboard", "page": "/dentalMechanicDashboardWebPage"},
          {"title": "Edit Profile", "page": "/viewProfilePageWeb"},
          {"title": "My Subscription", "page": "/viewPlanPageWeb"},
          {"title": "My Purchases", "page": "/viewInvoiceListPage"},
          {"title": "Jobs/Webinars", "page": "/viewJobWebinarWebPage"},
          {"title": "Products", "page": "/myServicesListWebPage"},
          {"title": "Add Profile", "page": "/clinicEditProfile"},
          {"title": "Add Branches", "page": "/addBranchesWeb"},
          {"title": "Change Password", "page": "/changePasswordWeb"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      case 'Dental Mechanic':
        return [
          {"title": "Dashboard", "page": "/dentalMechanicDashboardWebPage"},
          {"title": "Edit Profile", "page": "/viewProfilePageWeb"},
          {"title": "Edit Profile", "page": "/clinicEditProfile"},
          {"title": "My Subscription", "page": "/viewPlanPageWeb"},
          {"title": "My Purchases", "page": "/viewInvoiceListPage"},
          {"title": "Jobs/Webinars", "page": "/viewJobWebinarWebPage"},
          {"title": "Products", "page": "/myServicesListWebPage"},
          {"title": "Add Branches", "page": "/addBranchesWeb"},
          {"title": "Change Password", "page": "/changePasswordWeb"},
          {"title": "About Us", "page": "/aboutUsWebPage"},
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
          {"title": "About Us", "page": "/aboutUsWebPage"},
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
          {"title": "About Us", "page": "/aboutUsWebPage"},
          {"title": "Logout", "page": "/logout"},
        ];
      default:
        return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    double s = MediaQuery.of(context).size.width;
    return GetBuilder<LoginController>(
        builder: (controller) {
          return Container(
          width:s *0.125,
              height: double.infinity,
              decoration: const BoxDecoration(
                //color: AppColors.white
                gradient: LinearGradient(
                  colors: [AppColors.primary,AppColors.secondary],
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
                  fit: BoxFit.cover,
                  width: s*0.03,
                  height:  s*0.03,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width:  s*0.03,
                      height:  s*0.03,
                      color: Colors.grey.shade300,
                      child:  Icon(
                        Icons.person,
                        size:  s*0.016,
                        color: Colors.white,
                      ),
                    );
                  },
                )
              ),
              const SizedBox(height: 5,),
               Text(
                   Api.userInfo.read("orgName") ?? "",
                style: AppTextStyles.body(context,color: AppColors.white,fontWeight: FontWeight.bold)
              ),
             const Divider(thickness: 0.3,color: AppColors.grey,),
              const SizedBox(height: 30),

              GetBuilder<LoginController>(
                  builder: (controller) {
                    return Flexible(
                    child: ListView.builder(
                      //shrinkWrap: true,
                      itemCount: settingList.length,
                      itemBuilder: (context, index) {
                        final setting = settingList[index];
                        final bool isSelected = index == controller.selectedIndex;
                        return GestureDetector(
                          onTap: ()async {
                            setState(() {
                              controller.selectedIndex = index;
                            });
                            if (setting['title'] == "My Subscription") {
                             // bool multipleBranches =controller.userBranchesList.length > 1;
                              if (controller.userBranchesList.length > 1) {
                                 showBranchSelectionDialog(
                                context: context,
                                pageRoute: "",);
                              } else {
                                Get.toNamed("/viewPlanPageWeb");
                              }
                            }
                            if (setting['title'] == "Logout") {
                              Api.userInfo.erase();
                              showLogoutDialog(context);

                            //  Get.offAllNamed("/webLoginPage");
                            } else if (setting['title'] == "Add admin") {
                              Api.userInfo.write('isAdmin', 'true');
                              Get.offAllNamed("/registerPageWeb");

                            } else if (setting['title'] == "Create Plan") {
                              Get.toNamed('/createPlanPageWeb', arguments: {'selectedString': "BasePlan"});
                            }
                            else if (setting['title'] == "Dashboard") {
                              await loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
                              String userType = Api.userInfo.read('userType') ?? "";
                              Get.offAllNamed('/${pageUserTypeWeb(userType)}');
                            }
                            else if (setting['title'] == "Text Editor") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  EditorPage(),
                                ),
                              );
                            }
                            else {
                              Get.toNamed(setting['page'] ?? "");
                            }
                          },
                          child:
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.transparent,
                             //  gradient:  LinearGradient(
                             //    colors: isSelected ? [AppColors.primary,AppColors.secondary]:[AppColors.white,AppColors.white],
                             //    begin: Alignment.topLeft,
                             //    end: Alignment.bottomRight,
                             //  ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getIcon(setting['title'] ?? ""),
                                  color: isSelected ? AppColors.black:Colors.white,
                                  size: MediaQuery.of(context).size.width * 0.008,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    setting['title'] ?? "",
                                    style: AppTextStyles.caption(
                                      context,
                                      color: isSelected ? AppColors.black:Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              ),
            ],
          ),
        );
      }
    );
  }


  IconData _getIcon(String title) {
    switch (title) {

      case "Dashboard":
        return Icons.dashboard_rounded;

      case "Clinic Profile":
      case "Lab Profile":
      case "Shop Profile":
      case "Profile":
        return Icons.account_circle_rounded;

      case "Edit Profile":
      case "Add Profile":
        return Icons.edit_rounded;

      case "Add admin":
        return Icons.admin_panel_settings_rounded;

      case "UserList":
        return Icons.groups_rounded;

      case "My Subscription":
        return Icons.workspace_premium_rounded;

      case "My Purchases":
        return Icons.receipt_long_rounded;

      case "Create Plan":
        return Icons.add_card_rounded;

      case "Reports":
        return Icons.bar_chart_rounded;

      case "Job/Webinars":
      case "Jobs":
        return Icons.work_rounded;

      case "My Jobs":
        return Icons.work_history_rounded;

      case "Services":
        return Icons.miscellaneous_services_rounded;

      case "Products":
        return Icons.inventory_2_rounded;

      case "Add JobCategory":
        return Icons.category_rounded;

      case "Contact Form":
        return Icons.contact_mail_rounded;

      case "Add Branches":
        return Icons.account_tree_rounded;

      case "Change Password":
        return Icons.lock_reset_rounded;

      case "Create Notification":
        return Icons.notifications_active_rounded;

        case "Create Scrolling Ads Post":
        return Icons.campaign_rounded;

        case "Settings":
        return Icons.settings_rounded;

        case "About Us":
        return Icons.info_outline_rounded;

        case "Logout":
        return Icons.logout_rounded;

      default:
        return Icons.circle_outlined;
    }
  }
}