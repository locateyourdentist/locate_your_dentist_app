import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_drawer.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DentalClinicDashboard extends StatefulWidget {
  const DentalClinicDashboard({super.key});
  @override
  State<DentalClinicDashboard> createState() => _DentalClinicDashboardState();
}
class _DentalClinicDashboardState extends State<DentalClinicDashboard> {
  final TextEditingController searchController=TextEditingController();
  final jobController=Get.put(JobController());
  final loginController=Get.put(LoginController());
  final notificationController=Get.put(NotificationController());
  final planController=Get.put(PlanController());
  List<ProfileModel> filteredProfiles = [];
  List<String> title=["Dental Shop","Dental Lab","Dental Mechanic","Dental Consultant","Job Posts/Webinars"];
  @override
  void initState() {
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
   await  jobController.getJobListAdmin(context);
   await  jobController.getWebinarListAdmin(context);
   await  notificationController.getNotificationListAdmin(context);
   await  planController.checkPlansStatus(Api.userInfo.read('userId')??"",context);
   await loginController.getBranchDetails(context);
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return  Scaffold(
      //backgroundColor: AppColors.backGroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary,AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Padding(
          padding:  const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: (){
//Navigator.push(context, MaterialPageRoute(builder: (context)=>const LocationScreen()));
              final userId = Get.arguments?['selectedUserId'] ?? Api.userInfo.read('userId');
              },
            child: CircleAvatar(
              radius: size * 0.13,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: ProfileImageWidget(size: size),
              ),
            ),
          ),
        ),
        centerTitle: false,
        // title: Column(
        //   mainAxisAlignment:MainAxisAlignment.start,
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text(
        //       'Welcome Back',
        //       style: AppTextStyles.body(context,
        //           color: AppColors.white,fontWeight: FontWeight.bold,),
        //     ),
        //
        //   ],
        // ),
        actions: [
          GetBuilder<NotificationController>(
            builder: (controller) {
              bool multipleBranches = loginController.userBranchesList.length > 1;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  if(multipleBranches)
                    GestureDetector(
                        onTap: ()async{
                          //await   loginController.getBranchDetails(context);
                          Get.toNamed(
                            '/branchListPage',
                            arguments: {'page': 'dashboard'},
                          );
                        },
                        child: Row(
                            children:[
                              Text('Switch Account',style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold),),
                              Image.asset('assets/images/switch_account.png',height: size * 0.05,width:size * 0.05,)])),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_none,
                          color: AppColors.white,
                          size: size * 0.07,
                        ),
                        onPressed: () async {
                          await notificationController.getNotificationListAdmin(context);
                          notificationController.unreadCount="0";
                          notificationController.update();
                          Get.toNamed('/notificationPage');
                        },
                      ),

                      if (int.tryParse(notificationController.unreadCount ?? "0")! > 0)
                        Positioned(
                          top: 4,
                          right: 8,
                          child: CircleAvatar(
                            radius: size * 0.022,
                            backgroundColor: Colors.redAccent,
                            child: Text(
                              notificationController.unreadCount ?? "",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size * 0.022,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body:  GetBuilder<JobController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh:_refresh ,
            child: DefaultTabController(
              length: 2,
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary,AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        height: size*0.23,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            height: size*0.012,
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey, size: 24),
                                const SizedBox(width: 8),
                                Expanded(
                                  child:CommonSearchTextField(
                                    controller: searchController,
                                    hintText: "Search user list by name,mobileNumber...",
                                    onSubmitted: (value)async {
                                      print("Search text: $value");
                                      await  loginController.getProfileDetails('' ,'', '', 'true','','','',searchController.text.toString(), value,context);
                                      Get.toNamed('/filterResultPage');
                                    },
                                  )
                                ),
                                Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: AppColors.white,),
                                  child: Center(
                                    child: IconButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) {
                                            return FractionallySizedBox(
                                              heightFactor: 0.75,
                                              child: FilterDrawer(
                                                onApply: () async{
                                                  print("Selected State: ${loginController.selectedState}");
                                                  print("Selected District: ${loginController.selectedDistrict}");
                                                  print("Selected Area: ${loginController.selectedArea}");

                                                  String userType=  Api.userInfo.read('sUserType');
                                                  print("ssuser$userType");
                                                  filteredProfiles.map((e) => searchController.text.toString());
                                                  await loginController.getProfileDetails(
                                                    userType ?? "",
                                                    loginController.selectedState,
                                                    loginController.selectedDistrict,
                                                    loginController.selectedTaluka,"true",'','','','',
                                                    context,
                                                  );
                                                  Get.back();
                                                },
                                                onReset: () {
                                                  setState(() {
                                                    // loginController.selectedPlace = null;
                                                    // loginController.selectedDistrict = null;
                                                    loginController.selectedArea = null;
                                                    loginController.selectedUserType=null;
                                                    loginController.selectedState=null;
                                                    loginController.selectedDistrict=null;
                                                  });
                                                },
                                              ),
                                            );
                                          },
                                        );
                                       // _scaffoldKeyUser.currentState!.openDrawer();
                                      },
                                      icon:  Icon(Icons.filter_list, color: Colors.black, size: size*0.06),
                                      splashRadius: 22,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size*0.02,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text('What you Want?',style: AppTextStyles.subtitle(context,color: AppColors.black),),
                        SizedBox(height: size*0.02,),
                        SizedBox(
                          height: size * 0.45,
                          child: AnimationLimiter(
                            child: ListView.builder(
                              itemCount: title.length,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 500),
                                  child: SlideAnimation(
                                    horizontalOffset: 50,
                                    child: FadeInAnimation(
                                      child: GestureDetector(
                                        onTap: ()async {
                                          if (title[index] == "Job Posts/Webinars") {
                                            Get.toNamed('/viewJobWebinarPage');
                                          } else {
                                            Api.userInfo.write('sUserType', title[index] ?? "");
                                            print('cvv${title[index]}');
                                           await loginController.getProfileDetails(
                                              title[index], '', '', '', 'true', '', '', '', '',
                                              context,
                                            );
                                            Get.toNamed('/userTypeListPage');
                                          }
                                        },
                                        child: Container(
                                          width: size * 0.37,
                                          margin: const EdgeInsets.only(right: 15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                                child: Image.asset(
                                                  imgUserType(title[index]),
                                                  height: size * 0.28,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                  child: Text(
                                                    title[index],
                                                    textAlign: TextAlign.center,
                                                    style: AppTextStyles.caption(
                                                      context,
                                                      color: AppColors.black,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
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
                        SizedBox(height: size * 0.02),

                        Text('Jobs & Webinars',style: AppTextStyles.subtitle(context,color: AppColors.black),),
                        SizedBox(height: size*0.02,),
                        GetBuilder<JobController>(
                          builder: (controller){
                            return Container(
                              height: size*0.12,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(50),),
                              color: Colors.grey.shade100
                              ),
                              child: TabBar(
                                indicatorSize: TabBarIndicatorSize.tab,
                                dividerColor: Colors.transparent,
                                indicator:
                                BoxDecoration(borderRadius: BorderRadius.circular(50),
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary,AppColors.secondary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                labelColor: AppColors.white,
                                unselectedLabelColor: AppColors.black,
                                tabs:  const [
                                  Tab(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Jobs',),
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
                        const SizedBox(height: 10,),
                       SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: TabBarView(
            children: [

            jobController.jobList.isEmpty
            ? Center(
            child: Text(
            'No data found',
            style: AppTextStyles.caption(
            context,
            color: AppColors.black,
            ),
            ),
            )
                :
            AnimationLimiter(
              child: ListView.builder(
              itemCount: jobController.jobList.length,
                key: ValueKey(jobController.jobList.length),
                padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
              final jobs = jobController.jobList[index];
              final created =
              DateTime.parse(jobs.createdDate.toString());
              final postedAgo = timeAgo(created);
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 1300),
                child: SlideAnimation(
                  verticalOffset: 120.0,
                  curve: Curves.easeOutBack,
                  child: FadeInAnimation(
                    child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                    onTap: () async{
                      Api.userInfo.write('selectJobId',jobs.jobId.toString());
                      Api.userInfo.write('activeStatus',jobs.isActive.toString());
                      print("nnn${Api.userInfo.read('selectJobId')}");
                   await jobController.getJobsById(
                    jobs.jobId.toString(), context);
                  await  jobController.getAppliedJobsAdmin(
                    jobs.jobId.toString(), context);
                    Get.toNamed('/jobViewProfilePage');
                    },
                    child: JobCard(
                    title: jobs.jobTitle.toString(),
                    description: jobs.jobDescription.toString(),
                    jobType: jobs.jobType.toString(),
                    appliedCount:
                    jobs.totalApplicants.toString(),
                    postedAgo: postedAgo,
                      status: (jobs.isActive ?? false) ? "Open" : "Close",
                      statusColor: (jobs.isActive ?? false)
                          ? Colors.lightGreen
                          : Colors.redAccent,
                      jobId: jobs.jobId.toString(),
                    isActive: jobs.isActive.toString(),
                    size: size,
                    onTap: ()async {
                    await jobController.getJobsById(jobs.jobId.toString(), context);
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

            jobController.webinarList.isEmpty
            ? Center(
            child: Text(
            'No data found',
            style: AppTextStyles.caption(
            context,
            color: AppColors.black,
            ),
            ),
            )
                : AnimationLimiter(
                  child: ListView.builder(
                              itemCount: jobController.webinarList.length,
                                key: ValueKey(jobController.webinarList.length),
                                padding: const EdgeInsets.all(12),
                              itemBuilder: (context, index) {
                              final webinars = jobController.webinarList[index];
                              final created =
                              DateTime.parse(webinars.createdDate.toString());
                              final postedAgo = timeAgo(created);
                              return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 1300),
                                child: SlideAnimation(
                                  verticalOffset: 120.0,
                                  curve: Curves.easeOutBack,
                                  child: FadeInAnimation(
                                    child: GestureDetector(
                                    onTap: () async{
                                      print('web view id${webinars.webinarId.toString()}');
                                      Api.userInfo.write('webinarId',webinars.webinarId.toString());
                                  // await jobController.getWebinarById(webinars.webinarId.toString(), webinars.isActive.toString(), context);
                                    Get.toNamed('/viewWebinarPage');
                                    },
                                    child: JobCard(
                                    title: webinars.webinarTitle.toString(),
                                    description:
                                    webinars.webinarDescription.toString(),
                                    jobType: "",
                                    appliedCount:
                                    webinars.totalApplicants.toString()??'0',
                                    postedAgo: postedAgo,
                                    status: webinars.isActive == true
                                    ? "Open"
                                                      : "Close",
                                    statusColor: webinars.isActive == true
                                    ? Colors.lightGreen
                                                      : Colors.redAccent,
                                    jobId: webinars.webinarId.toString(),
                                    isActive: webinars.isActive.toString(),
                                    size: size,
                                    onTap: () {
                                    jobController.getWebinarById(
                                    webinars.webinarId.toString(),
                                    webinars.isActive.toString(),
                                    context);
                                    Get.toNamed(
                                    '/createJobAdminPage',
                                    arguments: {
                                    "selectedString": "Webinar"
                                    },
                                    );
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
            ],
            ),
            )

            ]),
                  )
                    ],
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

class JobCard extends StatelessWidget {
  final String title;
  final String description;
  final String jobType;
  final String appliedCount;
  final String postedAgo;
  final String status;
  final Color statusColor;
  final String jobId;
  final String isActive;
  final double size;
  final VoidCallback onTap;

   JobCard({
    super.key,
    required this.title,
    required this.description,
    required this.jobType,
    required this.appliedCount,
    required this.postedAgo,
    required this.status,
    required this.statusColor,
     required this.jobId,required this.isActive,
    required this.size,
     required this.onTap
  });
  final jobController=Get.put(JobController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<JobController>(
      builder: (controller) {
        return Container(
          height: size * 0.48,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200, width: 0.4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size*0.08,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: onTap,
                      child:Text(
                      "Edit",softWrap: true,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,fontSize: size*0.03,decoration: TextDecoration.underline,
                      ),
                    ),
                  ),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,softWrap: true,
                        style: AppTextStyles.body(
                          context,
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      jobType ??" ",softWrap: true,
                      style: AppTextStyles.caption(
                        context,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size * 0.01),
                Text(
                  description??"",
                  softWrap: true,maxLines: 2,
                  style: AppTextStyles.caption(context, color: AppColors.black,fontWeight: FontWeight.normal),
                ),
                const Divider(color: AppColors.grey, thickness: 0.3),
                SizedBox(height: size * 0.01),
                Row(
                  children: [
                    Text(
                      "$appliedCount Applied",
                      style: AppTextStyles.caption(context, color: AppColors.primary),
                    ),
                   // SizedBox(width: size * 0.03),
                   const VerticalDivider(color: AppColors.black,
                    thickness: 2,),
                    Text(
                      postedAgo??"",
                      style: AppTextStyles.caption(context, color: AppColors.grey),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Text(
                        status??"",
                        style: AppTextStyles.caption(
                          context,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

