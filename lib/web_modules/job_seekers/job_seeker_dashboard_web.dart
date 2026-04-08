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
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/dashboard/clinic_image_caurosel.dart';


class JobSeekerDashboardWeb extends StatefulWidget {
  const JobSeekerDashboardWeb({Key? key}) : super(key: key);
  @override
  State<JobSeekerDashboardWeb> createState() => _JobSeekerDashboardWebState();
}
class _JobSeekerDashboardWebState extends State<JobSeekerDashboardWeb> {
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
  int appliedCount = 0;
  int selectedCount = 0;
  int rejectedCount = 0;

  void calculateStats(List jobs) {
    appliedCount = 0;
    selectedCount = 0;
    rejectedCount = 0;

    for (var job in jobs) {
      if (job['isApplied'] == true) {
        appliedCount++;

        if (job['status'] == "Selected") {
          selectedCount++;
        } else if (job['status'] == "Rejected") {
          rejectedCount++;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
   // await jobController.getJobListJobSeekers(search: " ",jobCategory:loginController.selectedCategories,context: context);
    await jobController.getJobListJobSeekers(search: " ",context: context);
    await jobController.getJobSeekersAppliedLists(Api.userInfo.read('userId')??"",context);
    await jobController.getWebinarListJobSeekers('','','',context);
  //  await notificationController.getNotificationListAdmin(context);
    await planController.getUploadImages(userType: "Dental Clinic", context: context);
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: size * 0.08,
        title: "LYD",
        onLogout: () {
        },
        onNotification: () {
        },
      ),
      body: GetBuilder<PlanController>(
          builder: (controller) {
            String getFirstLetter(String text) {
              if (text.isEmpty) return "";
              return text[0].toUpperCase();
            }
            return RefreshIndicator(
              onRefresh: _refresh,
              child: Row(
                children: [
                  const AdminSideBar(),
                  GetBuilder<PlanController>(
                      builder: (controller) {
                      return Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
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
                                    padding: const EdgeInsets.all(30.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Featured Clinics", style: AppTextStyles.body(context,fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 20),
                                        if (loginController.profileList.isEmpty)
                                          Center(child: Text('No data found', style: AppTextStyles.caption(context))),
                                        if (loginController.isLoading)
                                          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                        if (loginController.profileList.isNotEmpty)
                                          GetBuilder<PlanController>(
                                            builder: (controller) {
                                              final imageUrls = controller.editUploadImage1
                                                  .map((clinic) => clinic.url ?? "")
                                                  .where((url) => url.isNotEmpty)
                                                  .toList();
                                              return ClinicImageCarousel(imageUrls: imageUrls);
                                            },
                                          ),

                                        const SizedBox(height: 40),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: SizedBox(
                                            width: size*0.35,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(40),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                   Icon(Icons.search, color: Colors.grey,size: size*0.012,),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: TextField(
                                                      controller: searchController,
                                                      decoration: const InputDecoration(
                                                        hintText: "Search jobs by clinic, area...",
                                                        border: InputBorder.none,
                                                      ),
                                                      onTap: ()async{
                                                        await jobController.getJobListJobSeekers(
                                                          search: searchController.text.toString(),
                                                          context: context,
                                                        );
                                                        Get.toNamed('/jobListJobSeekersWebPage');
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon:  Icon(Icons.filter_list, color: AppColors.grey,size: size*0.012,),
                                                    onPressed: () => Get.toNamed('/filterPageJobSeekersPage'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 30),

                                        // Section heading


                                        Text("Job Summary",
                                            style: AppTextStyles.body(context,fontWeight: FontWeight.bold)),
                                        SizedBox(height: size*0.01,),
                                        dashboardStats(jobController),
                                        SizedBox(height: size*0.01,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Popular Jobs & Webinars",
                                                style: AppTextStyles.body(context,fontWeight: FontWeight.bold)),

                                            Align(
                                              alignment: Alignment.topRight,
                                              child: TextButton(
                                                onPressed: ()async{
                                                  await jobController.getWebinarListJobSeekers('','','',context);
                                                  Get.toNamed('/webinarListWebPage');
                                                },
                                                child:Text(
                                                  "View Webinars",softWrap: true,
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,fontSize: size*0.0075,decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ),),
                                          ],
                                        ),
                                        SizedBox(height: size*0.01,),

                                        GetBuilder<JobController>(
                                            builder: (controller) {
                                              return GridView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: size > 1200 ? 3 : 2,
                                                crossAxisSpacing: 20,
                                                mainAxisSpacing: 20,
                                                childAspectRatio: 2.8,
                                              ),
                                              itemCount: jobController.jobListJobSeekers.length,
                                              itemBuilder: (context, index) {

                                                final job = jobController.jobListJobSeekers[index];
                                               // final Jobs=jobController.jobListJobSeekers[index];
                                                final logoUrl = (job.logoImage != null && job.logoImage!.isNotEmpty)
                                                    ? job.logoImage!.first
                                                    : null;
                                                print('logo url$logoUrl');
                                                return MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      Api.userInfo.write('selectJobId',job.jobId.toString());
                                                      Api.userInfo.write('activeStatus',job.isActive.toString());
                                                      await jobController.getJobsById(job.jobId!, context);
                                                      Get.toNamed('/viewJobDetailWebPage');
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(16),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.08),
                                                            blurRadius: 12,
                                                            offset: const Offset(0, 6),
                                                          ),
                                                        ],
                                                      ),
                                                      padding:  const EdgeInsets.all(16),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: size * 0.025,
                                                            height: size * 0.025,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              //shape: BoxShape.circle,
                                                              border: Border.all(
                                                                //color: getRandomColor(Jobs.orgName.toString()),
                                                                  color: Colors.grey.shade300,
                                                                  width: 1.5),
                                                              color: Colors.grey.shade100,
                                                            ),
                                                            child: ClipRRect(
                                                              child: Image.network(
                                                                logoUrl??"",
                                                                //Jobs.logoImage.toString()??"",
                                                                fit: BoxFit.cover,
                                                                width: size * 0.025,
                                                                height: size * 0.025,
                                                                errorBuilder: (context, error, stackTrace) {
                                                                  return
                                                                    Container(
                                                                      //  alignment: Alignment.center,
                                                                      width: size * 0.025,
                                                                      height: size * 0.025,
                                                                      decoration: BoxDecoration(
                                                                        color: AppColors.white, borderRadius: BorderRadius.circular(10),
                                                                        //getRandomColor(Jobs.orgName.toString()),
                                                                      ),
                                                                      child: Center(
                                                                        child: Text(
                                                                          getFirstLetter(job.orgName.toString()),
                                                                          style: AppTextStyles.body(
                                                                            context,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: getRandomColor(job.orgName.toString()),
                                                                          ),
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
                                                          SizedBox(width: size*0.01,),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(job.orgName ?? "",
                                                                    style:AppTextStyles.body(context,fontWeight: FontWeight.bold)),
                                                                const SizedBox(height: 8),
                                                                Text(job.jobTitle ?? "",
                                                                    style:AppTextStyles.caption(context,fontWeight: FontWeight.normal)),
                                                                const Spacer(),
                                                                Row(
                                                                  children: [
                                                                     Icon(Icons.location_on, size: size*0.013, color: Colors.grey),
                                                                    const SizedBox(width: 4),
                                                                    Expanded(
                                                                      child: Text("${job.city}, ${job.state}",
                                                                          style:  AppTextStyles.caption(context,color:Colors.grey)),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }
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
                    }
                  )

                ],
              ),
            );
          }
      ),
    );
  }
  Widget dashboardStats(JobController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard("Applied", appliedCount, Colors.blue),
        _statCard("Selected", selectedCount, Colors.green),
        _statCard("Rejected", rejectedCount, Colors.red),
      ],
    );
  }
  Widget _statCard(String title, int count, Color color) {
    double size=MediaQuery.of(context).size.width;
    return Expanded(
      child: Container(
        height: size*0.06,
        width: size*0.15,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color:  AppColors.white,
          // gradient: LinearGradient(
          //   colors: [color.withOpacity(0.8), color],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: AppTextStyles.subtitle(context,color:color,)
            ),
            const SizedBox(height: 8),
            Text(
              title,
                style: AppTextStyles.body(context,color: color,fontWeight: FontWeight.bold)

            ),
          ],
        ),
      ),
    );
  }
}
