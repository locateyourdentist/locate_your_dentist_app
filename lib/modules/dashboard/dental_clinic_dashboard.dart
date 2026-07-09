import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_drawer.dart';
import 'package:locate_your_dentist/common_widgets/common_sidebar_mobile.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../web_modules/common/common_side_bar.dart';
import '../../web_modules/job_seekers/view_jobWebinar_web.dart';

/// Hover/lift affordance (desktop & web pointers) used purely for a modern,
/// tactile feel on tappable cards/tiles; does not intercept taps.
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

class DentalClinicDashboard extends StatefulWidget {
  const DentalClinicDashboard({super.key});
  @override
  State<DentalClinicDashboard> createState() => _DentalClinicDashboardState();
}
class _DentalClinicDashboardState extends State<DentalClinicDashboard> {
  final TextEditingController searchController=TextEditingController();
  final jobController=Get.put(JobController());
  final loginController=Get.put(LoginController());
  final notificationController=Get.put(NotificationController());
  final planController=Get.put(PlanController());
  List<ProfileModel> filteredProfiles = [];
  List<String> title=["Dental Shop","Dental Lab","Dental Mechanic","Dental Consultant","Job Posts/Webinars"];

  /// Purely presentational: gradient pairs cycled across the bento category
  /// tiles so the grid doesn't read as a flat wall of white cards.
  final List<List<Color>> _tileColors = const [
    [Color(0xFF6C63FF), Color(0xFF9C88FF)],
    [Color(0xFFFF6B6B), Color(0xFFFF9E9E)],
    [Color(0xFF06B6D4), Color(0xFF67E8F9)],
    [Color(0xFFF59E0B), Color(0xFFFFC15E)],
  ];

  IconData _iconForCategory(String category) {
    switch (category) {
      case "Dental Shop":
        return Icons.storefront_rounded;
      case "Dental Lab":
        return Icons.biotech_rounded;
      case "Dental Mechanic":
        return Icons.build_rounded;
      case "Dental Consultant":
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
   await  jobController.getJobListAdmin(context);
   await  jobController.getWebinarListAdmin(context);
   await  notificationController.getNotificationListAdmin(context);
   await  planController.checkPlansStatus(Api.userInfo.read('userId')??"",context);
   await loginController.getBranchDetails(context);
   final userId = Api.userInfo.read('userId') ?? '';
   if (userId.isNotEmpty) {
     Api.userInfo.write('selectUId', userId);
     await loginController.getProfileByUserId(userId, context);
   }
  }

  Future<void> _onCategoryTap(String category) async {
    if (category == "Job Posts/Webinars") {
      Get.toNamed('/viewJobWebinarPage');
    } else {
      Api.userInfo.write('sUserType', category);

      await loginController.getProfileDetails(
        category,
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
  }

  void _openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: FilterDrawer(
            onApply: () async {
              print("Selected State: ${loginController.selectedState}");
              print("Selected District: ${loginController.selectedDistrict}");
              print("Selected Area: ${loginController.selectedArea}");

              String userType = Api.userInfo.read('sUserType');
              print("ssuser$userType");
              filteredProfiles.map((e) => searchController.text.toString());
              String distance = loginController.selectedDistance1.toString() ?? "0";
              if (distance != "0") {
                await getLocation();
              } else {
                loginController.latitude = null;
                loginController.longitude = null;
              }

              String safeLat =
              (distance != "0" && loginController.latitude != null)
                  ? loginController.latitude.toString()
                  : "";

              String safeLng =
              (distance != "0" && loginController.longitude != null)
                  ? loginController.longitude.toString()
                  : "";
              await loginController.getProfileDetails(
                userType ?? "",
                loginController.selectedState,
                loginController.selectedDistricts,
                loginController.selectedTalukas,loginController.selectedVillages,"true",safeLat,safeLng, distance,'',
                context,
              );
              Get.back();
            },
            onReset: () {
              setState(() {
                loginController.selectedArea = null;
                loginController.selectedUserType=null;
                loginController.selectedState=null;
                loginController.selectedDistrict=null;
              });
            },
          ),
        );
      },
    );
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

  Widget _sectionHeading({required IconData icon, required String text, String? trailing}) {
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
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(trailing, style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _ctaBanner(double size) {
    return GestureDetector(
      onTap: () => _onCategoryTap("Job Posts/Webinars"),
      child: _HoverLift(
        liftScale: 1.015,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
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
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Job Posts/Webinars",
                      style: AppTextStyles.body(context, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Hire staff & host learning sessions",
                      style: AppTextStyles.caption(context, color: Colors.white.withOpacity(0.85)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryTile(String category, List<Color> colors) {
    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      child: _HoverLift(
        liftScale: 1.03,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_iconForCategory(category), color: Colors.white, size: 22),
              ),
              const SizedBox(height: 12),
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
    double size=MediaQuery.of(context).size.width;
    final bool isDesktop = size >= 1100;
    final otherCategories = title.where((t) => t != "Job Posts/Webinars").toList();
    return  Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      drawer: !isDesktop ? Drawer(width: 250, child: SettingsSidebarDrawer()) : null,
      // appBar: AppBar(
      //   backgroundColor: AppColors.primary,
      //   automaticallyImplyLeading: true,
      //   elevation: 0,
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      //   ),
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   flexibleSpace: Container(
      //     decoration: const BoxDecoration(
      //       borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      //       gradient: LinearGradient(
      //         colors: [AppColors.primary,AppColors.secondary],
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //       ),
      //     ),
      //   ),
      //   centerTitle: false,
      //   title: Text(
      //     'Locate Your Dentist',
      //     style: AppTextStyles.body(context, color: AppColors.white, fontWeight: FontWeight.bold),
      //   ),
      //   actions: [
      //     GetBuilder<NotificationController>(
      //       builder: (controller) {
      //         bool multipleBranches = loginController.userBranchesList.length > 1;
      //         return Row(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             if (multipleBranches)
      //               _HoverLift(
      //                 liftScale: 1.1,
      //                 borderRadius: BorderRadius.circular(24),
      //                 child: IconButton(
      //                   tooltip: 'Switch Account',
      //                   onPressed: () async {
      //                     Get.toNamed(
      //                       '/branchListPage',
      //                       arguments: {'page': 'dashboard'},
      //                     );
      //                   },
      //                   icon: Image.asset('assets/images/switch_account.png',height: size * 0.05,width:size * 0.05,),
      //                 ),
      //               ),
      //             _HoverLift(
      //               liftScale: 1.1,
      //               borderRadius: BorderRadius.circular(24),
      //               child: Stack(
      //                 clipBehavior: Clip.none,
      //                 children: [
      //                   IconButton(
      //                     icon: Icon(
      //                       Icons.notifications_none,
      //                       color: AppColors.white,
      //                       size: size * 0.07,
      //                     ),
      //                     onPressed: () async {
      //                       await notificationController.getNotificationListAdmin(context);
      //                       notificationController.unreadCount="0";
      //                       notificationController.update();
      //                       Get.toNamed('/notificationPage');
      //                     },
      //                   ),
      //                   if (int.tryParse(notificationController.unreadCount ?? "0")! > 0)
      //                     Positioned(
      //                       top: 4,
      //                       right: 8,
      //                       child: CircleAvatar(
      //                         radius: size * 0.022,
      //                         backgroundColor: Colors.redAccent,
      //                         child: Text(
      //                           notificationController.unreadCount ?? "",
      //                           style: TextStyle(
      //                             color: Colors.white,
      //                             fontSize: size * 0.022,
      //                             fontWeight: FontWeight.w500,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body:  GetBuilder<JobController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh:_refresh ,
            child: DefaultTabController(
              length: 2,
              child: SafeArea(
                child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /// HERO + FLOATING SEARCH CARD
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 46),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(32),
                                  bottomRight: Radius.circular(32),
                                ),
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary,AppColors.secondary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Welcome back",
                                          style: AppTextStyles.caption(context, color: Colors.white.withOpacity(0.85)),
                                        ),
                                        const SizedBox(height: 3),
                                        GetBuilder<PlanController>(
                                          builder: (controller) {
                                            return Row(
                                              children: [
                                                const Icon(Icons.place_outlined, color: Colors.white, size: 14),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    planController.currentLocation ?? "",
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: -26,
                              child: _RevealIn(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  height: 56,
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
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child:CommonSearchTextField(
                                          controller: searchController,
                                          hintText: "Search lab,shop,etc...",
                                          onSubmitted: (value)async {
                                            print("Search text: $value");
                                            await  loginController.getProfileDetails('' ,'', [],[], [],'true','','','',value,context);
                                            Get.toNamed('/filterResultPage');
                                          },
                                        )
                                      ),
                                      _HoverLift(
                                        liftScale: 1.06,
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                                          ),
                                          child: Center(
                                            child: IconButton(
                                              onPressed: _openFilterDrawer,
                                              icon:  Icon(Icons.tune_rounded, color: Colors.white, size: size*0.05),
                                              splashRadius: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 46),
                
                        /// QUICK STATS
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _RevealIn(
                            delay: const Duration(milliseconds: 80),
                            child: Row(
                              children: [
                                _statTile(
                                  icon: Icons.work_outline_rounded,
                                  label: "Active Jobs",
                                  value: jobController.jobList.length.toString(),
                                  colors: const [AppColors.primary, AppColors.secondary],
                                ),
                                const SizedBox(width: 12),
                                _statTile(
                                  icon: Icons.video_camera_front_outlined,
                                  label: "Webinars",
                                  value: jobController.webinarList.length.toString(),
                                  colors: const [Color(0xFF06B6D4), Color(0xFF67E8F9)],
                                ),
                                const SizedBox(width: 12),
                                _statTile(
                                  icon: Icons.notifications_none_rounded,
                                  label: "Alerts",
                                  value: notificationController.unreadCount ?? "0",
                                  colors: const [Color(0xFFFF6B6B), Color(0xFFFF9E9E)],
                                ),
                              ],
                            ),
                          ),
                        ),
                
                        const SizedBox(height: 26),
                
                        /// BENTO CATEGORY GRID
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _RevealIn(
                            delay: const Duration(milliseconds: 140),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionHeading(icon: Icons.grid_view_rounded, text: 'What you Want?'),
                                const SizedBox(height: 14),
                                _ctaBanner(size),
                                const SizedBox(height: 14),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: otherCategories.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 1.5,
                                  ),
                                  itemBuilder: (context, index) {
                                    return _categoryTile(
                                      otherCategories[index],
                                      _tileColors[index % _tileColors.length],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                
                        const SizedBox(height: 30),
                
                        /// JOBS & WEBINARS
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _RevealIn(
                            delay: const Duration(milliseconds: 200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GetBuilder<JobController>(
                                  builder: (controller) {
                                    return _sectionHeading(
                                      icon: Icons.work_outline,
                                      text: 'Jobs & Webinars',
                                      trailing: "${jobController.jobList.length + jobController.webinarList.length}",
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                GetBuilder<JobController>(
                                  builder: (controller){
                                    return Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                                        color: Colors.grey.shade100,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: TabBar(
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        dividerColor: Colors.transparent,
                                        indicator:
                                        BoxDecoration(borderRadius: BorderRadius.circular(50),
                                          gradient: const LinearGradient(
                                            colors: [AppColors.primary,AppColors.secondary],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        labelColor: AppColors.white,
                                        unselectedLabelColor: AppColors.black,
                                        tabs:  const [
                                          Tab(text: 'Jobs'),
                                          Tab(text: 'Webinars'),
                                        ],
                                      ),
                                    );
                                  }
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.55,
                                  child: TabBarView(
                                    children: [
                                      jobController.jobList.isEmpty ?
                                      buildShimmerEmptyWidget(size)
                                          :AnimationLimiter(
                                        child: ListView.builder(
                                          itemCount: jobController.jobList.length,
                                          key: ValueKey(jobController.jobList.length),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          itemBuilder: (context, index) {
                                            final jobs = jobController.jobList[index];
                                            final created = DateTime.parse(jobs.createdDate.toString());
                                            final postedAgo = timeAgo(created);
                                            return AnimationConfiguration.staggeredList(
                                              position: index,
                                              duration: const Duration(milliseconds: 1300),
                                              child: SlideAnimation(
                                                verticalOffset: 120.0,
                                                curve: Curves.easeOutBack,
                                                child: FadeInAnimation(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(bottom: 12),
                                                    child: GestureDetector(
                                                      onTap: () async{
                                                        Api.userInfo.write('selectJobId',jobs.jobId.toString());
                                                        Api.userInfo.write('activeStatus',jobs.isActive.toString());
                                                        print("nnn${Api.userInfo.read('selectJobId')}");
                                                        await jobController.getJobsById(jobs.jobId.toString(), context);
                                                        await jobController.getAppliedJobsAdmin(jobs.jobId.toString(), context);
                                                        Get.toNamed('/jobViewProfilePage');
                                                      },
                                                      child: JobCard(
                                                        title: jobs.jobTitle.toString(),
                                                        description: "Posted On: ${formatDate1("${jobs.createdDate}")}",
                                                        jobType: jobs.jobType.toString(),
                                                        appliedCount: jobs.totalApplicants.toString(),
                                                        postedAgo: postedAgo,
                                                        status: (jobs.isActive ?? false) ? "Open" : "Close",
                                                        statusColor: (jobs.isActive ?? false)
                                                            ? Colors.lightGreen
                                                            : Colors.redAccent,
                                                        jobId: jobs.jobId.toString(),
                                                        isActive: jobs.isActive.toString(),
                                                        size: size,
                                                        onTap: ()async {
                                                          await jobController.getJobsById(jobs.jobId.toString(), context);
                                                          Get.toNamed('/createJobAdminPage');
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                
                                      jobController.webinarList.isEmpty ?
                                      buildShimmerEmptyWidget(size)
                                          : AnimationLimiter(
                                            child: ListView.builder(
                                              itemCount: jobController.webinarList.length,
                                              key: ValueKey(jobController.webinarList.length),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              itemBuilder: (context, index) {
                                                final webinars = jobController.webinarList[index];
                                                final created = DateTime.parse(webinars.createdDate.toString());
                                                final postedAgo = timeAgo(created);
                                                return Padding(
                                                  padding: const EdgeInsets.only(bottom: 12),
                                                  child: AnimationConfiguration.staggeredList(
                                                    position: index,
                                                    duration: const Duration(milliseconds: 1300),
                                                    child: SlideAnimation(
                                                      verticalOffset: 120.0,
                                                      curve: Curves.easeOutBack,
                                                      child: FadeInAnimation(
                                                        child: GestureDetector(
                                                          onTap: () async{
                                                            print('web view id${webinars.webinarId.toString()}');
                                                            Api.userInfo.write('webinarId',webinars.webinarId.toString());
                                                            Get.toNamed('/viewWebinarPage');
                                                          },
                                                          child: JobCard(
                                                            title: webinars.webinarTitle.toString(),
                                                            description:"Posted On: ${formatDate1("${webinars.createdDate}")}",
                                                            jobType: "",
                                                            appliedCount: webinars.totalApplicants.toString()??'0',
                                                            postedAgo: postedAgo,
                                                            status: webinars.isActive == true
                                                                ? "Open"
                                                                : "Close",
                                                            statusColor: webinars.isActive == true
                                                                ? Colors.lightGreen
                                                                : Colors.redAccent,
                                                            jobId: webinars.webinarId.toString(),
                                                            isActive: webinars.isActive.toString(),
                                                            size: size,
                                                            onTap: () {
                                                              jobController.getWebinarById(
                                                                webinars.webinarId.toString(),
                                                                webinars.isActive.toString(),
                                                                context);
                                                              Get.toNamed(
                                                                '/createJobAdminPage',
                                                                arguments: {
                                                                  "selectedString": "Webinar"
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                ),
              ),
            ),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String description;
  final String jobType;
  final String appliedCount;
  final String postedAgo;
  final String status;
  final Color statusColor;
  final String jobId;
  final String isActive;
  final double size;
  final VoidCallback onTap;

   JobCard({
    super.key,
    required this.title,
    required this.description,
    required this.jobType,
    required this.appliedCount,
    required this.postedAgo,
    required this.status,
    required this.statusColor,
     required this.jobId,required this.isActive,
    required this.size,
     required this.onTap
  });
  final jobController=Get.put(JobController());
  @override
  Widget build(BuildContext context) {
    final bool isWebinar = jobType.trim().isEmpty;
    return GetBuilder<JobController>(
      builder: (controller) {
        return _HoverLift(
          liftScale: 1.015,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isWebinar
                                      ? const [Color(0xFF06B6D4), Color(0xFF67E8F9)]
                                      : const [AppColors.primary, AppColors.secondary],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isWebinar ? Icons.video_camera_front_outlined : Icons.work_outline_rounded,
                                color: Colors.white,
                                size: size*0.04,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title,softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body(
                                  context,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _HoverLift(
                              liftScale: 1.08,
                              borderRadius: BorderRadius.circular(20),
                              child: IconButton(
                                onPressed: onTap,
                                icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: size*0.045),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size * 0.015),
                        if (!isWebinar)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              jobType,softWrap: true,
                              style: AppTextStyles.caption(
                                context,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Text(
                          description,
                          softWrap: true,maxLines: 2,
                          style: AppTextStyles.caption(context, color: AppColors.grey,fontWeight: FontWeight.normal),
                        ),
                        SizedBox(height: size * 0.015),
                        Row(
                          children: [
                            Icon(Icons.people_alt_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "$appliedCount Applied",
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.access_time_rounded, size: 14, color: AppColors.grey),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                postedAgo,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption(context, color: AppColors.grey),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor.withOpacity(0.4)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              child: Text(
                                status,
                                style: AppTextStyles.caption(
                                  context,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              ),
            ),
          ),
        );
      }
    );
  }
}
