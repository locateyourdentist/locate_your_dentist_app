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

import '../auth/login_screen/service_locations.dart';

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
  // @override
  // void initState(){
  //   super.initState();
  //   _refresh();
  // }

  Future<void> _refresh() async {
    await loginController.fetchStates();
    loginController.getProfileDetails(
      Api.userInfo.read('selectedUserType'),
      loginController.selectedState,
      loginController.selectedDistricts,
      loginController.selectedTalukas,[],"true",'','','','',
      context,
    );
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    String? selectedUserType = args?['selecteduserType'];
    print('userlist$selectedUserType');
    final bool isMobile = size < 700;
    return WillPopScope(
      onWillPop: () async {

        // loginController.getProfileDetails(
        //   Api.userInfo.read('selectedUserType'),
        //   loginController.selectedState,
        //   loginController.selectedDistrict,loginController.selectedTaluka,
        //   loginController.selectedArea,"true",'','','',
        //   context,
        // );
        // Get.toNamed('/userTypeListPage', arguments: {
        //   'userType': selectedUserType,
        // });
        return true;
      },
      child: Scaffold(
        key:_scaffoldKeyFilter,
        backgroundColor: Colors.grey.shade100,
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
          title: Text('Search Dental Clinics',style: AppTextStyles.subtitle(context,color: AppColors.white),),
          backgroundColor: AppColors.primary,iconTheme: const IconThemeData(color: AppColors.white),
        ),
        body: GetBuilder<LoginController>(
            init: loginController,
            builder: (controller) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary,AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                        ),
                        height: size*0.23,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
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
                                const Icon(Icons.search, color: AppColors.primary, size: 24),
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
                                          [],
                                          [],[],"true",
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
                                                  print("Selected distance: ${loginController.selectedDistance}");
                                                  print('latit${loginController.latitude.toString()} long ${loginController.longitude.toString()!}');
                                                  //String userType=  Api.userInfo.read('sUserType');
                                                  //print("ssuser$userType");
                                                  String distance =
                                                  (loginController.selectedDistance1 ?? 0).toString();

                                                  bool useLocation =
                                                      distance.isNotEmpty &&
                                                          distance != "0" &&
                                                          distance != "0.0";
                                                  if (useLocation) {
                                                    await getLocation();
                                                  } else {
                                                    loginController.latitude = null;
                                                    loginController.longitude = null;
                                                  }
                                                  String safeLat =
                                                  useLocation ? (loginController.latitude?.toString() ?? "") : "";

                                                  String safeLng =
                                                  useLocation ? (loginController.longitude?.toString() ?? "") : "";
                                                  filteredProfiles.map((e) => searchController.text.toString());
                                                  final filterDegree = loginController.filterUserType == 'Dental Consultant'
                                                      ? loginController.filterSelectedDegree
                                                      : null;
                                                  final filterLocations = loginController.filterUserType == 'Dental Consultant'
                                                      ? loginController.filterSelectedAvailableLocations
                                                      : null;
                                                  final filterTiming = loginController.filterUserType == 'Dental Consultant'
                                                      ? loginController.filterSelectedTimingSlots
                                                      : null;
                                                  Api.userInfo.read('token')==null?
                                                  await loginController.getProfileDetails(
                                                    "Dental Clinic",
                                                    loginController.selectedState,
                                                    loginController.selectedDistricts,
                                                    loginController.selectedTalukas,loginController.selectedVillages,"true",
                                                    safeLat,safeLng, distance,searchController.text.toString(),context,
                                                  ):
                                                  await loginController.getProfileDetails(
                                                    loginController.filterUserType ?? "",
                                                    loginController.selectedState,
                                                    loginController.selectedDistricts,
                                                    loginController.selectedTalukas,loginController.selectedVillages,"true",
                                                    safeLat,safeLng, distance,searchController.text.toString(),context,
                                                    degreeName: filterDegree, availableLocations: filterLocations, availableTiming: filterTiming,
                                                  )

                                                  ;
                                                  Navigator.pop(context);
                                                },
                                                onReset: () {
                                                  setState(() {
                                                    // loginController.selectedPlace = null;
                                                    // loginController.selectedDistrict = null;
                                                    loginController.selectedArea = null;
                                                    loginController.selectedUserType=null;
                                                    loginController.selectedState=null;
                                                    loginController.selectedDistrict=null;
                                                    loginController.resetUserTypeFilters();
                                                  });
                                                },
                                              ),
                                            );
                                          },
                                        );
                                        //_scaffoldKeyFilter.currentState!.openDrawer();
                                      },
                                      icon:  Icon(Icons.location_on, color: AppColors.primary, size: size*0.06),
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
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            buildActiveFilters(isMobile,context),

                            if(controller.profileList.isEmpty)
                              Center(child: Text('No data found',style: AppTextStyles.caption(context),),),
                            if(controller.isLoading==true)
                              const Center(child: CircularProgressIndicator(),),
                            Text('Total Profiles: ${controller.profileList.length}',style: AppTextStyles.body(context),),
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
                                      String userType=Api.userInfo.read('userType')??"";

                                      bool getPlanActive() {
                                        final userData = loginController.profileList;
                                        if (userData.isEmpty) return false;
                                        final raw = userData.first.details["plan"]?["basePlan"]?["isActive"]??"";
                                        return raw == true || raw == "true";
                                      }
                                      final planActive = getPlanActive();
                                      final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
                                      String addOnsPlanStatus = profile.details?["plan"]?["addonsPlan"]?["isActive"]?.toString() ?? "";
                                      return AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration: const Duration(milliseconds: 1300),
                                        child: SlideAnimation(
                                          verticalOffset: 120.0,
                                          curve: Curves.easeOutBack,
                                          child: FadeInAnimation(
                                            child:DoctorCardWidget(
                                              doctor: profile,
                                              size: size,
                                              planActive: planActive,
                                              isAdminUser: isAdminUser,
                                              addOnsPlanStatus: addOnsPlanStatus,
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
                ),
              );
            }
        ),
        bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
      ),
    );
  }
}
