import 'dart:math';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
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
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common_widgets/common_bottom_navigation.dart';
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
      await loginController.fetchStates();
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
    if (Api.userInfo.read('token') != null) {
      await notificationController.getNotificationListAdmin(context);
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

  Future<void> _performLocationSearch() async {
    String distance = loginController.selectedDistance1.toString();
    bool useLocation =
        distance.isNotEmpty && distance != "0" && distance != "0.0";
    if (useLocation) {
      await getLocation();
    } else {
      loginController.latitude = null;
      loginController.longitude = null;
    }

    String safeLat = useLocation
        ? (loginController.latitude?.toString() ?? "")
        : "";
    String safeLng = useLocation
        ? (loginController.longitude?.toString() ?? "")
        : "";

    await loginController.getProfileDetails(
      "Dental Clinic",
      loginController.selectedState,
      loginController.selectedDistricts,
      loginController.selectedTalukas,
      loginController.selectedVillages,
      "true",
      safeLat,
      safeLng,
      distance,
      searchController.text.trim(),
      context,
    );
    Get.toNamed('/filterResultPage');
  }

  Widget _buildLocationInfoRow() {
    return GetBuilder<PlanController>(
      builder: (controller) {
        final bool hasLocation = controller.currentLocation?.isNotEmpty == true;
        return Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.secondary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                hasLocation
                    ? controller.currentLocation!
                    : "Detecting location...",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(
                  context,
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.secondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CommonSearchTextField(
              controller: searchController,
              borderColor: Colors.transparent,
              hintStyle: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              hintText: "Search your nearby clinic",
              onSubmitted: (value) => _performLocationSearch(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSearchCard() {
    return GetBuilder<LoginController>(
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 4),
              _searchCardRow(
                icon: Icons.map_rounded,
                child: SizedBox(
                  height: 40,
                  child: CustomDropdown<String>.search(
                    key: ValueKey(loginController.selectedState),
                    hintText: "State",
                    textAlign: TextAlign.center,
                    closedHeaderPadding: EdgeInsets.zero,
                    items: loginController.states
                        .map((s) => s.toString())
                        .toList(),
                    initialItem:
                        loginController.selectedState != null &&
                            loginController.states
                                .map((s) => s.toString())
                                .contains(loginController.selectedState)
                        ? loginController.selectedState
                        : null,
                    onChanged: (val) {
                      loginController.selectedState = val;
                      loginController.districts.clear();
                      loginController.talukas.clear();
                      loginController.villages.clear();
                      loginController.selectedDistricts = [];
                      loginController.selectedTalukas = [];
                      loginController.selectedVillages = [];
                      if (val != null) {
                        loginController.fetchDistricts(val);
                      }
                      loginController.update();
                    },
                    decoration: CustomDropdownDecoration(
                      closedFillColor: Colors.transparent,
                      expandedFillColor: Colors.white,
                      closedBorder: Border.all(color: Colors.transparent),
                      closedBorderRadius: BorderRadius.circular(12),
                      expandedBorder: Border.all(color: Colors.transparent),
                      expandedBorderRadius: BorderRadius.circular(12),
                      closedSuffixIcon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.grey,
                      ),
                      expandedSuffixIcon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.grey,
                      ),
                      hintStyle: AppTextStyles.caption(
                        context,
                        color: AppColors.grey,
                      ),
                      headerStyle: AppTextStyles.caption(
                        context,
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              _rowDivider(),
              _searchCardRow(
                icon: Icons.location_city_rounded,
                child: _multiSelectField(
                  title: "Select districts",
                  hint: "District",
                  items: loginController.districts,
                  selected: loginController.selectedDistricts,
                  onConfirm: (values) async {
                    loginController.selectedDistricts = values;
                    await loginController.fetchTalukas(values);
                    loginController.update();
                  },
                ),
              ),
              _rowDivider(),
              _searchCardRow(
                icon: Icons.holiday_village_rounded,
                child: _multiSelectField(
                  title: "Select Taluka",
                  hint: "Taluka",
                  items: loginController.talukas,
                  selected: loginController.selectedTalukas,
                  onConfirm: (values) async {
                    loginController.selectedTalukas = values;
                    await loginController.fetchVillages(values);
                    loginController.update();
                  },
                ),
              ),
              _rowDivider(),
              _searchCardRow(
                icon: Icons.pin_drop_rounded,
                child: _multiSelectField(
                  title: "Select Areas",
                  hint: "Area",
                  items: loginController.villages,
                  selected: loginController.selectedVillages,
                  onConfirm: (values) {
                    loginController.selectedVillages = values;
                    loginController.update();
                  },
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  Widget _searchCardRow({required IconData icon, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _rowDivider() =>
      Divider(height: 1, thickness: 1, color: Colors.grey.shade200);

  Widget _multiSelectField({
    required String title,
    required String hint,
    required List items,
    required List<String> selected,
    required void Function(List<String>) onConfirm,
  }) {
    return MultiSelectDialogField<String>(
      checkColor: AppColors.primary,
      buttonIcon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.grey,
      ),
      items: items
          .toSet()
          .map((e) => MultiSelectItem<String>(e.toString(), e.toString()))
          .toList(),
      title: Center(child: Text(title, style: AppTextStyles.body(context))),
      buttonText: Text(
        selected.isEmpty
            ? hint
            : selected.length == 1
            ? selected.first
            : "${selected.first} +${selected.length - 1}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption(
          context,
          color: selected.isEmpty ? AppColors.grey : AppColors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      decoration: const BoxDecoration(),
      searchable: true,
      dialogHeight: 400,
      initialValue: selected,
      onConfirm: (values) =>
          onConfirm(values.map((e) => e.toString()).toList()),
      chipDisplay: MultiSelectChipDisplay.none(),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: _performLocationSearch,
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
              color: AppColors.primary.withValues(alpha: 0.1),
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
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: 76,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 60,
                      child: Image.asset(
                        'assets/images/logolyd.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "LYD",
                      style: TextStyle(
                        fontSize: size * 0.09,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondary,
                        letterSpacing: -0.5,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: -6,
                  top: -4,
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: size * 0.045,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              "Locate Your Dentist",
              style: TextStyle(
                fontSize: size * 0.03,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Column(
                      children: [
                        _buildLocationInfoRow(),
                        const SizedBox(height: 10),
                        _buildSearchBar(),
                        const SizedBox(height: 12),
                        _buildLocationSearchCard(),
                        const SizedBox(height: 12),
                        _buildSearchButton(),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size * 0.02),
                        _RevealIn(
                          delay: const Duration(milliseconds: 120),
                          child: _sectionHeading(
                            icon: Icons.star_rounded,
                            text: "Top Dentist in your State",
                          ),
                        ),
                        SizedBox(height: size * 0.03),
                        _RevealIn(
                          delay: const Duration(milliseconds: 160),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
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
                        Center(
                          child: Text(
                            "Login or Register to continue",
                            style: AppTextStyles.body(
                              context,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: size * 0.05),

                        _RevealIn(
                          delay: const Duration(milliseconds: 60),
                          child: _buildProfessionalCard(),
                        ),
                        SizedBox(height: size * 0.02),

                        _RevealIn(
                          delay: const Duration(milliseconds: 200),
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
                  _buildFooterStrip(),
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
                    color: AppColors.primary.withValues(alpha: .35),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Professional icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.35),
                width: 1.4,
              ),
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: AppColors.secondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // Text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DENTAL PROFESSIONAL',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Login or Register to continue\nas Dental Professional',
                  style: TextStyle(
                    color: AppColors.greyDark,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          Container(width: 1, height: 56, color: Colors.grey.shade300),
          const SizedBox(width: 10),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 92,
                height: 34,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed('/loginPage');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 92,
                height: 34,
                child: OutlinedButton(
                  onPressed: () {
                    Get.toNamed('/loginTypesPage');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    side: const BorderSide(
                      color: AppColors.secondary,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStrip() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(vertical: 18),
      color: AppColors.lightBlue,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Your smile, our priority",
              style: AppTextStyles.caption(context, color: AppColors.greyDark),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.secondary,
              size: 16,
            ),
          ],
        ),
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
                          color: items[i]["color"].withValues(alpha: .15),
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
