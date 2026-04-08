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
    await loginController.getProfileDetails(
        'Dental Clinic', '', '', '', "true", '', '', '', '', context);
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
    String firstImage = clinic.images.firstWhere(
            (img) => img.toLowerCase().endsWith('.jpg') || img.toLowerCase().endsWith('.png'),
        orElse: () => "");
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
                              ? Image.network(firstImage, width: double.infinity, fit: BoxFit.cover)
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
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffF0F4F8),
      appBar: const CommonHeader(),
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
                            // Container(
                            //   decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(20),
                            //     gradient: const LinearGradient(
                            //       colors: [AppColors.secondary, AppColors.primary],
                            //       begin: Alignment.topLeft,
                            //       end: Alignment.bottomRight,
                            //     ),
                            //   ),
                            //   padding: const EdgeInsets.all(40),
                            //   child: Row(
                            //     children: [
                            //       Expanded(
                            //         child: Column(
                            //           crossAxisAlignment: CrossAxisAlignment.start,
                            //           children: [
                            //             Text(
                            //               "Find & Connect With Dental Clinics",
                            //               style: AppTextStyles.body(context,
                            //                   color: AppColors.white, fontWeight: FontWeight.bold),
                            //             ),
                            //             const SizedBox(height: 20),
                            //             Text(
                            //               "Search nearby dental clinics, labs, mechanics, and jobs. Manage employee profiles, resumes, and job applications easily.",
                            //               style: AppTextStyles.caption(context, color: AppColors.white),
                            //             ),
                            //             const SizedBox(height: 30),
                            //             ElevatedButton.icon(
                            //               onPressed: () {},
                            //               icon: Icon(Icons.search, size: size * 0.01, color: AppColors.grey),
                            //               label: Text(
                            //                 "Search Now",
                            //                 style: AppTextStyles.caption(context, color: AppColors.grey),
                            //               ),
                            //               style: ElevatedButton.styleFrom(
                            //                 backgroundColor: Colors.white,
                            //                 foregroundColor: AppColors.primary,
                            //                 padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                            //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            //                 textStyle: AppTextStyles.caption(
                            //                     fontWeight: FontWeight.normal, context, color: AppColors.grey),
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //       const SizedBox(width: 40),
                            //       Expanded(
                            //         child: Image.asset(
                            //           "assets/images/lp1.jpg",
                            //           height: 300,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            // ClipRRect(child: Image.asset('images/welcome.png',fit: BoxFit.cover,width: double.infinity,height: size*0.32,)),
                            ClipRRect(
                              child: SizedBox(
                                width: double.infinity,
                                height: size * 0.32,
                                child: (_controller != null && _controller!.value.isInitialized)
                                    ? FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _controller!.value.size.width,
                                    height: _controller!.value.size.height,
                                    child: VideoPlayer(_controller!),
                                  ),
                                )
                                    : Image.asset(
                                  'images/welcome.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            Text("Featured Clinics", style: AppTextStyles.subtitle(context)),
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
                                        width: 220,
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
                                        width: 220,
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

                            const SizedBox(height: 60),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Center(
                                child: SizedBox(
                                  width: 1300,
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
                                          await loginController.getProfileDetails(
                                            'Dental Clinic', '', '', '', 'true', '', '', '', '',
                                            context,
                                          );
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

                            // Job Explore Section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text("Explore Jobs in Dental Industry", style: AppTextStyles.body(context, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Find nearby dental clinic jobs, lab, shop, and mechanic positions. Manage applications and resumes directly through LYD.",
                                    style: AppTextStyles.body(context),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.toNamed('/jobListJobSeekersWebPage');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                    child: Text("View Jobs", style: AppTextStyles.caption(context, color: AppColors.white)),
                                  ),
                                ],
                              ),
                            ),

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

  @override
  void dispose() {
    _fadeController.dispose();
  //  _controller.dispose();
    super.dispose();
  }
}