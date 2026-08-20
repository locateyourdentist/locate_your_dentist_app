import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import '../../api/api.dart';
import '../../common_widgets/color_code.dart';
import '../../common_widgets/common_drawer.dart';
import '../../common_widgets/common_sidebar_mobile.dart';
import '../../common_widgets/common_widget_all.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

import '../auth/login_screen/service_locations.dart';

class _HoverLift extends StatefulWidget {
  final Widget child;
  final double liftScale;
  final BorderRadius? borderRadius;
  const _HoverLift({required this.child, this.liftScale = 1.02, this.borderRadius});

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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _hovering ? -4.0 : 0.0)
          ..scale(_hovering ? widget.liftScale : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_hovering ? 0.18 : 0.0),
              blurRadius: _hovering ? 20 : 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Fades + slides a child in once on build, for a gentle section reveal.
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

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});
  @override
  State<SuperAdminDashboardPage> createState() =>
      _SuperAdminDashboardPageState();
}
class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  final LoginController loginController = Get.put(LoginController());
  final notificationController=Get.put(NotificationController());
  final planController=Get.put(PlanController());
  final GlobalKey<ScaffoldState> _scaffoldKeySuperAdmin = GlobalKey<ScaffoldState>();
  List<String> title=["Admin","Super Admin","Dental Clinic","Dental Shop","Dental Lab","Dental Mechanic","Dental Professionals"];
  final TextEditingController searchController=TextEditingController();
  List<ProfileModel> filteredProfiles = [];
  Map<String, int> typeCounts = {};

  final List<List<Color>> _tileColors = const [
    [Color(0xFF6C63FF), Color(0xFF9C88FF)],
    [Color(0xFFFF6B6B), Color(0xFFFF9E9E)],
    [Color(0xFF06B6D4), Color(0xFF67E8F9)],
    [Color(0xFFF59E0B), Color(0xFFFFC15E)],
    [Color(0xFF10B981), Color(0xFF6EE7B7)],
    [Color(0xFFEC4899), Color(0xFFF9A8D4)],
    [AppColors.primary, AppColors.secondary],
  ];

  IconData _iconForCategory(String category) {
    switch (category) {
      case "Admin":
        return Icons.admin_panel_settings_rounded;
      case "Super Admin":
        return Icons.shield_rounded;
      case "Dental Clinic":
        return Icons.local_hospital_rounded;
      case "Dental Shop":
        return Icons.storefront_rounded;
      case "Dental Lab":
        return Icons.biotech_rounded;
      case "Dental Mechanic":
        return Icons.build_rounded;
      case "Dental Professionals":
        return Icons.support_agent_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _refresh();
      }
  Future<void> _refresh() async {
    await loginController.fetchStates();
    await planController.getIncomeDetailsByPlan(context: context);
    //await planController.getExpense(month: "", year: "");
    await loginController.getAppLogoImage(context);
    await notificationController.getNotificationListAdmin(context);
    Api.userInfo.read('userType')=="superAdmin"?
    await loginController.getProfileDetails('', '', [], [],[], '','','','','', context): loginController.getProfileDetails('', Api.userInfo.read('state')??"", [],[], [], '','','','', '',context);
    //await planController.getIncomeDetailsByPlan(context: context);
  }

  Future<void> _onCategoryTap(String userType) async {
    Api.userInfo.write('sUserType', userType.toString());

    await loginController.getProfileDetails(
      userType,
      '',
      [],
      [],[],
      'true',
      '',
      '',
      '',
      '',
      context,
    );

    if (Get.currentRoute != '/userTypeListPage') {
      Get.toNamed('/userTypeListPage');
    }
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> colors,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.subtitle(context, color: AppColors.black),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(context, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: AppTextStyles.subtitle(context, color: AppColors.black)),
        ),
      ],
    );
  }

  Widget _categoryTile(String category, int count, List<Color> colors) {
    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      child: _HoverLift(
        liftScale: 1.03,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(_iconForCategory(category), color: Colors.white, size: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.first.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$count",
                      style: AppTextStyles.caption(context, color: colors.first, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                category,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(context, color: AppColors.black, fontWeight: FontWeight.bold),
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
    final bool isDesktop = size >= 1100;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scaffold(
        key: _scaffoldKeySuperAdmin,
        backgroundColor: const Color(0xFFF6F8FC),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: AppColors.white,
              size: size * 0.06,
            ),
            onPressed: () {
              _scaffoldKeySuperAdmin.currentState!.openDrawer();
            },
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
              gradient: LinearGradient(
                colors: [AppColors.primary,AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Column(
          mainAxisAlignment:MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Locate Your Dentist',
              style: AppTextStyles.body(context,
                color: AppColors.white,fontWeight: FontWeight.bold,),
            ),
            GetBuilder<PlanController>(
                builder: (controller) {
                  return Row(
                    children: [
                      Icon(Icons.place_outlined,color: AppColors.white,size: size*0.05,),
                      SizedBox(width: size*0.01,),
                      Expanded(child: Text(planController.currentLocation??"",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.white),)),
                    ],
                  );
                }
            ),
          ],
        ),
          automaticallyImplyLeading: false,
          actions: [
            GetBuilder<NotificationController>(
              builder: (controller) {
                return _HoverLift(
                  liftScale: 1.1,
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                  clipBehavior: Clip.none,
                  children: [

                    IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        color: AppColors.white,
                        size: size * 0.08,
                      ),
                      onPressed: () {
                        notificationController.getNotificationListAdmin(context);
                        notificationController.update();
                        Get.toNamed('/notificationPage');
                        },
                    ),
                 if (int.tryParse(notificationController.unreadCount ?? "0")! > 0)
                    Positioned(
                        top: 4,
                        right: 8,
                        child:  GetBuilder<NotificationController>(
                            builder: (controller) {
                              return CircleAvatar(
                              radius: size*0.022,backgroundColor: Colors.redAccent,child: Text(
                              notificationController.unreadCount.toString(),style: TextStyle(color: AppColors.white,fontWeight: FontWeight.w500,fontSize: size*0.022),
                            ),
                            );
                          }
                        ))
                  ],
                  ),
                );
              }
            )
          ],
        ),
        drawer: !isDesktop ? Drawer(width: 250, child: SettingsSidebarDrawer()) : null,
        body: GetBuilder<LoginController>(
          builder: (controller) {
            final int total = loginController.profileList.length;
            final int active = loginController.profileList.where((p) => p.isActive).length;
            final int inactive = total - active;
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    if(loginController.profileList.isEmpty)
                      Column(
                        children: [
                          dashboardShimmer()
                        ],
                      ),
                    if(loginController.isLoading)
                      dashboardShimmer(),
                    if(loginController.profileList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: _RevealIn(
                          child: Row(
                            children: [
                              _statTile(
                                icon: Icons.groups_rounded,
                                label: "Total Users",
                                value: "$total",
                                colors: const [AppColors.primary, AppColors.secondary],
                              ),
                              const SizedBox(width: 12),
                              _statTile(
                                icon: Icons.check_circle_outline_rounded,
                                label: "Active",
                                value: "$active",
                                colors: const [Color(0xFF10B981), Color(0xFF6EE7B7)],
                              ),
                              const SizedBox(width: 12),
                              _statTile(
                                icon: Icons.pause_circle_outline_rounded,
                                label: "Inactive",
                                value: "$inactive",
                                colors: const [Color(0xFFFF6B6B), Color(0xFFFF9E9E)],
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: size*0.01,),
                    if(loginController.profileList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _sectionHeading(icon: Icons.grid_view_rounded, text: 'What you Want?'),
                              ),
                            ),
                            SizedBox(height: size * 0.02),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _RevealIn(
                                delay: const Duration(milliseconds: 80),
                                child: Container(
                                height: size * 0.13,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.search, color: AppColors.primary, size: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: searchController,
                                        style: AppTextStyles.caption(
                                          context,
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Search users by name, area,mobile number...",
                                          hintStyle: AppTextStyles.caption(
                                            context,
                                            color: AppColors.grey,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                        onSubmitted: (value)async {
                                          String userType=  Api.userInfo.read('sUserType');
                                          print("ssuser$userType");
                                          String distance =
                                          (loginController.selectedDistance1 ?? 0).toString();

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
                                          String safeLat =
                                          useLocation ? (loginController.latitude?.toString() ?? "") : "";

                                          String safeLng =
                                          useLocation ? (loginController.longitude?.toString() ?? "") : "";
                                          filteredProfiles.map((e) => searchController.text.toString());
                                          if( Api.userInfo.read('userType')=="superAdmin") {
                                            await   loginController.getProfileDetails('',  '',
                                                [], [], [], '','',
                                                '','',searchController.text.toString(),  context);
                                            Get.toNamed('/userTypeListPage');
                                          }
                                          else if( Api.userInfo.read('userType')=="admin") {
                                            await   loginController.getProfileDetails('',  Api.userInfo.read('state') ?? "",
                                                [], [], [], '','',
                                                '','',searchController.text.toString(),  context);
                                          }
                                          else{
                                            await   loginController.getProfileDetails(userType, "",
                                                [], [], [], '','',
                                                '','',searchController.text.toString(),  context);
                                          }
                                          print("Search text: $value");
                                        },
                                      ),
                                    ),
                                    _HoverLift(
                                      liftScale: 1.06,
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.tune_rounded,
                                            color: Colors.white,
                                            size: size * 0.055,
                                          ),
                                          onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) {
                                            return FractionallySizedBox(
                                              heightFactor: 0.75,
                                              child: FilterDrawer(
                                                onApply: () async{
                                                  print("Selected State: ${loginController.selectedState}");
                                                  print("Selected District: ${loginController.selectedDistrict}");
                                                  print("Selected Area: ${loginController.selectedTaluka}");
                                                  print('distance${loginController.selectedDistance}');

                                                  String userType=  Api.userInfo.read('sUserType');
                                                  print("ssuser$userType");
                                                  if (loginController.selectedDistance != null) {
                                                    final position = await LocationService.getCurrentLocation();

                                                    if (position == null) {
                                                      return;
                                                    }

                                                    loginController.latitude = position.latitude;
                                                    loginController.longitude = position.longitude;

                                                    print("LAT: ${loginController.latitude}");
                                                    print("LNG: ${loginController.longitude}");
                                                  }
                                                  String distance =
                                                  (loginController.selectedDistance1 ?? 0).toString();

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
                                                  String safeLat =
                                                  useLocation ? (loginController.latitude?.toString() ?? "") : "";

                                                  String safeLng =
                                                  useLocation ? (loginController.longitude?.toString() ?? "") : "";
                                                  filteredProfiles.map((e) => searchController.text.toString());
                                                  final filterDegree = loginController.filterUserType == 'Dental Consultant'
                                                      ? loginController.filterSelectedDegree
                                                      : null;
                                                  final filterLocations = loginController.filterUserType == 'Dental Consultant'
                                                      ? loginController.filterSelectedAvailableLocations
                                                      : null;
                                                  final filterTiming = loginController.filterUserType == 'Dental Consultant'
                                                      ? loginController.filterSelectedTimingSlots
                                                      : null;
                                                  if( Api.userInfo.read('userType')=="superAdmin") {
                                                    await   loginController.getProfileDetails(loginController.filterUserType ?? '',  loginController.selectedState,
                                                        loginController.selectedDistricts,
                                                        loginController.selectedTalukas,[], '',safeLat,
                                                        safeLng,distance,searchController.text.toString(),  context,
                                                        degreeName: filterDegree, availableLocations: filterLocations, availableTiming: filterTiming);
                                                  }
                                                  else if( Api.userInfo.read('userType')=="admin") {
                                                    await loginController.getProfileDetails(loginController.filterUserType ?? '', Api.userInfo.read('state') ?? "", loginController.selectedDistricts,
                                                        loginController.selectedTalukas,loginController.selectedVillages, '',safeLat,
                                                        safeLng,distance,searchController.text.toString(), context,
                                                        degreeName: filterDegree, availableLocations: filterLocations, availableTiming: filterTiming);
                                                  }
                                                  else{
                                                    await  loginController.getProfileDetails(
                                                      loginController.filterUserType ?? userType,
                                                      loginController.selectedState,
                                                      loginController.selectedDistricts,
                                                      loginController.selectedTalukas,loginController.selectedVillages,'true',safeLat,
                                                      safeLng,distance, searchController.text.toString(),
                                                      context,
                                                      degreeName: filterDegree, availableLocations: filterLocations, availableTiming: filterTiming,
                                                    );
                                                  }
                                                  Navigator.pop(context);
                                                },
                                                onReset: () {
                                                  setState(() {
                                                    loginController.selectedDistance = null;
                                                    loginController.selectedDistrict = null;
                                                    loginController.selectedArea = null;
                                                    loginController.selectedUserType=null;
                                                    loginController.selectedTaluka=null;
                                                    loginController.selectedState=null;
                                                    loginController.resetUserTypeFilters();
                                                  });
                                                },
                                              ),
                                            );
                                          },
                                        );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ),
                              ),
                            ),
                            SizedBox(height: size*0.02,),

                            _RevealIn(
                              delay: const Duration(milliseconds: 100),
                              child: Column(
                                children: [
                                  postAdsBannerMobile(context),
                                  SizedBox(height: size * 0.02),
                                  scrollingAdsBannerMobile(context),
                                ],
                              ),
                            ),
                            SizedBox(height: size*0.02,),

                            GetBuilder<LoginController>(
                                builder: (controller) {
                                  return _RevealIn(
                                    delay: const Duration(milliseconds: 140),
                                    child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: title.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemBuilder: (context, index) {
                                    final String userType = title[index];
                                    final count = loginController.profileList
                                        .where((e) =>
                                    e.userType.toLowerCase().trim() ==
                                        userType.toLowerCase().trim())
                                        .length;
                                    return _categoryTile(
                                      userType,
                                      count,
                                      _tileColors[index % _tileColors.length],
                                    );
                                  },
                                ),
                                  );
                              }
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _sectionHeading(icon: Icons.people_alt_rounded, text: 'Latest Users List'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if(controller.profileList.isEmpty)
                          buildShimmerEmptyWidget(size),
                          if(controller.profileList.isNotEmpty)

                          AnimationLimiter(
                            child: Column(
                              children:  controller.profileList
                                  .take(10)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final profile = entry.value;
                            return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 1300),
                            child: SlideAnimation(
                            verticalOffset: 120.0,
                            curve: Curves.easeOutBack,
                            child: FadeInAnimation(
                            child: GestureDetector(
                            onTap: () async{
                            print('userlistId ${profile.userId}');
                            Api.userInfo.write('selectUId',profile.userId ?? '');

                            print('ids${profile.userId}');

                            await loginController.getProfileByUserId(
                            profile.userId ?? '', context);
                            if (PlatformHelper.platform != "Web") {
                            Get.toNamed('/${profilePage(profile.userType)}');
                            }
                            },
                            child: SuperAdminProfileCard(
                            profile: profile,
                            size: size,
                            onCall: ()async {
                            await launchCall(profile.mobileNumber);
                            },
                            ),
                            ),
                            ),
                            ),
                            );
                            }).toList(),
                            ),
                            )
                            ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
      ),
    );
  }

}

Widget dashboardShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

class SuperAdminProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final double size;
  final void Function()? onCall;
  const SuperAdminProfileCard({
    super.key,
    required this.profile,
    required this.size,
    this.onCall,
  });
  bool isBasePlanActive(ProfileModel profile) {
    final isActive =
    profile.details?["plan"]?["basePlan"]?["isActive"];
    return isActive == true || isActive == "true";
  }
  @override
  Widget build(BuildContext context) {
    final planActive = isBasePlanActive(profile);
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
    String firstImage = profile.images.firstWhere(
          (img) =>
      img.toLowerCase().endsWith('.jpg') ||
          img.toLowerCase().endsWith('.jpeg') ||
          img.toLowerCase().endsWith('.png') ||
          img.toLowerCase().endsWith('.webp'),
      orElse: () => "",
    );
    List<String> parts = [];
    if ((profile.address["state"] ?? "").isNotEmpty) parts.add(profile.address["state"]);
    if ((profile.address["district"] ?? "").isNotEmpty) parts.add(profile.address["district"]);
    if ((profile.address["city"] ?? "").isNotEmpty) parts.add(profile.address["city"]);
    String address = parts.join(", ");
    final loginController=Get.put(LoginController());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: _HoverLift(
        liftScale: 1.012,
        borderRadius: BorderRadius.circular(20),
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.white,
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 5))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        (firstImage.isNotEmpty && isAdminUser||
                            ((planActive == true &&
                                profile.details["plan"]?["basePlan"]?["details"]?["images"] == true)))
                            ? firstImage
                            : "",
                        width: size * 0.22,
                        height: size * 0.22,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: size * 0.22,
                            height: size * 0.22,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.12), AppColors.secondary.withOpacity(0.12)]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.primary.withOpacity(0.6),
                              size: size * 0.08,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: profile.isActive ? Colors.green : Colors.redAccent,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              (profile.userType == "Dental Clinic" ||
                                  profile.userType == "Dental Consultant")
                                  ? "Dr. ${profile.name}"
                                  : profile.name,softWrap: true,
                              style: AppTextStyles.caption(
                                context,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (profile.isActive ? Colors.green : Colors.redAccent).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: (profile.isActive ? Colors.green : Colors.redAccent).withOpacity(0.4)),
                            ),
                            child: Text(
                              profile.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: profile.isActive ? Colors.green : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: size*0.025,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text("UserId: ${profile.userId}",
                          style: AppTextStyles.caption(context, color: AppColors.grey)),
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("${profile.userType}",
                            style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 3),
                      Text("Address: $address",
                          style: AppTextStyles.caption(context,
                              color: Colors.grey)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((planActive == true &&
                                profile.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ||
                                isAdminUser)
                            Text(
                              "Mobile Number: ${profile.mobileNumber}",
                              style: AppTextStyles.caption(context),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              ]),
              const SizedBox(height: 10),

              Row(
                children: [

                  Expanded(
                    child: _HoverLift(
                      liftScale: 1.03,
                      borderRadius: BorderRadius.circular(12),
                      child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: ()async {
                        Api.userInfo.write('selectUId',profile.userId ?? '');

                        print('ids${profile.userId}');

                        await loginController.getProfileByUserId(
                            profile.userId ?? '', context);
                        if (PlatformHelper.platform != "Web") {
                          Get.toNamed('/${profilePage(profile.userType)}');
                        }
                      },
                      child:  Text(
                        "View Profile",
                        style: AppTextStyles.caption(color: Colors.white,context,fontWeight: FontWeight.bold),
                      ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  if ((planActive == true &&
                      profile.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ||
                      isAdminUser)
                    Expanded(
                      child: _HoverLift(
                        liftScale: 1.03,
                        borderRadius: BorderRadius.circular(12),
                        child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color:Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: onCall,
                        child: const Text(
                          "Call Now",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
    );
  }
}


class AdminDashboardWidget extends StatelessWidget {
  final List<ProfileModel> profiles;
  final loginController=Get.put(LoginController());
   AdminDashboardWidget({super.key, required this.profiles});
  @override
  Widget build(BuildContext context) {
    int total = profiles.length;
    int active = profiles.where((p) => p.isActive).length;
    int inactive = total - active;
    Map<String, int> typeCounts = {};
    for (var p in profiles) {
      typeCounts[p.userType] = (typeCounts[p.userType] ?? 0) + 1;
    }
    return Column(
      children: [
        _header(context,total,active,inactive),
        const SizedBox(height: 20),
        AnimationLimiter(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            //height: MediaQuery.of(context).size.width * 0.8,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
            children: typeCounts.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 1300),
            child: SlideAnimation(
              horizontalOffset: 80.0,
            curve: Curves.easeOutBack,
            child: FadeInAnimation(
            child: Column(
              children:[
               _typeTile(
              e.key,
              e.value,
              context,
              onTap: () async{
              Api.userInfo.write('selectedUserType', e.key);
              Api.userInfo.write('sUserType', e.key);
              Get.toNamed('/userTypeListPage');

             await  loginController.getProfileDetails(
              Api.userInfo.read('selectedUserType'),
              '',
              [],
              [],[],
              '','','','','',
                context,
              );

              },
               ),
              const Divider(color: Colors.grey,thickness: 0.3,)
              ]
            ),
            ),
            ),
            );
            }).toList(),
            ),
          ),
        ],
      ),
    ),
    ),

      ],
    );
  }
  Widget _header(BuildContext context, int total, int active, int inactive) {
    double width = MediaQuery.of(context).size.width;
    double height = width * 0.35;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dashboard",
                style: AppTextStyles.caption(
                  context,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Overview of user activity",
                style: AppTextStyles.subtitle(
                  context,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -30,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStatCard(context, "Total Users", total, AppColors.white, AppColors.primary),
              _miniStatCard(context, "Active", active, AppColors.white, Colors.green),
              _miniStatCard(context, "Inactive", inactive, AppColors.white, Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard(
      BuildContext context, String label, int value, Color bgColor, Color textColor) {
    double width = MediaQuery.of(context).size.width * 0.27;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.caption(
              context,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "$value",
            style: AppTextStyles.subtitle(
              context,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
  Widget _typeTile(String title, int count, BuildContext context,
      {VoidCallback? onTap}) {
    double size = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "$title ($count)",
                style: AppTextStyles.caption(
                  context,color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,softWrap: true,
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: size * 0.04,
              color: AppColors.black,
            ),
          ],
        ),
      ),
    );
  }

}

Widget drawerTitle(
    String title,
    IconData icon,
    String page,
    BuildContext context,
    ) {
  double size = MediaQuery.of(context).size.width;

  return ListTile(
    leading: Icon(
      icon,
      color: AppColors.white,
      size: size * 0.055,
    ),
    title: Text(
      title,
      style: AppTextStyles.caption(
        context,
        color: AppColors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    trailing: Icon(
      Icons.arrow_forward_ios,
      color: AppColors.white,
      size: size * 0.035,
    ),
    onTap: () {
      if (page.isNotEmpty) {
        Get.toNamed(page);
      }
    },
  );
}
