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
import 'package:google_fonts/google_fonts.dart';



class CustomAppBar extends StatefulWidget {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isScrolled = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.pixels > 50 && !isScrolled) {
          setState(() => isScrolled = true);
        } else if (scroll.metrics.pixels <= 50 && isScrolled) {
          setState(() => isScrolled = false);
        }
        return true;
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        color: isScrolled ? Colors.green.shade900 : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                TextButton(onPressed: () {}, child: Text("Home",style: AppTextStyles.caption(context),)),
                TextButton(onPressed: () {}, child: Text("About",style: AppTextStyles.caption(context),)),
                TextButton(onPressed: () {}, child: Text("Products",style: AppTextStyles.caption(context),)),
                TextButton(onPressed: () {}, child: Text("Contact",style: AppTextStyles.caption(context),)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
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
  final PlanController planController=Get.put(PlanController());
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
    double s=MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
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

                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _footerTitle(context, "Company",),
                        const SizedBox(height: 10),
                        _footerLink(context, "About Us",(){}),
                        _footerLink(context, "Contact Us",(){}),
                      ],
                    ),
                  ),

                  // Expanded(
                  //   flex: 2,
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       _footerTitle(context, "Legal"),
                  //       const SizedBox(height: 10),
                  //       _footerLink(context, "Privacy Policy"),
                  //       _footerLink(context, "Terms of Service"),
                  //     ],
                  //   ),
                  // ),
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
                                "${planController.streetController.text??""},${planController.cityController.text??""},${planController.stateController.text??""},${planController.zipController.text}",
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
                              planController.phoneController.text??"",
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
                              planController.emailController.text??"",
                              style: AppTextStyles.caption(
                                context,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                       // SizedBox(height: s*0.025,),
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

                        ...titles.map((title) {
                          return _footerLink(context, title,   () {
                            Api.userInfo.write('legalPage',title);
                            Get.toNamed('/viewLegalPage',
                              arguments: {'title':title},
                            );
                          },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(color: AppColors.white,thickness: 0.2,),
              Row(
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
                      launchWebsite(AppConstants.developerCompanyUrl);
                    },
                    child:Text(
                        "Developed by @ ${AppConstants.developerCompanyName}",
                        style: AppTextStyles.caption(
                          context,
                          color: AppColors.white.withOpacity(0.9),
                        )
                    ),),
                ],
              )
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

  Widget _footerLink(BuildContext context, String title,VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
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


// class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
//   const CommonHeader({super.key});
//
//   @override
//   Size get preferredSize => const Size.fromHeight(80);
//
//   @override
//   Widget build(BuildContext context) {
//     double size=MediaQuery.of(context).size.width;
//     return Container(
//       //color: Colors.white,
//       alignment: Alignment.center,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(0),
//           gradient: const LinearGradient(
//             colors: [AppColors.primary, AppColors.secondary],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),),
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 1200),
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                  Icon(Icons.medical_services, color: Colors.white, size: size*0.02),
//                 const SizedBox(width: 8),
//                 Text('LYD',
//                   //AppConstants.appName,
//                   style: GoogleFonts.alice(
//                     fontSize: size*0.016,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.white,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(width: size*0.06,),
//             Expanded(
//               //width:size*0.25 ,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   _navItem(context, "Home"),
//                   _navItem(context, "Clinics"),
//                   _navItem(context, "Jobs"),
//                   _navItem(context, "About"),
//                   _navItem(context, "Contact"),
//                 ],
//               ),
//             ),
//             SizedBox(width: size*0.001,),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => WebLoginPage()),
//                 );
//               },
//               child: const Text(
//                 "Login",
//                 style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// class CommonHeader extends StatefulWidget implements PreferredSizeWidget {
//   @override
//   Size get preferredSize => const Size.fromHeight(80);
//   State<CommonHeader> createState() => _CommonHeaderState();
// }
//
// class _CommonHeaderState extends State<CommonHeader> {
//   //const CommonHeader({super.key});
//   final loginController=Get.put(LoginController());
//
//   @override
//  // Size get preferredSize => const Size.fromHeight(80);
//
//   @override
//
//   @override
//   void initState() {
//     super.initState();
//     loginController.getAppLogoImage(context);
//   }
//
//   Widget build(BuildContext context) {
//     double size = MediaQuery.of(context).size.width;
//
//     return AppBar(
//       automaticallyImplyLeading: false,
//       elevation: 4,
//       backgroundColor: Colors.transparent,
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppColors.white, AppColors.white],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//       ),
//
//       titleSpacing: 0,
//       title: Container(
//         constraints: const BoxConstraints(maxWidth: 1200),
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Icon(Icons.medical_services,
//             //     color: Colors.white, size: size * 0.02),
//             loginController.appLogoUrl != null
//                 ? Image.network(
//               loginController.appLogoUrl!,
//               fit: BoxFit.cover,
//               width: size*0.025,
//               height: size*0.025,
//             )
//                 : Container(
//               color: Colors.transparent,
//               child:  Icon(
//                 Icons.medical_services,
//                 size: size*0.02,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(width: 8),
//
//             Text(
//               AppConstants.appNameShort,
//               style: GoogleFonts.alice(
//                 fontSize: size * 0.016,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.black,
//               ),
//             ),
//
//             const Spacer(),
//
//
//             _navItem(context, "Home"),
//             _navItem(context, "Clinics"),
//             _navItem(context, "Jobs"),
//             _navItem(context, "About"),
//             _navItem(context, "Contact Us"),
//
//             const SizedBox(width: 10),
//
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => WebLoginPage()),
//                 );
//               },
//               child:  Text(
//                 "Login",
//                 style:AppTextStyles.body(context,color: AppColors.white)
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _navItem(BuildContext context, String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: TextButton(
//         onPressed: () {
//           if (title == "Home") Get.toNamed('/landingPage');
//           if (title == "Clinics") Get.toNamed('/clinics');
//           if (title == "Jobs") Get.toNamed('/jobListJobSeekersWebPage');
//           if (title == "About") Get.toNamed('/aboutUsWebPage');
//           if (title == "Contact Us") Get.toNamed('/contactWebPage');
//
//         },
//         child: Text(
//           title,
//           style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.black)
//         ),
//       ),
//     );
//   }
// }
// class CommonHeader extends StatefulWidget implements PreferredSizeWidget {
//   @override
//   Size get preferredSize => const Size.fromHeight(95);
//
//   @override
//   State<CommonHeader> createState() => _CommonHeaderState();
// }
//
// class _CommonHeaderState extends State<CommonHeader> {
//   final loginController = Get.put(LoginController());
//
//   bool _scrolled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     loginController.getAppLogoImage(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double size = MediaQuery.of(context).size.width;
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//
//         Container(
//           height: size*0.02,
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           decoration: const BoxDecoration(
//             color: AppColors.primary
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children:  [
//
//               Icon(Icons.email, size: size*0.013, color: Colors.white),
//               SizedBox(width: size*0.002),
//               Text(
//                 AppConstants.companyEmail,
//                 style: AppTextStyles.body(context,color: AppColors.white)
//               ),
//
//               SizedBox(width: size*0.04),
//
//               Icon(Icons.facebook, color: Colors.white,size: size*0.013,),
//               SizedBox(width: size*0.01),
//               Icon(Icons.camera_alt, color: Colors.white, size: size*0.013,),
//               SizedBox(width: size*0.01),
//               Icon(Icons.alternate_email, color: Colors.white, size: size*0.013,),
//             ],
//           ),
//         ),
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           height: size*0.02,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               if (_scrolled)
//                 const BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 12,
//                 )
//             ],
//           ),
//
//           child: Row(
//             children: [
//
//               loginController.appLogoUrl != null
//                   ? Image.network(
//                 loginController.appLogoUrl!,
//                 height: size*0.2,
//                 fit: BoxFit.contain,
//               )
//                   :  Icon(Icons.medical_services_rounded, color: AppColors.primary, size: size*0.017),
//
//               const SizedBox(width: 10),
//
//               Text(
//                 AppConstants.appNameShort,
//                 style: GoogleFonts.poppins(
//                   fontSize: size*0.013,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//
//               const Spacer(),
//
//               Row(
//                 children: [
//                   _navItem("Home", '/landingPage'),
//                   _navItem("Clinics", '/clinics'),
//                   _navItem("Jobs", '/jobListJobSeekersWebPage'),
//                   _navItem("About", '/aboutUsWebPage'),
//                   _navItem("Contact", '/contactWebPage'),
//                 ],
//               ),
//
//               const SizedBox(width: 16),
//
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2E7D32),
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   elevation: 0,
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => WebLoginPage()),
//                   );
//                 },
//                 child:  Text(
//                   "Login",
//                     style: AppTextStyles.caption(context,color: AppColors.white)
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _navItem(String title, String route) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 6),
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(20),
//           onTap: () => Get.toNamed(route),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 8,
//             ),
//             child: Text(
//               title,
//               style:AppTextStyles.caption(context,fontWeight: FontWeight.bold)
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// class CommonHeader extends StatefulWidget implements PreferredSizeWidget {
//   const CommonHeader({super.key});
//
//   @override
//   Size get preferredSize => const Size.fromHeight(110);
//
//   @override
//   State<CommonHeader> createState() => _CommonHeaderState();
// }
//
// class _CommonHeaderState extends State<CommonHeader> {
//   final loginController = Get.put(LoginController());
//   final planController = Get.put(PlanController());
//
//   @override
//   void initState() {
//     super.initState();
//     loginController.getAppLogoImage(context);
//     planController.getCompanyDetails();
//   }
//   @override
//   Widget build(BuildContext context) {
//     final double size = MediaQuery.of(context).size.width;
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//
//         Container(
//           width: double.infinity,
//           color: AppColors.primary,
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//           child: Row(
//             children: [
//                Icon(Icons.email, size:  size*0.013, color: Colors.white),
//               const SizedBox(width: 6),
//               Text(planController.emailController.text ?? "",style: AppTextStyles.caption(context,color: Colors.white,fontWeight: FontWeight.normal),),
//
//               const SizedBox(width: 20),
//
//                Icon(Icons.call,size:  size*0.013,color: Colors.white),
//               const SizedBox(width: 6),
//               Text(planController.phoneController.text ?? "",style: AppTextStyles.caption(context,color: Colors.white,fontWeight: FontWeight.normal),),
//
//               const Spacer(),
//
//               Row(
//                 children:  [
//                   Icon(Icons.facebook, size:  size*0.01,color: Colors.white),
//                   SizedBox(width: 10),
//                   Icon(Icons.camera_alt,size:  size*0.01, color: Colors.white),
//                   SizedBox(width: 10),
//                   Icon(Icons.alternate_email,size:  size*0.01, color: Colors.white),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         Container(
//           width: double.infinity,
//           color: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//
//               Image.network(
//                 loginController.appLogoUrl ?? "",
//                 height: size*0.02,
//               ),
//
//               const SizedBox(width: 10),
//
//               Flexible(
//                 child: Text(
//                   AppConstants.appNameShort,
//                 style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold), ),
//               ),
//
//               const Spacer(),
//
//               Flexible(
//                 child: Wrap(
//                   spacing: 20,
//                   children: [
//                     _navItem("Home", '/landingPage'),
//                     _navItem("Jobs", '/jobListJobSeekersWebPage'),
//                     _navItem("About", '/aboutUsWebPage'),
//                     _navItem("Contact", '/contactWebPage'),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 20),
//
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primary,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 20,
//                                 vertical: 12,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               elevation: 0,
//                             ),
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => WebLoginPage(),
//                                 ),
//                               );
//                             },
//                             child: Text(
//                               "Login",
//                               style: AppTextStyles.caption(
//                                 context,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//             ],
//           ),
//         ),
//       ],
//     );

class CommonHeader extends StatefulWidget implements PreferredSizeWidget {
  const CommonHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(140);

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

  Widget _navItem(String title, String route) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 90,
      child: Column(
        children: [

          Container(
            height: 45,
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.email, size: 14, color: Colors.white),
                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    planController.emailController.text ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(
                      context,
                      color: Colors.white,
                    ),
                  ),
                ),

               // const SizedBox(width: 20),

                Icon(Icons.call, size: 14, color: Colors.white),
                const SizedBox(width: 6),

                Text(
                  planController.phoneController.text ?? "",
                  style: AppTextStyles.caption(
                    context,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                Row(
                  children: const [
                    Icon(Icons.facebook, size: 18, color: Colors.white),
                    SizedBox(width: 10),
                    Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    SizedBox(width: 10),
                    Icon(Icons.alternate_email, size: 18, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [

                  // LOGO
                  Image.network(
                    loginController.appLogoUrl ?? "",
                    height: 28,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image, size: 30),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    AppConstants.appNameShort,
                    style: AppTextStyles.body(
                      context,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const Spacer(),

                  // NAV ITEMS (Responsive safe)
                  Flexible(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 5,
                      children: [
                        _navItem("Home", '/landingPage'),
                        _navItem("Jobs", '/jobListJobSeekersWebPage'),
                        _navItem("About", '/aboutUsWebPage'),
                        _navItem("Contact", '/contactWebPage'),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Get.to(() => WebLoginPage());
                    },
                    child: Text(
                      "Login",
                      style: AppTextStyles.caption(
                        context,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
    //   Column(
    //   children: [
    //     Container(
    //       height: size*0.018,
    //       width: double.infinity,
    //       color: AppColors.primary,
    //       child: Center(
    //         child: ConstrainedBox(
    //           constraints: const BoxConstraints(maxWidth: 1500),
    //           child: Row(
    //             children: [
    //               const Icon(Icons.email, size: 14, color: Colors.white),
    //               const SizedBox(width: 6),
    //               Text(
    //                 planController.emailController.text??"",
    //                 style: AppTextStyles.caption(
    //                   context,
    //                   color: Colors.white,
    //                 ),
    //               ),
    //
    //               const SizedBox(width: 20),
    //
    //               const Icon(Icons.call, size: 14, color: Colors.white),
    //               const SizedBox(width: 6),
    //               Text(
    //                 planController.phoneController.text??"",
    //                 style: AppTextStyles.caption(
    //                   context,
    //                   color: Colors.white,
    //                 ),
    //               ),
    //
    //               const Spacer(),
    //
    //                Row(
    //                 children: [
    //                   Icon(Icons.facebook, color: Colors.white,size:  size*0.013,),
    //                   SizedBox(width: 10),
    //                   Icon(Icons.camera_alt, color: Colors.white,size:  size*0.013,),
    //                   SizedBox(width: 10),
    //                   Icon(Icons.alternate_email, color: Colors.white,size:size*0.013,),
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //
    //     Container(
    //       height: size*0.02,
    //       width: double.infinity,
    //       color: Colors.white,
    //       child: Center(
    //         child: ConstrainedBox(
    //           constraints:  BoxConstraints(maxWidth: 1500),
    //           child: Row(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: [
    //               loginController.appLogoUrl != null
    //                   ? Image.network(
    //                 loginController.appLogoUrl!,
    //                 height:size*0.26,
    //                 fit: BoxFit.contain,
    //               )
    //                   :  Icon(
    //                 Icons.medical_services_rounded,
    //                 color: AppColors.white,
    //                 size: size*0.015,
    //               ),
    //
    //               const SizedBox(width: 10),
    //
    //               Text(
    //                 AppConstants.appNameShort,
    //                 style: GoogleFonts.poppins(
    //                   fontSize:size*0.012,
    //                   fontWeight: FontWeight.w600,
    //                   color: Colors.black87,
    //                 ),
    //               ),
    //
    //               const Spacer(),
    //
    //               Row(
    //                 children: [
    //                   _navItem("Home", '/landingPage'),
    //                   _navItem("Clinics", '/clinics'),
    //                   _navItem("Jobs", '/jobListJobSeekersWebPage'),
    //                   _navItem("About", '/aboutUsWebPage'),
    //                   _navItem("Contact", '/contactWebPage'),
    //                 ],
    //               ),
    //
    //               const SizedBox(width: 20),
    //
    //               ElevatedButton(
    //                 style: ElevatedButton.styleFrom(
    //                   backgroundColor: AppColors.primary,
    //                   padding: const EdgeInsets.symmetric(
    //                     horizontal: 20,
    //                     vertical: 12,
    //                   ),
    //                   shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.circular(10),
    //                   ),
    //                   elevation: 0,
    //                 ),
    //                 onPressed: () {
    //                   Navigator.push(
    //                     context,
    //                     MaterialPageRoute(
    //                       builder: (context) => WebLoginPage(),
    //                     ),
    //                   );
    //                 },
    //                 child: Text(
    //                   "Login",
    //                   style: AppTextStyles.caption(
    //                     context,
    //                     color: Colors.white,
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );


  Widget _navItem(String title, String route,dynamic context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => Get.toNamed(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            child: Text(
              title,
              style: AppTextStyles.caption(
                context,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
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
    required this.height,
    this.title = "Admin Dashboard",
    this.onLogout,
    this.onNotification,
  });

  @override
  State<CommonWebAppBar> createState() => _CommonWebAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
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
    bool multipleBranches = loginController.userBranchesList.length > 1;
    double size=MediaQuery.of(context).size.width;

    return GetBuilder<LoginController>(
      builder: (_) {
        return Container(
          height: size * 0.03,
         // height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Row(
                children: [
                  loginController.appLogoUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      loginController.appLogoUrl!,
                      width: widget.height * 0.65,
                      height: widget.height * 0.65,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(Icons.medical_services,
                      size: widget.height * 0.45, color: Colors.white),

                  const SizedBox(width: 10),

                  Text(
                    widget.title,
                    style: AppTextStyles.body(
                      context,
                      color: Colors.white,fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),

              Row(
                children: [

                  if (multipleBranches)
                    GestureDetector(
                      onTap: () async {
                        await loginController.getBranchDetails(context);
                        await showBranchSelectionDialog(
                          context: context,
                          pageRoute: "dashboard",
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'Switch Account',
                            style: AppTextStyles.caption(
                              context,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            'assets/images/switch_account.png',
                            height: widget.height * 0.3,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(width: 10),

                  GetBuilder<NotificationController>(
                    builder: (_) {
                      int unread = int.tryParse(
                          notificationController.unreadCount ?? "0") ??
                          0;

                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: widget.height * 0.45,
                            ),
                            onPressed: () async {
                              await notificationController
                                  .getNotificationListAdmin(context);
                              await notificationController
                                  .updateNotificationListAdmin(context);

                              Get.toNamed('/viewNotificationWebPage');
                            },
                          ),

                          if (unread > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unread.toString(),
                                  style: AppTextStyles.caption(
                                      context, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () async {
                      String uId = Api.userInfo.read('userId') ?? "";
                      await Api.userInfo.write('selectUId', uId);
                      Get.toNamed('/clinicProfileWebPage');
                    },
                    child: CircleAvatar(
                      radius: widget.height * 0.35,
                      backgroundImage: NetworkImage(
                        Api.userInfo.read("profileImage") ?? "",
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  TextButton.icon(
                    onPressed: () {
                      showLogoutDialog(context);
                    },
                    icon: Icon(Icons.logout,
                        color: Colors.white, size: widget.height * 0.35),
                    label: Text(
                      "Logout",
                      style: AppTextStyles.caption(
                        context,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// class CommonWebAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final double height;
//   final String title;
//   final VoidCallback? onLogout;
//   final VoidCallback? onNotification;
//   final context;
//
//    CommonWebAppBar({
//     super.key,
//     required this.height,
//     this.title = "Admin Dashboard",
//     this.onLogout,
//     this.onNotification,
//      this.context
//   });
//   final notificationController=Get.put(NotificationController());
//   final loginController = Get.put(LoginController());
//   @override
//   void initState() {
//     //super.initState();
//     _refresh();
//   }
//   Future<void> _refresh() async {
//     await  loginController.getAppLogoImage(context);
//     await notificationController.getNotificationListAdmin(context);
//     }
//   @override
//   Widget build(BuildContext context) {
//     bool multipleBranches = loginController.userBranchesList.length > 1;
//     return  GetBuilder<LoginController>(
//         builder: (controller) {
//           return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 25),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [AppColors.primary,AppColors.secondary],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.15),
//                 blurRadius: 10,
//                 offset: const Offset(0, 3),
//               )
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   // Icon(Icons.dashboard,
//                   //     color: AppColors.white, size: height * 0.22),
//                   loginController.appLogoUrl != null
//                       ? ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                         child: Image.network(
//                         loginController.appLogoUrl!,
//                         fit: BoxFit.cover,
//                         width: height*0.25,
//                         height: height*0.25,
//                       ),
//                       )
//                       : Container(
//                     color: Colors.transparent,
//                     child:  Icon(
//                       Icons.medical_services,
//                       size: height*0.02,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     title,
//                     style: AppTextStyles.subtitle(
//                       context,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//
//               Row(
//                 children: [
//                   if(multipleBranches)
//                     GestureDetector(
//                         onTap: ()async{
//                           await   loginController.getBranchDetails(context);
//                           await showBranchSelectionDialog(
//                             context: context,
//                             pageRoute: "dashboard",);
//                         },
//                         child: Row(
//                             children:[
//                               Text('Switch Account',style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold),),
//                               Image.asset('assets/images/switch_account.png',height: height*0.016,width: height*0.022,)
//                             ])
//                     ),
//                   // if(multipleBranches)
//                   //   GestureDetector(
//                   //       onTap: ()async{
//                   //         await   loginController.getBranchDetails(context);
//                   //         await showBranchSelectionDialog(
//                   //         context: context,
//                   //         pageRoute: "dashboard",);
//                   //       },
//                   //       child: Row(
//                   //           children:[
//                   //             Text('Switch Account',style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold),),
//                   //            Image.asset('assets/images/switch_account.png',height: height*0.16,width: height*0.22,)])),
//
//                   const SizedBox(width: 10,),
//                   GetBuilder<NotificationController>(
//                       builder: (controller) {
//                         return Stack(
//                         children: [
//                           IconButton(
//                             icon: Icon(
//                               Icons.notifications_none,
//                               color: AppColors.white,
//                               size: height * 0.21,
//                             ),
//                             onPressed: ()async{
//                               await  notificationController.getNotificationListAdmin(context);
//                               await notificationController.updateNotificationListAdmin(context);
//                               notificationController.unreadCount==0;
//                               Get.toNamed('/viewNotificationWebPage');
//                               },
//                           ),
//                           if (int.tryParse(notificationController.unreadCount ?? "0")! > 0)
//
//                           Positioned(
//                             right: 6,
//                             top: 6,
//                             child: Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: const BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                               child:  Text(
//                                 notificationController.unreadCount.toString()??"",
//                                 style: AppTextStyles.caption(context,color: AppColors.white)
//                               ),
//                             ),
//                           )
//                         ],
//                       );
//                     }
//                   ),
//
//                   const SizedBox(width: 10),
//
//                   GestureDetector(
//                     onTap: ()async{
//                       String uId=Api.userInfo.read('userId')??"";
//                    await   Api.userInfo.write('selectUId',uId);
//                    print('fdfid$uId');
//                      //await loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
//
//                       Get.toNamed('/clinicProfileWebPage');
//                     },
//                     child: CircleAvatar(
//                       radius: height * 0.11,
//                       backgroundColor: Colors.grey.shade200,
//                       backgroundImage: NetworkImage(
//                         Api.userInfo.read("profileImage") ?? "",
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(width: 12),
//
//                   TextButton.icon(
//                     onPressed: (){
//                       showLogoutDialog(context);
//                       },
//                     icon:  Icon(Icons.logout,color:Colors.white,size: height*0.12,),
//                     label: Text(
//                       "Logout",
//                       style:
//                       AppTextStyles.caption(context, color: Colors.white,fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       }
//     );
//   }
//
//   @override
//   Size get preferredSize => Size.fromHeight(height);
// }


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
              Text(
                text,
                style: AppTextStyles.caption(
                  context,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}