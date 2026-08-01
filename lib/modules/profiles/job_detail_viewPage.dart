import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/common_widgets/job_share_utils.dart';
import 'package:locate_your_dentist/model/AppliedJobSeekerList_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ViewJobPage extends StatefulWidget {
  const ViewJobPage({super.key});

  @override
  State<ViewJobPage> createState() => _ViewJobPageState();
}

class _ViewJobPageState extends State<ViewJobPage> {
  final loginController = Get.put(LoginController());
  final jobController = Get.put(JobController());
  int? totalApplies;
  late String appliedKey;
  bool isAlreadyApplied = false;
  final ScrollController _scrollController = ScrollController();
  late QuillController _controller;
  void loadJobDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [];

      if (data == null) {
        delta = [
          {"insert": "\n"},
        ];
      } else if (data is List) {
        delta = List<Map<String, dynamic>>.from(data);
      } else if (data is String) {
        delta = List<Map<String, dynamic>>.from(jsonDecode(data));
      }

      _controller = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );

      setState(() {});
    } catch (e) {
      print("Quill load error: $e");

      _controller = QuillController.basic();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
      ),
    );
    _refresh();
  }

  Future<void> _refresh() async {
    final selectJobId = Api.userInfo.read('selectJobId') ?? "";
    await jobController.getJobsById(selectJobId, context);
    await jobController.getAppliedJobsAdmin(selectJobId, context);
    await jobController.getJobSeekersAppliedLists(
      Api.userInfo.read('userId') ?? "",
      context,
    );
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
      ),
    );
    loadJobDescription(jobController.jobDescriptionData);
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    Color? background,
    Color? foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background ?? AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground ?? AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(
                context,
                fontWeight: FontWeight.w600,
                color: foreground ?? AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    final jobController = Get.find<JobController>();
    final isAdminView = Api.userInfo.read('userType').toString() != 'Job Seekers';
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: DefaultTabController(
          length: 2,
          child: GetBuilder<JobController>(
            builder: (controller) {
              if (controller.job.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final job = controller.job.first;
              final String targetJobId = job.jobId ?? "";
              final bool isJobApplied = controller.jobSeekersAppliedLists.any(
                (j) => j.jobId.toString() == targetJobId,
              );
              final url = loginController.jobFileImages.isNotEmpty
                  ? loginController.jobFileImages.first.url.toString()
                  : "";
              final isOpen = job.isActive.toString() == 'true';
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(28),
                          ),
                          child: SizedBox(
                            height: size * 0.62,
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: url.isEmpty
                                  ? null
                                  : () => Get.toNamed(
                                        '/viewImagePage',
                                        arguments: {"url": url},
                                      ),
                              child: url.isNotEmpty
                                  ? FadeInImage(
                                      image: NetworkImage(url),
                                      placeholder: const AssetImage(
                                        'assets/images/Dental_clinic.jpg',
                                      ),
                                      fit: BoxFit.cover,
                                      fadeInDuration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      fadeOutDuration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      imageErrorBuilder: (_, __, ___) =>
                                          Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.secondary,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.work_outline,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.secondary,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.work_outline,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Container(
                          height: size * 0.62,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black45, Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: SafeArea(
                            bottom: false,
                            child: Material(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => Navigator.pop(context),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: SafeArea(
                            bottom: false,
                            child: Row(
                              children: [
                                Material(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => shareJobPost(
                                      jobTitle: job.jobTitle ?? '',
                                      orgName: job.orgName ?? '',
                                      jobType: job.jobType,
                                      salary: job.salary,
                                      location:
                                          "${job.city ?? ''}, ${job.district ?? ''}, ${job.state ?? ''}",
                                      description: plainTextFromDelta(
                                        job.jobDescription,
                                      ),
                                      imageUrl: url.isNotEmpty ? url : null,
                                      jobId: targetJobId,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.share_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isAdminView) ...[
                                  const SizedBox(width: 8),
                                  Material(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    shape: const CircleBorder(),
                                    child: PopupMenuButton<String>(
                                      onSelected: (String isActive) async {
                                        await jobController
                                            .updateApplicationStatusAdmin(
                                          job.jobId.toString(),
                                          isActive.toString(),
                                          context,
                                        );
                                        await jobController.getJobsById(
                                          job.jobId.toString(),
                                          context,
                                        );
                                        await jobController.getAppliedJobsAdmin(
                                          job.jobId.toString(),
                                          context,
                                        );
                                        jobController.update();
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          PopupMenuItem(
                                            value: "false",
                                            child: Text(
                                              "Close",
                                              style: AppTextStyles.caption(
                                                context,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ];
                                      },
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Transform.translate(
                      offset: const Offset(0, -24),
                      child: Container(
                        width: size,
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    job.jobTitle ?? '',
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body(
                                      context,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isOpen ? Colors.green : Colors.red)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isOpen ? "Open" : "Closed",
                                    style: AppTextStyles.caption(
                                      context,
                                      fontWeight: FontWeight.bold,
                                      color: isOpen ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.business,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    job.orgName ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body(
                                      context,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _infoChip(
                                  icon: Icons.work_outline,
                                  label: job.jobType ?? 'N/A',
                                  background: AppColors.primary,
                                  foreground: Colors.white,
                                ),
                                _infoChip(
                                  icon: Icons.currency_rupee,
                                  label: (job.salary ?? '').isEmpty
                                      ? 'N/A'
                                      : job.salary!,
                                ),
                                _infoChip(
                                  icon: Icons.place_outlined,
                                  label:
                                      "${job.city ?? ''}, ${job.district ?? ''}, ${job.state ?? ''}",
                                ),
                                _infoChip(
                                  icon: Icons.access_time,
                                  label:
                                      "${job.details?["startTime"] ?? 'N/A'} - ${job.details?["endTime"] ?? 'N/A'}",
                                ),
                                _infoChip(
                                  icon: Icons.calendar_today_outlined,
                                  label: job.createdDate != null
                                      ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(job.createdDate!)
                                      : 'N/A',
                                ),
                                _infoChip(
                                  icon: Icons.people_outline,
                                  label:
                                      "${job.totalApplicants ?? 0} Applicants",
                                ),
                              ],
                            ),
                            if (isAdminView) ...[
                              const SizedBox(height: 16),
                              GetBuilder<LoginController>(
                                builder: (controller) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Job Status",
                                            style: AppTextStyles.caption(
                                              context,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                        Switch(
                                          value: isOpen,
                                          activeThumbColor: Colors.green,
                                          activeTrackColor: AppColors.primary
                                              .withValues(alpha: 0.5),
                                          inactiveThumbColor: Colors.red,
                                          inactiveTrackColor:
                                              Colors.grey.shade400,
                                          onChanged: (value) {
                                            showDeactivateConfirmDialog(
                                              context: context,
                                              isActivating: value,
                                              onConfirm: () async {
                                                isOpen
                                                    ? await jobController
                                                        .updateApplicationStatusAdmin(
                                                        job.jobId.toString(),
                                                        'false',
                                                        context,
                                                      )
                                                    : await jobController
                                                        .updateApplicationStatusAdmin(
                                                        job.jobId.toString(),
                                                        'true',
                                                        context,
                                                      );
                                                await jobController.getJobsById(
                                                  job.jobId.toString(),
                                                  context,
                                                );
                                                await jobController
                                                    .getAppliedJobsAdmin(
                                                  job.jobId.toString(),
                                                  context,
                                                );
                                                jobController.update();
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TabBar(
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  color: AppColors.primary,
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                dividerColor: Colors.transparent,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.grey.shade600,
                                labelStyle: AppTextStyles.caption(
                                  context,
                                  fontWeight: FontWeight.bold,
                                ),
                                unselectedLabelStyle: AppTextStyles.caption(
                                  context,
                                  fontWeight: FontWeight.normal,
                                ),
                                tabs: [
                                  const Tab(text: 'Description'),
                                  Tab(
                                    text: isAdminView
                                        ? "Applicants"
                                        : 'Clinic Info',
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                              height: isAdminView ? 800 : size * 1,
                              child: TabBarView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: SingleChildScrollView(
                                      child: IgnorePointer(
                                        child: QuillEditor(
                                          controller: _controller,
                                          scrollController: _scrollController,
                                          focusNode: FocusNode(),
                                          config: const QuillEditorConfig(
                                            showCursor: false,
                                            expands: false,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  !isAdminView
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 12),
                                          child: Text(
                                            job.companyDescription ??
                                                'No clinic description available',
                                            style: AppTextStyles.caption(
                                              context,
                                              fontWeight: FontWeight.normal,
                                              color: AppColors.black,
                                              height: 1.5,
                                            ),
                                          ),
                                        )
                                      : jobController.jobIdListAdmin.isNotEmpty
                                          ? ListView.builder(
                                              itemCount: jobController
                                                  .jobIdListAdmin
                                                  .length,
                                              padding:
                                                  const EdgeInsets.only(top: 12),
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                final seekers = jobController
                                                    .jobIdListAdmin[index];
                                                totalApplies = jobController
                                                    .jobIdListAdmin
                                                    .length;
                                                return AnimationLimiter(
                                                  child: AnimationConfiguration
                                                      .staggeredList(
                                                    position: index,
                                                    duration: const Duration(
                                                      milliseconds: 1300,
                                                    ),
                                                    child: SlideAnimation(
                                                      verticalOffset: 120.0,
                                                      curve: Curves.easeOutBack,
                                                      child: FadeInAnimation(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            bottom: 12,
                                                          ),
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              if (seekers.status
                                                                      .toString()
                                                                      .toLowerCase() ==
                                                                  'applied') {
                                                                await jobController
                                                                    .updateJobStatusAdmin(
                                                                  seekers
                                                                      .jobSeekerId
                                                                      .toString(),
                                                                  seekers.jobId
                                                                      .toString(),
                                                                  "Viewed",
                                                                  job.orgName ??
                                                                      "",
                                                                  context,
                                                                );
                                                              }
                                                              await loginController
                                                                  .getProfileByUserId(
                                                                seekers
                                                                        .jobSeekerId ??
                                                                    "",
                                                                context,
                                                              );
                                                              Get.toNamed(
                                                                '/jobSeekerViewProfilePage',
                                                              );
                                                            },
                                                            child:
                                                                JobSeekerAppliedCard(
                                                              seeker: seekers,
                                                              orgName:
                                                                  job.orgName,
                                                              onCall: () {
                                                                launchCall(
                                                                  seekers
                                                                      .mobileNumber
                                                                      .toString(),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 40),
                                                child: Text(
                                                  'No applicants yet',
                                                  style: AppTextStyles.caption(
                                                    context,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                            if (!isAdminView)
                              GetBuilder<JobController>(
                                builder: (controller) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: isJobApplied
                                            ? null
                                            : const LinearGradient(
                                                colors: [
                                                  AppColors.primary,
                                                  AppColors.secondary,
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                        color: isJobApplied
                                            ? Colors.grey.shade100
                                            : null,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: isJobApplied
                                            ? null
                                            : () async {
                                                await jobController
                                                    .applyJobsJobSeekers(
                                                  job.jobId ?? '',
                                                  Api.userInfo.read('userId') ??
                                                      '',
                                                  job.userType ?? '',
                                                  job.orgName ?? '',
                                                  context,
                                                );
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          disabledBackgroundColor:
                                              Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text(
                                          isJobApplied ? 'Applied' : "Apply Now",
                                          style: AppTextStyles.body(
                                            context,
                                            fontWeight: FontWeight.bold,
                                            color: isJobApplied
                                                ? Colors.grey.shade600
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}

class JobSeekerAppliedCard extends StatelessWidget {
  final JobSeekerAppliedModel seeker;
  final String? orgName;
  final VoidCallback? onCall;

  const JobSeekerAppliedCard({
    super.key,
    required this.seeker,
    this.orgName,
    this.onCall,
  });
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final loginController = Get.put(LoginController());
    final jobController = Get.put(JobController());
    return GestureDetector(
      //  onTap: ()async{
      //    if(seeker.status.toString().toLowerCase()=='applied') {
      //      await jobController.updateJobStatusAdmin(
      //        seeker.jobSeekerId.toString(), seeker.jobId.toString(), "Viewed",
      //        orgName ?? "", context,);
      //      await loginController.getProfileByUserId(seeker.jobSeekerId ?? "", context);
      //      Get.toNamed('/jobViewProfilePage');
      //
      //      print('jobid${seeker.jobSeekerId}');
      //    }
      // },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Profile Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  "${AppConstants.baseUrl}${seeker.image}",
                  width: width * 0.22,
                  height: width * 0.22,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: width * 0.22,
                      height: width * 0.22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.grey.shade400,
                        size: width * 0.08,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(width: width * 0.04),

              // Right Side Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          seeker.name,
                          softWrap: true,
                          style: AppTextStyles.caption(
                            context,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String status) async {
                          print("Selected Status: $status");
                          print('jobid${seeker.jobSeekerId.toString()}');

                          await jobController.updateJobStatusAdmin(
                            seeker.jobSeekerId.toString(),
                            seeker.jobId.toString(),
                            status,
                            orgName ?? "",
                            context,
                          );
                          await jobController.getJobsById(
                            Api.userInfo.read('selectJobId') ?? "",
                            context,
                          );
                          await jobController.getAppliedJobsAdmin(
                            Api.userInfo.read('selectJobId') ?? "",
                            context,
                          );
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: "Shortlisted",
                              child: Text(
                                "Shortlisted",
                                style: AppTextStyles.caption(
                                  context,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: "Rejected",
                              child: Text(
                                "Rejected",
                                style: AppTextStyles.caption(
                                  context,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ];
                        },

                        child: Icon(Icons.more_vert, color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ID: ${seeker.jobSeekerId}",
                        style: TextStyle(
                          fontSize: width * 0.03,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor(
                            seeker.status.toString(),
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          seeker.status.toString(),
                          style: TextStyle(
                            color: getStatusColor(seeker.status.toString()),
                            fontSize: width * 0.028,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Email: ${seeker.email}",
                    softWrap: true,
                    style: TextStyle(
                      fontSize: width * 0.028,
                      color: Colors.grey,
                    ),
                  ),

                  // Text("JobId: ${seeker.jobId}",
                  //     style: TextStyle(fontSize: width * 0.035, color: Colors.grey)),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: width * 0.06,
                    child: Row(
                      children: [
                        SizedBox(
                          width: width * 0.08,
                          child: Transform.rotate(
                            angle: 20 * 3.1415926535 / 180,
                            child: IconButton(
                              icon: Icon(
                                Icons.call,
                                color: AppColors.primary,
                                size: width * 0.05,
                              ),
                              onPressed: onCall,
                            ),
                          ),
                        ),
                        Text(
                          seeker.mobileNumber,
                          style: TextStyle(fontSize: width * 0.035),
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
    );
  }
}
