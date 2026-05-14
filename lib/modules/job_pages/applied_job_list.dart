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

class AppliedJobLists extends StatefulWidget {
  const AppliedJobLists({super.key});
  @override
  State<AppliedJobLists> createState() => _AppliedJobListsState();
}
class _AppliedJobListsState extends State<AppliedJobLists> {
  final jobController=Get.put(JobController());
  String selectedTab = "All";
  @override
  void initState() {
    super.initState();
    jobController.getJobSeekersAppliedLists(Api.userInfo.read('userId')??"",context);
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    String getFirstLetter(String text) {
      if (text.isEmpty) return "";
      return text[0].toUpperCase();
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
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
        title: Text('My Jobs',style: AppTextStyles.subtitle(context,color: AppColors.black),),
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
          return Column(
            children: [
              AnimationLimiter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
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
                              padding: const EdgeInsets.all(10.0),
                              child: GestureDetector(
                                onTap: (){
                                  jobController.getJobsById(appliedJobs.jobId!, context);
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
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: getStatusColor(appliedJobs.status ?? "").withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(20),
                                                      // border: Border.all(
                                                      //   color: getStatusColor(Jobs.status ?? ""),
                                                      //   width: 1,
                                                      // ),
                                                    ),
                                                    child: Text(
                                                      appliedJobs.status ?? "Not Applied",
                                                      style: TextStyle(
                                                        fontSize: size * 0.03,
                                                        fontWeight: FontWeight.w500,
                                                        color: getStatusColor(appliedJobs.status ?? ""),
                                                      ),
                                                    ),
                                                  ),
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
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
