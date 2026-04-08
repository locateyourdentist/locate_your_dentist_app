import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_drawer.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/dashboard/superAdmin.dart';
import '../../common_widgets/common_widget_all.dart';
import '../../model/profile_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class userTypeList extends StatefulWidget {
  const userTypeList({super.key});

  @override
  State<userTypeList> createState() => _userTypeListState();
}

class _userTypeListState extends State<userTypeList> {
  final loginController = Get.put(LoginController());
  final GlobalKey<ScaffoldState> _scaffoldKeyUser = GlobalKey<ScaffoldState>();
  List<ProfileModel> filteredProfiles = [];
  final TextEditingController searchController = TextEditingController();
  String?userType;
  List<ProfileModel> getFilteredProfiles() {
    if (userType == null || userType!.isEmpty) {
      return loginController.profileList;
    }
    return loginController.profileList
        .where((p) => p.userType.toLowerCase() == userType!.toLowerCase())
        .toList();
  }
  @override
  void iniState(){
    super.initState();
    getFilteredProfiles();
    loginController.fetchStates();
  }
  bool isAnyBasePlanActive(List<ProfileModel> profiles) {
    return profiles.any((profile) {
      final isActive =
      profile.details?["plan"]?["basePlan"]?["isActive"];
      return isActive == true || isActive == "true";
    });
  }
  Future<void> _refresh() async {
    getFilteredProfiles();
    loginController.fetchStates();
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    print("Filtered profiles length: ${filteredProfiles.length}");
    final planActive = isAnyBasePlanActive(loginController.profileList);
    print('planStatus$planActive');
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed('/${pageUserType(Api.userInfo.read('userType') ?? "")}');
       if( Api.userInfo.read('userType')=="superAdmin") {
         loginController.getProfileDetails('', '', '', '', '','','','','',  context);
       }
        if( Api.userInfo.read('userType')=="admin") {
          loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", '', '', '','','','','', context);
        }
        return true;
        },
      child: Scaffold(
        key: _scaffoldKeyUser,
        appBar: AppBar(
          centerTitle: true,backgroundColor: AppColors.white,
          title: Text("User Lists",
            style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold),),automaticallyImplyLeading: true,iconTheme: IconThemeData(color: AppColors.black,size: size*0.05),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Get.back();
                //Navigator.pop(context);
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
        ),
        backgroundColor: AppColors.scaffoldBg,
        body: GetBuilder<LoginController>(
          builder: (controller) {
            final filteredProfiles = (userType == null || userType!.isEmpty)
                ? controller.profileList
                : controller.profileList
                .where((p) => p.userType.toLowerCase() == userType!.toLowerCase())
                .toList();
            print("Filtered profiles length: ${filteredProfiles.length}");
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
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
                                    String userType=  Api.userInfo.read('sUserType');
                                    print("ssuser$userType");
                                    filteredProfiles.map((e) => searchController.text.toString());
                                    loginController.getProfileDetails(
                                      userType ?? "",
                                      '',
                                      '',
                                      '','true','','', '', searchController.text.toString(),
                                      context,
                                    );
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
                                  Icons.tune_rounded,
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
                                            print("Selected Area: ${loginController.selectedArea}");

                                            String userType=  Api.userInfo.read('sUserType');
                                            print("ssuser$userType");
                                            filteredProfiles.map((e) => searchController.text.toString());
                                            await loginController.getProfileDetails(
                                              userType ?? "",
                                              loginController.selectedState,
                                              loginController.selectedDistrict,
                                              loginController.selectedTaluka,"true",'','','','',
                                              context,
                                            );
                                            Get.back();
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
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (filteredProfiles.isEmpty)
                        Center(child: Text('No data found', style: AppTextStyles.caption(context))),
                      if (filteredProfiles.isNotEmpty)
                        AnimationLimiter(
                          child: Column(
                            children: List.generate(filteredProfiles.length, (index) {
                                   final profile = filteredProfiles[index];
                                   return AnimationConfiguration.staggeredList(
                                   position: index,
                                   duration: const Duration(milliseconds: 700),
                                   child: SlideAnimation(
                                    horizontalOffset: 80.0,
                                    curve: Curves.easeOutCubic,
                                    child: FadeInAnimation(
                                    child: GestureDetector(
                                    onTap: ()async {
                                      print('userlistId ${profile.userId}');
                                      Api.userInfo.write('selectUserId', profile.userId ?? '');
                                      if (PlatformHelper.platform != "Web") {
                                       await loginController.getProfileByUserId( profile.userId ?? '', context);
                                        Get.toNamed('/${profilePage(profile.userType)}');
                                      }
                                    },
                                    child: SuperAdminProfileCard(
                                      profile: profile,
                                      size: MediaQuery.of(context).size.width,
                                      onCall: () {
                                        launchCall(profile.mobileNumber);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                            })
                                .toList(),
                          ),
                        ),
                    ],
                  ),
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