import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/profiles/jobseeker_viewprofile.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

 class ViewWebinarApplications extends StatefulWidget {
  const ViewWebinarApplications({super.key});

  @override
  State<ViewWebinarApplications> createState() => _ViewWebinarApplicationsState();
  }
 class _ViewWebinarApplicationsState extends State<ViewWebinarApplications> {
   final jobController = Get.put(JobController());
   final loginController=Get.put(LoginController());
   @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text('Webinar Applications',style: AppTextStyles.subtitle(context,color: AppColors.black),),
      backgroundColor: AppColors.white,iconTheme: const IconThemeData(color: AppColors.black),
),
      body: GetBuilder<JobController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  if (jobController.appliedWebinarList.isEmpty)
               Center(child: Text('No data found', style: AppTextStyles.caption(context, color: AppColors.black,fontWeight: FontWeight.normal),)),

                  if( jobController.appliedWebinarList.isNotEmpty)
              AnimationLimiter(
                child: ListView.builder(
                itemCount: jobController.appliedWebinarList.length,
                    padding: const EdgeInsets.all(12),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      //if(jobController.jobList.isNotEmpty)
                      final appliersList = jobController.appliedWebinarList[index];
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
                            onTap: ()async{
                              await   loginController.getProfileByUserId(appliersList.jobSeekerId??"", context);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const JobSeekerProfilePage()),);
                            },
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: AppColors.grey,width: 0.4,),color: AppColors.white),
                              child:  Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        radius: size*0.1,backgroundColor:AppColors.primary,
                                        child: ClipOval(
                                          child: FadeInImage.assetNetwork(
                                            placeholder: 'assets/images/doctor1.jpg',
                                            image: "${AppConstants.baseUrl}${appliersList.image}",
                                            fit: BoxFit.cover,
                                            width: size*0.19,
                                            height:  size*0.19,
                                            imageErrorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                    width:  size*0.19,
                                                    height:  size*0.19,
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
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(child:
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appliersList.name.toString()??"",
                                          style: TextStyle(
                                            fontSize: size * 0.035,color: AppColors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // Text("ID: ${appliersList.jobSeekerId}",
                                        //     style: TextStyle(fontSize: size * 0.035, color: Colors.black87)),
                                        Text("Email: ${appliersList.email}",
                                            style: TextStyle(fontSize: size * 0.035, color: Colors.black)),
                                        Text("JobId: ${appliersList.webinarId}",
                                            style: TextStyle(fontSize: size * 0.035, color: Colors.black)),

                                        const SizedBox(height: 8),

                                        SizedBox(
                                          height: size*0.06,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width:size*0.08,
                                                child: IconButton(
                                                  icon: Icon(Icons.call, color: AppColors.primary, size: size * 0.06),
                                                  onPressed: (){
                                                    launchCall(appliersList.mobileNumber.toString());
                                                  },
                                                ),
                                              ),
                                              Text(appliersList.mobileNumber.toString(),
                                                  style: TextStyle(fontSize: size * 0.035)),

                                              IconButton(
                                                icon: Icon(Icons.arrow_forward, color: AppColors.primary, size: size * 0.06),
                                                onPressed: ()async{
                                                  await   loginController.getProfileByUserId(appliersList.jobSeekerId??"", context);
                                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const JobSeekerProfilePage()),);                                      },
                                              ),

                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ))

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
              )
                ],
              ),
            ),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
