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
import '../../common_widgets/color_code.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


class ViewJobWebinar extends StatefulWidget {
  const ViewJobWebinar({super.key});

  @override
  State<ViewJobWebinar> createState() => _ViewJobWebinarState();
}

class _ViewJobWebinarState extends State<ViewJobWebinar> {
  final jobController=Get.put(JobController());
  final loginController=Get.put(LoginController());
  @override
  void initState() {
   jobController.getJobListAdmin(context);
   jobController.getWebinarListAdmin(context);
    super.initState();
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
    Future<void> _refresh() async {
      jobController.getJobListAdmin(context);
      jobController.getWebinarListAdmin(context);
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text('Job Posts / Webinars',style: AppTextStyles.subtitle(context,color: AppColors.black),),
        automaticallyImplyLeading: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      // backgroundColor: AppColors.backGroundColor,
      // appBar: AppBar(title: Text('Job Posts / Webinars',style: AppTextStyles.subtitle(context,color: AppColors.white),),
      //   backgroundColor: AppColors.primary,iconTheme: const IconThemeData(color: AppColors.white),
      // ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: DefaultTabController(
              length: 2,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                 // physics: const AlwaysScrollableScrollPhysics(),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("My Posts",style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.black),),
                    Padding(
                      padding:  const EdgeInsets.all(10.0),
                      child: Container(
                        height: size*0.2,
                        width: size,
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(color: AppColors.white,),borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text("Total Applicants",style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.grey),),
                                  const SizedBox(height: 10,),
                                  Text(totalApplicants.toString(),style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.black),),
                                ],
                              ),
                              const VerticalDivider(
                                width: 20,
                                thickness: 2,
                                color: Colors.grey,
                              ),
                              Column(
                                children: [
                                  Text("Shortlisted",style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.grey),),
                                  const SizedBox(height: 10,),
                                  Text(shortlistedCount.toString(),style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.black),),
                                ],
                              ),
                              const VerticalDivider(
                                width: 20,
                                thickness: 2,
                                color: Colors.grey,
                              ),
                              Column(
                                children: [
                                  Text("Rejected",style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.grey),),
                                  const SizedBox(height: 10,),
                                  Text(rejectedCount.toString(),style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.black),),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
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
                       Get.toNamed('/createJobAdminPage',arguments:{'job':'new'});
                        },
                        child: Text("Create Job/Webinars",style: TextStyle(fontSize: size*0.033,decoration:TextDecoration.underline,color:AppColors.primary,fontWeight: FontWeight.bold,),),
                      ),
                    ),

                    GetBuilder<JobController>(
                        builder: (controller){
                          return Container(
                            height: size*0.12,
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
                          );
                        }
                    ),
                  if(jobController.jobList.isEmpty)
                    Center(child: Column(
                      children: [
                        const SizedBox(height: 0.05,),
                        Text('No data found',style: AppTextStyles.caption(context,color: AppColors.black),),
                      ],
                    ),),                    if(jobController.jobList.isNotEmpty)

                      Expanded(
                          child: RefreshIndicator(
                            onRefresh: _refresh,
                            //height: MediaQuery.of(context).size.height * 1,
                      child: TabBarView(
                          children: [
                           // const SizedBox(height: 0.02,),

                            AnimationLimiter(
                              child: ListView.builder(
                                key: ValueKey(jobController.jobList.length),
                                padding: const EdgeInsets.all(12),
                                itemCount: jobController.jobList.length,
                                itemBuilder: (context, index) {
                                  final jobs = jobController.jobList[index];

                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 1300),
                                    child: SlideAnimation(
                                      verticalOffset: 120.0,
                                      curve: Curves.easeOutBack,
                                      child: FadeInAnimation(
                                        child: Padding(
                                          padding:  const EdgeInsets.only(bottom: 12),
                                          child: GestureDetector(
                                                      onTap: ()async {
                                                        Api.userInfo.write('selectJobId',jobs.jobId.toString());
                                                        Api.userInfo.write('activeStatus',jobs.isActive.toString());
                                                        print("nnn${Api.userInfo.read('selectJobId')}");
                                                        await  jobController.getJobsById(jobs.jobId.toString(), context);
                                                        await  jobController.getAppliedJobsAdmin(jobs.jobId.toString(),context);
                                                        Get.toNamed('/jobViewProfilePage');
                                                      },
                                            child: JobCard(
                                              title: jobs.jobTitle.toString(),
                                              description: jobs.jobDescription.toString(),
                                              jobType: jobs.jobType.toString(),
                                              appliedCount:
                                              jobs.totalApplicants.toString(),
                                              postedAgo: timeAgo(
                                                DateTime.parse(jobs.createdDate.toString()),
                                              ),
                                              status: jobs.isActive == true
                                                  ? "Open"
                                                  : "Close",
                                              statusColor: jobs.isActive == true
                                                  ? Colors.lightGreen
                                                  : Colors.redAccent,
                                              jobId: jobs.jobId.toString(),
                                              isActive: jobs.isActive.toString(),
                                              size: size,
                                                          onTap: (){
                                                            jobController.getJobsById(jobs.jobId.toString(), context);
                                                            Get.toNamed('/createJobAdminPage');
                                                          },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                                if(jobController.webinarList.isEmpty)
                              Center(child: Column(
                                children: [
                                  const SizedBox(height: 0.05,),
                                  Text('No data found',style: AppTextStyles.caption(context,color: AppColors.black),),
                                ],
                              ),),
                            if(jobController.webinarList.isNotEmpty)
                              AnimationLimiter(
                                child: ListView.builder(
                                  itemCount: jobController.webinarList.length,
                                  key: ValueKey(jobController.webinarList.length),
                                  shrinkWrap: true,
                                  //physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(12),
                                 // scrollDirection: ScrollDirection.vertical,
                                  itemBuilder: (context, index) {
                                    final webinars=jobController.webinarList[index];
                                    final created = DateTime.parse(webinars.createdDate.toString());
                                    final postedAgo = timeAgo(created);
                                    print(webinars.webinarTitle.toString());
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: GestureDetector(
                                        onTap: ()async{
                                          // Api.userInfo.write('selectWebinarId',webinars.webinarId.toString());
                                          // Api.userInfo.write('activeStatus1', webinars.isActive.toString());
                                          // jobController.getWebinarById(webinars.webinarId.toString(), webinars.isActive.toString(), context);
                                          // Get.toNamed('/viewWebinarPage');

                                          await jobController.getWebinarById(
                                              webinars.webinarId.toString(),
                                              webinars.isActive.toString(),
                                              context);
                                          await   jobController.getAppliedWebinarsAdmin(webinars.webinarId.toString(),context);
                                          Api.userInfo.write('webinarId', webinars.webinarId.toString());
                                          Api.userInfo.write('statusWebinar', webinars.isActive.toString());
                                          Get.toNamed('/viewWebinarPage');
                                        },
                                        child: AnimationConfiguration.staggeredList(
                                          position: index,
                                          duration: const Duration(milliseconds: 1300),
                                          child: SlideAnimation(
                                            verticalOffset: 120.0,
                                            curve: Curves.easeOutBack,
                                            child: FadeInAnimation(
                                              child: JobCard(
                                                title: webinars.webinarTitle.toString(),
                                                description: webinars.webinarDescription.toString(),
                                                jobType: "",
                                                appliedCount: webinars.totalApplicants.toString()??'0',
                                                postedAgo: postedAgo,
                                                status:webinars.isActive.toString()=="true"? "Open": "Close",
                                                statusColor: webinars.isActive.toString()=="true"?Colors.lightGreen:Colors.redAccent,
                                                jobId:webinars.webinarId.toString(),
                                                isActive: webinars.isActive.toString(),
                                                size: size,
                                                onTap: (){
                                                  jobController.getWebinarById(webinars.webinarId.toString(), webinars.isActive.toString(), context);
                                                  Get.toNamed('/createJobAdminPage',arguments: {"selectedString":"Webinar"});
                                                },

                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                          ]),
                    )
                      )],
                ),
              ),
            ),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
