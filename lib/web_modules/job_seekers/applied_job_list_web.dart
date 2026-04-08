import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

class AppliedJobListsWeb extends StatefulWidget {
  const AppliedJobListsWeb({super.key});
  @override
  State<AppliedJobListsWeb> createState() => _AppliedJobListsWebState();
}
class _AppliedJobListsWebState extends State<AppliedJobListsWeb> {
  final jobController=Get.put(JobController());
  String selectedTab = "All";
  @override
  void initState() {
    super.initState();
    jobController.getJobSeekersAppliedLists(Api.userInfo.read('userId')??"",context);
    final titles = [
      "All",
      ...{
        for (var n in jobController.jobSeekersAppliedLists)
          n.status.toString().trim()
      }
    ];
    final filteredList = selectedTab == "All"
        ? jobController.jobSeekersAppliedLists
        : jobController.jobSeekersAppliedLists
        .where((n) =>
    n.status.toString().trim()==
        selectedTab)
        .toList();
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    String getFirstLetter(String text) {
      if (text.isEmpty) return "";
      return text[0].toUpperCase();
    }
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,backgroundColor: AppColors.white,
      //   iconTheme: const IconThemeData(color: AppColors.white),
      //   leading: Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: GestureDetector(
      //       onTap: () {
      //         Navigator.pop(context);
      //       },
      //       child: Container(
      //         decoration: const BoxDecoration(
      //           shape: BoxShape.circle,
      //           gradient: LinearGradient(
      //             colors: [AppColors.primary, AppColors.secondary],
      //             begin: Alignment.topLeft,
      //             end: Alignment.bottomRight,
      //           ),
      //         ),
      //         child: const Center(
      //           child: Icon(
      //             Icons.arrow_back,
      //             color: AppColors.white,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      //   title: Text('My Jobs',style: AppTextStyles.subtitle(context,color: AppColors.black),),
      // ),
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: size * 0.08,
        title: "LYD",
        onLogout: () {
        },
        onNotification: () {
        },
      ),
      body:  GetBuilder<JobController>(
          builder: (controller) {
            if (controller.isLoading == true) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (controller.jobSeekersAppliedLists.isEmpty) {
              return Center(
                child: Text(
                  'No data found',
                  style: AppTextStyles.caption(context),
                ),
              );
            }
            final titles = [
              "All",
              ...{
                for (var n in controller.jobSeekersAppliedLists)
                  n.status.toString().trim()
              }
            ];
            final filteredList = selectedTab == "All"
                ? controller.jobSeekersAppliedLists
                : controller.jobSeekersAppliedLists
                .where((n) =>
            n.status.toString().trim()==
                selectedTab)
                .toList();
            return Row(
              children: [
                const AdminSideBar(),

                Expanded(

                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                            ],
                          ),
                          child: Column(
                            children: [
                              AnimationLimiter(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    children: [
                                      SizedBox(height: size*0.01,),
                              if (controller.isLoading == true)
                         const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                        ),

                            if (controller.jobSeekersAppliedLists.isEmpty)
                       Center(
                      child: Text(
                      'No data found',
                      style: AppTextStyles.caption(context),
                      ),
                      ),

                                      Text("MY JOBS",style: AppTextStyles.body(context,fontWeight: FontWeight.bold,color: Colors.black),),
                                        SizedBox(height: size*0.01,),
                                      Row(
                                        children: titles.map((t) {
                                          final isSelected = selectedTab == t;

                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedTab = t;
                                              });
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 10),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 18, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.greyLight,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(t,
                                                // t.toUpperCase(),
                                                style: AppTextStyles.caption(context,
                                                  color: isSelected ? Colors.white : Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              AnimationLimiter(
                                child: ListView.builder(
                                    itemCount: filteredList.length,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: ( BuildContext context,int index) {
                                      //final appliedJobs=jobController.jobSeekersAppliedLists[index];
                                      final appliedJobs=filteredList[index];
                                      final logoUrl = (appliedJobs.logoImage != null && appliedJobs.logoImage!.isNotEmpty)
                                          ? appliedJobs.logoImage!.first
                                          : null;
                                      print('logo url$logoUrl');
                                      return AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration: const Duration(milliseconds: 1300),
                                        child: SlideAnimation(
                                          verticalOffset: 120.0,
                                          curve: Curves.easeOutBack,
                                          child: FadeInAnimation(
                                            child: Padding(
                                              padding: const EdgeInsets.all(30.0),
                                              child: GestureDetector(
                                                onTap: (){
                                                  jobController.getJobsById(appliedJobs.jobId!, context);
                                                  Get.toNamed('/viewJobDetailWebPage');
                                                },
                                                child: Container(
                                                  height: size*0.1,
                                                  width: size,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius: BorderRadius.circular(12),
                                                    boxShadow: const [
                                                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(12.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [

                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Container(
                                                                width: size * 0.04,
                                                                height: size * 0.04,
                                                                clipBehavior: Clip.hardEdge,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  color: Colors.white,
                                                                  border: Border.all(
                                                                    //color: getRandomColor(Jobs.orgName.toString()),
                                                                      color: Colors.grey.shade300,
                                                                      width: 1.5),
                                                                ),
                                                                child: Image.network(
                                                                  logoUrl??"",
                                                                  //"${AppConstants.baseUrl}${appliedJobs.image ?? ""}",
                                                                  fit: BoxFit.cover,    width: size * 0.04,
                                                                  height: size * 0.04,
                                                                  errorBuilder: (context, error, stackTrace) {
                                                                    return Container(
                                                                      decoration: BoxDecoration(color:
                                                                      AppColors.white,
                                                                        borderRadius: BorderRadius.circular(10),

                                                                        //getRandomColor(appliedJobs.orgName.toString()
                                                                      ),
                                                                      //'assets/images/hospital.jpg',
                                                                      //fit: BoxFit.cover,
                                                                      width: size * 0.04,
                                                                      height: size * 0.04,
                                                                      child: Center(
                                                                        child: Text(getFirstLetter(appliedJobs.orgName.toString(),),style: AppTextStyles.headline(context,color: getRandomColor(appliedJobs.orgName.toString())),
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
                                                                  Text(appliedJobs.orgName.toString()??"N/A",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: Colors.black),),
                                                                  Text(appliedJobs.jobType.toString()??"N/A",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: Colors.grey),),
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                    decoration: BoxDecoration(
                                                                      color: getStatusColor(appliedJobs.status ?? ""),
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      // border: Border.all(
                                                                      //   color: getStatusColor(Jobs.status ?? ""),
                                                                      //   width: 1,
                                                                      // ),
                                                                    ),
                                                                    child: Text(
                                                                      appliedJobs.status ?? "Not Applied",
                                                                      style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,  color: AppColors.white,),
                                                                  ),),
                                                                  const SizedBox(height: 5,),
                                                                  Text(appliedJobs.jobTitle.toString()??"N/A",softWrap:true,
                                                                    style: AppTextStyles.caption(context,fontWeight: FontWeight.w400,color: Colors.black),),
                                                                  const SizedBox(height: 5),

                                                                  Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Icon(Icons.location_on_rounded, color: Colors.grey,size: size*0.01,),
                                                                      const SizedBox(width: 5,),
                                                                      Text("${appliedJobs.city.toString()??"N/A"},${appliedJobs.district.toString()??"N/A"}",   style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: Colors.grey),),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Icon(Icons.currency_rupee_rounded, color: Colors.grey,size: size*0.012,),
                                                                      Text(appliedJobs.salary.toString()??"N/A",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                                                                    ],
                                                                  ),
                                                                  Align(
                                                                    alignment:Alignment.bottomRight,
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(5.0),
                                                                      child:    Text('Posted On ${  DateFormat('MMM dd, yyyy').format(DateTime.parse(appliedJobs.createdDate.toString()))}',   style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: Colors.black54),),
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
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }
}
