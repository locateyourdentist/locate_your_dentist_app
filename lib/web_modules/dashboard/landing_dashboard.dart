import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/dashboard/clinic_image_caurosel.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/web_modules/dashboard/dental_problems.dart';
import 'package:locate_your_dentist/web_modules/dashboard/jobseekers_joblist_home.dart';
import 'package:locate_your_dentist/web_modules/dashboard/view_clinic_patients.dart';
import 'package:locate_your_dentist/web_modules/dashboard/webinar_dashboard_web.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common_widgets/common_widget_all.dart';
import '../../common_widgets/custom_toast.dart';
import '../../common_widgets/platform_helper.dart';


class _HoverLift extends StatefulWidget {
  final Widget child;
  final double liftScale;
  final BorderRadius? borderRadius;
  const _HoverLift({
    required this.child,
    this.liftScale = 1.03,
    this.borderRadius,
  });

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _hovering ? -6.0 : 0.0)
          ..scale(_hovering ? widget.liftScale : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_hovering ? 0.22 : 0.0),
              blurRadius: _hovering ? 28 : 0,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.45), color.withOpacity(0.0)],
          ),
        ),
      ),
    );
  }
}
class _RevealIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final double offsetY;
  const _RevealIn({
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 24,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 700 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * offsetY),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
class _SectionBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SectionBadge({required this.text, this.icon = Icons.auto_awesome});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.secondary.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: AppTextStyles.caption(
              context,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ).copyWith(letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }
}

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
  final jobController = Get.put(JobController());
  // final notificationController = Get.put(NotificationController());
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final TextEditingController searchController = TextEditingController();
  final dentalProblems = [
    {
      "title": "Tooth Decay",
      "icon": Icons.coronavirus_outlined,
      "color": Colors.red,
      "desc":
      "Caused by plaque and bacteria that damage tooth enamel.",
      "points": [
        "Persistent tooth pain",
        "Visible holes in teeth",
        "Sensitivity to sweets",
        "Bad breath"
      ]
    },
    {
      "title": "Gum Disease",
      "icon": Icons.health_and_safety,
      "color": Colors.pink,
      "desc":
      "Infection of the gums caused by poor oral hygiene.",
      "points": [
        "Bleeding gums",
        "Swollen gums",
        "Bad breath",
        "Loose teeth"
      ]
    },
    {
      "title": "Tooth Sensitivity",
      "icon": Icons.bolt,
      "color": Colors.orange,
      "desc":
      "Pain or discomfort when consuming hot or cold foods.",
      "points": [
        "Cold sensitivity",
        "Hot sensitivity",
        "Sharp tooth pain",
        "Enamel wear"
      ]
    },
    {
      "title": "Bad Breath",
      "icon": Icons.masks,
      "color": Colors.green,
      "desc":
      "Persistent unpleasant odor from the mouth.",
      "points": [
        "Dry mouth",
        "Gum infection",
        "Poor brushing habits",
        "Food debris"
      ]
    },
    {
      "title": "Tooth Erosion",
      "icon": Icons.shield_outlined,
      "color": Colors.deepPurple,
      "desc":
      "Loss of tooth enamel due to acidic foods and drinks.",
      "points": [
        "Yellow teeth",
        "Sensitivity",
        "Rounded edges",
        "Weak enamel"
      ]
    },
    {
      "title": "Wisdom Tooth Issues",
      "icon": Icons.medical_services,
      "color": Colors.blue,
      "desc":
      "Impacted or partially erupted wisdom teeth.",
      "points": [
        "Jaw pain",
        "Swelling",
        "Difficulty chewing",
        "Infection risk"
      ]
    },
  ];
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _fadeController.forward();
    _refresh();
  }
  Future<void> _refresh() async {
    if (!kIsWeb) {
      await getLocation();
    }
    await loginController.getProfileDetails('Dental Clinic', '', [], [],[], "true", '', '', '', '', context);
    await loginController.fetchStates();
    await loginController.getAppLogoImage(context);
    await planController.getUploadImages(userType: "Dental Clinic", context: context);
    await jobController.getWebinarListJobSeekers('','',context);
    await jobController.getJobListJobSeekers(
      search: searchController.text.trim(),
      state: null,
      district: null,
      city: null,
      salary: null,
      jobType: null,
      jobCategory: [],
      context: context,
    );
  }
  Future<void> getLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        Get.snackbar('Location', 'Location services are disabled',);
        return;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Location', 'Location permission denied',);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Location', 'Location permission permanently denied',);
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("Latitude: ${position.latitude}");
      print("Longitude: ${position.longitude}");
      String address = await getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );
      planController.currentLocation = address;
      print("Address: $address");
    } catch (e) {
      print("Location Error: $e");
      Get.snackbar('Error', 'Unable to get location');
    }
  }
  Future<String> getAddressFromLatLng(
      double lat,
      double lng,
      ) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.subLocality ?? ''}, ""${place.locality ?? ''}, ""${place.postalCode ?? ''}";
      }
      return '';

    } catch (e) {
      print("Address Error: $e");
      return '';
    }
  }
  Widget clinicCard(ProfileModel clinic) {
    bool isBasePlanActive(ProfileModel profile) {
      final isActive =
      profile.details?["plan"]?["basePlan"]?["isActive"];
      return isActive == true || isActive == "true";
    }
    final planActive = isBasePlanActive(clinic);
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
    String addOnsPlanStatus = clinic.details?["plan"]?["addonsPlan"]?["isActive"]?.toString() ?? "";
    String firstImage = clinic.logoImages.firstWhere(
          (img) => img.toLowerCase().endsWith('.jpg') ||
          img.toLowerCase().endsWith('.png') ||
          img.toLowerCase().endsWith('.jpeg'),
      orElse: () => "",
    );
    if (firstImage.isEmpty) {
      firstImage = clinic.images.firstWhere(
            (img) => img.toLowerCase().endsWith('.jpg') ||
            img.toLowerCase().endsWith('.png') ||
            img.toLowerCase().endsWith('.jpeg'),
        orElse: () => "",
      );
    }
    return GetBuilder<LoginController>(
        builder: (controller) {
          final double size = MediaQuery.of(context).size.width;
          return GestureDetector(
            onTap: ()async{
              Api.userInfo.write('selectUId',clinic.userId.toString());
              await  loginController.getProfileByUserId(clinic.userId.toString(), context);
              Get.toNamed('/clinicProfileWebPage');
            },
            child: _HoverLift(
              liftScale: 1.02,
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                                borderRadius:  BorderRadius.vertical(top: Radius.circular(20)),
                                child: (firstImage.isNotEmpty &&
                                    (isAdminUser ||
                                        (clinic.details["plan"]?["basePlan"]?["details"]?["images"] == true)))
                                    ? Image.network(
                                    firstImage,
                                    height:size < 700 ? (130) : 300.0,
                                    width: double.infinity, fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: double.infinity,
                                      height: size < 700 ? (130) : 300.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F3F6),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 50),
                                    ))
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
                                  style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.primary),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Dr.${clinic.name?.toString() ?? ""}",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.caption(context,fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 5),

                                if ((planActive == true &&
                                    clinic.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ||
                                    isAdminUser)
                                  Text(
                                    "Mobile : ${clinic.mobileNumber.toString()}",
                                    style: AppTextStyles.caption(context,),
                                  ),
                                const SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon:Icon( Icons.location_on,
                                        color: Colors.grey,
                                        size: 18,),
                                      onPressed: (){
                                        if(clinic.location.toString().isNotEmpty&&(planActive==true
                                            &&clinic.details["plan"]?["basePlan"]?["details"]?["location"]==true|| isAdminUser)) {
                                          if (PlatformHelper.platform == 'Android' ||
                                              PlatformHelper.platform == 'iOS') {
                                            Get.toNamed(
                                                '/webViewProfilePage', arguments: {
                                              "url": clinic
                                                  .location
                                                  .toString(),
                                              "clinicName": clinic
                                                  .details["name"].toString()
                                            });
                                          }
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        "${clinic.address['addressLine1'] ?? ''}, ${clinic.address['addressLine2'] ?? ''}, ${clinic.address['area'] ?? ''}, "
                                            "${clinic.address['city'] ?? ''}, "
                                            "${clinic.address['district'] ?? ''}, "
                                            "${clinic.address['state'] ?? ''}",
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,style: AppTextStyles.caption(context,color: AppColors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if ((planActive == true &&
                                    clinic.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ||
                                    isAdminUser)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    ),
                                    onPressed: () async{
                                      await   launchCallWeb("tel:${clinic.mobileNumber}");

                                    },
                                    icon: const Icon(Icons.call, size: 15, color: Colors.white),
                                    label: Text(
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
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.orangeAccent, Colors.deepOrange],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 11, color: Colors.white),
                              const SizedBox(width: 4),
                              Text("SPONSORED",
                                  style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ),
          );
        }
    );
  }
  bool getPlanActive() {
    final userData = loginController.userData;
    if (userData.isEmpty) return false;
    final raw = userData.first.details["plan"]?["basePlan"]?["isActive"]??"";
    return raw == true || raw == "true";
  }
  Widget buildFilterBox({
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    bool isMobile = size < 800;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CommonHeader(),
      body: GetBuilder<LoginController>(
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: isMobile ? 200 : 70,
                            ),
                            child: AspectRatio(
                              //aspectRatio: 16 / 7,
                              aspectRatio: isMobile  ? 16 / 10 : 16 / 9,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [

                                  Positioned.fill(
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 1.08, end: 1.0),
                                      duration: const Duration(milliseconds: 1200),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, scale, child) => Transform.scale(
                                        scale: scale,
                                        child: child,
                                      ),
                                      child: Image.asset(
                                        'assets/images/img_banner.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            AppColors.primary.withOpacity(.35),
                                            Colors.black.withOpacity(.15),
                                            Colors.black.withOpacity(.45),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if(!isMobile)
                                    Positioned(
                                      right: 80,
                                      top: 0,
                                      bottom: 120,
                                      child: Center(
                                        child: _buildTransparentLoginCard(context),
                                      ),
                                    ),
                                  Positioned(
                                    left: 20,
                                    right: 20,
                                    bottom: isMobile ? -230 :size>600? -30:-90,
                                    child: Center(
                                      child: _RevealIn(
                                        offsetY: 36,
                                        child: Container(
                                        // width:1500,
                                        width: isMobile
                                            ? MediaQuery.of(context).size.width * 0.62
                                            : 1500,
                                        margin: const EdgeInsets.symmetric(horizontal: 20),
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.97),
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(color: Colors.white.withOpacity(0.6)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(.18),
                                              blurRadius: 35,
                                              offset: const Offset(0, 16),
                                            ),
                                          ],
                                        ),
                                        child: Wrap(
                                          spacing: 15,
                                          runSpacing: 15,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: size > 1100
                                                  ? 250
                                                  : size > 800
                                                  ? 200
                                                  : 200,
                                              child:  GetBuilder<LoginController>(
                                                  builder: (controller) {
                                                    return buildFilterBox(
                                                    icon: Icons.map,
                                                    child: CustomDropdown<String>.search(
                                                      hintText: "State",
                                                      items: controller.states.map((e) => e.toString()).toList(),
                                                      onChanged: (val)async {
                                                        if (val != null) {
                                                          controller.selectedState = val;
                                                          await controller.fetchDistricts(val);
                                                          controller.update();
                                                        }
                                                      },
                                                    ),
                                                  );
                                                }
                                              ),
                                            ),
                                            SizedBox(
                                              width: size > 1100
                                                  ? 250
                                                  : size > 800
                                                  ? 200
                                                  : 200,
                                              child:  GetBuilder<LoginController>(
                                                  builder: (controller) {
                                                    return buildFilterBox(
                                                    icon: Icons.location_city,
                                                    child:MultiSelectDialogField<String>(
                                                      checkColor: AppColors.primary,
                                                      buttonIcon: const Icon(
                                                        Icons.arrow_drop_down,
                                                        color: AppColors.white,
                                                        size: 2,),
                                                      items: loginController.districts
                                                          .toSet()
                                                          .map(
                                                            (e) => MultiSelectItem<String>(
                                                          e.toString(),
                                                          e.toString(),
                                                        ),
                                                      ).toList(),
                                                      title: Center(
                                                        child: Text(
                                                          "Select districts",
                                                          style: AppTextStyles.body(context),
                                                        ),),
                                                      buttonText: Text(
                                                        loginController.selectedDistricts.isEmpty
                                                            ? "District"
                                                            : loginController.selectedDistricts.length == 1
                                                            ? loginController.selectedDistricts.first
                                                            : "${loginController.selectedDistricts.first} +${loginController.selectedDistricts.length - 1}",
                                                        style: AppTextStyles.caption(context,color: AppColors.grey),
                                                      ),
                                                      decoration: const BoxDecoration(),
                                                      searchable: true,
                                                      dialogHeight: 400,
                                                      dialogWidth:120,
                                                      initialValue: loginController.selectedDistricts,
                                                      onConfirm: (values)async {
                                                        loginController.selectedDistricts = values.map((e) => e.toString()).toList();
                                                        await  loginController.fetchTalukas(loginController.selectedDistricts);
                                                        loginController.update();
                                                      },
                                                      chipDisplay: MultiSelectChipDisplay.none(),
                                                    ),
                                                  );
                                                }
                                              ),
                                            ),
                                            SizedBox(
                                              width: size > 1100
                                                  ? 250
                                                  : size > 800
                                                  ? 200
                                                  : 200,
                                              child:  GetBuilder<LoginController>(
                                                  builder: (controller) {
                                                    return buildFilterBox(
                                                    icon: Icons.account_balance,
                                                    child:MultiSelectDialogField<String>(
                                                      checkColor: AppColors.primary,
                                                      buttonIcon: const Icon(
                                                        Icons.arrow_drop_down,
                                                        color: AppColors.white,
                                                        size: 2,),
                                                      items: loginController.talukas
                                                          .toSet()
                                                          .map(
                                                            (e) => MultiSelectItem<String>(
                                                          e.toString(),
                                                          e.toString(),
                                                        ),
                                                      ).toList(),
                                                      title: Center(
                                                        child: Text(
                                                          "Select Taluka",
                                                          style: AppTextStyles.body(context),
                                                        ),),
                                                      buttonText: Text(
                                                        loginController.selectedTalukas.isEmpty
                                                            ? "Taluka"
                                                            : loginController.selectedTalukas.length == 1
                                                            ? loginController.selectedTalukas.first
                                                            : "${loginController.selectedTalukas.first} +${loginController.selectedTalukas.length - 1}",
                                                        style: AppTextStyles.caption(context,color: AppColors.grey),
                                                      ),
                                                      decoration: const BoxDecoration(),
                                                      searchable: true,
                                                      dialogHeight: 400,
                                                      dialogWidth:120,
                                                      initialValue: loginController.selectedTalukas,
                                                      onConfirm: (values) async{
                                                        loginController.selectedTalukas = values.map((e) => e.toString()).toList();
                                                        await loginController.fetchVillages(loginController.selectedTalukas);
                                                        loginController.update();
                                                      },
                                                      chipDisplay: MultiSelectChipDisplay.none(),
                                                    ),
                                                  );
                                                }
                                              ),
                                            ),
                                            SizedBox(
                                              width: size > 1100
                                                  ? 250
                                                  : size > 800
                                                  ? 200
                                                  : 200,
                                              child:  GetBuilder<LoginController>(
                                                  builder: (controller) {
                                                    return buildFilterBox(
                                                    icon: Icons.place,
                                                    child:  MultiSelectDialogField<String>(
                                                      checkColor: AppColors.primary,
                                                      buttonIcon: const Icon(
                                                        Icons.arrow_drop_down,
                                                        color: AppColors.white,
                                                        size: 2,
                                                      ),
                                                      items: loginController.villages
                                                          .toSet()
                                                          .map(
                                                            (e) => MultiSelectItem<String>(
                                                          e.toString(),
                                                          e.toString(),
                                                        ),
                                                      ).toList(),
                                                      title: Center(
                                                        child: Text(
                                                          "Select Areas",
                                                          style: AppTextStyles.body(context),
                                                        ),
                                                      ),

                                                      buttonText: Text(
                                                        loginController.selectedVillages.isEmpty
                                                            ? "Areas"
                                                            : loginController.selectedVillages.length == 1
                                                            ? loginController.selectedVillages.first
                                                            : "${loginController.selectedVillages.first} +${loginController.selectedVillages.length - 1}",
                                                        style: AppTextStyles.caption(context,color: AppColors.grey),
                                                      ),
                                                      decoration: const BoxDecoration(),

                                                      searchable: true,
                                                      dialogHeight: 400,
                                                      dialogWidth:120,
                                                      initialValue: loginController.selectedVillages,

                                                      onConfirm: (values) {
                                                        loginController.selectedVillages = values.map((e) => e.toString()).toList();
                                                        loginController.update();
                                                      },
                                                      chipDisplay: MultiSelectChipDisplay.none(),
                                                    ),
                                                  );
                                                }
                                              ),
                                            ),
                                            _HoverLift(
                                              liftScale: 1.03,
                                              borderRadius: BorderRadius.circular(14),
                                              child: Center(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(14),
                                                    gradient: LinearGradient(
                                                      colors: [AppColors.primary, AppColors.secondary],
                                                    ),
                                                  ),
                                                  child: ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.transparent,
                                                      shadowColor: Colors.transparent,
                                                      elevation: 0,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 35,
                                                        vertical: 18,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                      ),
                                                    ),
                                                    icon: const Icon(
                                                      Icons.search_rounded,
                                                      color: Colors.white,
                                                      size: 22,
                                                    ),
                                                    label: Text(
                                                      "Search Dentist",
                                                      style: AppTextStyles.caption(
                                                        context,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      Api.userInfo.write('sUserType','Dental Clinic');
                                                      await loginController.getProfileDetails(
                                                        "Dental Clinic",
                                                        loginController.selectedState,
                                                        loginController.selectedDistricts,
                                                        loginController.selectedTalukas,loginController.selectedVillages,
                                                        "true",
                                                        '',
                                                        '',
                                                        '',
                                                        '',
                                                        context,
                                                      );
                                                      Get.toNamed('/viewPatientsListWeb');
                                                    },
                                                  ),
                                                ),
                                              ),
                                            )


                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 80,
                            ),
                            color: const Color(0xffF6FBFB),
                            child: Column(
                              children: [
                                const Center(child: _SectionBadge(text: "Featured", icon: Icons.local_hospital)),
                                const SizedBox(height: 12),
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
                                          .where((img) => img.isActive == true)
                                          .map((img) => img.url ?? "")
                                          .where((url) => url.isNotEmpty)
                                          .toList();
                                      return Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: GetBuilder<LoginController>(
                                            builder: (controller) {
                                              return ClinicImageCarousel(imageUrls: imageUrls);
                                          }
                                        ),
                                      );
                                    },
                                  ),

                                const SizedBox(height: 30),

                                //CompleteCareSection(),
                                const SizedBox(height: 30),
                                isMobile
                                    ? _buildMobile(context)
                                :CompleteCareSection(),
                                    //: _buildDesktop(context, !isMobile),
                                const SizedBox(height: 30),

                                const Center(child: _SectionBadge(text: "Treatments", icon: Icons.medical_services_outlined)),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    "Popular Dental Treatments",
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,color: AppColors.primary
                                    ),
                                  ),
                                ),
                                Container(
                                  // width: double.infinity,
                                  constraints: const BoxConstraints(maxWidth: 1500),
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                  color: const Color(0xffF8FAFC),
                                  child: Center(
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeInOutCubic,
                                      constraints: const BoxConstraints(maxWidth: 1500),
                                      child: Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        alignment: WrapAlignment.center,
                                        children: const [

                                          DentalServiceCard(
                                            title: "Root Canal",
                                            description:
                                            "Save damaged teeth with painless root canal treatment using advanced dental technology.",
                                            image: "assets/images/root_canal1.png",
                                            url: "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
                                          ),

                                          DentalServiceCard(
                                            title: "Dental Implants",
                                            description:"Permanent replacement for missing teeth with natural appearance and function.",
                                            image: "assets/images/dentalimplant1.png",
                                            url: "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
                                          ),

                                          DentalServiceCard(
                                            title: "Aligners",
                                            description:
                                            "Nearly invisible teeth straightening with removable clear aligners.",
                                            image: "assets/images/aligners1.png",
                                            url: "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
                                          ),

                                          DentalServiceCard(
                                            title: "Braces",
                                            description:
                                            "Straighten misaligned teeth and improve bite correction.",
                                            image: "assets/images/braces1.png",
                                            url: "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
                                          ),

                                          DentalServiceCard(
                                            title: "Gum Care",
                                            description:
                                            "Prevent and treat gum disease for healthier teeth and gums.",
                                            image: "assets/images/gumcare1.png",
                                            url: "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
                                          ),

                                          DentalServiceCard(
                                            title: "Tooth Whitening",
                                            description:
                                            "Professional whitening for a brighter, stain-free smile.",
                                            image: "assets/images/toothwhitening1.png",
                                            url: "https://youtu.be/0s35QCFg7p0?si=TxqOPWBNRP-5wNtX",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                WhyChooseUsSection(),

                                const SizedBox(height: 30),
                                AboutUsSection(),
                                SizedBox(height: size*0.01,),
                                platformOverviewSection(context),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 1500),
                                child:  GetBuilder<LoginController>(
                                    builder: (controller) {
                                      return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Dental Clinics", style: AppTextStyles.subtitle(context, color: AppColors.black)),
                                                TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: AppColors.primary,
                                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(30),
                                                      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                                                    ),
                                                  ),
                                                  onPressed: () async{
                                                    Api.userInfo.write('sUserType1', 'Dental Clinic',);
                                                    await loginController.getProfileDetails('Dental Clinic', '', [], [],[], 'true', '', '', '', '', context);
                                                    // Get.toNamed('/userTypeListWeb');
                                                    Get.toNamed('/viewPatientsListWeb');
                                                    },
                                                  icon: Text(
                                                    "View All",
                                                    style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold),
                                                  ),
                                                  label: Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.primary),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            if (loginController.isLoading)
                                              _buildClinicShimmerGrid(context)
                                            else if (loginController.profileList.isEmpty)
                                              _buildEmptyStateWithShimmer(context)
                                            else if (loginController.profileList.isNotEmpty)
                                                GetBuilder<LoginController>(
                                                    builder: (controller) {
                                                      return AnimationLimiter(
                                                        child: GridView.builder(
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          itemCount: loginController.profileList.length > 10
                                                              ? 10 : loginController.profileList.length,
                                                          gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
                                                            maxCrossAxisExtent: 280,
                                                            mainAxisSpacing: 20,
                                                            crossAxisSpacing: 20,
                                                            childAspectRatio: size < 700 ? 0.8 : 0.8,
                                                            //childAspectRatio: 0.9,
                                                          ),
                                                          itemBuilder: (context, index) {
                                                            return AnimationConfiguration.staggeredList(
                                                                position: index,
                                                                duration: const Duration(milliseconds: 700),
                                                                child: SlideAnimation(
                                                                    horizontalOffset: 80.0,
                                                                    curve: Curves.easeOutCubic,
                                                                    child: FadeInAnimation(
                                                                    child: EnlargeOnTapCard(child:AnimatedContainer(
                                                                        duration: const Duration(milliseconds: 250),
                                                                        curve: Curves.easeInOutCubic,
                                                                        child: clinicCard(loginController.profileList[index]))))));
                                                          },
                                                        ),
                                                      );
                                                    }
                                                ),
                                          ]);
                                    }
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),

                          jobsWebinarSection(),
                          const SizedBox(height: 40),
                          const Center(child: _SectionBadge(text: "Careers", icon: Icons.work_outline)),
                          const SizedBox(height: 12),
                          Center(child: Text("Latest Career Openings", style: AppTextStyles.subtitle(context, color: AppColors.primary,
                          ))),
                          //const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: GetBuilder<JobController>(
                              builder: (jController) {
                                return JobSeekersDashboardGrid(
                                  jobList: jController.jobListJobSeekers,
                                  isLoading: jController.isLoading,
                                );
                              },
                            ),
                          ),
                          Column(
                            children: [

                              const SizedBox(height: 20),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Text(
                                  "Upcoming Webinars",
                                  style: AppTextStyles.subtitle(
                                    context,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),

                              //const SizedBox(height: 20),

                              GetBuilder<JobController>(
                                  builder: (jController) {
                                    return  SizedBox(
                                      height:jobController.webinarListJobSeekers.length>3? 850:300,
                                      child: WebinarDashboardGrid(
                                        webinarList:
                                        jobController.webinarListJobSeekers.take(6).toList(),
                                        controller: jobController,
                                      ),
                                    );
                                  }
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          userTypesSection(),
                          const SizedBox(height: 60),
                        ],
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.blue,
                    ),
                    child:  Text("Get Started",style: AppTextStyles.caption(context,color: Colors.white),),
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
              const _SectionBadge(text: "Community", icon: Icons.groups_outlined),
              const SizedBox(height: 14),
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
    return _HoverLift(
      liftScale: 1.015,
      borderRadius: BorderRadius.circular(24),
      child: Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
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
                  top: Radius.circular(24),
                ),
                child: Container(
                  width: double.infinity,
                  height: s*0.13,
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
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 10,
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
      ),
    );
  }
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
        Text("How It Works", style: AppTextStyles.subtitle(context)),
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
                  Text(e, style: AppTextStyles.caption(context)),
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

    return ClipRRect(
      child: Container(
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(top: -60, right: -40, child: _GlowBlob(size: 220, color: Colors.white)),
          const Positioned(bottom: -80, left: -60, child: _GlowBlob(size: 260, color: Colors.white)),
          Center(
            child: _RevealIn(
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
          ),
        ],
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
            "assets/images/job.jpg",
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

  Widget _buildClinicShimmerGrid(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateWithShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 15),
            Text('No clinics found matching your location',
                style: AppTextStyles.subtitle(context, color: Colors.grey)),
          ],
        ),
      ),
    );
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
      "image": "assets/images/front_image.png",
      "title": "Find Your Dental Clinic near you",
      "button": "Enquire Now",
      "route": "/userTypeListWeb",
    },
    {
      "image": "assets/images/welcomePage.png",
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
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 700;
    final bool isDesktop = width >= 1000;
    return SizedBox(
      //  height: isMobile ? 300 : width * 0.4,
      height: isMobile
          ? 450
          : MediaQuery.of(context).size.height * 0.75,
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
                  cacheWidth: 1920,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primary.withOpacity(0.15),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 60),
                    ),
                  ),
                ),
              );
            },
          ),

          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: isDesktop
                  ? Row(
                children: [

                  /// LEFT CONTENT
                  Expanded(
                    flex: 5,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        key: ValueKey(currentPage),
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedText(
                            banners[currentPage]["title"]!,
                            width,
                          ),

                          const SizedBox(height: 25),

                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                final route =
                                banners[currentPage]["route"];
                                if (route != null) {
                                  Get.toNamed(route);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 16,
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
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 30),

                  /// RIGHT LOGIN CARD
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 400,
                        child: _buildTransparentLoginCard(context),
                      ),
                    ),
                  ),
                ],
              ) : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedText(
                    banners[currentPage]["title"]!,
                    width,
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      final route =
                      banners[currentPage]["route"];
                      if (route != null) {
                        Get.toNamed(route);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(
                      banners[currentPage]["button"]!,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],

      ),
    );
  }

}

Widget _buildTransparentLoginCard(BuildContext context) {
  final loginController=Get.put(LoginController());
  final _formKeyLoginFront = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String platform = kIsWeb
      ? "Web"
      : Platform.isAndroid
      ? "Android"
      : Platform.isIOS
      ? "iOS"
      : "Unknown";
  return ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
    width: 400,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.18),
          Colors.white.withOpacity(0.08),
        ],
      ),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 30,
          offset: const Offset(0, 14),
        )
      ],
    ),
    child: Form(
        key: _formKeyLoginFront,
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Login to your account",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),
          
          
                TextField(
                  controller: loginController.emailController,
                  style:  const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: AppTextStyles.caption(context,color: AppColors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                    prefixIcon:  const Icon(Icons.email, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: loginController.passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: AppTextStyles.caption(
                      context,
                      color: AppColors.white,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _obscurePassword = !_obscurePassword;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
          
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {
                        Get.toNamed('/forgotPasswordEmailWeb');
                      },
                      child:  Text("Forgot Password?",
                          style: AppTextStyles.caption(context,color: AppColors.white))),
                ),
                const SizedBox(height: 20),
          
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async{
          
                      if (_formKeyLoginFront.currentState!.validate()) {
                        String email = loginController.emailController.text.trim();
                        String password = loginController.passwordController.text;
          
                        if (email.isEmpty || password.isEmpty) {
                          showCustomToast(context, "Please enter email and password",backgroundColor: AppColors.secondary);
          
                          // ScaffoldMessenger
                          //     .of(context)
                          //     .showSnackBar(
                          //   const SnackBar(
                          //       content: Text(
                          //           "Please enter email and password")),
                          // );
                          return;
                        }
                        await loginController.login(loginController.emailController.text.toString(),loginController.passwordController.text.toString(),platform,context);
                        loginController.emailController.clear();
                        loginController.passwordController.clear();
                      } else {
                        showCustomToast(context,  "Invalid email or password",backgroundColor: AppColors.secondary);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child:  Text(
                      "Login",
                      style:
                      AppTextStyles.caption(context,color: AppColors.primary,fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
          
                Row(
                  children: [
                    Expanded(
                        child: Divider(color: Colors.white.withOpacity(0.4))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR",
                        style: AppTextStyles.caption(context,color: AppColors.white),
                      ),),
                    Expanded(
                        child: Divider(color: Colors.white.withOpacity(0.4))),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.caption(context,color: AppColors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/registerPageWeb');
                      },
                      child:  Text("Sign Up", style: AppTextStyles.body(context,fontWeight:FontWeight.bold,color: AppColors.white),
                      ),)
                  ],
                ),
              ]),
        )),
      ),
    ),
  );
}
Widget platformOverviewSection(context) {
  final size = MediaQuery.of(context).size.width;
  final isMobile = size < 800;

  final items = [
    {
      "title": "Dental Clinics",
      "desc": "Create profile, get patients, manage your clinic online",
      "icon": Icons.local_hospital,
    },
    {
      "title": "Dental Labs",
      "desc": "Connect with clinics and receive lab work orders easily",
      "icon": Icons.biotech,
    },
    {
      "title": "Dental Shops",
      "desc": "Show your dental products and reach nearby buyers",
      "icon": Icons.store,
    },
    {
      "title": "Dental Mechanics",
      "desc": "Get repair and equipment service jobs from clinics",
      "icon": Icons.build,
    },
    {
      "title": "Dental Professionals",
      "desc": "Consultants, assistants & experts can grow visibility",
      "icon": Icons.person_pin,
    },
    {
      "title": "Job Seekers",
      "desc": "Find dental jobs and attend webinars for career growth",
      "icon": Icons.work,
    },
  ];

  return Center(
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 1500),
      padding: const EdgeInsets.all(20),
      // padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      color: const Color(0xffF8FAFC),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Column(
            children: [
              const _SectionBadge(text: "Ecosystem", icon: Icons.hub_outlined),
              const SizedBox(height: 14),
              Text(
                "One Platform for the Entire Dental Ecosystem",
                textAlign: TextAlign.center,
                style: AppTextStyles.headline1(
                  context,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Free registration for all users • Connect • Grow • Get Opportunities",
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(context, color: AppColors.grey),
              ),
              const SizedBox(height: 40),

              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: items.map((item) {
                  return GestureDetector(
                    onTap: (){
                      Get.toNamed(
                        '/registerPageWeb',
                        arguments: {"userId": 0},
                      );
                    },
                    child: _HoverLift(
                      liftScale: 1.02,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                      width: isMobile ? double.infinity : 320,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.12),
                                  AppColors.secondary.withOpacity(0.12),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(item["icon"] as IconData,
                                color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            item["title"].toString(),
                            style: AppTextStyles.subtitle(context,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item["desc"].toString(),
                            style: AppTextStyles.caption(
                              context,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),
              GestureDetector(
                onTap: (){
                  Get.toNamed('/registerPageWeb');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Positioned(top: -50, right: -30, child: _GlowBlob(size: 160, color: Colors.white)),
                      Column(
                    children: [
                      SizedBox(height: 15),

                      Text(
                        "New to Locate Your Dentist?",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,color: AppColors.white
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Create your account to explore jobs, webinars, clinics and dental services.",
                        textAlign: TextAlign.center,style: AppTextStyles.caption(context,color: AppColors.white),
                      ),
                      SizedBox(height: 20),
                      _HoverLift(
                        liftScale: 1.04,
                        borderRadius: BorderRadius.circular(30),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.toNamed('/registerPageWeb');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "REGISTER NOW",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                      ),
                    ],
                  ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      "What You Can Do Here",
                      style: AppTextStyles.subtitle(
                        context,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: const [
                        _FeatureChip(text: "🔍 Find nearby clinics"),
                        _FeatureChip(text: "💼 Post & find dental jobs"),
                        _FeatureChip(text: "🎓 Attend webinars"),
                        _FeatureChip(text: "📍 Location-based search"),
                        _FeatureChip(text: "🆓 Free registration"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FeatureChip extends StatelessWidget {
  final String text;
  const _FeatureChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      liftScale: 1.05,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
class AnimatedText extends StatelessWidget {
  final String text;
  final double width;

  const AnimatedText(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = width < 700;
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
                  angle: value * 0.02,
                  child: child,
                ),
              ),
            );
          },
          child: Text(
            char,
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: isMobile ? 22 : width * 0.022,
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
    final isMobile = Responsive.isMobile(context);

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1500),
        padding: const EdgeInsets.all(20),
        //padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        color: Colors.white,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _RevealIn(
              child: isMobile
                  ? Column(
                children: [
                  _content(context),
                  const SizedBox(height: 20),
                  _image(),
                ],
              )
                  : Row(
                children: [
                  Expanded(child: _content(context)),
                  const SizedBox(width: 40),
                  Expanded(child: _image()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionBadge(text: "About Our Platform", icon: Icons.info_outline),
        const SizedBox(height: 14),

        Text(
            "A Complete Dental Ecosystem in One Platform",
            style: AppTextStyles.subtitle(context,color: AppColors.black,)

        ),

        const SizedBox(height: 15),

        Text(
            "Locate Your Dentist is a unified digital healthcare platform designed exclusively for the dental community. "
                "We bring together patients, dental clinics, dental laboratories, dental shops, dental mechanics, consultants, "
                "and job seekers into a single connected ecosystem.\n\n"
                "Our mission is to simplify dental healthcare access by enabling patients to easily discover nearby verified clinics "
                "based on location. Clinics can manage their profile, showcase services, hire professionals, and grow their practice. "
                "Dental labs and shops can connect directly with clinics for faster workflow and communication.\n\n"
                "We also empower dental professionals and job seekers by providing a dedicated job portal and webinar system where "
                "they can explore opportunities, enhance skills, and build their careers.\n\n"
                "This platform is built to strengthen the dental network by improving visibility, collaboration, and accessibility "
                "across the entire dental industry.",
            style: AppTextStyles.body(context,color: Colors.black)
        ),
      ],
    );
  }

  Widget _image() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset("assets/images/4p.jpg",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double width(BuildContext context, double value) {
    double screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth / 1440) * value;
  }
}

class CompleteCareSection extends StatelessWidget {
  const CompleteCareSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1500),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
      decoration:  BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Color(0xff042347),
            Color(0xff0A3D72),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                  Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.white70,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Our Expertise",
                        style: AppTextStyles.body(context,color: Colors.white70,   fontWeight: FontWeight.bold,)

                    ),
                  ],
                ),

                const SizedBox(height: 25),

                RichText(
                  text:  TextSpan(
                    children: [

                      TextSpan(text: "Complete Care\nfor Every ", style: AppTextStyles.body(context,color: Colors.white, fontWeight: FontWeight.bold,)),

                      TextSpan(text: "Smile", style: AppTextStyles.body(context,color: Color(0xff7DB6FF),   fontWeight: FontWeight.bold,)

                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 25),

                 Text(
                  "From routine checkups to advanced\n"
                      "treatments — we've got you covered.",
                  style: AppTextStyles.body(context,color: Colors.white70,)

                ),

                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 22,
                    ),
                  ),
                  onPressed: () {
                    Get.toNamed('/viewPatientsListWeb');
                  },
                  icon: Text(
                    "Search Nearby Dental Clinics",
                    style: AppTextStyles.body(
                      context,
                      color: Colors.white,
                    ),
                  ),
                  label: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(width: 35),

          Expanded(
            flex: 6,
            child: SizedBox(
              height: 420,
              child: Row(
                children: [

                  Expanded(
                    child: ServicePreviewCard(
                      image: "assets/images/dental_implant.jpg",
                      title: "Preventive Care",
                      subtitle: "Regular checkups & cleanings",
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: ServicePreviewCard(
                      highlight: true,
                      image: "assets/images/aligners.jpg",
                      title: "Tooth Decay",
                      subtitle: "Stronger roots,\nNatural Smile",
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: ServicePreviewCard(
                      image: "assets/images/align_dental.jpg",
                      title: "Tooth Sensitivity",
                      subtitle: "Brighter smile,\nMore confidence",
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}


class ServicePreviewCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final bool highlight;

  const ServicePreviewCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: highlight
              ? Colors.blueAccent
              : Colors.white24,
          width: highlight ? 3 : 1,
        ),
        boxShadow: [
          if (highlight)
            BoxShadow(
              blurRadius: 25,
              color: Colors.blue.withOpacity(.35),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [

            Positioned.fill(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,  style: AppTextStyles.body(context,color: Colors.white,fontWeight: FontWeight.bold,)

                  ),

                  const SizedBox(height: 10),

                  Text(
                    subtitle,
                      style: AppTextStyles.body(context,color: Colors.white,)
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AllServicesDialog extends StatelessWidget {
  const AllServicesDialog({super.key});

  @override
  Widget build(BuildContext context) {

    final services = [
      {
        "title":"Preventive Care",
        "image":"assets/services/preventive.png"
      },
      {
        "title":"Dental Implants",
        "image":"assets/services/implant.png"
      },
      {
        "title":"Teeth Whitening",
        "image":"assets/services/whitening.png"
      },
      {
        "title":"Root Canal",
        "image":"assets/services/rootcanal.png"
      },
      {
        "title":"Braces",
        "image":"assets/services/braces.png"
      },
      {
        "title":"Aligners",
        "image":"assets/services/aligners.png"
      },
      {
        "title":"Gum Care",
        "image":"assets/services/gumcare.png"
      },
      {
        "title":"Smile Makeover",
        "image":"assets/services/smile.png"
      },
    ];

    return Dialog(
      backgroundColor: const Color(0xff062A52),
      insetPadding: const EdgeInsets.all(30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        width: 900,
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              "Complete Dental Treatments",
              style: AppTextStyles.body(
                context,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: .9,
              ),
              itemBuilder: (_, index) {

                final item = services[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white12,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Image.asset(
                        item["image"]!,
                        height: 75,
                      ),

                      const SizedBox(height: 18),

                      Text(
                        item["title"]!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(
                          context,
                          color: Colors.white,
                        ),
                      ),

                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child:  Text("Close" , style: AppTextStyles.body(
                context,
                color: Colors.black,
              ),),
            )

          ],
        ),
      ),
    );
  }
}



Widget _buildMobile(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
    decoration:  BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
         AppColors.primary,AppColors.secondary
        ],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color:AppColors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                    "Our Expertise",
                    style: AppTextStyles.body(context,color: AppColors.white,   fontWeight: FontWeight.bold,)

                ),
              ],
            ),

            const SizedBox(height: 25),

            RichText(
              text:  TextSpan(
                children: [

                  TextSpan(
                      text: "Complete Care\nfor Every ",
                      style: AppTextStyles.body(context,color: Colors.white,   fontWeight: FontWeight.bold,)
                  ),

                  TextSpan(
                      text: "Smile",
                      style: AppTextStyles.body(context,color: Color(0xff7DB6FF),   fontWeight: FontWeight.bold,)

                  ),

                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
                "From routine checkups to advanced\n"
                    "treatments — we've got you covered.",
                style: AppTextStyles.body(context,color: Colors.white70,)

            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 22,
                  ),
                ),
                onPressed: () {
                  Get.toNamed('/viewPatientsListWeb');

                },
                icon: Text(
                  "Search Nearby Dental Clinics",
                  style: AppTextStyles.body(
                    context,
                    color: Colors.white,
                  ),
                ),
                label: const CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ),
            )
          ],
        ),

        const SizedBox(height: 30),

        // FIX: explicit bounded height for each Stack-only ServicePreviewCard
        SizedBox(
          height: 280,
          width: double.infinity,
          child: ServicePreviewCard(
            image: "assets/images/dental_implant.jpg",
            title: "Preventive Care",
            subtitle: "Regular Checkups",
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 280,
          width: double.infinity,
          child: ServicePreviewCard(
            highlight: true,
            image: "assets/images/aligners.jpg",
            title: "Dental Implants",
            subtitle: "Natural Smile",
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 280,
          width: double.infinity,
          child: ServicePreviewCard(
            image: "assets/images/align_dental.jpg",
            title: "Teeth Whitening",
            subtitle: "Bright Smile",
          ),
        ),
      ],
    ),
  );
}
