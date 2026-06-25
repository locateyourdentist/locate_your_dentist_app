import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:locate_your_dentist/web_modules/auth_web/web_login_page.dart';
import 'package:locate_your_dentist/web_modules/common/common_filter_dialog.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/branch_list_web.dart';
import '../../common_widgets/color_code.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common_widgets/common_widget_all.dart';
import '../../modules/auth/login_screen/service_locations.dart';


PreferredSizeWidget buildAppBar(dynamic context) {
  double size=MediaQuery.of(context).size.width;
  if (Api.userInfo.read('token') != null) {
    return CommonWebAppBar(
      height: size * 0.03,
      title: "LYD",
      onLogout: () {},
      onNotification: () {},
    );
  } else {
    return   CommonHeader();
  }
}


class CommonFooter extends StatefulWidget {
  const CommonFooter({super.key});

  @override
  State<CommonFooter> createState() => _CommonFooterState();
}

class _CommonFooterState extends State<CommonFooter> {
  final LoginController loginController = Get.find();
  final PlanController planController = Get.put(PlanController());

  final List<String> titles = const [
    "Privacy Policy",
    "Terms & Conditions",
    "Cookie Policy",
    "Refund Policy",
    "Disclaimer",
  ];

  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }

  Future<void> launchWebsite(String url) async {
    String safeUrl = url.trim();

    if (!safeUrl.startsWith('http')) {
      safeUrl = 'https://$safeUrl';
    }

    final Uri uri = Uri.parse(safeUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Could not open website",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    bool isMobile = width < 768;
    bool isTablet = width >= 768 && width < 1024;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: isMobile ? 20 : 40,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.secondary,
            AppColors.primary,
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1500),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// 🔹 MAIN CONTENT
              isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogoSection(context),
                  const SizedBox(height: 20),
                  VerticalDivider(
                    color: Colors.white,
                    thickness: 1,
                    width: 20,
                  ),

                  _buildCompanySection(context),
                  const SizedBox(height: 20),
                  VerticalDivider(
                    color: Colors.white,
                    thickness: 1,
                    width: 20,
                  ),

                  _buildContactSection(context),
                  const SizedBox(height: 20),
                  VerticalDivider(
                    color: Colors.white,
                    thickness: 1,
                    width: 20,
                  ),

                  _buildLegalSection(context),
                ],
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildLogoSection(context)),
                  const SizedBox(width: 20),
                  VerticalDivider(
                    color: Colors.white,
                    thickness: 1,
                    width: 20,
                  ),
                  Expanded(flex: 2, child: _buildContactSection(context)),
                  const SizedBox(width: 20),
                  VerticalDivider(
                    color: Colors.white,
                    thickness: 1,
                    width: 20,
                  ),
                  Expanded(flex: 1, child: _buildLegalSection(context)),
                  const SizedBox(width: 20),
                  VerticalDivider(
                    color: Colors.white,
                    thickness: 1,
                    width: 20,
                  ),
                  Expanded(flex: 1, child: _buildCompanySection(context)),
                  // const SizedBox(width: 20),

                ],
              ),

              const SizedBox(height: 20),
              Divider(color: AppColors.white, thickness: 0.2),

              isMobile
                  ? Column(
                children: [
                  Text(
                    "© ${DateTime.now().year} ${AppConstants.appName}. All rights reserved.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption(
                      context,
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      launchWebsite(
                          AppConstants.developerCompanyUrl);
                    },
                    child: Text(
                      "Developed by @ ${AppConstants.developerCompanyName}",
                      style: AppTextStyles.caption(
                        context,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "© ${DateTime.now().year} ${AppConstants.appName}. All rights reserved.",
                    style: AppTextStyles.caption(
                      context,
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      launchWebsite(
                          AppConstants.developerCompanyUrl);
                    },
                    child: Text(
                      "Developed by @ ${AppConstants.developerCompanyName}",
                      style: AppTextStyles.caption(
                        context,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GetBuilder<LoginController>(
              builder: (controller) {
                return Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: controller.appLogoFile != null
                        ? Image.file(controller.appLogoFile!,
                        fit: BoxFit.cover)
                        : controller.appLogoUrl != null
                        ? Image.network(controller.appLogoUrl!,
                        fit: BoxFit.cover)
                        : const Icon(Icons.image_outlined,
                        color: Colors.white),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppConstants.appName,
                style: AppTextStyles.subtitle(
                  context,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Text(
          AppConstants.appDescription,
          style: AppTextStyles.caption(
            context,
            color: AppColors.white.withOpacity(0.9),
          ),
        ),

      ],
    );
  }

  Widget _buildCompanySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerTitle(context, "Company"),
        const SizedBox(height: 10),
        _footerLink(context, "Home", () {
          Get.toNamed('/landingPage',);
        }),
        _footerLink(context, "About Us", () {
          Get.toNamed('/aboutUsWebPage',);
        }),
        _footerLink(context, "Contact Us", () {
          Get.toNamed('/contactWebPage');
        }),
        const SizedBox(height: 15),
        Text(
          "Follow Us On",
          style: AppTextStyles.caption(
            context,
            color: AppColors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            _socialIcon("assets/images/facebook.png",
                    () => launchWebsite("https://facebook.com")),
            _socialIcon("assets/images/instagram.png",
                    () => launchWebsite("https://instagram.com")),
            _socialIcon("assets/images/youtube.png",
                    () => launchWebsite("https://youtube.com")),
            _socialIcon("assets/images/linkein.png",
                    () => launchWebsite("https://linkedin.com")),
          ],
        ),
      ],
    );
  }

  Future<void> launchCall1(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerTitle(context, "Contact"),
        const SizedBox(height: 10),

        _infoRow(Icons.location_on,
            "${planController.streetController.text}, ${planController.cityController.text}, ${planController.stateController.text}, ${planController.zipController.text}"),

        _infoRow(Icons.phone,onTap: ()async {
          await   launchCall1("tel:${planController.phoneController.text.toString()}");
        }, planController.phoneController.text),

        _infoRow(Icons.email,   onTap: ()async {
          await  sendEmail("mailto:${planController.emailController.text.toString()}");
        }, planController.emailController.text),
      ],
    );
  }
  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerTitle(context, "Legal"),
        const SizedBox(height: 10),
        ...titles.map((title) {
          return _footerLink(context, title, () {
            Api.userInfo.write('legalPage', title);
            Get.toNamed('/viewLegalPage',
                arguments: {'title': title});
          });
        }).toList(),
      ],
    );
  }
  Widget _footerTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.caption(
        context,
        color: AppColors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _footerLink(
      BuildContext context, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: AppTextStyles.caption(
            context,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
      IconData icon,
      String text, {
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.caption(
                  context,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _socialIcon(String path, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        path,
        height: 22,
        width: 22,
        color: Colors.white,
      ),
    );
  }
}

class EnlargeOnTapCard extends StatefulWidget {
  final Widget child;
  const EnlargeOnTapCard({required this.child, super.key});

  @override
  State<EnlargeOnTapCard> createState() => _EnlargeOnTapCardState();
}

class _EnlargeOnTapCardState extends State<EnlargeOnTapCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      child: AnimatedScale(
        scale: _isTapped ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}



class CommonHeader extends StatefulWidget implements PreferredSizeWidget {
  const CommonHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(85);

  @override
  State<CommonHeader> createState() => _CommonHeaderState();
}

class _CommonHeaderState extends State<CommonHeader> {
  final loginController = Get.put(LoginController());
  final planController = Get.put(PlanController());

  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
    planController.getCompanyDetails();
  }

  Widget navItem(String title, String route) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Get.toNamed(route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget socialIcon(
      IconData icon,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }
  Future<void> launchWebsite(String url) async {
    String safeUrl = url.trim();

    if (!safeUrl.startsWith('http')) {
      safeUrl = 'https://$safeUrl';
    }

    final Uri uri = Uri.parse(safeUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Could not open website",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Material(
      elevation: 2,
      color: Colors.white,
      child: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [

            /// LOGO
            Row(
              children: [
                Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      loginController.appLogoUrl ?? "",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Icon(Icons.image);
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      "Dental Services Platform",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            /// MENU
            if (width > 900)
              Row(
                children: [
                  navItem("Home", "/"),
                  navItem("Jobs", "/jobListJobSeekersWebPage"),
                  navItem("About Us", "/aboutUsWebPage"),
                  navItem("Contact", "/contactWebPage"),
                ],
              ),

            const Spacer(),

            /// CONTACT
            if (width > 1000)
              Row(
                children: [

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          planController.emailController.text,
                          style: AppTextStyles.caption(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.call_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          planController.phoneController.text,
                          style: AppTextStyles.caption(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 15),
                  socialIcon(Icons.facebook,
                          () => launchWebsite("https://facebook.com")),
                  socialIcon(Icons.camera_alt_outlined,
                          () => launchWebsite("https://instagram.com")),
                  socialIcon(Icons.alternate_email,
                          () => launchWebsite("https://youtube.com")),
                  // socialIcon("assets/images/linkein.png",
                  //         () => launchWebsite("https://linkedin.com")),

                //  socialIcon(Icons.facebook),
                  //socialIcon(Icons.camera_alt_outlined),
                 // socialIcon(Icons.alternate_email),
                ],
              ),

            const SizedBox(width: 20),

            /// LOGIN BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Get.to(() => WebLoginPage());
              },
              child: Text(
                "Login/Register",
                style: AppTextStyles.caption(
                  context,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
void showFilterDialog(BuildContext context,
    {required VoidCallback onApply, required VoidCallback onReset}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          width: 200,
          height: MediaQuery.of(context).size.height * 0.75,
          child: FilterDialogContent(
            onApply: onApply,
            onReset: onReset,
          ),
        ),
      );
    },
  );
}


class CommonWebAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final String title;
  final VoidCallback? onLogout;
  final VoidCallback? onNotification;

  const CommonWebAppBar({
    super.key,
    this.height = 80,
    this.title = "Admin Dashboard",
    this.onLogout,
    this.onNotification,
  });

  @override
  Size get preferredSize => Size.fromHeight(height < 60 ? 60 : height);

  @override
  State<CommonWebAppBar> createState() => _CommonWebAppBarState();
}

class _CommonWebAppBarState extends State<CommonWebAppBar> {
  final notificationController = Get.put(NotificationController());
  final loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await loginController.getAppLogoImage(context);
    await notificationController.getNotificationListAdmin(context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    bool isMobile = width < 768;
    bool isTablet = width >= 768 && width < 1024;

    double safeHeight = widget.height < 60 ? 60 : widget.height;

    return GetBuilder<LoginController>(
      builder: (_) {
        return SafeArea(
          child: Container(
            height: safeHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary,AppColors.secondary],
              ),
            ),
            child: isMobile
                ? _mobileLayout()
                : _desktopLayout(isTablet),
          ),
        );
      },
    );
  }

  Widget _mobileLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _logo(),
              const SizedBox(width: 8),
              const Text(
                "Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _notificationModern(),
              const SizedBox(width: 8),
              _profileSection(),
            ],
          ),
        ],
      ),
    );
  }


  Widget _desktopLayout(bool isTablet) {
    bool multipleBranches = loginController.userBranchesList.length > 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Row(
            children: [
              _logo(),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (multipleBranches && !isTablet)
                _switchAccountModern(),

              const SizedBox(width: 16),
              _notificationModern(),

              const SizedBox(width: 16),
              _profileSection(),

             // const SizedBox(width: 16),
             // if (!isTablet) _profileSection(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return loginController.appLogoUrl != null
        ? ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        loginController.appLogoUrl!,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
      ),
    )
        : const Icon(Icons.local_hospital, color: Colors.white, size: 32);
  }

  Widget _switchAccountModern() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        await loginController.getBranchDetails(context);
        await showBranchSelectionDialog(
          context: context,
          pageRoute: "dashboard",
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.1),
        ),
        child: const Row(
          children: [
            Icon(Icons.swap_horiz, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text("Switch", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
  Future<void> getLocation() async {
    final position = await LocationService.getCurrentLocation();

    if (position != null) {
      loginController.latitude = position.latitude;
      loginController.longitude = position.longitude;
      print('latitude ${loginController.latitude}');
      print('longitude ${loginController.longitude}');

    } else {
      Get.snackbar('Location', 'Unable to get location');
    }
  }
  Widget _notificationModern() {
    return GetBuilder<NotificationController>(
      builder: (_) {
        int unread =
            int.tryParse(notificationController.unreadCount ?? "0") ?? 0;

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () async {
                  await notificationController.getNotificationListAdmin(context);
                  await notificationController.updateNotificationListAdmin(context);
                  Get.toNamed('/viewNotificationWebPage');
                },
              ),
            ),

            if (unread > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unread.toString(),
                    style: const TextStyle(
                        fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Widget _profileModern() {
  //   return GestureDetector(
  //     onTap: () {
  //       Get.toNamed('/clinicProfileWebPage');
  //     },
  //     child: Row(
  //       children: [
  //         CircleAvatar(
  //           radius: 18,
  //           backgroundImage: NetworkImage(
  //             Api.userInfo.read("profileImage") ?? "",
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _logoutModern() {
  //   return TextButton(
  //     style: TextButton.styleFrom(
  //       backgroundColor: Colors.red.withOpacity(0.15),
  //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //     ),
  //     onPressed: () {
  //       showLogoutDialog(context);
  //     },
  //     child:  Text(
  //       "Logout",
  //       style: AppTextStyles.caption(context,color: Colors.white),
  //     ),
  //   );
  // }
  Widget _profileSection() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 60),
      onSelected: (value) {
        if (value == "profile") {
          Get.toNamed('/clinicProfileWebPage');
        } else if (value == "logout") {
          showLogoutDialog(context);
        }
      },
      itemBuilder: (_) => [
         PopupMenuItem(
          value: "profile",
          child: ListTile(
            leading: Icon(Icons.person_outline,color:AppColors.black,size: 18,),
            title: Text("My Profile",style: AppTextStyles.caption(context,color: Colors.black),),
            contentPadding: EdgeInsets.zero,
          ),
        ),
         PopupMenuItem(
          value: "logout",
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout",style: AppTextStyles.caption(context,color: Colors.red),),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              Api.userInfo.read("profileImage") ?? "",
            ),
          ),
          // const SizedBox(height: 4),
          // Icon(
          //   Icons.keyboard_arrow_down,
          //   size: 18,
          //   color: Colors.white,
          // ),
        ],
      ),
    );
  }}

Widget gradientButton({
  required String text,
  required VoidCallback onTap,
  IconData? icon,
  double width = double.infinity,
  double height = 50,
  dynamic context,
}) {
  return Container(
    width: width,
    height: height,
    margin: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      gradient: const LinearGradient(
        colors: [AppColors.white, AppColors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: AppColors.primary,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(0, 4),
          blurRadius: 6,
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  style: AppTextStyles.caption(
                    context,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}