import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
import 'package:locate_your_dentist/modules/dashboard/slider_images_dashboard.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common_widgets/common_bottom_navigation.dart';
import '../../common_widgets/common_drawer.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../common_widgets/platform_helper.dart';


 class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});
  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
 }
 class _PatientDashboardState extends State<PatientDashboard> {
  int currentIndex=0;
  final loginController=Get.put(LoginController());
  String? selectedPlace;
  String? selectedDistrict;
  String? selectedArea;
  final TextEditingController searchController=TextEditingController();
  List<ProfileModel> filteredProfiles = [];
  final notificationController=Get.put(NotificationController());
  final GlobalKey<ScaffoldState> _scaffoldKeyUser1 = GlobalKey<ScaffoldState>();
  final planController=Get.put(PlanController());

  Future<void> getLocation() async {
    final position = await LocationService.getCurrentLocation();

    if (position != null) {
      loginController.latitude = position.latitude;
      loginController.longitude = position.longitude;

      final address = await getAddressFromLatLng(loginController.latitude!, loginController.longitude!);

      print('latitude ${loginController.latitude.toString()}');
      print('longitude ${loginController.longitude.toString()}');
      Api.userInfo.write('latitude', loginController.latitude.toString());
      Api.userInfo.write('longitude', loginController.longitude.toString());
      loginController.update();
      planController.currentLocation = address;
    } else {
      Get.snackbar('Location', 'Unable to get location');
    }
  }
  @override
  void initState(){
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
    getLocation();
    await loginController.fetchStates();
    await loginController.getProfileDetails('Dental Clinic', '', '', '',[],"true",'', '','','', context);
   // await loginController.getProfileDetails('Dental Clinic', '', '', '',"true",loginController.latitude.toString(), loginController.longitude.toString(),'','', context);
   await planController.getUploadImages(userType: "Dental Clinic",context: context);
  }
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks.first;
      return '${place.subLocality}, ${place.locality} ${place.postalCode}';
    } catch (e) {
      return '';
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return  Scaffold(
      key: _scaffoldKeyUser1,
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        elevation: 0,
        //backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary,AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // leading: Padding(
        //   padding:  const EdgeInsets.all(8.0),
        //   child: CircleAvatar(
        //     radius: size * 0.13,
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.circular(50),
        //       child: ProfileImageWidget(size: size),
        //     ),
        //   ),
        // ),
        centerTitle: false,
        title: Column(
          mainAxisAlignment:MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Locate Your Dentist',
              style: AppTextStyles.body(context,
                color: AppColors.white,fontWeight: FontWeight.bold,),
            ),
            GetBuilder<PlanController>(
                builder: (controller) {
                  return Row(
                  children: [
                    Icon(Icons.place_outlined,color: AppColors.white,size: size*0.06,),
                    SizedBox(width: size*0.01,),
                    Expanded(child: Text(planController.currentLocation??"",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.normal,color: Colors.white),)),
                  ],
                );
              }
            ),

          ],
        ),
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
                gradient: const LinearGradient(
                    colors: [AppColors.primary,AppColors.primary],
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
                       Icon(Icons.search, color: Colors.grey, size: size*0.025),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CommonSearchTextField(
                          controller: searchController,
                          hintText: "Search dental clinics Near you by name,area...",
                          onSubmitted: (value)async {
                            print("Search text: $value");
                          await  loginController.getProfileDetails(
                              "Dental Clinic",
                              '',
                              '',
                              '',[],"true",'','','',
                              searchController.text.toString(),
                              context,
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
                                          print('latit${Api.userInfo.read('latitude')??""} long ${Api.userInfo.read('longitude')??""}');
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
                                          await loginController.getProfileDetails(
                                            "Dental Clinic",
                                            loginController.selectedState,
                                            loginController.selectedDistrict,
                                            loginController.selectedTaluka, loginController.selectedVillages,"true",safeLat,safeLng, distance,'',
                                            context,
                                          );
                                          Get.toNamed('/filterResultPage');
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
                                            loginController.selectedSalary=null;
                                            loginController.selectedJobType=null;
                                            loginController.selectedCategories.clear();
                                            loginController.update();
                                          });
                                        },
                                      )      );
                                });
                            },
                            icon:  Icon(Icons.location_on_outlined, color: AppColors.primary, size: size*0.06),
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
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Top Dentist in your State",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(
                        context,color: AppColors.black)
                  ),
                  SizedBox(height: size * 0.02),
                GetBuilder<PlanController>(
                  builder: (controller) {
                    final imageUrls = controller.editUploadImage1
                        .map((e) => e.url ?? "").where((url) => url.isNotEmpty).toList();
                    return DashboardCarousel(
                      imageList: imageUrls,
                    );
                  },
                ),

                SizedBox(height: size * 0.03),
                  Text(
                      "Popular Dental Clinics",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(context,color: AppColors.black)
                  ),
                  SizedBox(height: size * 0.01),
                  if(loginController.profileList.isEmpty)
                  //  Center(child: Text('No data found',style: AppTextStyles.caption(context),),),
                  buildShimmerEmptyWidget(size),
                  if(loginController.isLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary,)),
                  if(loginController.profileList.isNotEmpty)
                  AnimationLimiter(
                    child: ListView.builder(
                      itemCount: loginController.profileList.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        final doctor = loginController.profileList[index];
                        bool getPlanActive() {
                          final userData = loginController.profileList;
                          if (userData.isEmpty) return false;
                          final raw = userData.first.details["plan"]?["basePlan"]?["isActive"]??"";
                          return raw == true || raw == "true";
                        }
                        String userType=Api.userInfo.read('userType')??"";

                        final planActive = getPlanActive();
                        final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';

                        String firstImage = doctor.images.firstWhere((img) =>
                        img.toLowerCase().endsWith('.jpg') || img.toLowerCase().endsWith('.png'), orElse: () => "",);
                        String addOnsPlanStatus =
                            doctor.details?["plan"]?["addonsPlan"]?["isActive"]?.toString() ?? "";
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 1300),
                          child: SlideAnimation(
                            verticalOffset: 120.0,
                            curve: Curves.easeOutBack,
                            child: FadeInAnimation(
                              child:DoctorCardWidget(
                              doctor: doctor,
                              size: size,
                              planActive: planActive,
                              isAdminUser: isAdminUser,
                              addOnsPlanStatus: addOnsPlanStatus,
                            ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                 // :Center(child: Text('No Data Found',style: AppTextStyles.caption(context,color: AppColors.black),))
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

    );
  }

 }
