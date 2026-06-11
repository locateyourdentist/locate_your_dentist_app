import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../common_widgets/color_code.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_quill/flutter_quill.dart';



class ViewJobWebinarWebPage extends StatefulWidget {
  const ViewJobWebinarWebPage({super.key});

  @override
  State<ViewJobWebinarWebPage> createState() => _ViewJobWebinarWebPageState();
}

class _ViewJobWebinarWebPageState extends State<ViewJobWebinarWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKeyJobs = GlobalKey<ScaffoldState>();
  final jobController=Get.put(JobController());
  final loginController=Get.put(LoginController());
  final ScrollController _scrollController = ScrollController();
  late QuillController _controller;
  void loadJobDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [];

      if (data == null) {
        delta = [{"insert": "\n"}];
      }

      else if (data is List) {
        delta = List<Map<String, dynamic>>.from(data);
      }

      else if (data is String) {
        delta = List<Map<String, dynamic>>.from(jsonDecode(data));
      }

      _controller = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );

      if (mounted) setState(() {});
    } catch (e) {
      print("Quill load error: $e");

      _controller = QuillController.basic();
      if (mounted) setState(() {});
    }
  }
  @override
  void initState() {
    _refresh();
    super.initState();
  }
  Future<void> _refresh() async {
    await jobController.getJobListAdmin(context);
    if (jobController.jobList.isNotEmpty) {
      await jobController.getAppliedJobsAdmin(jobController.jobList[0].jobId.toString(), context);
    }
    await jobController.getWebinarListAdmin(context);
  }
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isTablet = width >= 700 && width < 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    final totalApplicants = jobController.jobList.isNotEmpty ? jobController.jobList[0].totalApplicants : 0;
    int shortlistedCount = jobController.jobIdListAdmin.where((e) => e.status == "Shortlisted").length;
    int rejectedCount = jobController.jobIdListAdmin.where((e) => e.status == "Rejected").length;
    String getPlainText(List<Map<String, dynamic>>? delta) {
      if (delta == null) return "";
      return delta.map((e) => e['insert'] ?? "").join();
    }
    return Scaffold(
      key: _scaffoldKeyJobs,
      backgroundColor: AppColors.backGroundColor,
      drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "Job Posts / Webinars",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<JobController>(
          builder: (controller) {
            return Row(
              children: [
                if (isLoggedIn && isDesktop) const AdminSideBar(),

                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: Stack(
                        children: [
                          if (isLoggedIn && !isDesktop)
                            Positioned(
                              top: 10,
                              left: 10,
                              child: IconButton(
                                icon: const Icon(Icons.menu,color: AppColors.black,),
                                onPressed: () => _scaffoldKeyJobs.currentState?.openDrawer(),
                              ),
                            ),
                          NestedScrollView(
                            headerSliverBuilder: (context, innerBoxIsScrolled) => [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(isMobile ? 10 : 20, isLoggedIn && !isDesktop ? 60 : 20, isMobile ? 10 : 20, 20),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 1400),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: const [
                                            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Center(
                                                  child: Text(
                                                    "Last Job Posts Details",
                                                    style: AppTextStyles.body(context, fontWeight: FontWeight.bold, color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Wrap(
                                                  alignment: WrapAlignment.center,
                                                  spacing: 15,
                                                  runSpacing: 15,
                                                  children: [
                                                    SizedBox(
                                                      width: isMobile ? width * 0.85 : (isTablet ? width * 0.25 : width * 0.2),
                                                      child: _statCard(
                                                        title: "Total Applicants",
                                                        value: totalApplicants.toString(),
                                                        icon: Icons.people_alt_outlined,
                                                        color: Colors.blue, context: context
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: isMobile ? width * 0.85 : (isTablet ? width * 0.25 : width * 0.2),
                                                      child: _statCard(
                                                        title: "Shortlisted",
                                                        value: shortlistedCount.toString(),
                                                        icon: Icons.check_circle_outline,
                                                        color: Colors.green, context: context
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: isMobile ? width * 0.85 : (isTablet ? width * 0.25 : width * 0.2),
                                                      child: _statCard(
                                                        title: "Rejected",
                                                        value: rejectedCount.toString(),
                                                        icon: Icons.cancel_outlined,
                                                        color: Colors.redAccent, context: context
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: TextButton.icon(
                                                  onPressed: () {
                                                    jobController.job.clear();
                                                    jobController.webinar.clear();
                                                    loginController.selectedJobType = "";
                                                    jobController.selectedJobId = '';
                                                    jobController.selectedWebinarId = '';
                                                    loginController.typeNameController.clear();
                                                    loginController.jobTitleController.clear();
                                                    loginController.jobDescController.clear();
                                                    loginController.selectedSalary = "";
                                                    loginController.qualificationJobController.clear();
                                                    loginController.selectedExperience = "";
                                                    loginController.webinarTitleJobController.clear();
                                                    loginController.webinarDescriptionJobController.clear();
                                                    loginController.webinarLinkController.clear();
                                                    loginController.webinarDateController.clear();
                                                    loginController.startHour = '';
                                                    loginController.startMinutes = "";
                                                    loginController.startPeriod = "";
                                                    loginController.endHour = "";
                                                    loginController.endMinutes = "";
                                                    loginController.endPeriod = "";
                                                    jobController.webinarImage = "";
                                                    jobController.jobImage = "";
                                                    jobController.selectedWebinarId = "0";
                                                    jobController.selectedJobId = "0";
                                                    loginController.update();
                                                    jobController.update();
                                                    Get.toNamed('/createJobWebPage', arguments: {'job': 'new'});
                                                  },
                                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                                  label: Text(
                                                    "Create Job/Webinars",
                                                    style: AppTextStyles.body(context, fontWeight: FontWeight.bold, color: AppColors.primary),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Center(
                                                child: Container(
                                                  height: 45,
                                                  width: isMobile ? width * 0.9 : 400,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    color: Colors.grey.shade100
                                                  ),
                                                  child: TabBar(
                                                    indicatorSize: TabBarIndicatorSize.tab,
                                                    dividerColor: Colors.transparent,
                                                    indicator: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      gradient: const LinearGradient(
                                                        colors: [AppColors.primary, AppColors.secondary],
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
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            body: TabBarView(
                              children: [
                                _buildJobGrid(context, isMobile, isTablet, getPlainText),
                                _buildWebinarGrid(context, isMobile, isTablet, getPlainText),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }

  Widget _buildJobGrid(BuildContext context, bool isMobile, bool isTablet, String Function(List<Map<String, dynamic>>?) getPlainText) {
    if (jobController.jobList.isEmpty) return _emptyState(context);
    
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: isMobile ? 1.8 : (isTablet ? 2.2 : 2.7),
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
                  onTap: () {
                    Api.userInfo.write('selectJobId', jobs.jobId.toString());
                    Api.userInfo.write('activeStatus', jobs.isActive.toString());
                    Get.toNamed('/viewJobDetailWebPage');

                  },
                  child: _modernCard(
                    title: jobs.jobTitle ?? "",
                    desc:  "Posted On: ${formatDate1("${jobs.createdDate}")}",
                    status: (jobs.isActive ?? false) ? "Open" : "Closed",
                    statusColor: (jobs.isActive ?? false) ? Colors.green : Colors.red,
                    subtitle: jobs.jobType ?? "",
                    trailing: "${jobs.totalApplicants} Applicants",
                    onTap: () async {
                      await jobController.getJobsById(jobs.jobId.toString(), context);
                      Get.toNamed('/createJobWebPage');
                      print('${jobs.createdDate}gfdg');
                    },
                    context: context
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWebinarGrid(BuildContext context, bool isMobile, bool isTablet, String Function(List<Map<String, dynamic>>?) getPlainText) {
    if (jobController.webinarList.isEmpty) return _emptyState(context);

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: isMobile ? 1.8 : (isTablet ? 2.2 : 3),
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
                    Api.userInfo.write('webinarId', webinars.webinarId.toString());
                    Api.userInfo.write('activeStatus1', webinars.isActive.toString());
                    await jobController.getWebinarById(webinars.webinarId.toString(), webinars.isActive.toString(), context);
                    Get.toNamed('/viewWebinarDetailWebPage');
                  },
                  child: _modernCard(
                    title: webinars.webinarTitle ?? "",
                      desc: "Posted On: ${formatDate1("${webinars.createdDate}")}",
                      // desc: getPlainText(webinars.webinarDescription),
                    status: webinars.isActive == true ? "Open" : "Closed",
                    statusColor: webinars.isActive == true ? Colors.green : Colors.red,
                    subtitle: "Webinar",
                    trailing: "${webinars.totalApplicants ?? 0} Joined",
                    onTap: () async {
                      Api.userInfo.write('webinarId', webinars.webinarId.toString());
                      Api.userInfo.write('activeStatus1', webinars.isActive.toString());
                      Get.toNamed('/createJobWebPage', arguments: {"selectedString": "Webinar"});
                    },
                    context: context
                  ),
                ),
              ),
            ),
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
  required context
}) {
  final double size = MediaQuery.of(context).size.width;
  final bool isMobile = size < 700;
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
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
                style: AppTextStyles.caption(context, fontWeight: FontWeight.bold, color: AppColors.black),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: AppTextStyles.caption(context, color: statusColor, fontWeight: FontWeight.w600),
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
                style: AppTextStyles.caption(context, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_note, color: AppColors.primary, size: isMobile ? 22 : 24),
              onPressed: onTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Text(
            desc,
            maxLines: isMobile ? 2 : 3,
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
                style: AppTextStyles.caption(context, fontWeight: FontWeight.w500, color: AppColors.secondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward, size: 16, color: AppColors.grey),
          ],
        )
      ],
    ),
  );
}

Widget _emptyState(dynamic context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
        const SizedBox(height: 15),
        Text("No data found", style: AppTextStyles.body(context, color: Colors.grey)),
      ],
    ),
  );
}

Widget _statCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
  required BuildContext context
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.caption(context, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.body(context, fontWeight: FontWeight.bold, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
String formatDate1(dynamic isoDate) {
  if (isoDate == null) return "N/A";

  try {
    if (isoDate is DateTime) {
      return DateFormat('MMM dd, yyyy').format(isoDate);
    }

    if (isoDate is String) {
      if (isoDate.trim().isEmpty) return "N/A";

      String cleanStr = isoDate.trim().replaceAll('"', '');
      final date = DateTime.parse(cleanStr);
      return DateFormat('MMM dd, yyyy').format(date);
    }

    return "N/A";
  } catch (e) {
    print("Date Error Parsing ($isoDate): $e");
    return "N/A";
  }
}