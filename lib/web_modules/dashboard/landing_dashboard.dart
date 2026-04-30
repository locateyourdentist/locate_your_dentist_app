import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/dashboard/clinic_image_caurosel.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  String? selectedState;
  String? selectedDistrict;
  final loginController = Get.put(LoginController());
  final planController = Get.put(PlanController());
 // final notificationController = Get.put(NotificationController());
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  VideoPlayerController? _controller;
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _fadeController.forward();
    _refresh();
    _controller = VideoPlayerController.asset('assets/images/welcome1.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller!.setLooping(true);
          _controller!.setVolume(0);
          _controller!.play();
        }
      });
  }
  Future<void> _refresh() async {
    await getLocation();
    await loginController.getProfileDetails('Dental Clinic', '', '', '', "true", '', '', '', '', context);
    await loginController.fetchStates();
    await loginController.getAppLogoImage(context);
    await planController.getUploadImages(userType: "Dental Clinic", context: context);
  }
  Future<void> getLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      final address = await getAddressFromLatLng(position.latitude, position.longitude);
      planController.currentLocation = address;
    } else {
      Get.snackbar('Location', 'Unable to get location');
    }
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks.first;
      return '${place.subLocality}, ${place.locality} ${place.postalCode}';
    } catch (e) {
      return '';
    }
  }
  Widget clinicCard(ProfileModel clinic) {
    String firstImage = clinic.images.firstWhere((img) => img.toLowerCase().endsWith('.jpg') || img.toLowerCase().endsWith('.png'), orElse: () => "");
    String addOnsPlanStatus = clinic.details?["plan"]?["addonsPlan"]?["isActive"]?.toString() ?? "";
    return GestureDetector(
      onTap: ()async{
        Api.userInfo.write('selectUId',clinic.userId.toString());
        await  loginController.getProfileByUserId(clinic.userId.toString(), context);
        Get.toNamed('/clinicProfileWebPage');
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.95, end: 1.0),
          duration: const Duration(milliseconds: 400),
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: firstImage.isNotEmpty
                              ? Image.network(
                              //firstImage,
                              loginController.logoImage.isNotEmpty
                                  ? loginController.logoImage.first ?? ""
                                  : "",
                              width: double.infinity, fit: BoxFit.cover)
                              : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.image_outlined, color: Colors.grey, size: 50),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            clinic.details['name']?.toString() ?? "",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Mobile : ${clinic.mobileNumber.toString()}",
                            style: AppTextStyles.caption(context),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${clinic.address['city']?.toString() ?? ""}, ${clinic.address['state']?.toString() ?? ""},${clinic.address['district']?.toString() ?? ""}",
                            style: AppTextStyles.caption(context, color: AppColors.grey),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                            onPressed: () {},
                            child: Text(
                              "Call",
                              style: AppTextStyles.caption(context, color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (addOnsPlanStatus == "true")
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("SPONSORED", style: AppTextStyles.caption(context)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  bool getPlanActive() {
    final userData = loginController.userData;
    if (userData.isEmpty) return false;
    final raw = userData.first.details["plan"]?["basePlan"]?["isActive"]??"";
    return raw == true || raw == "true";
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffF0F4F8),
      body: GetBuilder<LoginController>(
          builder: (controller) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                       // constraints: const BoxConstraints(maxWidth: 1300),
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ClipRRect(
                            //   child: SizedBox(
                            //     width: double.infinity,
                            //     height: size * 0.32,
                            //     child: (_controller != null && _controller!.value.isInitialized)
                            //         ? FittedBox(
                            //       fit: BoxFit.cover,
                            //       child: SizedBox(
                            //         width: _controller!.value.size.width,
                            //         height: _controller!.value.size.height,
                            //         child: VideoPlayer(_controller!),
                            //       ),
                            //     )
                            //         : Image.asset(
                            //       'images/welcome.png',
                            //       fit: BoxFit.cover,
                            //       width: double.infinity,
                            //     ),
                            //   ),
                            // ),

                            AnimationLimiter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimationConfiguration.staggeredList(
                                    position: 0,
                                    duration: const Duration(milliseconds: 600),
                                    child: SlideAnimation(
                                      verticalOffset: -50.0,
                                      child: FadeInAnimation(
                                        child: CommonHeader(),
                                      ),
                                    ),
                                  ),

                                  // AnimationConfiguration.staggeredList(
                                  //   position: 1,
                                  //   duration: const Duration(milliseconds: 800),
                                  //   child: SlideAnimation(
                                  //     verticalOffset: 50.0,
                                  //     child: FadeInAnimation(
                                  //       child: TweenAnimationBuilder<double>(
                                  //         tween: Tween(begin: 1.2, end: 1.0),
                                  //         duration: const Duration(milliseconds: 800),
                                  //         curve: Curves.easeOut,
                                  //         builder: (context, scale, child) {
                                  //           return Transform.scale(
                                  //             scale: scale,
                                  //             child: child,
                                  //           );
                                  //         },
                                  //         child: HeroBanner(),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  HeroBanner(),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            Center(child: Text("Featured Clinics", style: AppTextStyles.headline1(context,color: AppColors.primary))),
                            const SizedBox(height: 20),
                            if (loginController.profileList.isEmpty)
                              Center(child: Text('No data found', style: AppTextStyles.caption(context))),
                            if (loginController.isLoading)
                              const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                            if (loginController.profileList.isNotEmpty)
                              GetBuilder<PlanController>(
                                builder: (controller) {
                                  final imageUrls = controller.editUploadImage1
                                      .map((clinic) => clinic.url ?? "")
                                      .where((url) => url.isNotEmpty)
                                      .toList();
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: ClinicImageCarousel(imageUrls: imageUrls),
                                  );
                                },
                              ),

                            const SizedBox(height: 40),

                            Center(
                              child: TweenAnimationBuilder(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                builder: (context, double scale, child) {
                                  return Transform.scale(scale: scale, child: child);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(25),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                                  child: Wrap(
                                    spacing: 20,
                                    runSpacing: 15,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: size*0.15,
                                        child: GetBuilder<LoginController>(
                                          builder: (controller) {
                                            return CustomDropdown<String>.search(
                                              hintText: "Select State",
                                              decoration: CustomDropdownDecoration(
                                                closedFillColor: Colors.grey[100],
                                                expandedFillColor: Colors.white,
                                                closedBorder: Border.all(color: AppColors.white, width: 1.5),
                                                expandedBorder: Border.all(color: AppColors.primary, width: 1.5),
                                                closedBorderRadius: BorderRadius.circular(10),
                                                expandedBorderRadius: BorderRadius.circular(10),
                                                hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                                                headerStyle: AppTextStyles.caption(context, color: Colors.black),
                                                listItemStyle: AppTextStyles.caption(context, color: Colors.black),
                                              ),
                                              items: controller.states.map((s) => s.toString()).toList(),
                                             // initialItem: controller.selectedState,
                                              onChanged: (val) {
                                                if (val != null) {
                                                  controller.selectedState = val;
                                                  controller.districts.clear();
                                                  controller.selectedDistrict = null;
                                                  controller.selectedTaluka = null;
                                                  controller.selectedVillage = null;
                                                  controller.fetchDistricts(val.toString());
                                                  controller.update();
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: size*0.15,
                                        child: GetBuilder<LoginController>(
                                          builder: (controller) {
                                            return CustomDropdown<String>.search(
                                              hintText: "Select District",
                                              items: controller.districts.map((d) => d.toString()).toList(),
                                              //initialItem: controller.selectedDistrict,
                                              decoration: CustomDropdownDecoration(
                                                hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                                                headerStyle: AppTextStyles.caption(context, color: Colors.black),
                                                listItemStyle: AppTextStyles.caption(context, color: Colors.black),
                                                closedFillColor: Colors.grey[100],
                                                expandedFillColor: Colors.white,
                                                closedBorder: Border.all(color: AppColors.white, width: 1.5),
                                                expandedBorder: Border.all(color: AppColors.primary, width: 1.5),
                                              ),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  controller.selectedDistrict = val;
                                                  controller.talukas.clear();
                                                  controller.selectedTaluka = null;
                                                  controller.selectedVillage = null;
                                                  controller.fetchTalukas(val.toString());
                                                  controller.update();
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18)),
                                        onPressed: () async {
                                          await loginController.getProfileDetails(
                                            "Dental Clinic",
                                            loginController.selectedState,
                                            loginController.selectedDistrict,
                                            loginController.selectedTaluka,
                                            "true",
                                            '',
                                            '',
                                            loginController.selectedDistance.toString(),
                                            '',
                                            context,
                                          );
                                        },
                                        icon: Icon(Icons.search, color: AppColors.white, size: size * 0.008),
                                        label: Text("Search", style: AppTextStyles.caption(context, color: AppColors.white)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Center(
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 1500),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Dental Clinics", style: AppTextStyles.subtitle(context, color: AppColors.black)),
                                            TextButton(
                                              onPressed: () async{
                                                Api.userInfo.write('sUserType1', 'Dental Clinic',);
                                                await loginController.getProfileDetails('Dental Clinic', '', '', '', 'true', '', '', '', '',
                                                  context,);
                                                Get.toNamed('/userTypeListWeb');
                                              },
                                              child: Text(
                                                "View All",
                                                style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold)
                                                    .copyWith(decoration: TextDecoration.underline),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        AnimationLimiter(
                                          child: GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: loginController.profileList.length > 10
                                                ? 10
                                                : loginController.profileList.length,
                                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: 280,
                                              mainAxisSpacing: 20,
                                              crossAxisSpacing: 20,
                                              childAspectRatio: 0.9,
                                            ),
                                            itemBuilder: (context, index) {
                                              return AnimationConfiguration.staggeredList(
                                                  position: index,
                                                  duration: const Duration(milliseconds: 700),
                                                  child: SlideAnimation(
                                                      horizontalOffset: 80.0,
                                                      curve: Curves.easeOutCubic,
                                                      child: FadeInAnimation(
                                                          child: EnlargeOnTapCard(child: clinicCard(loginController.profileList[index])))));
                                            },
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),
                           // heroSection(size),
                          //  featuresSection (),
                            AboutUsSection(),
                            SizedBox(height: size*0.01,),

                            userTypesSection(),
                           SizedBox(height: size*0.01,),
                           // howItWorks(),
                            jobsWebinarSection(),
                            const SizedBox(height: 60),


                            const SizedBox(height: 60),

                            // Footer
                          ],
                        ),
                      ),
                    ),
                    const CommonFooter(),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
  Widget heroSection(double width) {
    return Container(
      height: 500,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary,AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find Dental Services Around You",
                    style: TextStyle(
                      fontSize: width * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                   Text(
                    "Connect Patients, Clinics, Labs & Jobs in one platform",
                    style: AppTextStyles.caption(context,color: AppColors.white),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                    ),
                    child:  Text("Get Started",style: AppTextStyles.caption(context,color: AppColors.white),),
                  )
                ],
              ),
            ),
            Expanded(
              child: Image.network(
                "https://img.freepik.com/free-vector/dentist-concept-illustration_114360-2254.jpg",
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget featuresSection() {
    final features = [
      {"title": "Find Clinics", "icon": Icons.local_hospital},
      {"title": "Dental Labs", "icon": Icons.science},
      {"title": "Medical Shops", "icon": Icons.store},
      {"title": "Technicians", "icon": Icons.build},
      {"title": "Consultants", "icon": Icons.person},
      {"title": "Job Portal", "icon": Icons.work},
    ];

    return Padding(
      padding: const EdgeInsets.all(40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: features.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (_, i) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.grey.withOpacity(0.1),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(features[i]["icon"] as IconData,
                    size: 40, color: Colors.blue),
                const SizedBox(height: 10),
                Text(features[i]["title"].toString()),
              ],
            ),
          );
        },
      ),
    );
  }
  // Widget userTypesSection() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
  //     decoration: BoxDecoration(
  //       color: AppColors.white
  //       // gradient: LinearGradient(
  //       //   colors: [
  //       //     AppColors.primary,
  //       //     AppColors.secondary,
  //       //   ],
  //       //   begin: Alignment.topLeft,
  //       //   end: Alignment.bottomRight,
  //       // ),
  //     ),
  //     child: Center(
  //       child: Container(
  //         constraints: const BoxConstraints(maxWidth: 1500),
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           children: [
  //             Text(
  //               "Who Can Use This Platform?",
  //               style: AppTextStyles.subtitle(
  //                 context,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //             Text(
  //               "Connecting patients, clinics, dental shops, labs & professionals in one place",
  //               style: AppTextStyles.caption(
  //                 context,
  //                 color: Colors.black,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //             const SizedBox(height: 50),
  //
  //             Wrap(
  //               spacing: 150,
  //               runSpacing: 50,
  //               alignment: WrapAlignment.center,
  //               children: [
  //                 buildUserCard(
  //                   title: "Patients",
  //                   subtitle: "find your trusted & nearby dentists easily",
  //                   image: "assets/images/lp2.jpg",
  //                   icon: Icons.person,
  //                 ),
  //                 buildUserCard(
  //                   title: "Dental Clinics",
  //                   subtitle: "Manage clinic, hire staff & grow your practice",
  //                   image: "assets/images/aboutt.jpg",
  //                   icon: Icons.local_hospital,
  //                 ),
  //                 buildUserCard(
  //                   title: "Job Seekers",
  //                   subtitle: "Explore dental jobs & career opportunities",
  //                   image: "assets/images/doctor5.jpg",
  //                   icon: Icons.work,
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget userTypesSection() {
    final size = MediaQuery.of(context).size.width;
    final isMobile = size < 800;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      decoration: BoxDecoration(
        color: AppColors.white,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1500),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Who Can Use This Platform?",
                style: AppTextStyles.subtitle(
                  context,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Connecting patients, clinics, dental shops, labs & professionals in one place",
                style: AppTextStyles.caption(
                  context,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              isMobile
                  ? Column(
                children: [
                  buildUserCard(
                    title: "Patients",
                    subtitle: "find your trusted & nearby dentists easily",
                    image: "assets/images/lp2.jpg",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 30),
                  buildUserCard(
                    title: "Dental Clinics",
                    subtitle: "Manage clinic, hire staff & grow your practice",
                    image: "assets/images/aboutt.jpg",
                    icon: Icons.local_hospital,
                  ),
                  const SizedBox(height: 30),
                  buildUserCard(
                    title: "Job Seekers",
                    subtitle: "Explore dental jobs & career opportunities",
                    image: "assets/images/doctor5.jpg",
                    icon: Icons.work,
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildUserCard(
                      title: "Patients",
                      subtitle: "find your trusted & nearby dentists easily",
                      image: "assets/images/lp2.jpg",
                      icon: Icons.person,
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: buildUserCard(
                      title: "Dental Clinics",
                      subtitle: "Manage clinic, hire staff & grow your practice",
                      image: "assets/images/aboutt.jpg",
                      icon: Icons.local_hospital,
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: buildUserCard(
                      title: "Job Seekers",
                      subtitle: "Explore dental jobs & career opportunities",
                      image: "assets/images/doctor5.jpg",
                      icon: Icons.work,
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
  Widget buildUserCard({
    required String title,
    required String subtitle,
    required String image,
    required IconData icon,
  }) {
    double s=MediaQuery.of(context).size.width;
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius:  BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  height: s*0.1,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                  ),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                bottom: -18,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: s*0.015,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle(
                    context,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(
                    context,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Widget userTypesSection() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           AppColors.primary,
  //           AppColors.secondary,
  //         ],
  //       ),
  //     ),
  //     child: Center(
  //       child: Container(
  //         constraints: const BoxConstraints(maxWidth: 1500),
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           children: [
  //             Text(
  //               "Who Can Use This Platform?",
  //               style: AppTextStyles.subtitle(
  //                 context,color: AppColors.white
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //
  //             Text(
  //               "Connecting patients, clinics,Dental Shops,Dental Labs,Dental Consultant and professionals in one place",
  //               style: AppTextStyles.caption(
  //                 context,color:Colors.white
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //
  //             const SizedBox(height: 40),
  //
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 userCard("Patients", "Find nearby dentists instantly"),
  //                 userCard("Dental Clinics", "Connect with all & hire staff"),
  //                 userCard("Job Seekers", "Find dental jobs easily"),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget userCard(String title, String desc) {
    final size = MediaQuery.of(context).size.width;
    return Container(
      width: size*0.13,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),color: AppColors.white
        // gradient: LinearGradient(
        //   colors: [AppColors.primary,AppColors.secondary],
        // ),
      ),
      child: Column(
        children: [
           Icon(Icons.groups, size: size*0.02,color: AppColors.primary,),
          const SizedBox(height: 10),
          Text(title, style: AppTextStyles.caption(context,color:AppColors.black,fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center,style: AppTextStyles.caption(context,color:AppColors.black,fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }
  Widget howItWorks() {
    final steps = [
      "Search Nearby",
      "Connect Instantly",
      "Book / Hire",
      "Grow Your Network"
    ];

    return Column(
      children: [
        const Text("How It Works", style: TextStyle(fontSize: 24)),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: steps.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  CircleAvatar(radius: 25, child: Text("${steps.indexOf(e)+1}")),
                  const SizedBox(height: 10),
                  Text(e),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }
  Widget jobsWebinarSection() {
    final size = MediaQuery.of(context).size.width;
    final isMobile = size < 800;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1500),
          padding: const EdgeInsets.all(20),
          child: isMobile
              ? Column(
            children: [
              _leftContent(),
              const SizedBox(height: 40),
              _rightImage(size),
            ],
          )
              : Row(
            children: [
              Expanded(child: _leftContent()),
              const SizedBox(width: 40),
              Expanded(child: _rightImage(size)),
            ],
          ),
        ),
      ),
    );
  }
  Widget _leftContent() {
    double s=MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          //width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Career & Learning",
            style: AppTextStyles.caption(
              context,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// Title
        Text(
          "Jobs & Webinars",
          style: AppTextStyles.headline(
            context,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 15),

        Text(
          "Discover dental jobs, hire professionals, and join expert-led webinars to grow your career.",
          style: AppTextStyles.body(
            context,
            color: Colors.white.withOpacity(0.9),
          ),
        ),

        const SizedBox(height: 30),

        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Get.toNamed('/jobListJobSeekersWebPage');
              },
              icon:  Icon(Icons.work, color:AppColors.primary,size: s*0.012),
              label: Text(
                "Find Jobs",
                style: AppTextStyles.body(
                  context,
                  color: AppColors.primary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            OutlinedButton.icon(
              onPressed: () {
                Get.toNamed('/webinarListWebPage');
              },
              icon: const Icon(Icons.play_circle_outline, color: Colors.white),
              label: Text(
                "Explore Webinars",
                style: AppTextStyles.body(
                  context,
                  color: Colors.white,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _rightImage(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        /// Background Glow
        Container(
          height: size*0.15,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            "images/job.jpg",
            height: size*0.15,
            fit: BoxFit.cover,
          ),
        ),

        Positioned(
          bottom: -15,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.school,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
  //  _controller.dispose();
    super.dispose();
  }
}


class HeroBanner extends StatefulWidget {
  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner>
    with SingleTickerProviderStateMixin {

  final PageController _pageController = PageController();
  int currentPage = 0;

  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  final List<Map<String, String>> banners = [
    {
      "image": "images/welcome.png",
      "title": "Find Your Dental Clinic near you",
      "button": "Enquire Now",
      "route": "/userTypeListWeb",
    },
    {
      "image": "images/welcomePage.png",
      "title": "Find your ideal dental job",
      "button": "Get Started",
      "route": "/jobListJobSeekersWebPage",
    },
  ];

  @override
  void initState() {
    super.initState();

    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _zoomAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: _zoomController,
        curve: Curves.easeOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBanner();
    });
  }

  void _startBanner() {
    if (!mounted) return;

    _zoomController.forward();

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) autoSlide();
    });
  }

  void autoSlide() {
    if (!mounted) return;

    if (_pageController.hasClients) {
      currentPage = (currentPage + 1) % banners.length;

      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );

      _zoomController
        ..reset()
        ..forward();

      setState(() {});
    }

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) autoSlide();
    });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width;

    return SizedBox(
      height: size * 0.5,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });

              _zoomController
                ..reset()
                ..forward();
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _zoomAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _zoomAnimation.value,
                    child: child,
                  );
                },
                child: Image.asset(
                  banners[index]["image"]!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),

          /// 🔹 Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          /// 🔹 Animated Text Content
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Column(
                key: ValueKey(currentPage),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  AnimatedText(
                    banners[currentPage]["title"]!,
                    size,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      final route = banners[currentPage]["route"];
                      if (route != null) {
                        Get.toNamed(route);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      banners[currentPage]["button"]!,
                      style: AppTextStyles.body(
                        context,
                        color: AppColors.white,
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
class AnimatedText extends StatelessWidget {
  final String text;
  final double size;

  const AnimatedText(this.text, this.size);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(text.length, (index) {
        final char = text[index];

        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 400 + (index * 80)),
          tween: Tween<double>(begin: -50, end: 0),
          curve: Curves.easeOut,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, value),
              child: Opacity(
                opacity: (1 - (value.abs() / 50)).clamp(0, 1),
                child: Transform.rotate(
                  angle: value * 0.02, // slight tilt while falling
                  child: child,
                ),
              ),
            );
          },
          child: Text(
            char,
            style: GoogleFonts.poppins( // change font here
              color: AppColors.white,
              fontSize: size * 0.03,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }
}
class AboutUsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final isMobile = size < 800;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      color: Colors.white,

      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1500),

          child: isMobile
              ? Column(
            children: [
              _content(context),
              const SizedBox(height: 30),
              _image(context),
            ],
          )
              : Row(
            children: [
              Expanded(child: _content(context)),
              const SizedBox(width: 40),
              Expanded(child: _image(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),

      /// ❌ REMOVED extra Center + maxWidth from here
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ABOUT US",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.018,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            "Connecting the Dental Ecosystem in One Place",
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.014,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "We are building a unified digital platform...",
            style: TextStyle(
              height: 1.6,
              color: Colors.grey,
              fontSize: size * 0.009,
            ),
          ),
          const SizedBox(height: 20),

          _bullet("Connect Patients with verified clinics", context),
          _bullet("Link Clinics with Dental Labs & Shops", context),
          _bullet("Support Dental Consultants & Professionals", context),
          _bullet("Faster communication & workflow", context),
          _bullet("One unified dental network", context),
        ],
      ),
    );
  }

  Widget _image(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          "images/lp1.jpg",
          fit: BoxFit.cover,
          height: size * 0.18,
        ),
      ),
    );
  }

  Widget _bullet(String text, BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: size * 0.012),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption(context),
            ),
          ),
        ],
      ),
    );
  }
}