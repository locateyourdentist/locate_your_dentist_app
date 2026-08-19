import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_drawer.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/modules/profiles/jobseeker_viewprofile.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../common_widgets/common_sidebar_mobile.dart';

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

Widget _sectionHeading(BuildContext context, {required IconData icon, required String text}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption(context, color: AppColors.black, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}

class JobSeekerDashboard extends StatefulWidget {
  const JobSeekerDashboard({super.key});
  @override
  State<JobSeekerDashboard> createState() => _JobSeekerDashboardState();
}

class _JobSeekerDashboardState extends State<JobSeekerDashboard> {
  final List<Color> mildColors = [
    const Color(0xFFE8F0FE),
    const Color(0xFFE9F7EF),
    const Color(0xFFFFF4E6),
    const Color(0xFFFDEEEF),
    const Color(0xFFF3EAFB),
    const Color(0xFFF7F7F7),
  ];
  final TextEditingController searchController = TextEditingController();
  final jobController = Get.put(JobController());
  final loginController = Get.put(LoginController());
  final planController = Get.put(PlanController());
  final notificationController = Get.put(NotificationController());
  int currentIndex = 0;
  bool? isSelected;
  final GlobalKey<ScaffoldState> _scaffoldKeyJobs = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    // await loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
    await jobController.getJobListJobSeekers(
      search: " ",
      jobCategory: loginController.selectedCategories,
      context: context,
    );
    if (!mounted) return;
    await jobController.getJobSeekersAppliedLists(
      Api.userInfo.read('userId') ?? "",
      context,
    );
    if (!mounted) return;
    await jobController.getWebinarListJobSeekers('', '', context);
    if (!mounted) return;
    await notificationController.getNotificationListAdmin(context);
    if (!mounted) return;
    await planController.getUploadImages(
      userType: "Job Seekers",
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    final bool isDesktop = size >= 1100;
    String getFirstLetter(String text) {
      if (text.isEmpty) return "";
      return text[0].toUpperCase();
    }

    return Scaffold(
      key: _scaffoldKeyJobs,
      backgroundColor: const Color(0xFFF6F8FC),
      drawer: !isDesktop
          ? Drawer(width: 250, child: SettingsSidebarDrawer())
          : null,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(1)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(1)),
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: size * 0.032,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            Text(
              Api.userInfo.read('personName') ?? "",
              style: TextStyle(
                fontSize: size * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _HoverLift(
            liftScale: 1.08,
            borderRadius: BorderRadius.circular(50),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const JobSeekerProfilePage(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                ),
                child: ProfileImageWidget(size: size),
              ),
            ),
          ),
        ),
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
                        Get.toNamed('/notificationPage');
                        notificationController.update();
                      },
                    ),
                    if (int.tryParse(notificationController.unreadCount ?? "0")! >
                        0)
                      Positioned(
                        top: 4,
                        right: 12,
                        child: CircleAvatar(
                          radius: size * 0.024,
                          backgroundColor: Colors.redAccent,
                          child: Text(
                            notificationController.unreadCount.toString(),
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: size * 0.025,
                            ),
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
      endDrawer: FilterDrawer(
        onApply: () async {
          print("Selected State: ${loginController.selectedState}");
          print("Selected District: ${loginController.selectedDistrict}");
          print("Selected Area: ${loginController.selectedArea}");

          //String userType=  Api.userInfo.read('sUserType');
          print("ssuser${loginController.selectedState.toString()},");

          await jobController.getWebinarListJobSeekers(
            loginController.selectedState.toString(),
            loginController.selectedDistrict.toString(),
            context,
          );
        },
        onReset: () {
          setState(() {
            // loginController.selectedPlace = null;
            // loginController.selectedDistrict = null;
            loginController.selectedArea = null;
            loginController.selectedUserType = null;
            loginController.selectedState = null;
            loginController.selectedDistrict = null;
            loginController.resetUserTypeFilters();
          });
        },
      ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// HERO + FLOATING SEARCH CARD
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        height: size * 0.28,
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
                                  child: const Icon(
                                    Icons.search,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      hintText:
                                          "Search your job by clinic name,area..",
                                      hintStyle: AppTextStyles.caption(
                                        context,
                                        fontWeight: FontWeight.normal,
                                        color: AppColors.grey,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                    style: AppTextStyles.caption(
                                      context,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    cursorColor: AppColors.primary,
                                    onSubmitted: (value) {
                                      print("Search text: $value");
                                      jobController.getJobListJobSeekers(
                                        search: searchController.text.toString(),
                                        context: context,
                                      );
                                      Get.toNamed('/filterPageJobSeekersPage');
                                    },
                                  ),
                                ),
                                _HoverLift(
                                  liftScale: 1.06,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        _scaffoldKeyJobs.currentState!
                                            .openDrawer();
                                      },
                                      icon: Icon(
                                        Icons.filter_alt,
                                        color: Colors.white,
                                        size: size * 0.05,
                                      ),
                                      splashRadius: 22,
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
                  const SizedBox(height: 44),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Let Find a Job With LYD',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: size * 0.045,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GetBuilder<JobController>(
                          builder: (controller) {
                            return _RevealIn(
                              delay: const Duration(milliseconds: 80),
                              child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Automatically switches between 2 or 4 columns based on available width
                                int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

                                return GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 1.6, // Adjust this ratio to control card height
                                  children: [
                                    _buildRowCard(
                                      title: "Applied",
                                      count: controller.appliedCount.toString(),
                                      icon: Icons.work_outline,
                                      colors: const [AppColors.primary, AppColors.secondary],
                                    ),
                                    _buildRowCard(
                                      title: "Shortlisted",
                                      count: controller.shortlistedCount.toString(),
                                      icon: Icons.star_border_rounded,
                                      colors: const [Color(0xFFF59E0B), Color(0xFFFFC15E)],
                                    ),
                                    _buildRowCard(
                                      title: "Rejected",
                                      count: controller.rejectedCount.toString(),
                                      icon: Icons.cancel_outlined,
                                      colors: const [Color(0xFFFF6B6B), Color(0xFFFF9E9E)],
                                    ),
                                    _buildRowCard(
                                        title: "Viewed",
                                      count: controller.viewedCount.toString(),
                                      icon: Icons.hourglass_empty_rounded,
                                      colors: const [Color(0xFF06B6D4), Color(0xFF67E8F9)],
                                    ),
                                  ],
                                );
                              },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _sectionHeading(context, icon: Icons.local_fire_department_rounded, text: 'Popular Jobs/Webinars Posts'),
                            ),
                            _HoverLift(
                              liftScale: 1.04,
                              borderRadius: BorderRadius.circular(20),
                              child: TextButton(
                                onPressed: () async {
                                  await jobController.getWebinarListJobSeekers(
                                    '',
                                    '',
                                    context,
                                  );
                                  Get.toNamed('/viewWebinarListJobseekersPage');
                                },
                                child: Text(
                                  "Webinars",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: size * 0.03,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _sectionHeading(context, icon: Icons.trending_up_rounded, text: 'Find your Top Jobs'),
                            ),
                            _HoverLift(
                              liftScale: 1.04,
                              borderRadius: BorderRadius.circular(20),
                              child: TextButton(
                                onPressed: () {
                                  jobController.getJobListJobSeekers(
                                    search: searchController.text.toString(),
                                    context: context,
                                  );
                                  Get.toNamed('/filterPageJobSeekersPage');
                                },
                                child: Text(
                                  "View All",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: size * 0.03,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (jobController.isLoading)
                          _buildShimmerPopularJobs(size)
                        else if (jobController.jobListJobSeekers.isEmpty)
                          Center(
                            child: Text(
                              'No Preference Jobs found',
                              style: AppTextStyles.caption(context),
                            ),
                          )
                        else
                          SizedBox(
                            height: size * 0.6,
                            child: AnimationLimiter(
                              child: ListView.builder(
                                itemCount:
                                    jobController.jobListJobSeekers.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  final Jobs =
                                      jobController.jobListJobSeekers[index];
                                  final logoUrl =
                                      (Jobs.logoImage != null &&
                                          Jobs.logoImage!.isNotEmpty)
                                      ? Jobs.logoImage!.first
                                      : null;
                                  final created = DateTime.parse(
                                    Jobs.createdDate.toString(),
                                  );
                                  final postedAgo = timeAgo(created);
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(
                                      milliseconds: 1300,
                                    ),
                                    child: SlideAnimation(
                                      horizontalOffset: 120.0,
                                      curve: Curves.easeOutBack,
                                      child: FadeInAnimation(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              Api.userInfo.write(
                                                'selectJobId',
                                                Jobs.jobId!,
                                              );
                                              Get.toNamed(
                                                '/jobViewProfilePage',
                                              );
                                              isSelected =
                                                  currentIndex == index;
                                            },
                                            child: _HoverLift(
                                              liftScale: 1.02,
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                              width: size * 0.8,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: AppColors.white,
                                                border: Border.all(
                                                  color: Colors.grey.shade100,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  14.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: size * 0.063,
                                                          backgroundColor:
                                                              AppColors.primary,
                                                          child: ClipOval(
                                                            child: Image.network(
                                                              logoUrl ?? "",
                                                              fit: BoxFit.cover,
                                                              width:
                                                                  size * 0.14,
                                                              height:
                                                                  size * 0.12,
                                                              errorBuilder:
                                                                  (
                                                                    context,
                                                                    error,
                                                                    stackTrace,
                                                                  ) {
                                                                    return CircleAvatar(
                                                                      radius:
                                                                          size *
                                                                          0.063,
                                                                      backgroundColor: getRandomColor(
                                                                        Jobs.orgName
                                                                            .toString(),
                                                                      ),
                                                                      child: Text(
                                                                        getFirstLetter(
                                                                          Jobs.orgName
                                                                              .toString(),
                                                                        ),
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              size *
                                                                              0.04,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                Jobs.orgName
                                                                    .toString(),
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      size *
                                                                      0.035,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              Container(
                                                                margin: const EdgeInsets.only(top: 3),
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                                decoration: BoxDecoration(
                                                                  color: AppColors.primary.withOpacity(0.08),
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: Text(
                                                                  Jobs.jobType
                                                                      .toString(),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        size *
                                                                        0.028,
                                                                    fontWeight:
                                                                        FontWeight.w600,
                                                                    color: AppColors
                                                                        .primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Text(
                                                          postedAgo,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style: TextStyle(
                                                            fontSize:
                                                                size * 0.026,
                                                            fontWeight:
                                                                FontWeight.normal,
                                                            color: Colors
                                                                .grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      Jobs.jobTitle.toString(),
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: size * 0.032,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          color: Colors.grey,
                                                          size: size * 0.04,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            "${Jobs.city.toString()}, ${Jobs.district.toString()} ,${Jobs.state.toString()}",
                                                            softWrap: true,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  size * 0.03,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .currency_rupee_rounded,
                                                          color: Colors.grey,
                                                          size: size * 0.04,
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            Jobs.salary
                                                                .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  size * 0.03,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Jobs.totalApplicants != 0
                                                        ? Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        20,
                                                                      ),
                                                                  gradient: const LinearGradient(
                                                                    colors: [
                                                                      AppColors
                                                                          .primary,
                                                                      AppColors
                                                                          .secondary,
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                  ),
                                                                ),
                                                                padding: EdgeInsets.symmetric(horizontal: size*0.03, vertical: size*0.015),
                                                                child: Text(
                                                                    '${Jobs.totalApplicants} Applied',
                                                                    softWrap:
                                                                        true,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          size *
                                                                          0.03,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                ),
                                                            ),
                                                          )
                                                        : Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: Text(
                                                              'Be a early Applicant',
                                                              softWrap: true,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    size *
                                                                    0.03,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 22),
                        _sectionHeading(context, icon: Icons.assignment_turned_in_outlined, text: 'Applied Jobs Lists'),
                        const SizedBox(height: 12),
                        if (jobController.isLoading)
                          _buildShimmerAppliedJobs(size)
                        else if (jobController.jobSeekersAppliedLists.isEmpty)
                          _buildShimmerAppliedJobs(size)
                        else
                          AnimationLimiter(
                            child: ListView.builder(
                              itemCount:
                                  jobController.jobSeekersAppliedLists.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                final appliedJobs =
                                    jobController.jobSeekersAppliedLists[index];
                                final logoUrl =
                                    (appliedJobs.logoImage != null &&
                                        appliedJobs.logoImage!.isNotEmpty)
                                    ? appliedJobs.logoImage!.first
                                    : null;
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 1300),
                                  child: SlideAnimation(
                                    verticalOffset: 120.0,
                                    curve: Curves.easeOutBack,
                                    child: FadeInAnimation(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            jobController.getJobsById(
                                              appliedJobs.jobId!,
                                              context,
                                            );
                                            Get.toNamed('/jobViewProfilePage');
                                          },
                                          child: _HoverLift(
                                            liftScale: 1.015,
                                            borderRadius: BorderRadius.circular(18),
                                            child: Container(
                                            width: size,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18),
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
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                14.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: 54,
                                                        height: 54,
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)]),
                                                            ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                11,
                                                              ),
                                                          child: Image.asset(
                                                            'assets/images/tooth.png',
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    appliedJobs
                                                                            .orgName
                                                                            .toString() ??
                                                                        "N/A",
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          size *
                                                                          0.035,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'Posted On ${DateFormat('MMM dd, yyyy').format(DateTime.parse(appliedJobs.createdDate.toString()))}',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        size *
                                                                        0.024,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    color: Colors
                                                                        .black45,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              margin: const EdgeInsets.symmetric(vertical: 3),
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: AppColors.primary.withOpacity(0.08),
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Text(
                                                                appliedJobs
                                                                        .jobType
                                                                        .toString() ??
                                                                    "N/A",
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      size * 0.028,
                                                                  fontWeight:
                                                                      FontWeight.w600,
                                                                  color:
                                                                      AppColors.primary,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              appliedJobs
                                                                      .jobTitle
                                                                      .toString() ??
                                                                  "N/A",
                                                              softWrap: true,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    size *
                                                                    0.032,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .location_on_rounded,
                                                                  color: Colors
                                                                      .grey,
                                                                  size:
                                                                      size *
                                                                      0.04,
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    "${appliedJobs.city.toString() ?? "N/A"},${appliedJobs.district.toString() ?? "N/A"}",
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          size *
                                                                          0.03,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .currency_rupee_rounded,
                                                                  color: Colors
                                                                      .grey,
                                                                  size:
                                                                      size *
                                                                      0.04,
                                                                ),
                                                                Flexible(
                                                                  child: Text(
                                                                    appliedJobs
                                                                            .salary
                                                                            .toString() ??
                                                                        "N/A",
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          size *
                                                                          0.03,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            ),
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
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildShimmerPopularJobs(double size) {
    return SizedBox(
      height: size * 0.6,
      child: ListView.builder(
        itemCount: 3,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: size * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerAppliedJobs(double size) {
    return ListView.builder(
      itemCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: size * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildRowCard({
  required String title,
  required String count,
  required IconData icon,
  required List<Color> colors,
}) {
  return _HoverLift(
    liftScale: 1.03,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
