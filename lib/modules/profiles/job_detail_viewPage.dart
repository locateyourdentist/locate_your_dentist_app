import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }
  Future<void> _refresh() async {
    final selectJobId = Api.userInfo.read('selectJobId') ?? "";
    await jobController.getJobsById(selectJobId, context);
    await jobController.getAppliedJobsAdmin(selectJobId, context);
    await jobController.getJobSeekersAppliedLists(Api.userInfo.read('userId') ?? "", context);
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
        ),

      ),
    );
    loadJobDescription(
        jobController.jobDescriptionData);
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    final jobController = Get.find<JobController>();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: DefaultTabController(
          length: 2,
          child: GetBuilder<JobController>(
            builder: (controller) {
              final job1 = jobController.job.isNotEmpty ? jobController.job[0] : null;
              String targetJobId = job1?.jobId ?? "";
              print('targetid$targetJobId');
              bool isJobApplied = jobController.jobSeekersAppliedLists
                  .any((j) => j.jobId.toString() == targetJobId);
              print("Is job applied? $isJobApplied");
              if (controller.job.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final job = controller.job.isNotEmpty ? controller.job[0] : null;
              if (job == null) {
                return const Center(child: Text("No job data available"));
              }
              final url = loginController.jobFileImages.isNotEmpty
                  ? loginController.jobFileImages.first.url.toString() : "";
              String getPlainText(List<Map<String, dynamic>>? delta) {
                if (delta == null) return "";
                return delta.map((e) => e['insert'] ?? "").join();
              }
              return SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: size * 0.75,
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: (){
                                  Get.toNamed('/viewImagePage',arguments: {"url":url});
                                  },
                                child: FadeInImage(
                                  image: NetworkImage(url.toString()),
                                  placeholder: const AssetImage('assets/images/Dental_clinic.jpg'),
                                  fit: BoxFit.cover,
                                  fadeInDuration: const Duration(milliseconds: 400),
                                  fadeOutDuration: const Duration(milliseconds: 200),
                                  imageErrorBuilder: (_, __, ___) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F3F6),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: Colors.grey.shade400,
                                        size: size * 0.08,
                                      ),
                                    );
                                    //   Center(
                                    //   child: Icon(
                                    //     Icons.camera_alt_outlined,
                                    //     size: size*0.12,
                                    //     color: Colors.grey[400],
                                    //   ),
                                    // );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              left: 10,
                              top: 5,
                              child: IconButton(
                                icon:  Icon(Icons.arrow_back_ios,size: size*0.06, color: Colors.black),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                          ),
                          Positioned(
                              right: 35,
                              top: 10,
                              child: PopupMenuButton<String>(
                            onSelected: (String isActive)async {
                              print("Selected Status: $isActive");
                              print('jobid${job.jobId}');
                              await  jobController.updateApplicationStatusAdmin(
                                job.jobId.toString(), isActive.toString(),
                                context,
                              );
                              // jobController.getJobsById(
                              //     seeker.jobSeekerId.toString(),
                              //     seeker.isActive.toString(), context);
                             await  jobController.getJobsById(job.jobId.toString(), context);
                             await   jobController.getAppliedJobsAdmin(job.jobId.toString(),context);
                           jobController.update();
                            },
                                itemBuilder: (BuildContext context) {
                              return [
                                // PopupMenuItem(
                                //   value: "true",
                                //   child: Text("Open",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),
                                // ),
                                PopupMenuItem(
                                  value: "false",
                                  child: Text("Close",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal)),
                                ),
                              ];
                            },

                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.black,
                            ),
                          )
                          )
                        ],
                      ),

                      // Job Info Container
                      Container(
                        clipBehavior: Clip.antiAlias,
                        width: size,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(60),
                            topLeft: Radius.circular(60),
                          ),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Job Title
                            Row(
                              mainAxisAlignment:MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Expanded(
                                    child: Text(
                                      job.jobTitle ?? '',softWrap: true,maxLines: 2,
                                      style: AppTextStyles.caption(
                                          context,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.black),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      job.isActive.toString()=='true' ? ". Open" :". Close",
                                      style: AppTextStyles.caption(
                                          context,
                                          fontWeight: FontWeight.bold,
                                          color: job.isActive.toString()=='true' ?Colors.green:Colors.redAccent),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          Center(
                              child: Text(
                               job.orgName ?? '',
                                style: AppTextStyles.body(
                                    context,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black),
                              ),),
                            const SizedBox(height: 4),
                            // Location
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Icon(Icons.place,color: AppColors.grey,size: size*0.05,),
                            Center(
                              child: Text(
                                "${job.city ?? ''}, ${job.district ?? ''}, ${job.state ?? ''}",
                                style: AppTextStyles.caption(
                                    context,
                                    fontWeight: FontWeight.normal,
                                    color: AppColors.grey),
                              ),
                            ),]),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  "Posted: ${job.createdDate != null ? DateFormat('MMM dd, yyyy').format(job.createdDate!) : ''}",
                                  softWrap: true,
                                  style: AppTextStyles.caption(
                                      context,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.grey),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Applicants: ${job.totalApplicants ?? 0}",
                                  style: AppTextStyles.caption(
                                      context,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.grey),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(color: AppColors.primary,borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        job.jobType ?? '',
                                        style: AppTextStyles.caption(
                                            context,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                "Salary :${job.salary ?? ''}",
                                style: AppTextStyles.caption(
                                    context,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                            "Job Timing : ${job.details?["startTime"] ?? 'N/A'} - ${job.details?["endTime"] ?? 'N/A'}",
                                style: AppTextStyles.caption(
                                    context,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black),
                              ),
                            ),
                            const SizedBox(height: 16),
                             TabBar(
                              // indicator: BoxDecoration(
                              //   color: AppColors.primary,
                              //   borderRadius: BorderRadius.circular(10),
                              // ),
                              indicatorColor: AppColors.primary,
                              indicatorWeight: 3,
                              labelColor: AppColors.black,
                              unselectedLabelColor: AppColors.black,
                              tabs: [
                                const Tab(text: 'Job Description'),
                                Tab(text: Api.userInfo.read('userType').toString()=='Job Seekers'?'Clinic Description':"Applicants List"),
                              ],
                            ),

                            SizedBox(
                              height:Api.userInfo.read('userType').toString()=='Job Seekers'? size * 0.25 :800,
                              child: TabBarView(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:  IgnorePointer(
                                        child: QuillEditor(
                                          controller: _controller,
                                          scrollController: _scrollController,
                                          focusNode: FocusNode(),
                                          config: const QuillEditorConfig(
                                            showCursor: false,
                                            expands: false,
                                          ),
                                        ),
                                      )
                                    //Text( getPlainText(job.jobDescription), style: AppTextStyles.caption(context, fontWeight: FontWeight.normal, color: AppColors.black, height: 1.5)),
                                  ),
                                  Api.userInfo.read('userType') == 'Job Seekers'
                                      ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      job.companyDescription ??
                                          'No clinic description available',
                                      style: AppTextStyles.caption(
                                          context, fontWeight: FontWeight.normal, color: AppColors.black, height: 1.5),
                                    ),
                                  )
                                      : jobController.jobIdListAdmin.isNotEmpty? ListView.builder(
                                    itemCount: jobController.jobIdListAdmin.length,
                                    padding: const EdgeInsets.all(12),
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      if(jobController.jobIdListAdmin.isEmpty) {
                                        Text('No data found',style: AppTextStyles.caption(context,color: AppColors.black),);
                                      }
                                      //if(jobController.jobList.isNotEmpty)
                                      final seekers = jobController.jobIdListAdmin[index];
                                      totalApplies=jobController.jobIdListAdmin.length;
                                      return AnimationLimiter(
                                        child: AnimationConfiguration.staggeredList(
                                          position: index,
                                          duration: const Duration(milliseconds: 1300),
                                          child: SlideAnimation(
                                            verticalOffset: 120.0,
                                            curve: Curves.easeOutBack,
                                            child: FadeInAnimation(
                                              child: Padding(
                                                padding: const EdgeInsets.only(bottom: 12),
                                                child: GestureDetector(
                                                  onTap: ()async{
                                                      if(seekers.status.toString().toLowerCase()=='applied') {
                                                        await jobController.updateJobStatusAdmin(
                                                          seekers.jobSeekerId.toString(), seekers.jobId.toString(), "Viewed",
                                                          job.orgName??"", context,);
                                                      }
                                                      await loginController.getProfileByUserId(seekers.jobSeekerId ?? "", context);
                                                      Get.toNamed('/jobSeekerViewProfilePage');
                                                      print('jobid${seekers.jobSeekerId}');
                                                     },
                                                  child: JobSeekerAppliedCard(
                                                    seeker: seekers,orgName:job.orgName,
                                                    onCall: () {
                                                    launchCall(seekers.mobileNumber.toString());
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ): const SizedBox(),
                                ],
                              ),
                            ),


                            const SizedBox(height: 14),
                            if(Api.userInfo.read('userType').toString()=='Job Seekers')
                              GetBuilder<JobController>(
                                  builder: (controller) {
                                    return Center(
                                  child: SizedBox(
                                    width: size * 0.9,
                                    child: ElevatedButton(
                                      onPressed: ()async {
                                      await  jobController.applyJobsJobSeekers(
                                          job.jobId ?? '',
                                          Api.userInfo.read('userId') ?? '',
                                          job.userType ?? '',job.orgName??'',
                                          context,
                                        );
                                       },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:isJobApplied==true? AppColors.white:AppColors.primary,
                                        padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: Text(
                                        isJobApplied==true?'Applied': "Apply Now",
                                        style: AppTextStyles.caption(
                                            context,
                                            fontWeight: FontWeight.bold,
                                            color: isJobApplied==true? AppColors.primary:AppColors.white,),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            ),
                            //if(isAlreadyApplied==false)
                             // Center(child: TextButton(onPressed: (){}, child: Text('Applied',style: AppTextStyles.body(context,color: AppColors.primary,fontWeight: FontWeight.bold),))),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
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
    final loginController=Get.put(LoginController());
    final jobController=Get.put(JobController());
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
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 4)),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            seeker.name,softWrap: true,
                            style: TextStyle(
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (String status)async {
                            print("Selected Status: $status");
                            print('jobid${seeker.jobSeekerId.toString()}');

                            await  jobController.updateJobStatusAdmin(
                              seeker.jobSeekerId.toString(), seeker.jobId.toString(),
                              status,orgName??"",
                              context,
                            );
                          await  jobController.getJobsById(Api.userInfo.read('selectJobId')??"",  context);
                            await   jobController.getAppliedJobsAdmin(Api.userInfo.read('selectJobId')??"",context);
                           },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                value: "Shortlisted",
                                child: Text("Shortlisted",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),
                              ),
                              PopupMenuItem(
                                value: "Rejected",
                                child: Text("Rejected",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal)),
                              ),
                            ];
                          },

                          child: Icon(
                            Icons.more_vert,
                            color: Colors.grey[700],
                          ),
                        )

                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ID: ${seeker.jobSeekerId}",
                            style: TextStyle(fontSize: width * 0.03, color: Colors.black87)),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: getStatusColor(seeker.status.toString()).withOpacity(0.1),
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
                    Text("Email: ${seeker.email}",softWrap: true,
                        style: TextStyle(fontSize: width * 0.028, color: Colors.grey)),
                    // Text("JobId: ${seeker.jobId}",
                    //     style: TextStyle(fontSize: width * 0.035, color: Colors.grey)),

                    const SizedBox(height: 5),
                    SizedBox(
                      height: width*0.06,
                      child: Row(
                        children: [
                          SizedBox(
                            width:width*0.08,
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
                            )
                          ),
                          Text(seeker.mobileNumber,
                              style: TextStyle(fontSize: width * 0.035)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
