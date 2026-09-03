import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/common/filter_side_bar.dart';

class JobSeekerFilterWeb extends StatefulWidget {
  const JobSeekerFilterWeb({super.key});
  @override
  State<JobSeekerFilterWeb> createState() => _JobSeekerFilterWebState();
}

class _JobSeekerFilterWebState extends State<JobSeekerFilterWeb> {
  final jobController = Get.put(JobController());
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeyJobList =
      GlobalKey<ScaffoldState>();
  final loginController = Get.put(LoginController());
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    loginController.selectedCategories = [];
    loginController.selectedArea = null;
    loginController.selectedUserType = null;
    loginController.selectedState = null;
    loginController.selectedDistrict = null;
    loginController.selectedDistance = null;
    loginController.selectedTaluka = null;
    loginController.selectedJobType = null;
    loginController.selectedSalary = null;

    await loginController.getProfileByUserId(
      Api.userInfo.read('userId') ?? "",
      context,
    );
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

  String getFirstLetter(String text) {
    if (text.isEmpty) return "";
    return text[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    return Scaffold(
      key: _scaffoldKeyJobList,
      backgroundColor: AppColors.scaffoldBg,
      drawer: (!isDesktop && isLoggedIn)
          ? const Drawer(width: 250, child: AdminSideBar())
          : null,
      endDrawer: !isDesktop
          ? const Drawer(width: 300, child: FilterSidebar())
          : null,
      appBar: buildAppBar(context),
      body: Row(
        children: [
          if (isDesktop && isLoggedIn) const AdminSideBar(),
          Expanded(
            child: GetBuilder<JobController>(
              builder: (controller) {
                return Stack(
                  children: [
                    if (!isDesktop)
                      Positioned(
                        top: 15,
                        left: 15,
                        child: IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () =>
                              _scaffoldKeyJobList.currentState?.openDrawer(),
                        ),
                      ),
                    SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 10 : 30,
                        !isDesktop ? 60 : 30,
                        isMobile ? 10 : 30,
                        30,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
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
                                  _buildSearchHeader(isMobile, width),
                                  const SizedBox(height: 20),
                                  _buildActiveFilterChips(isMobile),
                                  if (jobController.isLoading)
                                    _buildJobShimmerList(isMobile)
                                  else if (jobController
                                      .jobListJobSeekers
                                      .isEmpty)
                                    _buildEmptyJobState(context)
                                  else
                                    _buildJobList(isDesktop, isMobile, width),
                                ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(bool isMobile, double width) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        width: isMobile ? double.infinity : 450,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: "Search jobs by name, area...",
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (value) async {
                  await jobController.getJobListJobSeekers(
                    search: value,
                    context: context,
                  );
                },
              ),
            ),
            Container(height: 25, width: 1, color: Colors.grey.shade300),
            IconButton(
              icon: const Icon(Icons.tune_rounded, color: AppColors.grey),
              onPressed: () {
                if (MediaQuery.of(context).size.width < 1100) {
                  _scaffoldKeyJobList.currentState?.openEndDrawer();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChips(bool isMobile) {
    return GetBuilder<LoginController>(
      builder: (_) {
        bool hasFilters =
            loginController.selectedState != null ||
            loginController.selectedDistrict != null ||
            loginController.selectedTaluka != null ||
            loginController.selectedJobType != null ||
            loginController.selectedSalary != null ||
            loginController.selectedCategories.isNotEmpty;

        if (!hasFilters) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (loginController.selectedState != null)
                _filterChip(loginController.selectedState!, () {
                  loginController.selectedState = null;
                  loginController.update();
                }),
              if (loginController.selectedDistrict != null)
                _filterChip(loginController.selectedDistrict!, () {
                  loginController.selectedDistrict = null;
                  loginController.update();
                }),
              if (loginController.selectedTaluka != null)
                _filterChip(loginController.selectedTaluka!, () {
                  loginController.selectedTaluka = null;
                  loginController.update();
                }),
              if (loginController.selectedJobType != null)
                _filterChip(loginController.selectedJobType!, () {
                  loginController.selectedJobType = null;
                  loginController.update();
                }),
              if (loginController.selectedSalary != null)
                _filterChip(loginController.selectedSalary!, () {
                  loginController.selectedSalary = null;
                  loginController.update();
                }),
              for (var category in loginController.selectedCategories)
                _filterChip(category, () {
                  loginController.selectedCategories.remove(category);
                  loginController.update();
                }),
              TextButton(
                onPressed: () async {
                  loginController.selectedCategories.clear();
                  loginController.selectedArea = null;
                  loginController.selectedUserType = null;
                  loginController.selectedState = null;
                  loginController.selectedDistrict = null;
                  loginController.selectedDistance = null;
                  loginController.selectedTaluka = null;
                  loginController.selectedJobType = null;
                  loginController.selectedSalary = null;
                  loginController.update();
                  await jobController.getJobListJobSeekers(
                    search: searchController.text.trim(),
                    context: context,
                  );
                },
                child: const Text(
                  "Clear All",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, VoidCallback onDeleted) {
    return InputChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onDeleted: onDeleted,
      deleteIconColor: Colors.red,
    );
  }

  Widget _buildJobList(bool isDesktop, bool isMobile, double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop) const SizedBox(width: 250, child: FilterSidebar()),
        if (isDesktop) const SizedBox(width: 20),
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              itemCount: jobController.jobListJobSeekers.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final job = jobController.jobListJobSeekers[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: _buildJobCard(job, isMobile)),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobCard(dynamic job, bool isMobile) {
    final logoUrl = (job.logoImage != null && job.logoImage!.isNotEmpty)
        ? job.logoImage!.first
        : null;
    final double width = MediaQuery.of(context).size.width;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    return GestureDetector(
      onTap: () {
        Api.userInfo.write('selectJobId', job.jobId.toString());
        Api.userInfo.write('activeStatus', job.isActive.toString());
        //  Get.toNamed('/viewJobDetailWebPage');
        Api.userInfo.read('token') == null
            ? Get.toNamed('/webLoginPage')
            : Get.toNamed('/viewJobDetailWebPage');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.orgName.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.jobType.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor(
                            job.status ?? "",
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          job.status ?? "Not Applied",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: getStatusColor(job.status ?? ""),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                _buildOrgLogo(job, logoUrl),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              job.jobTitle.toString(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${job.city}, ${job.district}, ${job.state}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.currency_rupee_rounded,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Salary: ${job.salary}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Posted ${DateFormat('MMM dd, yyyy').format(DateTime.parse(job.createdDate.toString()))}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                if (!isLoggedIn)
                  SizedBox(
                    width: width * 0.19,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.toNamed('/webLoginPage');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "Apply Now",
                        style: AppTextStyles.caption(
                          context,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                if (isLoggedIn)
                  Text(
                    '${job.totalApplicants} Applied',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgLogo(dynamic job, String? logoUrl) {
    final hasLogo =
        logoUrl != null &&
        logoUrl.trim().isNotEmpty &&
        logoUrl.trim().toLowerCase() != "null";

    return Container(
      width: hasLogo ? 80 : 40,
      height: hasLogo ? 80 : 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.grey.shade50,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: hasLogo
            ? Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      getFirstLetter(job.orgName.toString()),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: getRandomColor(job.orgName.toString()),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  getFirstLetter(job.orgName.toString()),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: getRandomColor(job.orgName.toString()),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildJobShimmerList(bool isMobile) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          height: 180,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyJobState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: [
            const Icon(Icons.work_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 15),
            Text(
              'No jobs found matching your criteria',
              style: AppTextStyles.subtitle(context, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
