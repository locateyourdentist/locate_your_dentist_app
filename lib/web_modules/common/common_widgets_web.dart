import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:locate_your_dentist/web_modules/auth_web/web_login_page.dart';
import 'package:locate_your_dentist/web_modules/common/common_filter_dialog.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/branch_list_web.dart';
import '../../common_widgets/color_code.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonFooter extends StatefulWidget {
  const CommonFooter({super.key});

  @override
  State<CommonFooter> createState() => _CommonFooterState();
}

class _CommonFooterState extends State<CommonFooter> {
  final LoginController loginController = Get.find();

  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }
  Future<void> launchWebsite(String url) async {
    String safeUrl = url.trim();

    if (!safeUrl.startsWith('http://') && !safeUrl.startsWith('https://')) {
      safeUrl = 'https://$safeUrl';
    }

    final Uri uri = Uri.parse(safeUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Error",
        "Could not open website",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
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
          stops: [0.0, 0.2, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1300),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GetBuilder<LoginController>(
                              builder: (controller) {
                                return GestureDetector(
                                  onTap: () {
                                  },
                                  child: Container(
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
                                          ? Image.file(
                                        controller.appLogoFile!,
                                        fit: BoxFit.cover,
                                      )
                                          : controller.appLogoUrl != null
                                          ? Image.network(
                                        controller.appLogoUrl!,
                                        fit: BoxFit.cover,
                                      )
                                          : const Icon(
                                        Icons.image_outlined,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(width: 12),

                            /// App Name
                            Text(
                              AppConstants.appName,
                              style: AppTextStyles.subtitle(
                                context,
                                color: AppColors.white,
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

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            _socialIcon("assets/images/facebook.png",(){
                              launchWebsite("https://facebook.com");}),
                            const SizedBox(width: 10),
                            _socialIcon("assets/images/instagram.png",(){
                              launchWebsite("https://instagram.com");}),
                            const SizedBox(width: 10),
                            _socialIcon("assets/images/youtube.png",(){
                              launchWebsite("https://youtube.com");}),
                            const SizedBox(width: 10),
                            _socialIcon("assets/images/linkein.png",(){
                              launchWebsite("https://www.linkedin.com");}),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// Copyright
                        Text(
                          "© ${DateTime.now().year} ${AppConstants.appName}. All rights reserved.",
                          style: AppTextStyles.caption(
                            context,
                            color: AppColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _footerTitle(context, "Company"),
                        const SizedBox(height: 10),
                        _footerLink(context, "About Us"),
                        _footerLink(context, "Contact Us"),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _footerTitle(context, "Legal"),
                        const SizedBox(height: 10),
                        _footerLink(context, "Privacy Policy"),
                        _footerLink(context, "Terms of Service"),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _footerTitle(context, "Contact"),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Tamil nadu,Chennai",
                                style: AppTextStyles.caption(
                                  context,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "+91 98765 43210",
                              style: AppTextStyles.caption(
                                context,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.email, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              AppConstants.companyEmail,
                              style: AppTextStyles.caption(
                                context,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  launchWebsite(AppConstants.developerCompanyUrl);
                },
                child:Text(
                "Developed by @ ${AppConstants.developerCompanyName}",
                style: AppTextStyles.caption(
                  context,
                  color: AppColors.white.withOpacity(0.9),
                )
              ),)
            ],
          ),
        ),
      ),
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

  Widget _footerLink(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: () {},
        child: Text(
          title,
          style: AppTextStyles.caption(
            context,
            color: AppColors.white,
          )
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


class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  const CommonHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Container(
      //color: Colors.white,
      alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                 Icon(Icons.medical_services, color: Colors.white, size: size*0.02),
                const SizedBox(width: 8),
                Text('LYD',
                  //AppConstants.appName,
                  style: GoogleFonts.alice(
                    fontSize: size*0.016,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            SizedBox(width: size*0.06,),
            Expanded(
              //width:size*0.25 ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _navItem(context, "Home"),
                  _navItem(context, "Clinics"),
                  _navItem(context, "Jobs"),
                  _navItem(context, "About"),
                  _navItem(context, "Contact"),
                ],
              ),
            ),
            SizedBox(width: size*0.001,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WebLoginPage()),
                );
              },
              child: const Text(
                "Login",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {
          if (title == "Home") Get.toNamed('/landingPage');
          if (title == "Clinics") Get.toNamed('/clinics');
          if (title == "Jobs") Get.toNamed('/jobListJobSeekersWebPage');
          if (title == "About") Get.toNamed('/aboutUsWebPage');

        },
        child: Text(
          title,
          style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white)
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
          width: 600,
          height: MediaQuery
              .of(context)
              .size
              .height * 0.75,
          child: FilterDialogContent(
            onApply: onApply,
            onReset: onReset,
          ),
        ),
      );
    },
  );
}



class CommonWebAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String title;
  final VoidCallback? onLogout;
  final VoidCallback? onNotification;
  final context;

   CommonWebAppBar({
    super.key,
    required this.height,
    this.title = "Admin Dashboard",
    this.onLogout,
    this.onNotification,
     this.context
  });
  final notificationController=Get.put(NotificationController());
  @override
  void initState() {
    //super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
    await notificationController.getNotificationListAdmin(context);
    }
  @override
  Widget build(BuildContext context) {
    final loginController = Get.put(LoginController());
    bool multipleBranches = loginController.userBranchesList.length > 1;
    return  GetBuilder<LoginController>(
        builder: (controller) {
          return Container(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary,AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.dashboard,
                      color: AppColors.white, size: height * 0.22),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: AppTextStyles.subtitle(
                      context,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              Row(
                children: [

                  if(multipleBranches)
                    GestureDetector(
                        onTap: ()async{
                          await   loginController.getBranchDetails(context);
                          await showBranchSelectionDialog(
                          context: context,
                          pageRoute: "dashboard",);
                        },
                        child: Image.asset('assets/images/switch_account.png',height: height*0.15,width: height*0.18,)),
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.switch_access_shortcut,
                  //     color: AppColors.white,
                  //     size: height * 0.21,
                  //   ),
                  //   onPressed: ()async{
                  //     await   loginController.getBranchDetails(context);
                  //     await showBranchSelectionDialog(
                  //       context: context,
                  //       pageRoute: "dashboard",);
                  //     },
                  // ),
                  const SizedBox(width: 10,),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_none,
                          color: AppColors.white,
                          size: height * 0.21,
                        ),
                        onPressed: ()async{
                          await  notificationController.getNotificationListAdmin(context);
                          await notificationController.updateNotificationListAdmin(context);
                          notificationController.unreadCount==0;
                          Get.toNamed('/viewNotificationWebPage');
                          },
                      ),
                      if (int.tryParse(notificationController.unreadCount ?? "0")! > 0)

                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child:  Text(
                            notificationController.unreadCount.toString()??"",
                            style: AppTextStyles.caption(context,color: AppColors.white)
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: ()async{
                     await loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);

                      Get.toNamed('/clinicProfileWebPage');
                    },
                    child: CircleAvatar(
                      radius: height * 0.11,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: NetworkImage(
                        Api.userInfo.read("profileImage") ?? "",
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  TextButton.icon(
                    onPressed: (){
                      showLogoutDialog(context);
                      },
                    icon: const Icon(Icons.logout,color:Colors.white,),
                    label: Text(
                      "Logout",
                      style:
                      AppTextStyles.caption(context, color: Colors.white,fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

Widget gradientButton({required String text, required VoidCallback onTap, double width = double.infinity, double height = 50,dynamic context}) {
  return Container(
    width: width,
    height: height,margin: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      gradient: const LinearGradient(
        colors: [AppColors.white,AppColors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),border: Border.all(
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
        borderRadius: BorderRadius.circular(1),
        onTap: onTap,
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.caption(context,color: AppColors.primary,fontWeight: FontWeight.bold)
          ),
        ),
      ),
    ),
  );
}