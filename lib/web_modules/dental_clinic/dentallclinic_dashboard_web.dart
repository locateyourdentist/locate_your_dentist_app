import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
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
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

class DentalClinicDashboardWebPage extends StatefulWidget {
  const DentalClinicDashboardWebPage({super.key});
  @override
  State<DentalClinicDashboardWebPage> createState() => _DentalClinicDashboardWebPageState();
}
class _DentalClinicDashboardWebPageState extends State<DentalClinicDashboardWebPage> {
  final TextEditingController searchController=TextEditingController();
  final jobController=Get.put(JobController());
  final loginController=Get.put(LoginController());
  final notificationController=Get.put(NotificationController());
  final planController=Get.put(PlanController());
  List<ProfileModel> filteredProfiles = [];
  List<String> title=["Dental Shop","Dental Lab","Dental Mechanic","Dental Consultant","Job Posts/Webinars"];
  Widget modernSearchBar(double size) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade600, size: size*0.013),

          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: searchController,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: "Search dental clinic, lab, shop...",
                border: InputBorder.none,
              ),
              onSubmitted: (value) async {
                await loginController.getProfileDetails(
                  '', '', '', 'true', '', '', '', searchController.text, value, context,
                );
                //Get.toNamed('/filterResultPage');
                Get.toNamed('/userTypeListWeb');

              },
            ),
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),

          const SizedBox(width: 10),

          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return FractionallySizedBox(
                    heightFactor: 0.75,
                    child: FilterDrawer(
                      onApply: () async {
                        String userType = Api.userInfo.read('sUserType');

                        await loginController.getProfileDetails(
                          userType ?? "",
                          loginController.selectedState,
                          loginController.selectedDistrict,
                          loginController.selectedTaluka,
                          "true", '', '', '', '',
                          context,
                        );

                        Get.back();
                      },
                      onReset: () {
                        setState(() {
                          loginController.selectedArea = null;
                          loginController.selectedUserType = null;
                          loginController.selectedState = null;
                          loginController.selectedDistrict = null;
                        });
                      },
                    ),
                  );
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
                size: size*0.011,
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
 await   jobController.getJobListAdmin(context);
 await  jobController.getWebinarListAdmin(context);
 await  notificationController.getNotificationListAdmin(context);
 await planController.checkPlansStatus(Api.userInfo.read('userId')??"",context);  }
  String getPlainText(List<Map<String, dynamic>>? delta) {
    if (delta == null) return "";
    return delta.map((e) => e['insert'] ?? "").join();
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return  Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body:  GetBuilder<JobController>(
          builder: (controller) {
            return RefreshIndicator(
              onRefresh:_refresh ,
              child: DefaultTabController(
                length: 2,
                child: Row(
                  children: [
                    const AdminSideBar(),

                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
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
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Column(
                                    children: [

//                                       Padding(
//                                         padding: const EdgeInsets.all(15.0),
//                                         child: Align(
//                                           alignment: Alignment.topRight,
//                                           child: Row(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               Container(
//                                                 width: size * 0.35,
//                                                 padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.grey.shade100,
//                                                   borderRadius: BorderRadius.circular(10),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.grey.withOpacity(0.15),
//                                                       blurRadius: 6,
//                                                     )
//                                                   ],
//                                                 ),
//                                                 child:  Expanded(
//                                                 child:CommonSearchTextField(
//                                                   controller: searchController,
//                                                   hintText: "Search dental clinic",
//                                                   onSubmitted: (value)async {
//                                                     print("Search text: $value");
//                                                     await  loginController.getProfileDetails('' ,'', '', 'true','','','',searchController.text.toString(), value,context);
//                                                     Get.toNamed('/userTypeListWeb');
//                                                   },
//                                                 )
//                                               ),),
//
//                                               const SizedBox(width: 10),
//
//                                               /// Filter Button
//                                               Container(
//                                                 height: 45,
//                                                 width: 45,
//                                                 decoration: BoxDecoration(
//                                                   color: AppColors.primary,
//                                                   borderRadius: BorderRadius.circular(10),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: AppColors.primary.withOpacity(0.3),
//                                                       blurRadius: 6,
//                                                     )
//                                                   ],
//                                                 ),
//                                                 child: IconButton(
//                                                   icon: const Icon(Icons.filter_list, color: Colors.white),
//                                                   onPressed: () {
//
//                                                     // showFilterDialog(context,onApply: ()async{
//                                                     //
//                                                     //   print("Selected State: ${loginController.selectedState}");
//                                                     //   print("Selected District: ${loginController.selectedDistrict}");
//                                                     //   print("Selected Area: ${loginController.selectedArea}");
//                                                     //
//                                                     //   filteredProfiles.map((e) => searchController.text.toString());
//                                                     //   await loginController.getProfileDetails(
//                                                     //     Api.userInfo.read('selectedUserType1'),
//                                                     //     loginController.selectedState,
//                                                     //     loginController.selectedDistrict,
//                                                     //     loginController.selectedTaluka,"",'','','','',
//                                                     //     context,
//                                                     //   );
//                                                     //   Get.back();
//                                                     // },onReset: (){
//                                                     //
//                                                     //   loginController.selectedArea = null;
//                                                     //   loginController.selectedUserType=null;
//                                                     //   loginController.selectedState=null;
//                                                     //   loginController.selectedDistrict=null;
//                                                     // });
// //                   showModalBottomSheet(
//                                                     //                     context: context,
//                                                     //                     isScrollControlled: true,
//                                                     //                     backgroundColor: Colors.transparent,
//                                                     //                     builder: (context) {
//                                                     //                       return FractionallySizedBox(
//                                                     //                         heightFactor: 0.75,
//                                                     //                         child: FilterDrawer(
//                                                     //                           onApply: () async{
//                                                     //                             print("Selected State: ${loginController.selectedState}");
//                                                     //                             print("Selected District: ${loginController.selectedDistrict}");
//                                                     //                             print("Selected Area: ${loginController.selectedArea}");
//                                                     //
//                                                     //                             String userType=  Api.userInfo.read('sUserType');
//                                                     //                             print("ssuser$userType");
//                                                     //                             filteredProfiles.map((e) => searchController.text.toString());
//                                                     //                             await loginController.getProfileDetails(
//                                                     //                               userType ?? "",
//                                                     //                               loginController.selectedState,
//                                                     //                               loginController.selectedDistrict,
//                                                     //                               loginController.selectedTaluka,"true",'','','','',
//                                                     //                               context,
//                                                     //                             );
//                                                     //                             Get.back();
//                                                     //                           },
//                                                     //                           onReset: () {
//                                                     //                             setState(() {
//                                                     //                               // loginController.selectedPlace = null;
//                                                     //                               // loginController.selectedDistrict = null;
//                                                     //                               loginController.selectedArea = null;
//                                                     //                               loginController.selectedUserType=null;
//                                                     //                               loginController.selectedState=null;
//                                                     //                               loginController.selectedDistrict=null;
//                                                     //                             });
//                                                     //                           },
//                                                     //                         ),
//                                                     //                       );
//                                                     //                     },
//                                                     //                   );
//                                                     //                   // _scaffoldKeyUser.currentState!.openDrawer();
//                                                     //                 },
//
//
//                                                     showModalBottomSheet(
//                                                                         context: context,
//                                                                         isScrollControlled: true,
//                                                                         backgroundColor: Colors.transparent,
//                                                                         builder: (context) {
//                                                                           return FractionallySizedBox(
//                                                                             heightFactor: 0.75,
//                                                                             child: FilterDrawer(
//                                                                               onApply: () async{
//                                                                                 print("Selected State: ${loginController.selectedState}");
//                                                                                 print("Selected District: ${loginController.selectedDistrict}");
//                                                                                 print("Selected Area: ${loginController.selectedArea}");
//
//                                                                                 String userType=  Api.userInfo.read('sUserType');
//                                                                                 print("ssuser$userType");
//                                                                                 filteredProfiles.map((e) => searchController.text.toString());
//                                                                                 await loginController.getProfileDetails(
//                                                                                   userType ?? "",
//                                                                                   loginController.selectedState,
//                                                                                   loginController.selectedDistrict,
//                                                                                   loginController.selectedTaluka,"true",'','','','',
//                                                                                   context,
//                                                                                 );
//                                                                                 //Get.back();
//                                                                                 Get.toNamed('/userTypeListWeb');
//
//                                                                               },
//                                                                               onReset: () {
//                                                                                 setState(() {
//                                                                                   // loginController.selectedPlace = null;
//                                                                                   // loginController.selectedDistrict = null;
//                                                                                   loginController.selectedArea = null;
//                                                                                   loginController.selectedUserType=null;
//                                                                                   loginController.selectedState=null;
//                                                                                   loginController.selectedDistrict=null;
//                                                                                 });
//                                                                               },
//                                                                             ),
//                                                                           );
//                                                                         },
//                                                                       );
//                                                   },
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: size * 0.35,
                                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.15),
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                ),
                                                child: CommonSearchTextField(
                                                  controller: searchController,
                                                  hintText: "Search by userType,name,userId,Mobile number",
                                                  onSubmitted: (value) async {
                                                    print("Search text: $value");
                                                    await loginController.getProfileDetails(
                                                        '', '', '', 'true', '', '', '', searchController.text, value, context
                                                    );
                                                    Get.toNamed('/userTypeListWeb');
                                                  },
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ),
                                      // Align(
                                      //     alignment: Alignment.topRight,
                                      //     child: modernSearchBar(size)),
                                      SizedBox(height: size*0.01,),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                               Text(
                                                'What are you looking for?',
                                                style: AppTextStyles.subtitle(context)
                                              ),
                                              const SizedBox(height: 20),

                                              GridView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: title.length,
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 6,
                                                  crossAxisSpacing: 20,
                                                  mainAxisSpacing: 20,
                                                  childAspectRatio: 1.2,
                                                ),
                                                itemBuilder: (context, index) {
                                                  return _dashboardTile(
                                                    title: title[index],
                                                    image: imgUserType(title[index]),
                                                    onTap: () async {
                                                      if (title[index] == "Job Posts/Webinars") {
                                                        Get.toNamed('/viewJobWebinarWebPage');
                                                      } else {
                                                        Api.userInfo.write('sUserType1', title[index]);
                                                        await loginController.getProfileDetails(title[index], '', '', '', 'true', '', '', '', '', context,);
                                                        Get.toNamed('/userTypeListWeb');
                                                      }
                                                    },
                                                  );
                                                },
                                              ),
                                              SizedBox(height: size * 0.02),

                                              Text('Jobs & Webinars',style: AppTextStyles.subtitle(context,color: AppColors.black),),
                                              SizedBox(height: size*0.02,),
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
                                              const SizedBox(height: 10,),
                                              SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.8,
                                                child: TabBarView(
                                                  children: [

                                                    jobController.jobList.isEmpty
                                                        ? _emptyState(context)
                                                        : AnimationLimiter(
                                                          child: GridView.builder(
                                                          padding: const EdgeInsets.all(20),
                                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          crossAxisSpacing: 20,
                                                          mainAxisSpacing: 20,
                                                          childAspectRatio: 2.3,),
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
                                                                child: InkWell(
                                                                  onTap: () async{
                                                                    print("nnn${Api.userInfo.read('selectJobId')}");
                                                                    // await jobController.getJobsById(
                                                                    //     jobs.jobId.toString(), context);
                                                                    // await  jobController.getAppliedJobsAdmin(
                                                                    //     jobs.jobId.toString(), context);
                                                                    Api.userInfo.write('selectJobId',jobs.jobId.toString());
                                                                    Api.userInfo.write('activeStatus',jobs.isActive.toString());
                                                                    Get.toNamed('/viewJobDetailWebPage');
                                                                  },
                                                                  child: _modernCard(
                                                                    title: jobs.jobTitle ?? "",
                                                                      desc: getPlainText(jobs.jobDescription),
                                                                      //desc: jobs.jobDescription ?? "",
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
                                                            padding: const EdgeInsets.all(20),
                                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          crossAxisSpacing: 20,
                                                          mainAxisSpacing: 20,
                                                          childAspectRatio: 2.2,
                                                            ),
                                                            itemCount: jobController.webinarList.length,
                                                            itemBuilder: (context, index) {
                                                          final webinars = jobController.webinarList[index];
                                                          final created = DateTime.parse(webinars.createdDate.toString());
                                                          final postedAgo = timeAgo(created);
                                                          return AnimationConfiguration.staggeredList(
                                                            position: index,
                                                            duration: const Duration(milliseconds: 1300),
                                                            child: SlideAnimation(
                                                              verticalOffset: 120.0,
                                                              curve: Curves.easeOutBack,
                                                              child: FadeInAnimation(
                                                                child: GestureDetector(
                                                                  onTap: () async{
                                                                    // await jobController.getWebinarById(
                                                                    //     webinars.webinarId.toString(),
                                                                    //     webinars.isActive.toString(),
                                                                    //     context);
                                                                    // await   jobController.getAppliedWebinarsAdmin(webinars.webinarId.toString(),context);
                                                                    Api.userInfo.write('webinarId', webinars.webinarId.toString());
                                                                    Api.userInfo.write('activeStatus1',webinars.isActive.toString());
                                                                    Get.toNamed('/viewWebinarDetailWebPage');
                                                                  },
                                                                  child: _modernCard(
                                                                    title: webinars.webinarTitle ?? "",
                                                                      desc: getPlainText(webinars.webinarDescription),
                                                                      //desc: webinars.webinarDescription ?? "",
                                                                    status: webinars.isActive == true ? "Open" : "Closed",
                                                                    statusColor: webinars.isActive == true
                                                                        ? Colors.green
                                                                        : Colors.red,
                                                                    subtitle: "Webinar",
                                                                    trailing: "${webinars.totalApplicants ?? 0} Joined",
                                                                    onTap: ()async {
                                                                   await   jobController.getWebinarById(
                                                                          webinars.webinarId.toString(),
                                                                          webinars.isActive.toString(),
                                                                          context);
                                                                      Get.toNamed(
                                                                        '/createJobWebPage',
                                                                        arguments: {
                                                                          "selectedString": "Webinar"
                                                                        },
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
                                              ),
                                            ]),
                                      )
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
    height: size*0.15,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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

        /// Subtitle
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

        const SizedBox(height: 5),

        Expanded(
          child: Text(
            desc,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context,
              color: Colors.grey.shade700,
            ),
          ),
        ),


        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              trailing,
              style: AppTextStyles.caption(context,
                fontWeight: FontWeight.w500,
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
  final double size = MediaQuery.of(context).size.width;
  return  Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox, size: size*0.012, color: Colors.grey),
        const SizedBox(height: 10),
        Text("No data found",style: AppTextStyles.caption(context),),
      ],
    ),
  );
}
Widget _dashboardTile({
  required String title,
  required String image,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(image, fit: BoxFit.cover,width: double.infinity,),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}