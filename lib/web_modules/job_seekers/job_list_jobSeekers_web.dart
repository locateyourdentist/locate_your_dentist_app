import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_drawer.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/common/filter_side_bar.dart';


class JobSeekerFilterWeb extends StatefulWidget {
  const JobSeekerFilterWeb({super.key});
  @override
  State<JobSeekerFilterWeb> createState() => _JobSeekerFilterWebState();
}
class _JobSeekerFilterWebState extends State<JobSeekerFilterWeb> {
  final jobController=Get.put(JobController());
  final TextEditingController searchController = TextEditingController();
 // final GlobalKey<ScaffoldState> _scaffoldKeyJobSeekers = GlobalKey<ScaffoldState>();
  final loginController=Get.put(LoginController());
  @override
  void initState(){
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
    loginController.selectedCategories = [];
    loginController.selectedArea = null;
    loginController.selectedUserType = null;
    loginController.selectedState = null;
    loginController.selectedDistrict = null;
    loginController.selectedDistance = null;
    loginController.selectedTaluka = null;
    loginController.selectedJobType = null;
    loginController.selectedSalary = null;
   // loginController.update();
    await loginController.getProfileByUserId(
      Api.userInfo.read('userId') ?? "",
      context,
    );
    await jobController.getJobListJobSeekers(
      search: searchController.text.toString(),
      state: null,
      district: null,
      city: null,
      salary: null,
      jobType: null,
      jobCategory: [],
      context: context,
    );
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    String getFirstLetter(String text) {
      if (text.isEmpty) return "";
      return text[0].toUpperCase();
    }
    PreferredSizeWidget buildAppBar() {
      if (Api.userInfo.read('token') != null) {
        return CommonWebAppBar(
          height: size * 0.08,
          title: "LYD",
          onLogout: () {},
          onNotification: () {},
        );
      } else {
        return const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CommonHeader(),
        );
      }
    }
    return Scaffold(
     // key:_scaffoldKeyJobSeekers,
      backgroundColor: AppColors.scaffoldBg,
       appBar: buildAppBar(),
      body: Row(
        children: [
         if( Api.userInfo.read('token')!=null)
          const AdminSideBar(),
         // if( Api.userInfo.read('token')==null)
         //   SizedBox(
         //     width: size*0.15,
         //     child: FilterSidebar(),
         //   ),
                    GetBuilder<JobController>(
              builder: (controller) {
                return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 50.0,right: 50,top: 20,bottom: 20),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Align(
                                //   alignment:Alignment.topRight,
                                //   child: Container(
                                //     padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                //     height: size * 0.018,
                                //     width: size*0.2,
                                //     decoration: BoxDecoration(
                                //       color: Colors.grey.shade100,
                                //       borderRadius: BorderRadius.circular(14),
                                //       boxShadow: [
                                //         BoxShadow(
                                //           color: Colors.black.withOpacity(0.05),
                                //           blurRadius: 8,
                                //           offset: const Offset(0, 3),
                                //         ),
                                //       ],
                                //     ),
                                //     child: Row(
                                //       children: [
                                //         Expanded(
                                //           child: TextField(
                                //             controller: searchController,
                                //             style: AppTextStyles.caption(
                                //               context,
                                //               color: AppColors.black,
                                //               fontWeight: FontWeight.w500,
                                //             ),
                                //             decoration: InputDecoration(
                                //               hintText: "Search jobs by name, area...",
                                //               hintStyle: AppTextStyles.caption(
                                //                 context,
                                //                 color: AppColors.grey,
                                //                 fontWeight: FontWeight.normal,
                                //               ),
                                //               prefixIcon: Icon(
                                //                 Icons.search_rounded,
                                //                 color: AppColors.grey,
                                //                 size: size * 0.012,
                                //               ),
                                //               border: InputBorder.none,
                                //               contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                //             ),
                                //             onSubmitted: (value) {
                                //               jobController.getJobListJobSeekers(
                                //                   search: value, context: context);
                                //             },
                                //           ),
                                //         ),
                                //         Container(
                                //           height: size * 0.015,
                                //           width: 1,
                                //           color: Colors.grey.shade300,
                                //         ),
                                //         IconButton(
                                //           icon: Icon(
                                //             Icons.tune_rounded,
                                //             color: AppColors.grey,
                                //             size: size * 0.012,
                                //           ),
                                //           onPressed: () {
                                //             showDialog(
                                //               context: context,
                                //               barrierDismissible: true,
                                //               builder: (context) {
                                //                 return Dialog(
                                //                   shape: RoundedRectangleBorder(
                                //                     borderRadius: BorderRadius.circular(20),
                                //                   ),
                                //                   insetPadding: const EdgeInsets.symmetric(
                                //                       horizontal: 200, vertical: 40),
                                //                   child: SizedBox(
                                //                     width: MediaQuery.of(context).size.width * 0.5,
                                //                     child: Padding(
                                //                       padding: const EdgeInsets.all(16.0),
                                //                       child:
                                //                       FilterDrawer(
                                //                         onApply: () async {
                                //                           await jobController.getJobListJobSeekers(
                                //                             search: searchController.text,
                                //                             state: loginController.selectedState,
                                //                             district: loginController.selectedDistrict,
                                //                             city: loginController.selectedTaluka,
                                //                             salary: loginController.selectedSalary,
                                //                             jobType: loginController.selectedJobType,
                                //                             jobCategory: loginController.selectedCategories,
                                //                             context: context,
                                //                           );
                                //                           Navigator.pop(context);
                                //                         },
                                //                         onReset: () {
                                //                           loginController.selectedCategories.clear();
                                //                           loginController.selectedArea = null;
                                //                           loginController.selectedUserType = null;
                                //                           loginController.selectedState = null;
                                //                           loginController.selectedDistrict = null;
                                //                           loginController.selectedDistance = null;
                                //                           loginController.selectedTaluka = null;
                                //                           loginController.selectedJobType = null;
                                //                           loginController.selectedSalary = null;
                                //                           loginController.update();
                                //                         },
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 );
                                //               },
                                //             );
                                //           },
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: searchController,
                                          style: AppTextStyles.caption(
                                            context,
                                            color: AppColors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "Search jobs by name, area...",
                                            hintStyle: AppTextStyles.caption(
                                              context,
                                              color: AppColors.grey,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.search_rounded,
                                              color: AppColors.grey,
                                              size: size * 0.012,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                          ),
                                          onSubmitted: (value)async {
                                           await jobController.getJobListJobSeekers(
                                              search: value,
                                              context: context,
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        height: size * 0.015,
                                        width: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.tune_rounded,
                                          color: AppColors.grey,
                                          size: size * 0.012,
                                        ),
                                        onPressed: () {

                                          // showDialog(
                                          //   context: context,
                                          //   barrierDismissible: true,
                                          //   builder: (context) {
                                          //     return Dialog(
                                          //       shape: RoundedRectangleBorder(
                                          //         borderRadius: BorderRadius.circular(20),
                                          //       ),
                                          //       insetPadding: const EdgeInsets.symmetric(
                                          //           horizontal: 200, vertical: 40),
                                          //       child: SizedBox(
                                          //         width: MediaQuery.of(context).size.width * 0.5,
                                          //         child: Padding(
                                          //           padding: const EdgeInsets.all(16.0),
                                          //           child: FilterDrawer(
                                          //             onApply: () async {
                                          //               await jobController.getJobListJobSeekers(
                                          //                 search: searchController.text,
                                          //                 state: loginController.selectedState,
                                          //                 district: loginController.selectedDistrict,
                                          //                 city: loginController.selectedTaluka,
                                          //                 salary: loginController.selectedSalary,
                                          //                 jobType: loginController.selectedJobType,
                                          //                 jobCategory: loginController.selectedCategories,
                                          //                 context: context,
                                          //               );
                                          //               Navigator.pop(context);
                                          //             },
                                          //             onReset: () {
                                          //               loginController.selectedCategories.clear();
                                          //               loginController.selectedArea = null;
                                          //               loginController.selectedUserType = null;
                                          //               loginController.selectedState = null;
                                          //               loginController.selectedDistrict = null;
                                          //               loginController.selectedDistance = null;
                                          //               loginController.selectedTaluka = null;
                                          //               loginController.selectedJobType = null;
                                          //               loginController.selectedSalary = null;
                                          //               loginController.update();
                                          //             },
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     );
                                          //   },
                                          // );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                                if (loginController.selectedState != null ||
                                    loginController.selectedDistrict != null ||
                                    loginController.selectedTaluka != null ||
                                    loginController.selectedJobType != null ||
                                    loginController.selectedSalary != null ||
                                    loginController.selectedCategories.isNotEmpty)
                                  GetBuilder<LoginController>(
                                      builder: (_) {
                                        return  Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            if (loginController.selectedState != null)
                                              InputChip(
                                                label: Text(loginController.selectedState!),
                                                onDeleted: () {
                                                  loginController.selectedState = null;
                                                  loginController.update();
                                                },
                                              ),
                                            if (loginController.selectedDistrict != null)
                                              InputChip(
                                                label: Text(loginController.selectedDistrict!),
                                                onDeleted: () {
                                                  loginController.selectedDistrict = null;
                                                  loginController.update();
                                                },
                                              ),
                                            if (loginController.selectedTaluka != null)
                                              InputChip(
                                                label: Text(loginController.selectedTaluka!),
                                                onDeleted: () {
                                                  loginController.selectedTaluka = null;
                                                  loginController.update();
                                                },
                                              ),
                                            if (loginController.selectedJobType != null)
                                              InputChip(
                                                label: Text(loginController.selectedJobType!),
                                                onDeleted: () {
                                                  loginController.selectedJobType = null;
                                                  loginController.update();
                                                },
                                              ),
                                            if (loginController.selectedSalary != null)
                                              InputChip(
                                                label: Text(loginController.selectedSalary!),
                                                onDeleted: () {
                                                  loginController.selectedSalary = null;
                                                  loginController.update();
                                                },
                                              ),
                                            for (var category in loginController.selectedCategories)
                                              InputChip(
                                                label: Text(category,style: AppTextStyles.caption(context),),
                                                onDeleted: () {
                                                  loginController.selectedCategories.remove(category);
                                                  loginController.update();
                                                },
                                              ),
                                            TextButton(
                                              onPressed: () async{
                                                loginController.selectedCategories.clear();
                                                loginController.selectedArea = null;
                                                loginController.selectedUserType = null;
                                                loginController.selectedState = null;
                                                loginController.selectedDistrict = null;
                                                loginController.selectedDistance = null;
                                                loginController.selectedTaluka = null;
                                                loginController.selectedJobType = null;
                                                loginController.selectedSalary = null;
                                                loginController.update();
                                                await jobController.getJobListJobSeekers(
                                                  search: searchController.text.toString(),
                                                  state: null,
                                                  district: null,
                                                  city: null,
                                                  salary: null,
                                                  jobType: null,
                                                  jobCategory: [],
                                                  context: context,
                                                );
                                              },
                                              child: const Text(
                                                "Clear All",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  ),

                                                      if(jobController.jobListJobSeekers.isEmpty)
                          Center(child: Text('No Job found',style: AppTextStyles.caption(context),),),
                                                      if(jobController.isLoading==true)
                          const CircularProgressIndicator(color: AppColors.primary,),

                                                      if(jobController.jobListJobSeekers.isNotEmpty)
                          AnimationLimiter(
                            child:  GetBuilder<JobController>(
                                builder: (controller) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: size*0.15,
                                        child: FilterSidebar(),
                                      ),
                                   Expanded(
                                     child: ListView.builder(
                                        itemCount: jobController.jobListJobSeekers.length,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: ( BuildContext context,int index) {
                                          final Jobs=jobController.jobListJobSeekers[index];
                                          final logoUrl = (Jobs.logoImage != null && Jobs.logoImage!.isNotEmpty)
                                              ? Jobs.logoImage!.first
                                              : null;
                                          return AnimationConfiguration.staggeredList(
                                            position: index,
                                            duration: const Duration(milliseconds: 1300),
                                            child: SlideAnimation(
                                              verticalOffset: 120.0,
                                              curve: Curves.easeOutBack,
                                              child: FadeInAnimation(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 50.0,right: 50,top: 20,bottom: 20),
                                                  child: GestureDetector(
                                                    onTap: ()async{
                                                      await jobController.getJobsById(Jobs.jobId!, context);
                                                      Get.toNamed('/viewJobDetailWebPage');
                                                    },
                                                    child: Container(
                                                      height: size*0.11,
                                                      width: size*0.15,
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                                          color: AppColors.white,border: Border.all(color: AppColors.white,),
                                                        boxShadow:  const [
                                                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(Jobs.orgName.toString(),softWrap:true,maxLines:2,style: AppTextStyles.body(context,color: Colors.black,fontWeight: FontWeight.bold),),
                                                                   SizedBox(height: size*0.001,),
                                                                    Text(Jobs.jobType.toString(),style: AppTextStyles.caption(context,color: Colors.grey,fontWeight: FontWeight.normal),),
                                                                    SizedBox(height: size*0.001,),

                                                                    Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      decoration: BoxDecoration(
                                                                        color: getStatusColor(Jobs.status ?? "").withOpacity(0.1),
                                                                        borderRadius: BorderRadius.circular(20),
                                                                        // border: Border.all(
                                                                        //   color: getStatusColor(Jobs.status ?? ""),
                                                                        //   width: 1,
                                                                        // ),
                                                                      ),
                                                                      child: Text(
                                                                        Jobs.status ?? "Not Applied",
                                                                        style: AppTextStyles.caption(context,
                                                                          fontWeight: FontWeight.w500,
                                                                          color: getStatusColor(Jobs.status ?? ""),
                                                                        ),
                                                                      ),
                                                                    )

                                                                  ],
                                                                ),
                                                                SizedBox(width: 10,),
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
                                                                  child: Image.network(
                                                                    logoUrl??"",
                                                                    fit: BoxFit.cover,
                                                                    width: size * 0.025,
                                                                    height: size * 0.025,
                                                                    errorBuilder: (context, error, stackTrace) {
                                                                      return Container(
                                                                      //  alignment: Alignment.center,
                                                                        width: size * 0.025,
                                                                        height: size * 0.025,
                                                                        decoration: BoxDecoration(
                                                                            color: AppColors.white, borderRadius: BorderRadius.circular(10),
                                                                          //getRandomColor(Jobs.orgName.toString()),
                                                                        ),
                                                                        child: Center(
                                                                          child: Text(
                                                                            getFirstLetter(Jobs.orgName.toString()),
                                                                            style: AppTextStyles.body(
                                                                              context,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: getRandomColor(Jobs.orgName.toString()),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 15,),
                                                            Text(Jobs.jobTitle.toString(),
                                                              softWrap:true,style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: Colors.black),),
                                                            const SizedBox(height: 5),

                                                            Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Icon(Icons.location_on_outlined, color: Colors.grey,size: size*0.012,),
                                                                const SizedBox(width: 5,),
                                                                Text("${Jobs.city.toString()}, ${Jobs.district.toString()} ,${Jobs.state.toString()}",softWrap:true,style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: Colors.grey),),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.currency_rupee_rounded, color: Colors.grey,size: size*0.012,),
                                                                Text("Salary: ${Jobs.salary.toString()}",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: Colors.black),),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text('Posted On ${  DateFormat('MMM dd, yyyy').format(DateTime.parse(Jobs.createdDate.toString()))}',style:  AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: Colors.grey),),
                                                                // Align(
                                                                //   alignment:Alignment.bottomRight,
                                                                //   child: Padding(
                                                                //     padding: const EdgeInsets.all(6.0),
                                                                //     child: Container(
                                                                //       decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                                                //         gradient: const LinearGradient(
                                                                //           colors: [AppColors.primary,AppColors.secondary],
                                                                //           begin: Alignment.topLeft,
                                                                //           end: Alignment.bottomRight,
                                                                //         ),),
                                                                //       height: size*0.012,
                                                                //       width: size*0.1,
                                                                //       child: Center(child: Text('${Jobs.totalApplicants.toString()} Applied',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: Colors.white),)),
                                                                //
                                                                //     ),
                                                                //   ),
                                                                // ),
                                                                Center(child: Text('${Jobs.totalApplicants.toString()} Applied',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: Colors.grey),))
                                                              ],
                                                            )
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
                                 ] );
                              }
                            ),
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
          ),
        ],
      ),
    );
  }
}
