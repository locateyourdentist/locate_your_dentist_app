import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_drawer.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class FilterResultPage extends StatefulWidget {
  const FilterResultPage({super.key});
  @override
  State<FilterResultPage> createState() => _FilterResultPageState();
}
class _FilterResultPageState extends State<FilterResultPage> {

  final loginController=Get.put(LoginController());
  List<ProfileModel> filteredProfiles = [];
  final TextEditingController searchController=TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeyFilter = GlobalKey<ScaffoldState>();
  final args = Get.arguments as Map<String, dynamic>?;
  @override
  void initState() {
    super.initState();
    //_loadData();
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    String? selectedUserType = args?['selecteduserType'];
    print('userlist$selectedUserType');
    return WillPopScope(
      onWillPop: () async {

        loginController.getProfileDetails(
          Api.userInfo.read('selectedUserType'),
          loginController.selectedState,
          loginController.selectedDistrict,
          loginController.selectedArea,"true",'','','','',
          context,
        );
        // Get.toNamed('/userTypeListPage', arguments: {
        //   'userType': selectedUserType,
        // });
         return true;
      },
      child: Scaffold(
        key:_scaffoldKeyFilter,
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          centerTitle: true,automaticallyImplyLeading: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary,AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text('Filter Result',style: AppTextStyles.subtitle(context,color: AppColors.white),),
        backgroundColor: AppColors.primary,iconTheme: const IconThemeData(color: AppColors.white),
        ),
        drawer: FilterDrawer(
          onApply: () async{
            print("Selected State: ${loginController.selectedState}");
            print("Selected District: ${loginController.selectedDistrict}");
            print("Selected Area: ${loginController.selectedArea}");

            //String userType=  Api.userInfo.read('sUserType');
            //print("ssuser$userType");
            filteredProfiles.map((e) => searchController.text.toString());
            await loginController.getProfileDetails(
              "Dental Clinic",
              loginController.selectedState,
              loginController.selectedDistrict,
              loginController.selectedTaluka,"true",'',
              '','', '',context,
            );
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
        body: GetBuilder<LoginController>(
            init: loginController,
            builder: (controller) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    //margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    //padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary,AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50),bottomRight: Radius.circular(50)),
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
                              child: CommonSearchTextField(
                                controller: searchController,
                                hintText: "Search dental clinic",
                                onSubmitted: (value) {
                                  print("Search text: $value");
                                  loginController.getProfileDetails(
                                    "Dental Clinic",
                                    '',
                                    '',
                                    '',"true",
                                    searchController.text.toString(),
                                    '','', '',context,
                                  );
                                  Get.toNamed('/filterResultPage');
                                },
                              )
              
                            ),
              
                            Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: AppColors.white,),
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

                                              //String userType=  Api.userInfo.read('sUserType');
                                              //print("ssuser$userType");
                                              filteredProfiles.map((e) => searchController.text.toString());
                                              await loginController.getProfileDetails(
                                                "Dental Clinic",
                                                loginController.selectedState,
                                                loginController.selectedDistrict,
                                                loginController.selectedTaluka,"true",'',
                                                '','', '',context,
                                              );
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
                                    //_scaffoldKeyFilter.currentState!.openDrawer();
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
              
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                    
                        if(controller.profileList.isEmpty)
                        Center(child: Text('No data found',style: AppTextStyles.caption(context),),),
                        if(controller.isLoading==true)
                          const Center(child: CircularProgressIndicator(),),
                        if(controller.profileList.isNotEmpty)
                        AnimationLimiter(
                          child: ListView.builder(
                              itemCount:controller.profileList.length ,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context,index){
                                final profile=controller.profileList[index];
                                String firstImage = profile.images.firstWhere(
                                      (img) =>
                                  img.toLowerCase().endsWith('.jpg') ||
                                      img.toLowerCase().endsWith('.png'),
                                  orElse: () => "",
                                );
                                List<String> parts = [];
                                if ((profile.address["state"] ?? "").isNotEmpty) parts.add(profile.address["state"]);
                                if ((profile.address["district"] ?? "").isNotEmpty) parts.add(profile.address["district"]);
                                if ((profile.address["city"] ?? "").isNotEmpty) parts.add(profile.address["city"]);
                                String address = parts.join(", ");
                                String addOnsPlanStatus = profile.details?["plan"]?["addonsPlan"]?["isActive"]?.toString() ?? "";
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 1300),
                                child: SlideAnimation(
                                  verticalOffset: 120.0,
                                  curve: Curves.easeOutBack,
                                  child: FadeInAnimation(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: AppColors.white),
                                        child:Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                             ClipRRect(
                                                borderRadius:BorderRadius.circular(10),
                                                 child: Image.network(firstImage.isNotEmpty
                                                     ? "$firstImage"
                                                     : "",
                                                   width: double.infinity,
                                                   height: size * 0.6,
                                                   fit: BoxFit.cover,
                                                   errorBuilder: (context, error, stackTrace) {
                                                     return Container(
                                                       width: double.infinity,
                                                       height: double.infinity,
                                                       color: Colors.grey[200], // light grey background
                                                       child: Column(
                                                         mainAxisAlignment: MainAxisAlignment.center,
                                                         children: [
                                                           Icon(
                                                             Icons.image_not_supported,
                                                             color: Colors.grey[400],
                                                             size: 50,
                                                           ),
                                                           const SizedBox(height: 8),
                                                           Text(
                                                             "No Image Available",
                                                             style: TextStyle(
                                                               color: Colors.grey[500],
                                                               fontSize: 14,
                                                               fontWeight: FontWeight.w500,
                                                             ),
                                                           ),
                                                         ],
                                                       ),
                                                     );
                                                   },
                                                   // errorBuilder: (c, e, s) => Image.asset(
                                                   //   'assets/images/lp3.jpg',
                                                   //   width: double.infinity,
                                                   //   height: size * 0.6,
                                                   //   fit: BoxFit.cover,
                                                   // ),
                                                 ),
                                             ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                //const SizedBox(height: 10,),
                                                Text(address,style: AppTextStyles.caption(context,color: AppColors.grey),),
                                                const SizedBox(height: 5,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(child: Text(profile.details['name'].toString()??"",softWrap:true,style: AppTextStyles.subtitle(context,color: AppColors.black),)),
                                                    IconButton(onPressed: (){
                                                      print('click id${profile.userId.toString()??""}');
                                                      loginController.getProfileByUserId(profile.userId.toString()??"", context);
                                                      Get.toNamed('/clinicProfilePage');
                                                    },icon: Icon(Icons.arrow_forward,color: AppColors.grey,size: size*0.06,),),
                                                  ],
                                                ),
                                                if(addOnsPlanStatus=="true")
                                                  Column(
                                                    children: [
                                                      const SizedBox(height: 2,),
                                                      Align(
                                                        alignment:Alignment.topRight,
                                                        child: Text(
                                                          "* Sponsored",
                                                          style: TextStyle(fontSize: size*0.025,
                                                              color: AppColors.black,fontWeight: FontWeight.normal),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                               // const SizedBox(height: 2,),
                                               // Center(child: IconButton(onPressed: (){},icon: Icon(Icons.arrow_forward,color: AppColors.grey,size: size*0.06,),),)
                                                // SizedBox(
                                                //   height: size*0.09,
                                                //   child: Row(
                                                //     children: [
                                                //       Text("Mobile : ",style: AppTextStyles.caption(context,color: AppColors.black),),
                                                //
                                                //       SizedBox(
                                                //         width:size*0.09,
                                                //         child: IconButton(onPressed: (){
                                                //           launchCall(profile.mobileNumber.toString()??"");
                                                //
                                                //         }, icon: Icon(Icons.call,color: Colors.green,size: size*0.06,)),
                                                //       ),
                                                //       Text(profile.mobileNumber??"",style: AppTextStyles.caption(context,color: AppColors.black),),
                                                //     ],
                                                //   ),
                                                // ),
                                                // Row(
                                                //   children: [
                                                //     Text("email : ",style: AppTextStyles.caption(context,color: AppColors.black),),
                                                //     const SizedBox(width: 5,),
                                                //
                                                //     Text(profile.email??"",style: AppTextStyles.caption(context,color: AppColors.black),),
                                                //   ],
                                                // ),
                                                // SizedBox(
                                                //   height: size*0.09,
                                                //   child: Row(
                                                //     children: [
                                                //       Text("Website : ",style: AppTextStyles.caption(context,color: AppColors.black),),
                                                //
                                                //       SizedBox(
                                                //         width:size*0.09,
                                                //         child: IconButton(onPressed: (){
                                                //           if(PlatformHelper.platform=='Android'||PlatformHelper.platform=='iOS'){
                                                //             Get.toNamed('/webViewProfilePage',arguments: {"url":profile.details["website"]??"".toString()??"","clinicName":profile.details['name']??"".toString()});
                                                //             debugPrint(profile.details['website']);
                                                //             if(loginController.userData.first.details["website"]??"".toString().isEmpty||loginController.userData.first.details["website"]??"".toString()==null){
                                                //               showCustomToast(context,  "Website error",backgroundColor: AppColors.secondary);
                                                //
                                                //             }
                                                //           }
                                                //         }, icon: Icon(Icons.public,color: Colors.blueAccent,size: size*0.06,)),
                                                //       ),
                                                //       Text(profile.details['website']??"",style: AppTextStyles.caption(context,color: AppColors.black),),
                                                //     ],
                                                //   ),
                                                // ),
                                                // SizedBox(
                                                //   height: size*0.09,
                                                //   child: Row(
                                                //     children: [
                                                //       Text("Googlemap Link : ",style: AppTextStyles.caption(context,color: AppColors.black),),
                                                //
                                                //       SizedBox(
                                                //         width:size*0.07,
                                                //         child: IconButton(onPressed: (){
                                                //           if(PlatformHelper.platform=='Android'||PlatformHelper.platform=='iOS'){
                                                //             Get.toNamed('/webViewProfilePage',arguments: {"url":profile.location??"","clinicName":profile.details['name'].toString()??""});
                                                //             debugPrint('ghh${profile.details['website']??""}');
                                                //           }
                                                //         }, icon: Icon(Icons.location_on,color: AppColors.primary,size: size*0.06,)),
                                                //       ),
                                                //       Text(profile.location??"",style: AppTextStyles.caption(context,color: AppColors.black),),
                                                //     ],
                                                //   ),
                                                // ),

                                               // Text("Zion offers the best in health care to patients who have come to trust the hospital as one of India’s best.  A 1000-bed facility offering superlative treatment in 63 specialities, MIOT proudly lays claim to a team of world-class professionals",maxLines: 3,style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.normal),),
                                          ]),
                                        )
                                            ])
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
                ],
              ),
            );
          }
        ),
        bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
      ),
    );
  }
}
