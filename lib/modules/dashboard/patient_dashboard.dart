import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
import 'package:locate_your_dentist/modules/dashboard/slider_images_dashboard.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common_widgets/common_bottom_navigation.dart';
import '../../common_widgets/common_drawer.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class _RevealIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  const _RevealIn({required this.child, this.delay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});
  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int currentIndex = 0;
  final loginController = Get.put(LoginController());
  String? selectedPlace;
  String? selectedDistrict;
  String? selectedArea;
  final TextEditingController searchController = TextEditingController();
  List<ProfileModel> filteredProfiles = [];
  final notificationController = Get.put(NotificationController());
  final GlobalKey<ScaffoldState> _scaffoldKeyUser1 = GlobalKey<ScaffoldState>();
  final planController = Get.put(PlanController());
  final ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  final List<Map<String, dynamic>> items = [
    {
      "title": "Root Canal",
      "icon": Icons.medical_services,
      "color": Colors.red,
      "url": "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
    },
    {
      "title": "Dental Implants",
      "icon": Icons.health_and_safety,
      "color": Colors.orange,
      "url": "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
    },
    {
      "title": "Aligners",
      "icon": Icons.straighten,
      "color": Colors.green,
      "url": "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
    },
    {
      "title": "Braces",
      "icon": Icons.grid_view,
      "color": Colors.purple,
      "url": "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
    },
    {
      "title": "Gum Care",
      "icon": Icons.spa,
      "color": Colors.teal,
      "url": "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
    },
    {
      "title": "Tooth Whitening",
      "icon": Icons.auto_awesome,
      "color": Colors.blue,
      "url": "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
    },
  ];
  Future<void> _launchUrl(url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> getLocation() async {
    final position = await LocationService.getCurrentLocation();

    if (position != null) {
      loginController.latitude = position.latitude;
      loginController.longitude = position.longitude;

      final address = await getAddressFromLatLng(
        loginController.latitude!,
        loginController.longitude!,
      );

      print('latitude ${loginController.latitude.toString()}');
      print('longitude ${loginController.longitude.toString()}');
      Api.userInfo.write('latitude', loginController.latitude.toString());
      Api.userInfo.write('longitude', loginController.longitude.toString());
      loginController.update();
      planController.currentLocation = address;
    } else {
      Get.snackbar('Location', 'Unable to get location');
    }
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    getLocation();
    await loginController.fetchStates();
    await loginController.getProfileDetails(
      'Dental Clinic',
      '',
      [],
      [],
      [],
      "true",
      '',
      '',
      '',
      '',
      context,
    );
    // await loginController.getProfileDetails('Dental Clinic', '', '', '',"true",loginController.latitude.toString(), loginController.longitude.toString(),'','', context);
    await planController.getUploadImages(
      userType: "Dental Clinic",
      context: context,
    );
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

  Widget _sectionHeading({
    required IconData icon,
    required String text,
    String? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.subtitle(context, color: AppColors.black),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing,
              style: AppTextStyles.caption(
                context,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKeyUser1,
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        //backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // leading: Padding(
        //   padding:  const EdgeInsets.all(8.0),
        //   child: CircleAvatar(
        //     radius: size * 0.13,
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.circular(50),
        //       child: ProfileImageWidget(size: size),
        //     ),
        //   ),
        // ),
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Locate Your Dentist',
              style: TextStyle(
                fontSize: size * 0.045,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 6),
            GetBuilder<PlanController>(
              builder: (controller) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.place_rounded,
                        color: AppColors.white,
                        size: size * 0.04,
                      ),
                      SizedBox(width: size * 0.01),
                      Flexible(
                        child: Text(
                          planController.currentLocation?.isNotEmpty == true
                              ? planController.currentLocation!
                              : "Detecting location...",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: size * 0.028,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: GetBuilder<LoginController>(
        init: loginController,
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.28),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Find Your Perfect Dentist",
                          style: AppTextStyles.headline(
                            context,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Search trusted clinics near you in seconds",
                          style: AppTextStyles.caption(
                            context,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.search_rounded,
                                      color: AppColors.primary,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: CommonSearchTextField(
                                        controller: searchController,
                                        borderColor: Colors.transparent,
                                        hintText:
                                            "Search by clinic name or area...",
                                        onSubmitted: (value) async {
                                          print("Search text: $value");
                                          await loginController
                                              .getProfileDetails(
                                                "Dental Clinic",
                                                '',
                                                [],
                                                [],
                                                [],
                                                "true",
                                                '',
                                                '',
                                                '',
                                                searchController.text
                                                    .toString(),
                                                context,
                                              );
                                          Get.toNamed('/filterResultPage');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.75,
                                        child: FilterDrawer(
                                          onApply: () async {
                                            print(
                                              "Selected State: ${loginController.selectedState}",
                                            );
                                            print(
                                              "Selected District: ${loginController.selectedDistrict}",
                                            );
                                            print(
                                              "Selected Area: ${loginController.selectedArea}",
                                            );
                                            print(
                                              "Selected distance: ${loginController.selectedDistance}",
                                            );
                                            print(
                                              'latit${Api.userInfo.read('latitude') ?? ""} long ${Api.userInfo.read('longitude') ?? ""}',
                                            );
                                            //String userType=  Api.userInfo.read('sUserType');
                                            //print("ssuser$userType");
                                            String distance =
                                                (loginController
                                                            .selectedDistance1 ??
                                                        0)
                                                    .toString();

                                            bool useLocation =
                                                distance.isNotEmpty &&
                                                distance != "0" &&
                                                distance != "0.0";
                                            if (useLocation) {
                                              await getLocation();
                                            } else {
                                              loginController.latitude = null;
                                              loginController.longitude = null;
                                            }

                                            String safeLat = useLocation
                                                ? (loginController.latitude
                                                          ?.toString() ??
                                                      "")
                                                : "";

                                            String safeLng = useLocation
                                                ? (loginController.longitude
                                                          ?.toString() ??
                                                      "")
                                                : "";
                                            filteredProfiles.map(
                                              (e) => searchController.text
                                                  .toString(),
                                            );
                                            await loginController
                                                .getProfileDetails(
                                                  "Dental Clinic",
                                                  loginController.selectedState,
                                                  loginController
                                                      .selectedDistricts,
                                                  loginController
                                                      .selectedTalukas,
                                                  loginController
                                                      .selectedVillages,
                                                  "true",
                                                  safeLat,
                                                  safeLng,
                                                  distance,
                                                  '',
                                                  context,
                                                );
                                            Get.toNamed('/filterResultPage');
                                          },
                                          onReset: () {
                                            setState(() {
                                              // loginController.selectedPlace = null;
                                              // loginController.selectedDistrict = null;
                                              loginController.selectedArea =
                                                  null;
                                              loginController.selectedUserType =
                                                  null;
                                              loginController.selectedState =
                                                  null;
                                              loginController.selectedDistrict =
                                                  null;
                                              loginController.selectedDistance =
                                                  null;
                                              loginController.selectedSalary =
                                                  null;
                                              loginController.selectedJobType =
                                                  null;
                                              loginController.selectedCategories
                                                  .clear();
                                              loginController
                                                  .resetUserTypeFilters();
                                              loginController.update();
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.tune_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                                splashRadius: 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RevealIn(
                          child: _sectionHeading(
                            icon: Icons.star_rounded,
                            text: "Top Dentist in your State",
                          ),
                        ),
                        SizedBox(height: size * 0.03),
                        _RevealIn(
                          delay: const Duration(milliseconds: 60),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: GetBuilder<PlanController>(
                                builder: (controller) {
                                  final imageUrls = controller.editUploadImage1
                                      .map((e) => e.url ?? "")
                                      .where((url) => url.isNotEmpty)
                                      .toList();
                                  return DashboardCarousel(
                                    imageList: imageUrls,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size * 0.05),
                        _RevealIn(
                          delay: const Duration(milliseconds: 120),
                          child: _buildProfessionalCard(),
                        ),
                        SizedBox(height: size * 0.05),

                        _RevealIn(
                          delay: const Duration(milliseconds: 180),
                          child: _sectionHeading(
                            icon: Icons.local_hospital_rounded,
                            text: "Popular Dental Clinics",
                            trailing: loginController.profileList.isNotEmpty
                                ? loginController.profileList.length.toString()
                                : null,
                          ),
                        ),
                        SizedBox(height: size * 0.03),

                        if (loginController.profileList.isEmpty)
                          //  Center(child: Text('No data found',style: AppTextStyles.caption(context),),),
                          buildShimmerEmptyWidget(size),

                        if (loginController.isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        if (loginController.profileList.isNotEmpty)
                          AnimationLimiter(
                            child: ListView.builder(
                              itemCount: loginController.profileList.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                final doctor =
                                    loginController.profileList[index];
                                bool getPlanActive() {
                                  final userData = loginController.profileList;
                                  if (userData.isEmpty) return false;
                                  final raw =
                                      userData
                                          .first
                                          .details["plan"]?["basePlan"]?["isActive"] ??
                                      "";
                                  return raw == true || raw == "true";
                                }

                                String userType =
                                    Api.userInfo.read('userType') ?? "";

                                final planActive = getPlanActive();
                                final bool isAdminUser =
                                    userType == 'admin' ||
                                    userType == 'superAdmin';

                                String firstImage = doctor.images.firstWhere(
                                  (img) =>
                                      img.toLowerCase().endsWith('.jpg') ||
                                      img.toLowerCase().endsWith('.png'),
                                  orElse: () => "",
                                );
                                String addOnsPlanStatus =
                                    doctor
                                        .details?["plan"]?["addonsPlan"]?["isActive"]
                                        ?.toString() ??
                                    "";
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 1300),
                                  child: SlideAnimation(
                                    verticalOffset: 120.0,
                                    curve: Curves.easeOutBack,
                                    child: FadeInAnimation(
                                      child: DoctorCardWidget(
                                        doctor: doctor,
                                        size: size,
                                        planActive: planActive,
                                        isAdminUser: isAdminUser,
                                        addOnsPlanStatus: addOnsPlanStatus,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        // :Center(child: Text('No Data Found',style: AppTextStyles.caption(context,color: AppColors.black),))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: SpeedDial(
        openCloseDial: isDialOpen,
        closeManually: false,
        closeDialOnPop: true,
        renderOverlay: true,
        overlayOpacity: 0.2,
        overlayColor: Colors.black,
        backgroundColor: AppColors.primary,
        elevation: 12,
        buttonSize: const Size(60, 60),
        childrenButtonSize: const Size(55, 55),
        spacing: 12,
        spaceBetweenChildren: 12,
        animationCurve: Curves.easeOutBack,
        animationDuration: const Duration(milliseconds: 350),
        children: items.map((item) {
          return SpeedDialChild(
            child: Icon(item["icon"], color: Colors.white),
            backgroundColor: item["color"],
            labelWidget: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Text(
                  item["title"],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            onTap: () async {
              await _launchUrl(item["url"]);
            },
          );
        }).toList(),

        child: AnimatedScale(
          scale: 1,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: AnimatedRotation(
            turns: 0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(.35),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildProfessionalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Professional icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              // Text
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DENTAL PROFESSIONAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Login or register to continue as a\nDental Professional',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed('/loginPage');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white, width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed('/loginTypesPage');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DentalMenu extends StatelessWidget {
  DentalMenu({super.key});

  final List<Map<String, dynamic>> items = [
    {
      "title": "Root Canal",
      "icon": Icons.medical_services,
      "color": Colors.red,
      "url": "https://yourwebsite.com/root-canal",
    },
    {
      "title": "Dental Implants",
      "icon": Icons.health_and_safety,
      "color": Colors.orange,
      "url": "https://yourwebsite.com/dental-implants",
    },
    {
      "title": "Aligners",
      "icon": Icons.straighten,
      "color": Colors.green,
      "url": "https://yourwebsite.com/aligners",
    },
    {
      "title": "Braces",
      "icon": Icons.grid_view,
      "color": Colors.purple,
      "url": "https://yourwebsite.com/braces",
    },
    {
      "title": "Gum Care",
      "icon": Icons.spa,
      "color": Colors.teal,
      "url": "https://yourwebsite.com/gum-care",
    },
    {
      "title": "Tooth Whitening",
      "icon": Icons.auto_awesome,
      "color": Colors.blue,
      "url": "https://yourwebsite.com/tooth-whitening",
    },
  ];
  Future<void> _launchUrl(url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: 280,
        height: 360,
        child: Stack(
          children: List.generate(items.length, (i) {
            final angle = -70 + (i * 28);

            final radius = 130.0;

            final dx = radius * cos(angle * pi / 180);
            final dy = radius * sin(angle * pi / 180);

            return Positioned(
              left: dx,
              bottom: 140 - dy,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () async {
                  Navigator.pop(context);

                  await _launchUrl(items[i]["url"].toString() ?? "");
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: items[i]["color"],
                        child: Icon(
                          items[i]["icon"],
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: items[i]["color"].withOpacity(.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          items[i]["title"],
                          style: TextStyle(
                            color: items[i]["color"],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
