import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/job_seekers/view_jobWebinar_web.dart';
import 'package:shimmer/shimmer.dart';

class DentalClinicDashboardWebPage extends StatefulWidget {
  const DentalClinicDashboardWebPage({super.key});
  @override
  State<DentalClinicDashboardWebPage> createState() =>
      _DentalClinicDashboardWebPageState();
}

class _DentalClinicDashboardWebPageState
    extends State<DentalClinicDashboardWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  final jobController = Get.put(JobController());
  final loginController = Get.put(LoginController());
  final notificationController = Get.put(NotificationController());
  final planController = Get.put(PlanController());
  List<ProfileModel> filteredProfiles = [];
  List<String> title = [
    "Dental Shop",
    "Dental Lab",
    "Dental Mechanic",
    "Dental Consultant",
    "Job Posts/Webinars",
  ];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await jobController.getJobListAdmin(context);
    await jobController.getWebinarListAdmin(context);
    await notificationController.getNotificationListAdmin(context);
    await planController.checkPlansStatus(
      Api.userInfo.read('userId') ?? "",
      context,
    );
  }

  String getPlainText(List<Map<String, dynamic>>? delta) {
    if (delta == null) return "";
    return delta.map((e) => e['insert'] ?? "").join();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,
      drawer: (isLoggedIn && !isDesktop)
          ? const Drawer(width: 250, child: AdminSideBar())
          : null,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          return Row(
            children: [
              if (isLoggedIn && isDesktop) const AdminSideBar(),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: DefaultTabController(
                    length: 2,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 10.0 : 30.0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 15.0 : 30.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isDesktop)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 15.0,
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.menu,
                                                color: AppColors.black,
                                              ),
                                              onPressed: () => _scaffoldKey
                                                  .currentState
                                                  ?.openDrawer(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        width: isMobile
                                            ? double.infinity
                                            : width * 0.35,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withValues(
                                                alpha: 0.15,
                                              ),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: CommonSearchTextField(
                                          controller: searchController,
                                          hintText:
                                              "Search by userType, name, userId, Mobile number",
                                          onSubmitted: (value) async {
                                            await loginController
                                                .getProfileDetails(
                                                  '',
                                                  '',
                                                  [],
                                                  [],
                                                  [],
                                                  'true',
                                                  '',
                                                  '',
                                                  '',
                                                  value,
                                                  context,
                                                );
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                                  Get.toNamed(
                                                    '/userTypeListWeb',
                                                  );
                                                });
                                          },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),
                                    Text(
                                      'What are you looking for?',
                                      style: AppTextStyles.subtitle(context),
                                    ),
                                    const SizedBox(height: 20),

                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        double w = constraints.maxWidth;
                                        int crossAxisCount = w < 500
                                            ? 2
                                            : (w < 800
                                                  ? 3
                                                  : (w < 1200 ? 4 : 5));
                                        double childAspectRatio = w < 500
                                            ? 1
                                            : (w < 800
                                                  ? 0.85
                                                  : (w < 1200 ? 0.95 : 1.0));
                                        return GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: title.length,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossAxisCount,
                                                crossAxisSpacing: 16,
                                                mainAxisSpacing: 16,
                                                childAspectRatio:
                                                    childAspectRatio,
                                              ),
                                          itemBuilder: (context, index) {
                                            return _dashboardTile(
                                              title: title[index],
                                              image: imgUserType(title[index]),
                                              context: context,
                                              onTap: () async {
                                                if (title[index] ==
                                                    "Job Posts/Webinars") {
                                                  Get.toNamed(
                                                    '/viewJobWebinarWebPage',
                                                  );
                                                } else {
                                                  Api.userInfo.write(
                                                    'sUserType1',
                                                    title[index],
                                                  );
                                                  await loginController
                                                      .getProfileDetails(
                                                        title[index],
                                                        '',
                                                        [],
                                                        [],
                                                        [],
                                                        'true',
                                                        '',
                                                        '',
                                                        '',
                                                        '',
                                                        context,
                                                      );
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback((
                                                        _,
                                                      ) {
                                                        Get.toNamed(
                                                          '/userTypeListWeb',
                                                        );
                                                      });
                                                }
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 30),
                                    Text(
                                      'Jobs & Webinars',
                                      style: AppTextStyles.subtitle(
                                        context,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: Container(
                                        width: isMobile ? double.infinity : 400,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: Colors.grey.shade100,
                                        ),
                                        child: TabBar(
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,
                                          dividerColor: Colors.transparent,
                                          indicator: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            gradient: const LinearGradient(
                                              colors: [
                                                AppColors.primary,
                                                AppColors.secondary,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          labelColor: AppColors.white,
                                          unselectedLabelColor: AppColors.black,
                                          tabs: const [
                                            Tab(text: 'Jobs'),
                                            Tab(text: 'Webinars'),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.9,
                                      child: TabBarView(
                                        children: [
                                          _buildJobGrid(
                                            context,
                                            controller,
                                            getPlainText,
                                          ),
                                          _buildWebinarGrid(
                                            context,
                                            controller,
                                            getPlainText,
                                          ),
                                        ],
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJobGrid(
    BuildContext context,
    JobController controller,
    String Function(List<Map<String, dynamic>>?) getPlainText,
  ) {
    if (controller.isLoading) return _shimmerGrid(context);
    if (jobController.jobList.isEmpty)
      return _buildEmptyStateWithShimmer(context);
    return AnimationLimiter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double w = constraints.maxWidth;
          int crossAxisCount = w < 600 ? 1 : (w < 900 ? 2 : (w < 1200 ? 3 : 4));
          double aspectRatio = w < 600
              ? 1.9
              : (w < 900 ? 1.8 : (w < 1200 ? 2.0 : 2.2));
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: aspectRatio,
            ),
            itemCount: jobController.jobList.length,
            itemBuilder: (context, index) {
              final jobs = jobController.jobList[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 1000),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: InkWell(
                      onTap: () async {
                        Api.userInfo.write(
                          'selectJobId',
                          jobs.jobId.toString(),
                        );
                        Api.userInfo.write(
                          'activeStatus',
                          jobs.isActive.toString(),
                        );
                        Get.toNamed('/viewJobDetailWebPage');
                      },
                      child: _modernCard(
                        title: jobs.jobTitle ?? "",
                        desc:
                            "Posted On: ${formatDate1("${jobs.createdDate}")}",
                        status: (jobs.isActive ?? false) ? "Open" : "Closed",
                        statusColor: (jobs.isActive ?? false)
                            ? Colors.green
                            : Colors.red,
                        subtitle: jobs.jobType ?? "",
                        trailing: "${jobs.totalApplicants} Applicants",
                        onTap: () async {
                          await jobController.getJobsById(
                            jobs.jobId.toString(),
                            context,
                          );
                          Get.toNamed('/createJobWebPage');
                        },
                        context: context,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWebinarGrid(
    BuildContext context,
    JobController controller,
    String Function(List<Map<String, dynamic>>?) getPlainText,
  ) {
    if (controller.isLoading) return _shimmerGrid(context);
    if (jobController.webinarList.isEmpty)
      return _buildEmptyStateWithShimmer(context);
    return AnimationLimiter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double w = constraints.maxWidth;
          int crossAxisCount = w < 600 ? 1 : (w < 900 ? 2 : (w < 1200 ? 3 : 4));
          double aspectRatio = w < 600
              ? 1.9
              : (w < 900 ? 1.8 : (w < 1200 ? 2.0 : 2.2));
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: aspectRatio,
            ),
            itemCount: jobController.webinarList.length,
            itemBuilder: (context, index) {
              final webinars = jobController.webinarList[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 1000),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: GestureDetector(
                      onTap: () async {
                        Api.userInfo.write(
                          'webinarId',
                          webinars.webinarId.toString(),
                        );
                        Api.userInfo.write(
                          'activeStatus1',
                          webinars.isActive.toString(),
                        );
                        Get.toNamed('/viewWebinarDetailWebPage');
                      },
                      child: _modernCard(
                        title: webinars.webinarTitle ?? "",
                        desc:
                            "Posted On: ${formatDate1("${webinars.createdDate}")}",
                        status: webinars.isActive == true ? "Open" : "Closed",
                        statusColor: webinars.isActive == true
                            ? Colors.green
                            : Colors.red,
                        subtitle: "Webinar",
                        trailing: "${webinars.totalApplicants ?? 0} Joined",
                        onTap: () async {
                          await jobController.getWebinarById(
                            webinars.webinarId.toString(),
                            webinars.isActive.toString(),
                            context,
                          );
                          Get.toNamed(
                            '/createJobWebPage',
                            arguments: {"selectedString": "Webinar"},
                          );
                        },
                        context: context,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Widget _modernCard({
  required String title,
  required String desc,
  required String status,
  required Color statusColor,
  required String subtitle,
  required String trailing,
  required VoidCallback onTap,
  required BuildContext context,
}) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
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
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(
                  context,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: AppTextStyles.caption(
                  context,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                subtitle,
                style: AppTextStyles.caption(
                  context,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_note,
                color: AppColors.primary,
                size: 24,
              ),
              onPressed: onTap,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context, color: Colors.grey.shade700),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                trailing,
                style: AppTextStyles.caption(
                  context,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward, size: 16, color: AppColors.grey),
          ],
        ),
      ],
    ),
  );
}

Widget _buildEmptyStateWithShimmer(BuildContext context) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          const Text(
            "No data found",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

Widget _shimmerCard(BuildContext context) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 14, width: 120, color: Colors.white),
              Container(height: 20, width: 60, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 12, width: 80, color: Colors.white),
              Container(height: 20, width: 20, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 10, width: double.infinity, color: Colors.white),
          const SizedBox(height: 6),
          Container(height: 10, width: double.infinity, color: Colors.white),
          const SizedBox(height: 6),
          Container(height: 10, width: 150, color: Colors.white),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 12, width: 100, color: Colors.white),
              Container(height: 12, width: 12, color: Colors.white),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _shimmerGrid(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double w = constraints.maxWidth;
      int crossAxisCount = w < 600 ? 1 : (w < 900 ? 2 : (w < 1200 ? 3 : 4));
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.8,
        ),
        itemBuilder: (context, index) => _shimmerCard(context),
      );
    },
  );
}

Widget _dashboardTile({
  required String title,
  required String image,
  required VoidCallback onTap,
  required BuildContext context,
}) {
  final double size = MediaQuery.of(context).size.width;
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                image,
                height: size < 700 ? (size * 0.65) : 300.0,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(
                context,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}
