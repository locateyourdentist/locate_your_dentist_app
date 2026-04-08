import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/dashboard/slider_images_dashboard.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/modules/profiles/jobseeker_viewprofile.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


class JobSeekerDashboard extends StatefulWidget {
  const JobSeekerDashboard({Key? key}) : super(key: key);
  @override
  State<JobSeekerDashboard> createState() => _JobSeekerDashboardState();
}
class _JobSeekerDashboardState extends State<JobSeekerDashboard> {
  final List<Color> mildColors = [
    const Color(0xFFE8F0FE),
    const Color(0xFFE9F7EF),
    const Color(0xFFFFF4E6),
    const Color(0xFFFDEEEF),
    const Color(0xFFF3EAFB),
    const Color(0xFFF7F7F7),
  ];
  final TextEditingController searchController=TextEditingController();
  final jobController=Get.put(JobController());
  final loginController=Get.put(LoginController());
  final planController=Get.put(PlanController());
  final notificationController=Get.put(NotificationController());
  int currentIndex=0;
  bool?isSelected;

 @override
  void initState() {
    super.initState();
    _refresh();
 }
  Future<void> _refresh() async {
   // await loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
    await jobController.getJobListJobSeekers(search: " ",jobCategory:loginController.selectedCategories,context: context);
    await jobController.getJobSeekersAppliedLists(Api.userInfo.read('userId')??"",context);
    await jobController.getWebinarListJobSeekers('','','',context);
    await notificationController.getNotificationListAdmin(context);
    await planController.getUploadImages(userId:Api.userInfo.read('userId')??"",userType:  "Job Seekers",context: context);
 }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    String getFirstLetter(String text) {
      if (text.isEmpty) return "";
      return text[0].toUpperCase();
    }
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          centerTitle: false,elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                 AppColors.primary,AppColors.secondary
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome Back',style: TextStyle(fontSize: size*0.04,fontWeight: FontWeight.bold,color: Colors.white,),),
              Text(Api.userInfo.read('personName')??"",style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.bold,color: Colors.white),),
            ],
          ),
          leading: Padding(
            padding: const EdgeInsets.all(5.0),
            child: GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) =>  const JobSeekerProfilePage(),
                  ),
                );
              },
              child: ProfileImageWidget(size: size),

          ),
          ),
          actions: [
            GetBuilder<NotificationController>(
                builder: (controller) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_none,
                          color: AppColors.white,
                          size: size * 0.08,
                        ),
                        onPressed: () {
                          notificationController.getNotificationListAdmin(context);
                          Get.toNamed('/notificationPage');
                          notificationController.update();
                          },
                      ),
                      if (int.tryParse(notificationController.unreadCount ?? "0")! > 0)
                        Positioned(
                            top: 0,
                            right: 15,
                            child: CircleAvatar(
                              radius: size*0.024,backgroundColor: Colors.redAccent,child: Text(
                              notificationController.unreadCount.toString()??"",style: TextStyle(color: AppColors.white,fontWeight: FontWeight.w500,fontSize: size*0.025),
                            ),
                            ))
                    ],
                  );
                }
            )
          ],

        ),
        body: GetBuilder<JobController>(
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
              child:Column(
                children: [
                  Container(
                    //margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    //padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,AppColors.secondary
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40),bottomRight: Radius.circular(40)),
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
                          borderRadius: BorderRadius.circular(50),
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
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  hintText: "Search your job by clinic name,area..",
                                  hintStyle: AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: AppColors.grey),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.normal),
                                cursorColor: AppColors.primary,
                                onSubmitted: (value) {
                                  print("Search text: $value");
                                  jobController.getJobListJobSeekers(search:searchController.text.toString() ,context: context);
                                  Get.toNamed('/filterPageJobSeekersPage');
                                  },
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: AppColors.white,border: Border.all(color: AppColors.primary,width: 1.3)),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () {
                                      // _scaffoldKeyUser.currentState!.openDrawer();
                                    },
                                    icon:  Icon(Icons.filter_list, color: Colors.black, size: size*0.06),
                                    splashRadius: 22,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Let Find a Job With LYD',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: size*0.045),),
                      //  Text('With LYD',textAlign:TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: size*0.05),),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Popular Jobs/Webinars Posts' ,style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.normal,color: Colors.grey),),
                            Align(
                              alignment: Alignment.topRight,
                              child: TextButton(
                                onPressed: ()async{
                                  await jobController.getWebinarListJobSeekers('','','',context);
                                  Get.toNamed('/viewWebinarListJobseekersPage');
                                  },
                                child:Text(
                                  "View Webinars",softWrap: true,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,fontSize: size*0.03,decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),),
                          ],
                        ),
                        const SizedBox(height: 5),
                         DashboardCarousel(
                           imageList: planController.editUploadImage
                               .map((e) => e.url ?? '')
                               .where((url) => url.isNotEmpty)
                               .toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Find your Top Jobs',style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.normal,color: Colors.grey),),
                            Align(
                              alignment: Alignment.topRight,
                              child: TextButton(
                                onPressed: (){
                                  jobController.getJobListJobSeekers(search:searchController.text.toString() ,context: context);
                                  Get.toNamed('/filterPageJobSeekersPage');

                                },
                                child:Text(
                                  "View All",softWrap: true,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,fontSize: size*0.03,decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if(jobController.jobListJobSeekers.isEmpty)
                          Center(child: Text('No Preference Jobs found',style: AppTextStyles.caption(context),),),
                        if(jobController.isLoading==true)
                          const CircularProgressIndicator(color: AppColors.primary,),

                        if(jobController.jobListJobSeekers.isNotEmpty)

                          SizedBox(
                        height: size*0.55,
                        child: AnimationLimiter(
                          child: ListView.builder(
                              itemCount: jobController.jobListJobSeekers.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: ( BuildContext context,int index) {
                                final Jobs=jobController.jobListJobSeekers[index];
                                final logoUrl = (Jobs.logoImage != null && Jobs.logoImage!.isNotEmpty)
                                    ? Jobs.logoImage!.first
                                    : null;
                                print('logo url$logoUrl');
                                final created =
                                DateTime.parse(Jobs.createdDate.toString());
                                final postedAgo = timeAgo(created);
                                //print('${AppConstants.baseUrl}${Jobs.image}');
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 1300),
                                    child: SlideAnimation(
                                      horizontalOffset: 120.0,
                                      curve: Curves.easeOutBack,
                                      child: FadeInAnimation(
                                        child: Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: GestureDetector(
                                                      onTap: ()async{
                                                                 await jobController.getJobsById(Jobs.jobId!, context);
                                                                 Get.toNamed('/jobViewProfilePage');
                                                                 isSelected = currentIndex == index;
                                                      },
                                                      child: Container(
                                                                  height: size*0.58,
                                                                    width: size*0.8,
                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
                                                                      color: AppColors.white,border: Border.all(color: AppColors.primary,width: 1.5)
                                                                      //color: mildColors[index % 5],
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(10.0),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: size * 0.063,
                                              backgroundColor: AppColors.primary,
                                              child: ClipOval(
                                                child: Image.network(
                                                  logoUrl??"",
                                                  //Jobs.logoImage.toString()??"",
                                                  fit: BoxFit.cover,
                                                  width: size * 0.14,
                                                  height: size * 0.12,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return
                                                      CircleAvatar(
                                                        radius: size * 0.063,
                                                        backgroundColor:getRandomColor(Jobs.orgName.toString()),
                                                        child: Text(
                                                          getFirstLetter(Jobs.orgName.toString()),
                                                          style: TextStyle(
                                                            fontSize: size * 0.04,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  // loadingBuilder: (context, child, loadingProgress) {
                                                  //   if (loadingProgress == null) return child;
                                                  //   return Center(
                                                  //     child: CircularProgressIndicator(
                                                  //       value: loadingProgress.expectedTotalBytes != null
                                                  //           ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                  //           : null,
                                                  //     ),
                                                  //   );
                                                  // },
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 10,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(Jobs.orgName.toString(),style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.black),),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(Jobs.jobType.toString(),style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.grey),),
                                                    const SizedBox(width: 10,),
                                                    Text(postedAgo,style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.grey),),

                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(Jobs.jobTitle.toString(),softWrap:true,style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.black),),
                                        const SizedBox(height: 2),

                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.location_on_rounded, color: Colors.grey,size: size*0.04,),
                                            const SizedBox(width: 5,),
                                            Expanded(child: Text("${Jobs.city.toString()}, ${Jobs.district.toString()} ,${Jobs.state.toString()}",softWrap:true,style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.grey),)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.currency_rupee_rounded, color: Colors.grey,size: size*0.04,),
                                            Text(Jobs.salary.toString(),style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.grey),),
                                          ],
                                        ),
                                        Jobs.totalApplicants != 0 ?
                                        Align(
                                          alignment:Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Container(
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                                  gradient: const LinearGradient(
                                                    colors: [AppColors.primary,AppColors.secondary],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),),
                                              height: size*0.07,
                                              width: size*0.3,
                                              child: Center(child: Text('${Jobs.totalApplicants} Applied',softWrap:true,style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.normal,color: Colors.white),)),

                                            ),
                                          ),
                                        ):
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                               'Be a early Applicant',softWrap:true,style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.normal,color: Colors.black54),),
                                        )
                                                                        ],
                                                                      ),
                                                                    ),
                                                      ),
                                                    ),),
                                      ),
                                    ),
                                  );

                          }),
                        ),
                      ),
                        Text('Applied Jobs Lists' ,style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.normal,color: Colors.grey),),
                        const SizedBox(height: 10),

                        AnimationLimiter(
                          child: ListView.builder(
                              itemCount: jobController.jobSeekersAppliedLists.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: ( BuildContext context,int index) {
                                final appliedJobs=jobController.jobSeekersAppliedLists[index];
                                final logoUrl = (appliedJobs.logoImage != null && appliedJobs.logoImage!.isNotEmpty)
                                    ? appliedJobs.logoImage!.first
                                    : null;
                                print('log url$logoUrl');
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 1300),
                                  child: SlideAnimation(
                                    verticalOffset: 120.0,
                                    curve: Curves.easeOutBack,
                                    child: FadeInAnimation(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: GestureDetector(
                                          onTap: (){
                                            jobController.getJobsById(appliedJobs.jobId!, context);
                                            print('jobb id${appliedJobs.jobId}');
                                            Get.toNamed('/jobViewProfilePage');                            },
                                          child: Container(
                                            height: size*0.54,
                                            width: size,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white,),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: size * 0.22,
                                                        height: size * 0.22,
                                                        clipBehavior: Clip.hardEdge,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: Colors.white,
                                                        ),
                                                        child: Image.network(
                                                          logoUrl??"",
                                                          //"${AppConstants.baseUrl}${appliedJobs.image ?? ""}",
                                                          fit: BoxFit.cover,width: size * 0.26,
                                                            height: size * 0.26,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return Container(
                                                              decoration: BoxDecoration(color: getRandomColor(appliedJobs.orgName.toString()),
                                                              ),
                                                                //'assets/images/hospital.jpg',
                                                                //fit: BoxFit.cover,
                                                                width: size * 0.2,
                                                                height: size * 0.2,
                                                              child: Center(
                                                                child: Text(getFirstLetter(appliedJobs.orgName.toString(),),style: AppTextStyles.headline(context,color: AppColors.white),
                                                                ),
                                                              ),
                                                            );
                                                          },)
                                                      ),

                                                  //
                                                  const SizedBox(width: 10,),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(appliedJobs.orgName.toString()??"N/A",style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.black),),
                                                        Text(appliedJobs.jobType.toString()??"N/A",style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.grey),),

                                                  const SizedBox(height: 15,),
                                                  Text(appliedJobs.jobTitle.toString()??"N/A",softWrap:true,style: TextStyle(fontSize: size*0.032,fontWeight: FontWeight.bold,color: Colors.black),),
                                                  const SizedBox(height: 5),

                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Icon(Icons.location_on_rounded, color: Colors.grey,size: size*0.04,),
                                                      const SizedBox(width: 5,),
                                                      Text("${appliedJobs.city.toString()??"N/A"},${appliedJobs.district.toString()??"N/A"}",style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.grey),),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.currency_rupee_rounded, color: Colors.grey,size: size*0.04,),
                                                      Text(appliedJobs.salary.toString()??"N/A",style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.grey),),
                                                    ],
                                                  ),
                                                  Align(
                                                    alignment:Alignment.bottomRight,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child:    Text('Posted On ${  DateFormat('MMM dd, yyyy').format(DateTime.parse(appliedJobs.createdDate.toString()))}',style: TextStyle(fontSize: size*0.025,fontWeight: FontWeight.normal,color: Colors.black54),),
                                                    ),
                                                  )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ],
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );

                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            );
          }
        ),
        bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),

      );
  }
}
