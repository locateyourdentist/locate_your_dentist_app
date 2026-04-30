import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/dental_clinic_dashboard.dart';
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

      setState(() {});
    } catch (e) {
      print("Quill load error: $e");

      _controller = QuillController.basic();
      setState(() {});
    }
  }
  @override
  void initState() {
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
        ),

      ),
    );
    _refresh();
    super.initState();
  }
  Future<void> _refresh() async {
    await jobController.getJobListAdmin(context);
    await jobController.getWebinarListAdmin(context);
    loadJobDescription(
        jobController.webDescriptionData);

  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    final jobId = jobController.jobList.isNotEmpty ? jobController.jobList[0].jobId : null;
    jobController.getAppliedJobsAdmin(jobId.toString(),context);
    final totalApplicants = jobController.jobList.isNotEmpty ? jobController.jobList[0].totalApplicants : 0;
    int shortlistedCount = jobController.jobIdListAdmin.where((e) => e.status == "Shortlisted").length;
    int rejectedCount = jobController.jobIdListAdmin.where((e) => e.status == "Rejected").length;
    print("Shortlisted: $shortlistedCount");
    print("Rejected: $rejectedCount");
    String getPlainText(List<Map<String, dynamic>>? delta) {
      if (delta == null) return "";
      return delta.map((e) => e['insert'] ?? "").join();
    }
    Future<void> _refresh() async {
      jobController.getJobListAdmin(context);
      jobController.getWebinarListAdmin(context);
    }
    return Scaffold(
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "Job Posts / Webinars",
        onLogout: () {},
        onNotification: () {},
      ),
      backgroundColor: AppColors.backGroundColor,
      body: GetBuilder<JobController>(
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: Row(
                children: [
                  const AdminSideBar(),

                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child:ConstrainedBox(
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
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  // physics: const AlwaysScrollableScrollPhysics(),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Center(child: Text("Last Job Posts Details",style: AppTextStyles.body(context,fontWeight: FontWeight.bold,color: Colors.black),)),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width:size*0.2,
                                          child: _statCard(
                                            title: "Total Applicants",
                                            value: totalApplicants.toString(),
                                            icon: Icons.people_alt_outlined,
                                            color: Colors.blue,context: context
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        SizedBox(
                                          width:size*0.2,
                                          child: _statCard(
                                            title: "Shortlisted",
                                            value: shortlistedCount.toString(),
                                            icon: Icons.check_circle_outline,
                                            color: Colors.green,context: context
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        SizedBox(
                                          width:size*0.2,
                                          child: _statCard(
                                            title: "Rejected",
                                            value: rejectedCount.toString(),
                                            icon: Icons.cancel_outlined,
                                            color: Colors.redAccent,context: context
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size*0.01,),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: TextButton(
                                        onPressed: () {
                                          jobController.job.clear();
                                          jobController.webinar.clear();
                                          loginController.selectedJobType="";
                                          jobController.selectedJobId='';
                                          jobController.selectedWebinarId='';
                                          loginController.typeNameController.clear();
                                          loginController.jobTitleController.clear();
                                          loginController.jobDescController.clear();
                                          loginController.selectedSalary="";
                                          loginController.qualificationJobController.clear();
                                          loginController.selectedExperience="";
                                          loginController.selectedJobType="";
                                          loginController.selectedExperience="";
                                          loginController.selectedSalary="";
                                          loginController.webinarTitleJobController.clear();
                                          loginController.webinarDescriptionJobController.clear();
                                          loginController.webinarLinkController.clear();
                                          loginController.webinarDateController.clear();
                                          loginController.startHour='';
                                          loginController.startMinutes="";
                                          loginController.startPeriod="";
                                          loginController.endHour="";
                                          loginController.endMinutes="";
                                          loginController.endPeriod="";
                                          jobController.webinarImage="";
                                          jobController.startHour='';
                                          jobController.startMinutes="";
                                          jobController.startPeriod="";
                                          jobController.endHour="";
                                          jobController.endMinutes="";
                                          jobController.endPeriod="";
                                          jobController.jobImage="";
                                          // loginController.jobFileImages="";
                                          jobController.selectedWebinarId="0";
                                          jobController.selectedJobId="0";
                                          loginController.update();
                                          jobController.update();
                                          Get.toNamed('/createJobWebPage',arguments:{'job':'new'});
                                        },
                                        child: Text("Create Job/Webinars",style: AppTextStyles.body(context,fontWeight: FontWeight.bold,color: AppColors.primary),),
                                      ),
                                    ),
                                    SizedBox(height: size*0.01,),
                    
                                    GetBuilder<JobController>(
                                        builder: (controller){
                                          return Center(
                                            child: Container(
                                              height: size*0.023,
                                              width: size*0.35,
                                              margin: const EdgeInsets.symmetric(horizontal: 20),
                                              decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10),),
                                                  color: Colors.grey.shade100
                                              ),
                                              child: TabBar(
                                                indicatorSize: TabBarIndicatorSize.tab,
                                                dividerColor: Colors.transparent,
                                                indicator:
                                                BoxDecoration(borderRadius: BorderRadius.circular(10),
                                                  gradient: const LinearGradient(
                                                    colors: [AppColors.primary,AppColors.secondary],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                                labelColor: AppColors.white,
                                                unselectedLabelColor: AppColors.black,
                                                tabs: const [
                                                  Tab(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text('Jobs'),
                                                      ],
                                                    ),
                                                  ),
                                                  Tab(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text('Webinars',)
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                    ),
                                    if(jobController.jobList.isEmpty)
                                      Center(child: Column(
                                        children: [
                                          const SizedBox(height: 15,),
                                          Text('No data found',style: AppTextStyles.caption(context,color: AppColors.black),),
                                        ],
                                      ),),                    if(jobController.jobList.isNotEmpty)
                    
                                      Expanded(
                                          child: RefreshIndicator(
                                            onRefresh: _refresh,
                                            //height: MediaQuery.of(context).size.height * 1,
                                            child: TabBarView(
                                              children: [
                    
                                                jobController.jobList.isEmpty
                                                    ? _emptyState(context)
                                                    : AnimationLimiter(
                                                      child: GridView.builder(
                                                        padding: const EdgeInsets.all(10),
                                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      crossAxisSpacing: 20,
                                                      mainAxisSpacing: 30,
                                                      childAspectRatio: 2.7,
                                                        ),
                                                        itemCount: jobController.jobList.length,
                                                        itemBuilder: (context, index) {
                                                      final jobs = jobController.jobList[index];
                                                      String getPlainText(List<Map<String, dynamic>>? delta) {
                                                        if (delta == null) return "";
                                                        return delta.map((e) => e['insert'] ?? "").join();
                                                      }
                                                      return AnimationConfiguration.staggeredList(
                                                        position: index,
                                                        duration: const Duration(milliseconds: 1300),
                                                        child: SlideAnimation(
                                                          verticalOffset: 120.0,
                                                          curve: Curves.easeOutBack,
                                                          child: FadeInAnimation(
                                                            child: InkWell(
                                                              onTap: () async{
                                                                Api.userInfo.write('selectJobId',jobs.jobId.toString());
                                                                Api.userInfo.write('activeStatus',jobs.isActive.toString());
                                                              //  print("nnn${Api.userInfo.read('selectJobId')}");
                                                               // await jobController.getJobsById(jobs.jobId.toString(), context);
                                                                //await  jobController.getAppliedJobsAdmin(jobs.jobId.toString(), context);
                                                                Get.toNamed('/viewJobDetailWebPage');
                                                              },
                                                              child: _modernCard(
                                                                  title: jobs.jobTitle ?? "",
                                                                  desc: getPlainText(jobs.jobDescription),
                                                                  status: (jobs.isActive ?? false) ? "Open" : "Closed",
                                                                  statusColor: (jobs.isActive ?? false)
                                                                      ? Colors.green
                                                                      : Colors.red,
                                                                  subtitle: jobs.jobType ?? "",
                                                                  trailing: "${jobs.totalApplicants} Applicants",
                                                                  onTap: ()async {
                    
                                                                   await jobController.getJobsById(jobs.jobId.toString(), context);
                                                                    Get.toNamed('/createJobWebPage');
                                                                  },context: context
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                                                                      },
                                                                                                    ),
                                                    ),
                    
                                                jobController.webinarList.isEmpty
                                                    ? _emptyState(context)
                                                    : AnimationLimiter(
                                                      child: GridView.builder(
                                                        padding: const EdgeInsets.all(10),
                                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      crossAxisSpacing: 20,
                                                      mainAxisSpacing: 20,
                                                      childAspectRatio: 3,
                                                        ),
                                                        itemCount: jobController.webinarList.length,
                                                        itemBuilder: (context, index) {
                                                      final webinars = jobController.webinarList[index];
                                                      return AnimationConfiguration.staggeredList(
                                                        position: index,
                                                        duration: const Duration(milliseconds: 1300),
                                                        child: SlideAnimation(
                                                          verticalOffset: 120.0,
                                                          curve: Curves.easeOutBack,
                                                          child: FadeInAnimation(
                                                            child: GestureDetector(
                                                              onTap: () async{
                                                                Api.userInfo.write('webinarId', webinars.webinarId.toString());
                                                                Api.userInfo.write('activeStatus1',webinars.isActive.toString());
                                                                await jobController.getWebinarById(
                                                                    webinars.webinarId.toString(),
                                                                    webinars.isActive.toString(),
                                                                    context);
                                                                Get.toNamed('/viewWebinarDetailWebPage');
                                                                },
                                                              child: _modernCard(
                                                                  title: webinars.webinarTitle ?? "",
                                                                  desc: getPlainText(webinars.webinarDescription),
                                                                 // desc: webinars.webinarDescription ?? "",
                                                                  status: webinars.isActive == true ? "Open" : "Closed",
                                                                  statusColor: webinars.isActive == true
                                                                      ? Colors.green
                                                                      : Colors.red,
                                                                  subtitle: "Webinar",
                                                                  trailing: "${webinars.totalApplicants ?? 0} Joined",
                                                                  onTap: () async{
                                                                    Api.userInfo.write('webinarId',webinars.webinarId.toString());
                                                                    Api.userInfo.write('activeStatus1',webinars.isActive.toString());
                                                                  // await  jobController.getWebinarById(
                                                                  //       webinars.webinarId.toString(),
                                                                  //       webinars.isActive.toString(),
                                                                  //       context);
                                                                    Get.toNamed('/createJobWebPage', arguments: {"selectedString": "Webinar"},
                                                                    );
                                                                  },
                                                                  context: context
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
                                          )
                                      )],
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
            );
          }
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
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
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
                style: AppTextStyles.caption(
                  context,
                  fontWeight: FontWeight.bold,color: AppColors.black
                ),
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: AppTextStyles.caption(context,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subtitle,
              style: AppTextStyles.caption(context,
              ),
            ),
            SizedBox(width: size*0.001,),
            SizedBox(
              height: size*0.012,
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.edit,color: AppColors.grey,size: size*0.01,),
                  onPressed: onTap,
                ),),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Expanded(
          child: Text(
            //"A clinic is a healthcare facility focused on outpatient care, providing diagnosis, treatment, and preventive services for non-life-threatening conditions without overnight stays. Often staffed by specialized doctors, nurses, or general practitioners, they are typically smaller than hospitals and offer accessible, specialized care (e.g., dental, mental health, or pediatric)",
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context,
              color: Colors.grey.shade700,
            ),
          ),
        ),

        SizedBox(height: size*0.001),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              trailing,
              style: AppTextStyles.caption(context,
                fontWeight: FontWeight.normal,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: size*0.012,color: AppColors.grey,),
          ],
        )
      ],
    ),
  );
}
Widget _emptyState(dynamic context) {
  final double size = MediaQuery
      .of(context)
      .size
      .width;
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox, size: size * 0.012, color: Colors.grey),
        const SizedBox(height: 10),
        Text("No data found", style: AppTextStyles.caption(context),),
      ],
    ),
  );
}

Widget _statCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,dynamic context
}) {
  final size = MediaQuery.of(context).size.width;

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
     // color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
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
            color: Colors.white,
            //color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color:color, size: 26),
        ),

        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.caption(context)
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.caption(context)
            ),
          ],
        ),
      ],
    ),
  );
}