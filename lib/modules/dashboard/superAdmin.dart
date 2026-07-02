import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import '../../api/api.dart';
import '../../common_widgets/color_code.dart';
import '../../common_widgets/common_drawer.dart';
import '../../common_widgets/common_sidebar_mobile.dart';
import '../../common_widgets/common_widget_all.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

import '../auth/login_screen/service_locations.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});
  @override
  State<SuperAdminDashboardPage> createState() =>
      _SuperAdminDashboardPageState();
}
class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  final LoginController loginController = Get.put(LoginController());
  final notificationController=Get.put(NotificationController());
  final planController=Get.put(PlanController());
  final GlobalKey<ScaffoldState> _scaffoldKeySuperAdmin = GlobalKey<ScaffoldState>();
  List<String> title=["Admin","Super Admin","Dental Clinic","Dental Shop","Dental Lab","Dental Mechanic","Dental Professionals"];
  final TextEditingController searchController=TextEditingController();
  List<ProfileModel> filteredProfiles = [];
  Map<String, int> typeCounts = {};

  @override
  void initState() {
    super.initState();
    _refresh();
      }
  Future<void> _refresh() async {
    await loginController.fetchStates();
    await planController.getIncomeDetailsByPlan(context: context);
    //await planController.getExpense(month: "", year: "");
    await loginController.getAppLogoImage(context);
    await notificationController.getNotificationListAdmin(context);
    Api.userInfo.read('userType')=="superAdmin"?
    await loginController.getProfileDetails('', '', [], [],[], '','','','','', context): loginController.getProfileDetails('', Api.userInfo.read('state')??"", [],[], [], '','','','', '',context);
    //await planController.getIncomeDetailsByPlan(context: context);
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    final bool isDesktop = size >= 1100;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scaffold(
        key: _scaffoldKeySuperAdmin,
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: AppColors.black,
              size: size * 0.06,
            ),
            onPressed: () {
              _scaffoldKeySuperAdmin.currentState!.openDrawer();
            },
          ), flexibleSpace: Container(
          // decoration: const BoxDecoration(
          //   gradient: LinearGradient(
          //     colors: [AppColors.primary,AppColors.secondary],
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //   ),
          // ),
        ),
          title: Column(
          mainAxisAlignment:MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Locate Your Dentist',
              style: AppTextStyles.body(context,
                color: AppColors.black,fontWeight: FontWeight.bold,),
            ),
            Text(Api.userInfo.read('name')??"",style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.bold,color: Colors.black),),
          ],
        ),
          automaticallyImplyLeading: false,
          actions: [
            GetBuilder<NotificationController>(
              builder: (controller) {
                return Stack(
                  children: [

                    CircleAvatar(
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications_none,
                          color: AppColors.black,
                          size: size * 0.08,
                        ),
                        onPressed: () {
                          notificationController.getNotificationListAdmin(context);
                          notificationController.update();
                          Get.toNamed('/notificationPage');
                          },
                      ),
                    ),
                 if (int.tryParse(notificationController.unreadCount ?? "0")! > 0)
                    Positioned(
                        top: 0,
                        right: 5,
                        child:  GetBuilder<NotificationController>(
                            builder: (controller) {
                              return CircleAvatar(
                              radius: size*0.024,backgroundColor: Colors.redAccent,child: Text(
                              notificationController.unreadCount.toString()??"",style: TextStyle(color: AppColors.white,fontWeight: FontWeight.w500,fontSize: size*0.025),
                            ),
                            );
                          }
                        ))
                  ],
                );
              }
            )
          ],
        ),
        drawer: !isDesktop ? Drawer(width: 250, child: SettingsSidebarDrawer()) : null,
        body: GetBuilder<LoginController>(
          builder: (controller) {
            // if (controller.profileList.isEmpty) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    if(loginController.profileList.isEmpty)
                      Column(
                        children: [
                          dashboardShimmer()
                          // const SizedBox(height: 15),
                          // Center(child: Text('No data found',style: AppTextStyles.caption(context),),),
                        ],
                      ),
                    if(loginController.isLoading)
                      dashboardShimmer(),
                    SizedBox(height: size*0.02,),
                    //  const Center(child: CircularProgressIndicator(color: AppColors.primary,)),
                    if(loginController.profileList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'What you Want?',
                              style: AppTextStyles.subtitle(
                                context,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: size * 0.02),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
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
                                          hintText: "Search users by name, area,mobile number...",
                                          hintStyle: AppTextStyles.caption(
                                            context,
                                            color: AppColors.grey,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.text_fields,
                                            color: AppColors.grey,
                                            size: size * 0.05,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                        onSubmitted: (value)async {
                                          String userType=  Api.userInfo.read('sUserType');
                                          print("ssuser$userType");
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
                                          if( Api.userInfo.read('userType')=="superAdmin") {
                                            await   loginController.getProfileDetails('',  '',
                                                [], [], [], '','',
                                                '','',searchController.text.toString(),  context);
                                          }
                                          else if( Api.userInfo.read('userType')=="admin") {
                                            await   loginController.getProfileDetails('',  Api.userInfo.read('state') ?? "",
                                                [], [], [], '','',
                                                '','',searchController.text.toString(),  context);
                                          }
                                          else{
                                            await   loginController.getProfileDetails(userType, "",
                                                [], [], [], '','',
                                                '','',searchController.text.toString(),  context);
                                          }
                                          print("Search text: $value");
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
                                        Icons.search,
                                        color: AppColors.primary,
                                        size: size * 0.06,
                                      ),
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
                                                  print("Selected Area: ${loginController.selectedTaluka}");
                                                  print('distance${loginController.selectedDistance}');

                                                  String userType=  Api.userInfo.read('sUserType');
                                                  print("ssuser$userType");
                                                  //  filteredProfiles.map((e) => searchController.text.toString());
                                                  //   await loginController.getProfileDetails(
                                                  //     userType ?? "",
                                                  //     loginController.selectedState,
                                                  //     loginController.selectedDistrict,
                                                  //     loginController.selectedTaluka,"true",'','','','',
                                                  //     context,
                                                  //   );
                                                  if (loginController.selectedDistance != null) {
                                                    final position = await LocationService.getCurrentLocation();

                                                    if (position == null) {
                                                      return;
                                                    }

                                                    loginController.latitude = position.latitude;
                                                    loginController.longitude = position.longitude;

                                                    print("LAT: ${loginController.latitude}");
                                                    print("LNG: ${loginController.longitude}");
                                                  }
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
                                                  if( Api.userInfo.read('userType')=="superAdmin") {
                                                    await   loginController.getProfileDetails('',  loginController.selectedState,
                                                        loginController.selectedDistricts,
                                                        loginController.selectedTalukas,[], '',safeLat,
                                                        safeLng,distance,searchController.text.toString(),  context);
                                                  }
                                                  else if( Api.userInfo.read('userType')=="admin") {
                                                    await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", loginController.selectedDistricts,
                                                        loginController.selectedTalukas,loginController.selectedVillages, '',safeLat,
                                                        safeLng,distance,searchController.text.toString(), context);
                                                  }
                                                  else{
                                                    await  loginController.getProfileDetails(
                                                      userType,
                                                      loginController.selectedState,
                                                      loginController.selectedDistricts,
                                                      loginController.selectedTalukas,loginController.selectedVillages,'true',safeLat,
                                                      safeLng,distance, searchController.text.toString(),
                                                      context,
                                                    );
                                                  }
                                                  Navigator.pop(context);
                                                  // Get.back();
                                                },
                                                onReset: () {
                                                  setState(() {
                                                    loginController.selectedDistance = null;
                                                    loginController.selectedDistrict = null;
                                                    loginController.selectedArea = null;
                                                    loginController.selectedUserType=null;
                                                    loginController.selectedTaluka=null;
                                                    loginController.selectedState=null;
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
                            SizedBox(height: size*0.02,),

                            GetBuilder<LoginController>(
                                builder: (controller) {
                                  return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: title.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1.2,
                                  ),
                                  itemBuilder: (context, index) {
                                    final String userType = title[index];
                                   // final int count = typeCounts[userType] ?? 0;
                                    Map<String, int> typeCounts = {};

                                    for (var p in controller.profileList) {
                                      typeCounts[p.userType] =
                                          (typeCounts[p.userType] ?? 0) + 1;
                                    }
                                    final count = loginController.profileList
                                        .where((e) =>
                                    e.userType.toLowerCase().trim() ==
                                        userType.toLowerCase().trim())
                                        .length;
                                    return GestureDetector(
                                      onTap: () async {
                                        // if (title[index] == "Job Posts/Webinars") {
                                        //   Get.toNamed('/viewJobWebinarPage');
                                        // } else {
                                          Api.userInfo.write(
                                            'sUserType',
                                            title[index].toString(),
                                          );

                                          await loginController.getProfileDetails(
                                            title[index],
                                            '',
                                            [],
                                            [],[],
                                            'true',
                                            '',
                                            '',
                                            '',
                                            '',
                                            context,
                                          );

                                          if (Get.currentRoute != '/userTypeListPage') {
                                            Get.toNamed('/userTypeListPage');
                                         // }
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [

                                            /// IMAGE
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: Image.asset(
                                                  // imgUserType(title[index]),
                                                  imgUserTypeNew(title[index]),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),

                                            /// TITLE
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                                child: Column(
                                              children: [

                                              /// TITLE
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                                child: Text(
                                                  "${userType} ($count)",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTextStyles.caption(
                                                    context,
                                                    color: AppColors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              /// COUNT BADGE
                                              const SizedBox(height: 5),
                                              ],
                                            ),
                                                // Text(
                                                //   title[index],
                                                //   textAlign: TextAlign.center,
                                                //   maxLines: 2,
                                                //   overflow: TextOverflow.ellipsis,
                                                //   style: AppTextStyles.caption(
                                                //     context,
                                                //     color: AppColors.black,
                                                //     fontWeight: FontWeight.bold,
                                                //   ),
                                                ),
                                            ),
                                          ],
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
                      // AdminDashboardWidget(profiles: controller.profileList),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Text(
                            'Latest Users List',textAlign: TextAlign.start,
                             style: AppTextStyles.body(context,fontWeight: FontWeight.bold),
                                ),
                          if(controller.profileList.isEmpty)
                          buildShimmerEmptyWidget(size),
                          if(controller.profileList.isNotEmpty)

                          AnimationLimiter(
                            child: Column(
                            children: controller.profileList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final profile = entry.value;
                            return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 1300),
                            child: SlideAnimation(
                            verticalOffset: 120.0,
                            curve: Curves.easeOutBack,
                            child: FadeInAnimation(
                            child: GestureDetector(
                            onTap: () async{
                            print('userlistId ${profile.userId}');
                            // Api.userInfo.write(
                            // 'selectUserId', profile.userId ?? '');
                            Api.userInfo.write('selectUId',profile.userId ?? '');

                            print('ids${profile.userId}');

                            await loginController.getProfileByUserId(
                            profile.userId ?? '', context);
                            if (PlatformHelper.platform != "Web") {
                            Get.toNamed('/${profilePage(profile.userType)}');
                            }
                            },
                            child: SuperAdminProfileCard(
                            profile: profile,
                            size: size,
                            onCall: ()async {
                            await launchCall(profile.mobileNumber);
                            },
                            ),
                            ),
                            ),
                            ),
                            );
                            }).toList(),
                            ),
                            )
                            ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
      ),
    );
  }

}

Widget dashboardShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

class SuperAdminProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final double size;
  final void Function()? onCall;
  const SuperAdminProfileCard({
    super.key,
    required this.profile,
    required this.size,
    this.onCall,
  });
  bool isBasePlanActive(ProfileModel profile) {
    final isActive =
    profile.details?["plan"]?["basePlan"]?["isActive"];
    return isActive == true || isActive == "true";
  }
  @override
  Widget build(BuildContext context) {
    final planActive = isBasePlanActive(profile);
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
    //print('planStatus$planActive isAdminn$isAdminUser');
    String firstImage = profile.images.firstWhere(
          (img) =>
      img.toLowerCase().endsWith('.jpg') ||
          img.toLowerCase().endsWith('.jpeg') ||
          img.toLowerCase().endsWith('.png') ||
          img.toLowerCase().endsWith('.webp'),
      orElse: () => "",
    );
    List<String> parts = [];
    if ((profile.address["state"] ?? "").isNotEmpty) parts.add(profile.address["state"]);
    if ((profile.address["district"] ?? "").isNotEmpty) parts.add(profile.address["district"]);
    if ((profile.address["city"] ?? "").isNotEmpty) parts.add(profile.address["city"]);
    String address = parts.join(", ");
    final loginController=Get.put(LoginController());
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 4))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    // (firstImage.isNotEmpty&&(planActive==true&&profile.details["plan"]?["basePlan"]?["details"]?["images"] == true||
                    //     isAdminUser)) ? firstImage : "",
                    (firstImage.isNotEmpty && isAdminUser||
                        ((planActive == true &&
                            profile.details["plan"]?["basePlan"]?["details"]?["images"] == true)))
                        ? firstImage
                        : "",
                    width: size * 0.25,
                    height: size * 0.25,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: size * 0.25,
                        height: size * 0.25,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              (profile.userType == "Dental Clinic" ||
                                  profile.userType == "Dental Consultant")
                                  ? "Dr. ${profile.name}"
                                  : profile.name,softWrap: true,
                              style: AppTextStyles.caption(
                                context,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(color:profile.isActive
                                ? Colors.green
                                : Colors.redAccent,borderRadius: BorderRadius.circular(10) ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                "•${profile.isActive ? 'Active' : 'Inactive'}",
                                style: TextStyle(
                                  color: AppColors.white,fontWeight: FontWeight.bold,fontSize: size*0.025),
                              ),
                            ),
                          )
                        ],
                      ),
                      Text("UserId: ${profile.userId}",
                          style: AppTextStyles.caption(context)),
                      Text("UserType: ${profile.userType}",
                          style: AppTextStyles.caption(context)),
                      Text("Address: $address",
                          style: AppTextStyles.caption(context,
                              color: Colors.grey)),
                      // if((planActive==true&&profile.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true)||
                      //     isAdminUser)
                      // Row(children: [
                      //   IconButton(
                      //       icon: Icon(Icons.call,
                      //           size: size * 0.05, color: AppColors.primary),
                      //       onPressed: onCall),
                      //   Flexible(child: Text(profile.mobileNumber,
                      //       overflow: TextOverflow.ellipsis,
                      //       style: AppTextStyles.caption(context))),
                      // ])
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((planActive == true &&
                                profile.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ||
                                isAdminUser)
                            Text(
                              "Mobile Number: ${profile.mobileNumber}",
                              style: AppTextStyles.caption(context),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              ]),
              const SizedBox(height: 8),

              Row(
                children: [

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: ()async {
                        Api.userInfo.write('selectUId',profile.userId ?? '');

                        print('ids${profile.userId}');

                        await loginController.getProfileByUserId(
                            profile.userId ?? '', context);
                        if (PlatformHelper.platform != "Web") {
                          Get.toNamed('/${profilePage(profile.userType)}');
                        }
                      },
                      child:  Text(
                        "View Profile",
                        style: AppTextStyles.caption(color: Colors.white,context,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  if ((planActive == true &&
                      profile.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ||
                      isAdminUser)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color:Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onCall,
                        child: Text(
                          "Call Now",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class AdminDashboardWidget extends StatelessWidget {
  final List<ProfileModel> profiles;
  final loginController=Get.put(LoginController());
   AdminDashboardWidget({super.key, required this.profiles});
  @override
  Widget build(BuildContext context) {
    int total = profiles.length;
    int active = profiles.where((p) => p.isActive).length;
    int inactive = total - active;
    Map<String, int> typeCounts = {};
    for (var p in profiles) {
      typeCounts[p.userType] = (typeCounts[p.userType] ?? 0) + 1;
    }
    return Column(
      children: [
        _header(context,total,active,inactive),
        const SizedBox(height: 20),
        AnimationLimiter(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            //height: MediaQuery.of(context).size.width * 0.8,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
            children: typeCounts.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 1300),
            child: SlideAnimation(
              horizontalOffset: 80.0,
            curve: Curves.easeOutBack,
            child: FadeInAnimation(
            child: Column(
              children:[
               _typeTile(
              e.key,
              e.value,
              context,
              onTap: () async{
              Api.userInfo.write('selectedUserType', e.key);
              Api.userInfo.write('sUserType', e.key);
              Get.toNamed('/userTypeListPage');

             await  loginController.getProfileDetails(
              Api.userInfo.read('selectedUserType'),
              '',
              [],
              [],[],
              '','','','','',
                context,
              );

              },
               ),
              const Divider(color: Colors.grey,thickness: 0.3,)
              ]
            ),
            ),
            ),
            );
            }).toList(),
            ),
          ),
        ],
      ),
    ),
    ),

      ],
    );
  }
  Widget _header(BuildContext context, int total, int active, int inactive) {
    double width = MediaQuery.of(context).size.width;
    double height = width * 0.35;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dashboard",
                style: AppTextStyles.caption(
                  context,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Overview of user activity",
                style: AppTextStyles.subtitle(
                  context,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -30,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStatCard(context, "Total Users", total, AppColors.white, AppColors.primary),
              _miniStatCard(context, "Active", active, AppColors.white, Colors.green),
              _miniStatCard(context, "Inactive", inactive, AppColors.white, Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard(
      BuildContext context, String label, int value, Color bgColor, Color textColor) {
    double width = MediaQuery.of(context).size.width * 0.27;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.caption(
              context,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "$value",
            style: AppTextStyles.subtitle(
              context,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
  Widget _typeTile(String title, int count, BuildContext context,
      {VoidCallback? onTap}) {
    double size = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "$title ($count)",
                style: AppTextStyles.caption(
                  context,color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,softWrap: true,
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: size * 0.04,
              color: AppColors.black,
            ),
          ],
        ),
      ),
    );
  }

}

Widget drawerTitle(
    String title,
    IconData icon,
    String page,
    BuildContext context,
    ) {
  double size = MediaQuery.of(context).size.width;

  return ListTile(
    leading: Icon(
      icon,
      color: AppColors.white,
      size: size * 0.055,
    ),
    title: Text(
      title,
      style: AppTextStyles.caption(
        context,
        color: AppColors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    trailing: Icon(
      Icons.arrow_forward_ios,
      color: AppColors.white,
      size: size * 0.035,
    ),
    onTap: () {
      if (page.isNotEmpty) {
        Get.toNamed(page);
      }
    },
  );
}
