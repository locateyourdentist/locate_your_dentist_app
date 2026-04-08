import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

class ViewJobPageWeb extends StatefulWidget {
  const ViewJobPageWeb({super.key});

  @override
  State<ViewJobPageWeb> createState() => _ViewJobPageWebState();
}

class _ViewJobPageWebState extends State<ViewJobPageWeb> {
  final loginController = Get.put(LoginController());
  final jobController = Get.put(JobController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }
  Future<void> _refresh() async {
    final selectJobId = Api.userInfo.read('selectJobId') ?? "";
    await jobController.getJobsById(selectJobId, context);
    await jobController.getAppliedJobsAdmin(selectJobId, context);
    await jobController.getJobSeekersAppliedLists(Api.userInfo.read('userId') ?? "", context);
  }
  Widget _networkImageSafe(String? url, {required double width, required double height, BorderRadius? borderRadius, BoxFit fit = BoxFit.cover}) {
    final br = borderRadius ?? BorderRadius.circular(10);
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: const Color(0xFFF1F3F6), borderRadius: br),
      child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: (width < height ? width : height) * 0.25),
    );

    if (url == null || url.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: br,
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: CommonWebAppBar(
        height: screenWidth * 0.08,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: GetBuilder<JobController>(
          builder: (controller) {
            if (controller.job.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final job = controller.job.isNotEmpty ? controller.job[0] : null;
            if (job == null) {
              return const Center(child: Text("No job data available"));
            }

            final url = (loginController.jobFileImages.isNotEmpty && loginController.jobFileImages.first != null)
                ? (loginController.jobFileImages.first.url?.toString() ?? "")
                : "";
            final targetJobId = job.jobId ?? "";
            final isJobApplied = jobController.jobSeekersAppliedLists.any((j) => j.jobId.toString() == targetJobId);
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdminSideBar(),
                    Expanded(
                      child: Center(
                        child: DefaultTabController(
                          length: 2,
                          child:ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1000),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          height: screenWidth * 0.15,
                                          width: double.infinity,
                                          child: GestureDetector(
                                            onTap: () {
                                              if (url.isNotEmpty) {
                                                try {
                                                  Get.toNamed('/viewImagePage', arguments: {"url": url});
                                                } catch (_) {}
                                              }
                                            },
                                            child: _networkImageSafe(url, width: double.infinity, height: screenWidth * 0.15, borderRadius: BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ),
                                  
                                      const SizedBox(height: 12),
                                  
                                      // Job info container
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(60), topLeft: Radius.circular(60)),
                                          color: Colors.white,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Title + status
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: Text(job.jobTitle ?? '', textAlign: TextAlign.center, style: AppTextStyles.body(context, fontWeight: FontWeight.bold, color: AppColors.black)),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(job.isActive.toString() == 'true' ? ". Open" : ". Close", style: AppTextStyles.caption(context, fontWeight: FontWeight.bold, color: job.isActive.toString() == 'true' ? Colors.green : Colors.redAccent)),
                                              ],
                                            ),
                                  
                                            const SizedBox(height: 8),
                                  
                                            Center(child: Text(job.orgName ?? '', style: AppTextStyles.body(context, fontWeight: FontWeight.bold, color: AppColors.black))),
                                            const SizedBox(height: 8),
                                  
                                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                              Icon(Icons.place, color: AppColors.grey, size: screenWidth * 0.015),
                                              const SizedBox(width: 6),
                                              Flexible(child: Text("${job.city ?? ''}, ${job.district ?? ''}, ${job.state ?? ''}", style: AppTextStyles.caption(context, fontWeight: FontWeight.normal, color: AppColors.grey))),
                                            ]),
                                  
                                            const SizedBox(height: 12),
                                  
                                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                              Text("Posted: ${job.createdDate != null ? DateFormat('MMM dd, yyyy').format(job.createdDate!) : ''}", style: AppTextStyles.caption(context, fontWeight: FontWeight.normal, color: AppColors.grey)),
                                              const SizedBox(width: 12),
                                              Text("Applicants: ${job.totalApplicants ?? 0}", style: AppTextStyles.caption(context, fontWeight: FontWeight.normal, color: AppColors.grey)),
                                              const SizedBox(width: 12),
                                              Container(
                                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(6.0),
                                                  child: Text(job.jobType ?? '', style: AppTextStyles.caption(context, fontWeight: FontWeight.bold, color: Colors.white)),
                                                ),
                                              ),
                                            ]),
                                  
                                            const SizedBox(height: 12),

                                          Center(
                                            child: SizedBox(
                                              height: screenWidth*0.03,
                                              width: screenWidth*0.12,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      "Salary : ${job.salary ?? ''}",
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: AppTextStyles.caption(
                                                        context,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  GetBuilder<LoginController>(
                                                    builder: (controller) {
                                                      bool isUserActive = controller.userData.isNotEmpty &&
                                                          controller.userData.first.isActive;

                                                      return Switch(
                                                        value: job.isActive.toString() == 'true',
                                                        activeColor:
                                                        job.isActive.toString() == 'true' ? AppColors.primary : Colors.red,
                                                        activeTrackColor:job.isActive.toString()=='true'?
                                                        AppColors.primary.withOpacity(0.5):Colors.red,
                                                        inactiveThumbColor: Colors.red,
                                                        inactiveTrackColor: Colors.grey.shade400,
                                                        onChanged: (value) {
                                                          showDeactivateConfirmDialog(
                                                            context: context,
                                                            isActivating: value,
                                                            onConfirm: () async {
                                                              print('jhg${job.isActive.toString()}');
                                                              job.isActive.toString()=='true'?
                                                              await jobController.updateApplicationStatusAdmin(
                                                                job.jobId.toString(), 'false', context):await jobController.updateApplicationStatusAdmin(
                                                                  job.jobId.toString(),'true', context);
                                                              await jobController.getJobsById(job.jobId.toString(), context);
                                                              await jobController.getAppliedJobsAdmin(job.jobId.toString(), context);
                                                              jobController.update();
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                            const SizedBox(height: 12),
                                            Center(child: Text("Job Timing : ${job.details?["startTime"] ?? 'N/A'} - ${job.details?["endTime"] ?? 'N/A'}", style: AppTextStyles.caption(context, fontWeight: FontWeight.bold, color: AppColors.black))),
                                            const SizedBox(height: 16),
                                  

                                            SizedBox(
                                              height: screenWidth*0.04,
                                              child: TabBar(
                                                indicatorColor: AppColors.primary,
                                                indicatorWeight: 3,
                                                labelColor: AppColors.black,
                                                unselectedLabelColor: AppColors.black,
                                                tabs: [
                                                  const Tab(text: 'Job Description'),
                                                  Tab(text: (Api.userInfo.read('userType').toString() == 'Job Seekers'|| Api.userInfo.read('token')==null)? 'Clinic Description' : "Applicants List"),
                                                ],
                                              ),
                                            ),
                                  
                                            const SizedBox(height: 12),
                                  
                                            SizedBox(
                                              height: Api.userInfo.read('userType').toString() == 'Job Seekers' ? screenWidth * 0.55 : 800,
                                              child: TabBarView(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(job.jobDescription ?? '', style: AppTextStyles.caption(context, fontWeight: FontWeight.normal, color: AppColors.black, height: 1.5)),
                                                  ),
                                  
                                                  // Clinic Description or Applicants List
                                                  Api.userInfo.read('userType') == 'Job Seekers'
                                                      ? Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Center(child: Text(job.companyDescription ?? 'No clinic description available', style: AppTextStyles.body(context, fontWeight: FontWeight.normal, color: AppColors.black, ))),
                                                  )
                                                      : (jobController.jobIdListAdmin.isNotEmpty
                                                      ? ListView.builder(
                                                    itemCount: jobController.jobIdListAdmin.length,
                                                    shrinkWrap: true,
                                                    padding: const EdgeInsets.all(12),
                                                    itemBuilder: (context, index) {
                                                      final seekers = jobController.jobIdListAdmin[index];
                                                      return AnimationLimiter(
                                                        child: AnimationConfiguration.staggeredList(
                                                          position: index,
                                                          duration: const Duration(milliseconds: 800),
                                                          child: SlideAnimation(
                                                            verticalOffset: 50.0,
                                                            curve: Curves.easeOut,
                                                            child: FadeInAnimation(
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(bottom: 12),
                                                                child: GestureDetector(
                                                                  onTap: () async {
                                                                    if (seekers.status.toString().toLowerCase() == 'applied') {
                                                                      await jobController.updateJobStatusAdmin(seekers.jobSeekerId.toString(), seekers.jobId.toString(), "Viewed", job.orgName ?? "", context);
                                                                    }
                                                                    await loginController.getProfileByUserId(seekers.jobSeekerId ?? "", context);
                                                                    Get.toNamed('/jobSeekerViewProfilePage');
                                                                  },
                                                                  child: SizedBox(
                                                                    width: screenWidth*0.25,
                                                                    child: JobSeekerAppliedCard(
                                                                      seeker: seekers,
                                                                      orgName: job.orgName,
                                                                      onCall: () {
                                                                        try {
                                                                          launchCall(seekers.mobileNumber.toString());
                                                                        } catch (_) {}
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                      : Center(child: Text('No applicants found', style: AppTextStyles.caption(context, fontWeight: FontWeight.normal)))),
                                                ],
                                              ),
                                            ),
                                  
                                            const SizedBox(height: 14),
                                  
                                            if (Api.userInfo.read('userType').toString() == 'Job Seekers')
                                              GetBuilder<JobController>(
                                                builder: (_) {
                                                  return Center(
                                                    child: SizedBox(
                                                      width: screenWidth * 0.19,
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          await jobController.applyJobsJobSeekers(job.jobId ?? '', Api.userInfo.read('userId') ?? '', job.userType ?? '', job.orgName ?? '', context);
                                                          setState(() {});
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: isJobApplied ? AppColors.white : AppColors.primary,
                                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                          elevation: 5,
                                                        ),
                                                        child: Text(isJobApplied ? 'Applied' : "Apply Now", style: AppTextStyles.caption(context, fontWeight: FontWeight.bold, color: isJobApplied ? AppColors.primary : AppColors.white)),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                  
                                            const SizedBox(height: 14),
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Applicant card widget
class JobSeekerAppliedCard extends StatelessWidget {
  final dynamic seeker;
  final String? orgName;
  final VoidCallback? onCall;

  const JobSeekerAppliedCard({super.key, required this.seeker, this.orgName, this.onCall});

  Widget _buildNetworkImageSafe(String? url, double width, double height) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: const Color(0xFFF1F3F6), borderRadius: BorderRadius.circular(16)),
      child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: width * 0.2),
    );

    if (url == null || url.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final imageUrl = (seeker.image != null) ? "${AppConstants.baseUrl}${seeker.image}" : "";
    return Container(
      width: width*0.15,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 4))]),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: _buildNetworkImageSafe(imageUrl, width * 0.05, width * 0.04)),
            SizedBox(width: width * 0.01),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(seeker.name ?? '', softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(seeker.email ?? '', style: AppTextStyles.caption(context, color: AppColors.black)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton(icon:  Icon(Icons.call,size: width*0.012,color: AppColors.primary,), onPressed: onCall),
                      SizedBox(width: width*0.003,),
                      Text(seeker.mobileNumber ?? '', style: AppTextStyles.caption(context, color: AppColors.black)),
                    ],
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
