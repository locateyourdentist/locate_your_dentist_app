import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/dashboard/clinic_image_caurosel.dart';

class JobSeekerDashboardWeb extends StatefulWidget {
  const JobSeekerDashboardWeb({Key? key}) : super(key: key);
  @override
  State<JobSeekerDashboardWeb> createState() => _JobSeekerDashboardWebState();
}

class _JobSeekerDashboardWebState extends State<JobSeekerDashboardWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKeyJob = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  final jobController = Get.put(JobController());
  final loginController = Get.put(LoginController());
  final planController = Get.put(PlanController());

  int appliedCount = 0;
  int selectedCount = 0;
  int rejectedCount = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await jobController.getJobListJobSeekers(search: " ", context: context);
    await jobController.getJobSeekersAppliedLists(Api.userInfo.read('userId') ?? "", context);
    await jobController.getWebinarListJobSeekers('', '',  context);
    await planController.getUploadImages(userType: "Dental Clinic", context: context);
    _calculateStats();
  }

  void _calculateStats() {
    appliedCount = jobController.jobSeekersAppliedLists.length;
    selectedCount = jobController.jobSeekersAppliedLists.where((e) => e.status == "Selected").length;
    rejectedCount = jobController.jobSeekersAppliedLists.where((e) => e.status == "Rejected").length;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    String getFirstLetter(String text) {
      if (text.isEmpty) return "";
      return text[0].toUpperCase();
    }

    return Scaffold(
      key: _scaffoldKeyJob,
      backgroundColor: AppColors.scaffoldBg,
      drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LYD",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Row(
              children: [
                if (isDesktop) const AdminSideBar(),
                Expanded(
                  child: Stack(
                    children: [
                      if (!isDesktop)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => _scaffoldKeyJob.currentState?.openDrawer(),
                          ),
                        ),
                      SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(isMobile ? 10 : 24, isLoggedIn && !isDesktop ? 60 : 24, isMobile ? 10 : 24, 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 15 : 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Featured Clinics", style: AppTextStyles.body(context, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 20),
                                    GetBuilder<PlanController>(
                                      builder: (pController) {
                                        if (loginController.isLoading) return const Center(child: CircularProgressIndicator());
                                        final imageUrls = pController.editUploadImage1
                                            .map((clinic) => clinic.url ?? "")
                                            .where((url) => url.isNotEmpty).toList();
                                        return ClinicImageCarousel(imageUrls: imageUrls);
                                      },
                                    ),
                                    const SizedBox(height: 40),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        width: isMobile ? double.infinity : width * 0.35,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(40),
                                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.search, color: Colors.grey, size: 24),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: TextField(
                                                controller: searchController,
                                                decoration: const InputDecoration(hintText: "Search jobs...", border: InputBorder.none),
                                                onSubmitted: (value) async {
                                                  await jobController.getJobListJobSeekers(search: value, context: context);
                                                  Get.toNamed('/jobListJobSeekersWebPage');
                                                },
                                              ),
                                            ),
                                            IconButton(icon: const Icon(Icons.filter_list, color: AppColors.grey), onPressed: () => Get.toNamed('/filterPageJobSeekersPage')),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Text("Job Summary", style: AppTextStyles.body(context, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 15),
                                    dashboardStats(),
                                    const SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Popular Jobs", style: AppTextStyles.body(context, fontWeight: FontWeight.bold)),
                                        TextButton(
                                          onPressed: () => Get.toNamed('/jobListJobSeekersWebPage'),
                                          child: const Text("View All", style: TextStyle(decoration: TextDecoration.underline)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: width > 1200 ? 3 : (width > 800 ? 2 : 1),
                                        crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: width > 700 ? 2.8 : 3.2,
                                      ),
                                      itemCount: controller.jobListJobSeekers.length > 6 ? 6 : controller.jobListJobSeekers.length,
                                      itemBuilder: (context, index) {
                                        final job = controller.jobListJobSeekers[index];
                                        final logoUrl = (job.logoImage != null && job.logoImage!.isNotEmpty) ? job.logoImage!.first : null;
                                        return GestureDetector(
                                          onTap: () async {
                                            Api.userInfo.write('selectJobId', job.jobId.toString());
                                            Api.userInfo.write('activeStatus', job.isActive.toString());
                                            Get.toNamed('/viewJobDetailWebPage');
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300), color: Colors.grey.shade100),
                                                  child: ClipRRect(child: Image.network(logoUrl ?? "", fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(getFirstLetter(job.orgName ?? ""), style: TextStyle(fontWeight: FontWeight.bold, color: getRandomColor(job.orgName ?? "")))))),
                                                ),
                                                const SizedBox(width: 15),
                                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                  Text(job.orgName ?? "", style: AppTextStyles.caption(context, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                  const SizedBox(height: 15),
                                                  Text(job.jobTitle ?? "", style: AppTextStyles.caption(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                  const SizedBox(height: 15),
                                                  Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text("${job.city}, ${job.state}", style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis))])
                                                ]))
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget dashboardStats() {
    return Row(
      children: [
        _statCard("Applied", appliedCount, Colors.blue),
        _statCard("Selected", selectedCount, Colors.green),
        _statCard("Rejected", rejectedCount, Colors.red),
      ],
    );
  }

  Widget _statCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          children: [
            Text(count.toString(), style: AppTextStyles.subtitle(context, color: color, )),
            const SizedBox(height: 5),
            Text(title, style: AppTextStyles.caption(context, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
