import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../../common_widgets/color_code.dart';
import '../common/common_side_bar.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';


class AddBranchesWeb extends StatefulWidget {
  const AddBranchesWeb({super.key});
  @override
  State<AddBranchesWeb> createState() => _AddBranchesWebState();
}
class _AddBranchesWebState extends State<AddBranchesWeb> {
  final loginController=Get.put(LoginController());
  final planController=Get.put(PlanController());
  final _formKeyBranchProfileWeb = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKeyBranch= GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _refresh();
  }
  Future<void> setProfileData(user) async {

    loginController.selectedState = user.address["state"] ?? "";
    loginController.selectedDistrict = user.address["district"] ?? "";
    loginController.selectedTaluka = user.address["city"] ?? "";
    loginController.selectedVillage = user.address["area"] ?? "";
    print('fgf${user.address["district"] ?? ""}');
    await loginController.fetchStates();
    if (loginController.selectedState != null && loginController.selectedState!.isNotEmpty) {
      await loginController.fetchDistricts(loginController.selectedState!);
    }
    if (loginController.selectedDistrict != null && loginController.selectedDistrict!.isNotEmpty) {
      await loginController.fetchTalukas(loginController.selectedDistricts!);
    }
    if (loginController.selectedTaluka != null && loginController.selectedTaluka!.isNotEmpty) {
      await loginController.fetchVillages(loginController.selectedTalukas!);
    }

    loginController.update();
  }

  Future<void> _refresh() async {
  await  loginController.getBranchDetails(context);
    //loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
    final position = await LocationService.getCurrentLocation();
    if (loginController.userData.isNotEmpty) {
      setProfileData(loginController.userData.first);
    }
    if (position != null) {
      loginController.latitude = position.latitude;
      loginController.longitude = position.longitude;
      print('latt${loginController.latitude}long${loginController.longitude}');
      debugPrint(
          'User location: Lat ${position.latitude}, Lng ${position.longitude}');
    }
  }
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double size = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isTablet = width >= 700 && width < 1100;
    final bool isMobile = width < 700;
    return  Scaffold(
      key: _scaffoldKeyBranch,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : (isTablet ? 70 : 80),
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<LoginController>(
          init: LoginController(),
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: Row(
                children: [
                  if (isDesktop) const AdminSideBar(),

                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKeyBranchProfileWeb,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1000),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(height: size*0.01,),
                                      if (!isDesktop)
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.menu,
                                              color: AppColors.black,
                                            ),
                                            onPressed: () {
                                              _scaffoldKeyBranch.currentState?.openDrawer();
                                            },
                                          ),
                                        ),

                                      Text(
                                        "Add Branches",
                                        style: AppTextStyles.subtitle(context, color: AppColors.black),
                                      ),
                                      SizedBox(height: size*0.005,),
                                      GetBuilder<LoginController>(
                                          init: LoginController(),
                                          builder: (controller) {
                                            return Column(
                                                children: [
                                                  for (int i = 0; i < loginController.branchList.length; i++)
                                                    _branchListFields(i,size),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                                                    child: Container(
                                                      //height:size * 0.018,
                                                                                                     // width:size*0.12,
                                                      decoration: BoxDecoration(
                                                        gradient: const LinearGradient(
                                                          colors: [AppColors.primary, AppColors.secondary],
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                        ),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: ElevatedButton(
                                                        onPressed: ()async {
                                                          loginController.userData.clear();
                                                          loginController.clearProfileData();
                                                          // loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
                                                          Get.toNamed('/registerPageWeb',arguments: {'branchId':'0'});
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.transparent,
                                                          shadowColor:Colors.transparent,
                                                          elevation: 4,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                                        ),
                                                        child: Center(
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(Icons.add, size: 13, color: AppColors.white),
                                                              const SizedBox(width: 8),
                                                              Flexible(
                                                                child: Text(
                                                                  "Add Branches",
                                                                  style: AppTextStyles.caption(context, color: AppColors.white),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                  ),
                                                  SizedBox(height: 25),

                                                ]);
                                          }
                                      ),
                                      SizedBox(height: size*0.02,),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    //  bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }Widget _branchListFields(int index,size) {
    final loginController=Get.put(LoginController());
    final exp = loginController.branchList[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Branch ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),

                // if (index > 0)
                //   GetBuilder<LoginController>(
                //       builder: (controller) {
                //         return IconButton(
                //           icon:  Icon(Icons.delete, color: Colors.red,size: MediaQuery.of(context).size.width*0.06,),
                //           onPressed: () {
                //             loginController.removeBranchField(index);
                //            // loginController.deactivateUserAdmin(userId, isActive, context)
                //             },
                //         );
                //       }
                //   ),
                GetBuilder<LoginController>(
                    builder: (controller) {
                      return IconButton(
                        icon:  Icon(Icons.edit, color: Colors.red,size: MediaQuery.of(context).size.width*0.012,),
                        onPressed: () {
                          print('id ${exp.userId ?? ""}');

                          if (exp.userId != null && exp.userId!.isNotEmpty) {
                            loginController.getProfileByUserId(exp.userId!, context);
                            Get.toNamed('/registerPageWeb',);
                          } else {
                            print("UserId is null");
                          }
                        },
                      );
                    }
                ),
              ],
            ),
            CustomTextField(
              hint: "Branch Name",
              controller: exp.branchName,
            ),
            SizedBox(height: size * 0.01),
            //   _buildStateDropdown(),
            // SizedBox(height: size * 0.01),
            //   _buildDistrictDropdown(),
            // SizedBox(height: size * 0.01),
            //   _buildTalukaDropdown(),
            // SizedBox(height: size * 0.01),
            //   _buildAreaDropdown(),
            // SizedBox(height: size * 0.01),

            CustomTextField(
              hint: "State",
              controller: exp.state,
            ),
            SizedBox(height: size * 0.01),
            CustomTextField(
              hint: "District",
              controller: exp.district,
            ),
            SizedBox(height: size * 0.01),
            CustomTextField(
              hint: "City",
              controller: exp.city,
            ),
            SizedBox(height: size * 0.01),
            CustomTextField(
              hint: "Area",
              controller: exp.area,
            ),
            SizedBox(height: size * 0.01),
            CustomTextField(
              hint: "Pin Code",
              controller: exp.pincode,
            ),
            SizedBox(height: size * 0.01),
            CustomTextField(
              hint: "Location",
              controller: exp.location,
            ),
            SizedBox(height: size * 0.01),

          ],
        ),
      ),
    );
  }
  Widget _buildStateDropdown() {
    return GetBuilder<LoginController>(
      builder: (c) {
        final stateItems = c.states.map((e) => e.toString()).toList();

        return CustomDropdown<String>.search(
          hintText: "State",
          items: stateItems,
          initialItem: stateItems.contains(c.selectedState)
              ? c.selectedState
              : null,
          onChanged: (v) {
            if (v != null) {
              c.selectedState = v;

              c.selectedDistrict = null;
              c.selectedTaluka = null;

              c.districts.clear();
              c.talukas.clear();

              c.fetchDistricts(v);
              c.update();
            }
          },
        );
      },
    );
  }

  Widget _buildDistrictDropdown() {
    return GetBuilder<LoginController>(
      builder: (c) {
        final districtItems =
        c.districts.map((e) => e.toString()).toList();

        return CustomDropdown<String>.search(
          hintText: "District",
          items: districtItems,
          initialItem: districtItems.contains(c.selectedDistrict)
              ? c.selectedDistrict
              : null,
          onChanged: (v) {
            if (v != null) {
              c.selectedDistrict = v;

              c.selectedTaluka = null;

              c.talukas.clear();

              c.fetchTalukas([v]);
              c.update();
            }
          },
        );
      },
    );
  }

  Widget _buildTalukaDropdown() {
    return GetBuilder<LoginController>(
      builder: (c) {

        final talukaItems =
        c.talukas.map((e) => e.toString()).toList();

        final selectedTaluka =
        talukaItems.contains(c.selectedTaluka)
            ? c.selectedTaluka
            : null;

        return CustomDropdown<String>.search(
          hintText: "Taluka",

          items: talukaItems,

          initialItem: selectedTaluka,

          onChanged: (v) {
            if (v != null) {
              c.selectedTaluka = v;

              c.villages.clear();
              c.selectedVillage = null;

              c.fetchVillages([v]);

              c.update();
            }
          },
        );
      },
    );
  }
  Widget _buildAreaDropdown() {
    return GetBuilder<LoginController>(
      builder: (c) {
        final villageItems = c.villages.map((e) => e.toString()).toList();
        final selectedVillage = villageItems.contains(c.selectedVillage) ? c.selectedVillage : null;

        return CustomDropdown<String>.search(
          hintText: "Area",
          items: villageItems,
          initialItem: selectedVillage,
          onChanged: (v) {
            if (v != null) {
              c.selectedVillage = v;
              c.update();
            }
          },
        );
      },
    );
  }


}
