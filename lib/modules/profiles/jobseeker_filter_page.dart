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


  class JobSeekerFilter extends StatefulWidget {
  const JobSeekerFilter({super.key});
  @override
  State<JobSeekerFilter> createState() => _JobSeekerFilterState();
  }
  class _JobSeekerFilterState extends State<JobSeekerFilter> {
  final jobController=Get.put(JobController());
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeyJobSeekers = GlobalKey<ScaffoldState>();
  final loginController=Get.put(LoginController());
  @override
  @override
  void initState(){
    super.initState();
    loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
    jobController.getJobListJobSeekers(search:searchController.text.toString() ,context: context);
  }
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    String getFirstLetter(String text) {
      if (text.isEmpty) return "";
      return text[0].toUpperCase();
    }
    return Scaffold(
      key:_scaffoldKeyJobSeekers,
      backgroundColor: Colors.grey.shade100,
    //   drawer: FilterDrawer(
    //     onApply: () async{
    //   print("Selected State: ${loginController.selectedState}");
    //   print("Selected District: ${loginController.selectedDistrict}");
    //   print("Selected Area: ${loginController.selectedArea}");
    //   //String userType=  Api.userInfo.read('sUserType');
    //   //print("ssuser$userType");
    //   //filteredProfiles.map((e) => searchController.text.toString());
    //   jobController.getJobListJobSeekers(search:searchController.text.toString(),state:loginController.selectedState,district:loginController.selectedDistrict,
    //       city: loginController.selectedTaluka,salary: loginController.selectedSalary,jobType: loginController.selectedJobType,jobCategory: loginController.selectedCategories,
    //       context: context);
    //   },
    // onReset: () {
    // setState(() {
    // // loginController.selectedPlace = null;
    // // loginController.selectedDistrict = null;
    // loginController.selectedArea = null;
    // loginController.selectedUserType=null;
    // loginController.selectedState=null;
    // loginController.selectedDistrict=null;
    // loginController.selectedDistance=null;
    // loginController.selectedTaluka=null;
    // loginController.selectedJobType=null;
    // loginController.selectedSalary=null;
    // loginController.selectedCategories.clear();
    // });
    // },
    // ),
      appBar: AppBar(
        //backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: size * 0.16,
        automaticallyImplyLeading: false,
        title: Container(
          height: size * 0.12,
          decoration: BoxDecoration(
            color: Colors.white,
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
                      size: size * 0.05,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (value) {
                    jobController.getJobListJobSeekers(search:value,context: context);
                    Get.toNamed('/filterPageJobSeekersPage');
                  },
                ),
              ),
              Container(
                height: size * 0.06,
                width: 1,
                color: Colors.grey.shade300,
              ),
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: size * 0.06,
                ),
                onPressed: () {
                  // FilterDrawer(
                  //   onApply: () async{
                  //     print("Selected State: ${loginController.selectedState}");
                  //     print("Selected District: ${loginController.selectedDistrict}");
                  //     print("Selected Area: ${loginController.selectedArea}");
                  //     //String userType=  Api.userInfo.read('sUserType');
                  //     //print("ssuser$userType");
                  //     //filteredProfiles.map((e) => searchController.text.toString());
                  //     jobController.getJobListJobSeekers(search:searchController.text.toString(),state:loginController.selectedState,district:loginController.selectedDistrict,
                  //         city: loginController.selectedTaluka,salary: loginController.selectedSalary,jobType: loginController.selectedJobType,jobCategory: loginController.selectedCategories,
                  //         context: context);
                  //   },
                  //   onReset: () {
                  //     setState(() {
                  //       // loginController.selectedPlace = null;
                  //       // loginController.selectedDistrict = null;
                  //       loginController.selectedArea = null;
                  //       loginController.selectedUserType=null;
                  //       loginController.selectedState=null;
                  //       loginController.selectedDistrict=null;
                  //       loginController.selectedDistance=null;
                  //       loginController.selectedTaluka=null;
                  //       loginController.selectedJobType=null;
                  //       loginController.selectedSalary=null;
                  //       loginController.selectedCategories.clear();
                  //     });
                  //   },
                  // );
                 // _scaffoldKeyJobSeekers.currentState!.openDrawer();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.75, // 75% of screen height (not full screen)
                        child: FilterDrawer(
                            onApply: () async{
                              print("Selected State: ${loginController.selectedState}");
                              print("Selected District: ${loginController.selectedDistrict}");
                              print("Selected Area: ${loginController.selectedArea}");
                              //String userType=  Api.userInfo.read('sUserType');
                              //print("ssuser$userType");
                              //filteredProfiles.map((e) => searchController.text.toString());
                             await jobController.getJobListJobSeekers(search:searchController.text.toString(),state:loginController.selectedState,district:loginController.selectedDistrict,
                                  city: loginController.selectedTaluka,salary: loginController.selectedSalary,jobType: loginController.selectedJobType,jobCategory: loginController.selectedCategories,
                                  context: context);
                            },
                            onReset: () {
                              setState(() {
                                // loginController.selectedPlace = null;
                                // loginController.selectedDistrict = null;
                                loginController.selectedArea = null;
                                loginController.selectedUserType=null;
                                loginController.selectedState=null;
                                loginController.selectedDistrict=null;
                                loginController.selectedDistance=null;
                                loginController.selectedTaluka=null;
                                loginController.selectedJobType=null;
                                loginController.selectedSalary=null;
                                loginController.selectedCategories.clear();
                              });
                            },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: GetBuilder<JobController>(
     builder: (controller) {
       return SingleChildScrollView(
       child: Padding(
         padding: const EdgeInsets.all(10.0),
         child: Column(
          children: [
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         controller: searchController,
            //         decoration: InputDecoration(
            //           hintText: "Search your jobs by name,area...",
            //           hintStyle: AppTextStyles.caption(context,color: AppColors.grey,fontWeight: FontWeight.normal),
            //           prefixIcon:  Icon(Icons.search,color: AppColors.grey,size: size*0.05,),
            //           filled: true,
            //           fillColor: Colors.white,
            //           contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(12),
            //             borderSide: BorderSide.none,
            //           ),
            //         ),
            //         onChanged: (value) {
            //           print("Search text: $value");
            //           jobController.getJobListJobSeekers(searchController.text.toString(),context);
            //           Get.toNamed('/filterPageJobSeekersPage');
            //         },
            //       ),
            //     ),
            //
            //     const SizedBox(width: 10),
            //
            //     Container(
            //       height: size*0.12,
            //       width: size*0.15,
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: IconButton(
            //         icon: const Icon(Icons.filter_list, color: Colors.black),
            //         onPressed: () {},
            //       ),
            //     )
            //   ],
            // ),

            if(jobController.jobListJobSeekers.isEmpty)
              Center(child: Text('No Job found',style: AppTextStyles.caption(context),),),
            if(jobController.isLoading==true)
              const CircularProgressIndicator(color: AppColors.primary,),

            if(jobController.jobListJobSeekers.isNotEmpty)
            AnimationLimiter(
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
                    //print('${AppConstants.baseUrl}${Jobs.image}');
                    final created =
                    DateTime.parse(Jobs.createdDate.toString());
                    final postedAgo = timeAgo(created);
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
                                jobController.getJobsById(Jobs.jobId!, context);
                                Get.toNamed('/jobViewProfilePage');
                              },
                              child: Container(
                                height: size*0.6,
                                width: size,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
                                    color: AppColors.white,border: Border.all(color: AppColors.primary,width: 1.5)
                                  //color: mildColors[index % 5],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
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
                                                fit: BoxFit.cover,
                                                width: size * 0.14,
                                                height: size * 0.12,
                                                errorBuilder: (context, error, stackTrace) {
                                                  // Show a placeholder on error
                                                  return  CircleAvatar(
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
                                                  ); },
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
                                              Text(Jobs.orgName.toString(),softWrap:true,maxLines:2,style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.black),),
                                              Text(Jobs.jobType.toString(),style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.grey),),
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
                                                  style: TextStyle(
                                                    fontSize: size * 0.03,
                                                    fontWeight: FontWeight.w500,
                                                    color: getStatusColor(Jobs.status ?? ""),
                                                  ),
                                                ),
                                              )

                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15,),
                                      Text(Jobs.jobTitle.toString(),softWrap:true,style: TextStyle(fontSize: size*0.035,fontWeight: FontWeight.bold,color: Colors.black),),
                                      const SizedBox(height: 5),

                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.location_on_rounded, color: Colors.grey,size: size*0.04,),
                                          const SizedBox(width: 5,),
                                          Text("${Jobs.city.toString()}, ${Jobs.district.toString()} ,${Jobs.state.toString()}",softWrap:true,style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.grey),),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.currency_rupee_rounded, color: Colors.grey,size: size*0.04,),
                                          Text(Jobs.salary.toString(),style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.grey),),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Posted On ${  DateFormat('MMM dd, yyyy').format(DateTime.parse(Jobs.createdDate.toString()))}',style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.grey),),
                                          Align(
                                            alignment:Alignment.bottomRight,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                                  gradient: const LinearGradient(
                                                    colors: [AppColors.primary,AppColors.secondary],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),),
                                                height: size*0.07,
                                                width: size*0.3,
                                                child: Center(child: Text('${Jobs.totalApplicants.toString()} Applied',style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.white),)),

                                              ),
                                            ),
                                          ),
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
