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
import '../../web_modules/common/common_side_bar.dart';

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
    await jobController.getJobSeekersAppliedLists(
      Api.userInfo.read('userId') ?? "",
      context,
    );
    await jobController.getWebinarListJobSeekers('', '', context);
    await notificationController.getNotificationListAdmin(context);
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
      backgroundColor: Colors.grey.shade100,
      drawer: !isDesktop
          ? Drawer(width: 250, child: SettingsSidebarDrawer())
          : null,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
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
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: size * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              Api.userInfo.read('personName') ?? "",
              style: TextStyle(
                fontSize: size * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const JobSeekerProfilePage(),
                ),
              );
            },
            child: ProfileImageWidget(size: size),
          ),
        ),
        actions: [
          GetBuilder<NotificationController>(
            builder: (controller) {
              return Stack(
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
                      top: 0,
                      right: 15,
                      child: CircleAvatar(
                        radius: size * 0.024,
                        backgroundColor: Colors.redAccent,
                        child: Text(
                          notificationController.unreadCount.toString() ?? "",
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: size * 0.025,
                          ),
                        ),
                      ),
                    ),
                ],
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
                  Container(
                    //margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    //padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.15),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    height: size * 0.23,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.15),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        height: size * 0.012,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
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

                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.white,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 1.3,
                                  ),
                                ),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () {
                                      _scaffoldKeyJobs.currentState!
                                          .openDrawer();
                                    },
                                    icon: Icon(
                                      Icons.filter_alt,
                                      color: Colors.black,
                                      size: size * 0.05,
                                    ),
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

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Let Find a Job With LYD',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: size * 0.045,
                          ),
                        ),
                        //  Text('With LYD',textAlign:TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: size*0.05),),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Popular Jobs/Webinars Posts',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: size * 0.035,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
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
                                  "View Webinars",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: size * 0.03,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // DashboardCarousel(
                        //   imageList: planController.editUploadImage
                        //       .map((e) => e.url ?? '')
                        //       .where((url) => url.isNotEmpty)
                        //       .toList(),
                        // ),
                        GetBuilder<JobController>(
                          builder: (controller) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                // Automatically switches between 2 or 4 columns based on available width
                                int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

                                return GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.6, // Adjust this ratio to control card height
                                  children: [
                                    _buildRowCard(
                                      title: "Applied",
                                      count: controller.appliedCount.toString(),
                                      icon: Icons.work_outline,
                                      color: Colors.blue,
                                    ),
                                    _buildRowCard(
                                      title: "Shortlisted",
                                      count: controller.shortlistedCount.toString(),
                                      icon: Icons.star_border_rounded,
                                      color: Colors.orange,
                                    ),
                                    _buildRowCard(
                                      title: "Rejected",
                                      count: controller.rejectedCount.toString(),
                                      icon: Icons.cancel_outlined,
                                      color: Colors.red,
                                    ),
                                    _buildRowCard(
                                        title: "Viewed",
                                      count: controller.viewedCount.toString(),
                                      icon: Icons.hourglass_empty_rounded,
                                      color: Colors.amber,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Find your Top Jobs',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: size * 0.035,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
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
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                            height: size * 0.55,
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
                                          padding: const EdgeInsets.all(10.0),
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
                                            child: Container(
                                              width: size * 0.8,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: AppColors.white,
                                                border: Border.all(
                                                  color: AppColors.primary,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  10.0,
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
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      Jobs.jobType
                                                                          .toString(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            size *
                                                                            0.03,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Flexible(
                                                                    child: Text(
                                                                      postedAgo,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            size *
                                                                            0.03,
                                                                        fontWeight:
                                                                            FontWeight.normal,
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
                                                    const SizedBox(height: 2),
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
                                                    Jobs.totalApplicants != 0
                                                        ? Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    5.0,
                                                                  ),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
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
                                                                height:
                                                                    size * 0.07,
                                                                width:
                                                                    size * 0.3,
                                                                child: Center(
                                                                  child: Text(
                                                                    '${Jobs.totalApplicants} Applied',
                                                                    softWrap:
                                                                        true,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          size *
                                                                          0.035,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Text(
                                                              'Be a early Applicant',
                                                              softWrap: true,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    size *
                                                                    0.035,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Colors
                                                                    .black54,
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
                                  );
                                },
                              ),
                            ),
                          ),
                        Text(
                          'Applied Jobs Lists',
                          style: TextStyle(
                            fontSize: size * 0.035,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (jobController.isLoading)
                          _buildShimmerAppliedJobs(size)
                        else if (jobController.jobSeekersAppliedLists.isEmpty)
                          _buildShimmerAppliedJobs(size)
                        // Center(child: Text("No applied jobs found", style: AppTextStyles.caption(context)))
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
                                        padding: const EdgeInsets.all(10.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            jobController.getJobsById(
                                              appliedJobs.jobId!,
                                              context,
                                            );
                                            Get.toNamed('/jobViewProfilePage');
                                          },
                                          child: Container(
                                            width: size,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withValues(
                                                    alpha: 0.1,
                                                  ),
                                                  spreadRadius: 1,
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // Container(
                                                      //     width: size * 0.22,
                                                      //     height: size * 0.22,
                                                      //     clipBehavior: Clip.hardEdge,
                                                      //     decoration: BoxDecoration(
                                                      //       borderRadius: BorderRadius.circular(10),
                                                      //       color: Colors.white,
                                                      //     ),
                                                      //     child: Image.network(
                                                      //       logoUrl ?? "",
                                                      //       fit: BoxFit.cover,
                                                      //       width: size * 0.26,
                                                      //       height: size * 0.26,
                                                      //       errorBuilder: (context, error, stackTrace) {
                                                      //         return Container(
                                                      //           decoration: BoxDecoration(
                                                      //             color: getRandomColor(appliedJobs.orgName.toString()),
                                                      //           ),
                                                      //           width: size * 0.12,
                                                      //           height: size * 0.12,
                                                      //           child: Center(
                                                      //             child: Text(
                                                      //               getFirstLetter(appliedJobs.orgName.toString()),
                                                      //               style: AppTextStyles.headline(context, color: AppColors.white),
                                                      //             ),
                                                      //           ),
                                                      //         );
                                                      //       },
                                                      //     )),
                                                      Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors
                                                                  .grey
                                                                  .shade100,
                                                            ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                12,
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
                                                            Text(
                                                              appliedJobs
                                                                      .orgName
                                                                      .toString() ??
                                                                  "N/A",
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
                                                            Text(
                                                              appliedJobs
                                                                      .jobType
                                                                      .toString() ??
                                                                  "N/A",
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
                                                            const SizedBox(
                                                              height: 5,
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
                                                            Align(
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      5.0,
                                                                    ),
                                                                child: Text(
                                                                  'Posted On ${DateFormat('MMM dd, yyyy').format(DateTime.parse(appliedJobs.createdDate.toString()))}',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        size *
                                                                        0.025,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    color: Colors
                                                                        .black54,
                                                                  ),
                                                                ),
                                                              ),
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
      height: size * 0.55,
      child: ListView.builder(
        itemCount: 3,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(10.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: size * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
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
        padding: const EdgeInsets.all(10.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: size * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border(
        left: BorderSide(color: color, width: 4),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Row(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ],
    ),
  );
}