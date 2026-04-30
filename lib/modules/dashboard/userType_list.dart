import 'dart:io';

import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_drawer.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
import 'package:locate_your_dentist/modules/dashboard/superAdmin.dart';
import '../../common_widgets/common_widget_all.dart';
import '../../model/profile_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
// import 'package:universal_html/html.dart' as html;
import 'package:open_filex/open_filex.dart';

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
  bool isExporting = false;
  List<int>? generateExcel(List profiles) {
    final excel = Excel.createExcel();
    const sheetName = "Users";
    excel.rename('Sheet1', sheetName);

    final sheet = excel[sheetName];

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
    );

    final headerStyle = CellStyle(
      bold: true,
    );

    sheet.appendRow([
      TextCellValue("User Report"),
      TextCellValue(""),
      TextCellValue(""),
      TextCellValue(""),
      TextCellValue(""),
    ]);

    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("E1"));

    sheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

    sheet.appendRow([
      TextCellValue("S.No"),
      TextCellValue("Name"),
      TextCellValue("User ID"),
      TextCellValue("User Type"),
      TextCellValue("Mobile"),
      TextCellValue("Email"),
    ]);

    for (var col in ["A2", "B2", "C2", "D2", "E2","F2"]) {
      sheet.cell(CellIndex.indexByString(col)).cellStyle = headerStyle;
    }
    for (int i = 0; i < profiles.length; i++) {
      final user = profiles[i];

      sheet.appendRow([
        TextCellValue("${i + 1}"),
        TextCellValue(user.name ?? ""),
        TextCellValue(user.userId ?? ""),
        TextCellValue(user.userType ?? ""),
        TextCellValue(user.mobileNumber ?? ""),
        TextCellValue(user.email ?? ""),
      ]);
    }

    return excel.encode();
  }
  Future<void> exportExcelMobile(List profiles) async {
    final bytes = generateExcel(profiles);

    if (bytes == null || bytes.isEmpty) {
      print("Excel empty");
      return;
    }
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    final dir = await getExternalStorageDirectory();

    final filePath =
        "${dir!.path}/users_${DateTime.now()}.xlsx";

    final file = File(filePath);

    await file.writeAsBytes(bytes);

    print("Excel saved at: $filePath");

    await OpenFilex.open(filePath);
    await Share.shareXFiles(
      [XFile(filePath)],
      text: "User Excel Report",
    );
  }
  @override
  void iniState(){
    super.initState();
    _refresh();
  }
  bool isAnyBasePlanActive(List<ProfileModel> profiles) {
    return profiles.any((profile) {
      final isActive =
      profile.details?["plan"]?["basePlan"]?["isActive"];
      return isActive == true || isActive == "true";
    });
  }
  Future<void> _refresh() async {
  // await getFilteredProfiles();
   await loginController.fetchStates();
   loginController.selectedState=null;
   loginController.selectedDistrict=null;
   loginController.selectedTaluka=null;
   loginController.update();
    if( Api.userInfo.read('userType')=="superAdmin") {
    await   loginController.getProfileDetails('', '', '', '', '','','','','',  context);
    }
    else if( Api.userInfo.read('userType')=="admin") {
     await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", '', '', '','','','','', context);
    }
    else {
      await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", '', '', '','','','','', context);
    }
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
          await   loginController.getProfileDetails('', '', '', '', '','','','','',  context);
        }
        else if( Api.userInfo.read('userType')=="admin") {
          await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", '', '', '','','','','', context);
        }
        else {
          await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", '', '', '','','','','', context);
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
            // final filteredProfiles = (userType == null || userType!.isEmpty)
            //     ? controller.profileList
            //     : controller.profileList
            //     .where((p) => p.userType.toLowerCase() == userType!.toLowerCase())
            //     .toList();
           // print("Filtered profiles length: ${filteredProfiles.length}");
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
                                    hintText: "Search users by name, area,mobile number...",
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
                                  onSubmitted: (value)async {
                                    String userType=  Api.userInfo.read('sUserType');
                                    print("ssuser$userType");
                                    //filteredProfiles.map((e) => searchController.text.toString());
                                    // loginController.getProfileDetails(
                                    //   userType ?? "",
                                    //   '',
                                    //   '',
                                    //   '','true','','', '', searchController.text.toString(),
                                    //   context,
                                    // );
                                    if( Api.userInfo.read('userType')=="superAdmin") {
                                      await   loginController.getProfileDetails('', '', '', '', '','','',loginController.selectedDistance.toString(),searchController.text.toString(),  context);
                                    }
                                    if( Api.userInfo.read('userType')=="admin") {
                                      await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", '', '', '','','',loginController.selectedDistance.toString(),searchController.text.toString(), context);
                                    }
                                   else{
                                      await  loginController.getProfileDetails(
                                        userType ?? "",
                                        '',
                                        '',
                                        '','true','','', loginController.selectedDistance.toString(), searchController.text.toString(),
                                        context,
                                      );
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
                                            print("Selected Area: ${loginController.selectedTaluka}");

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
                                            String distance = loginController.selectedDistance ?? "";
                                            String safeLat = (loginController.latitude == null) ? "" : loginController.latitude.toString();
                                            String safeLng = (loginController.longitude == null) ? "" : loginController.longitude.toString();
                                            if( Api.userInfo.read('userType')=="superAdmin") {
                                              await   loginController.getProfileDetails('',  loginController.selectedState,
                                                  loginController.selectedDistrict,
                                                  loginController.selectedTaluka, '',safeLat,
                                                  safeLng,distance,searchController.text.toString(),  context);
                                            }
                                           else if( Api.userInfo.read('userType')=="admin") {
                                              await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", loginController.selectedDistrict,
                                                  loginController.selectedTaluka, '',safeLat,
                                                  safeLng,distance,searchController.text.toString(), context);
                                            }
                                            else{
                                              await  loginController.getProfileDetails(
                                                userType,
                                                loginController.selectedState,
                                                loginController.selectedDistrict,
                                                loginController.selectedTaluka,'true',safeLat,
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
                      // Align(
                      //   alignment: Alignment.topRight,
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(3.0),
                      //     child: SizedBox(
                      //       height: size * 0.1,
                      //       child: ElevatedButton.icon(
                      //         onPressed: () async{
                      //          await exportExcelMobile(loginController.profileList);
                      //         },
                      //         icon: const Icon(Icons.download, size: 18, color: Colors.white),
                      //         label: const Text(
                      //           "Export Excel",
                      //           style: TextStyle(color: Colors.white),
                      //         ),
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: AppColors.primary,
                      //           elevation: 4,
                      //           padding: const EdgeInsets.symmetric(horizontal: 14),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      if (loginController.selectedDistance != null ||loginController.selectedState != null||
                          loginController.selectedDistrict != null ||
                          loginController.selectedTaluka != null ||
                          loginController.selectedJobType != null ||
                          loginController.selectedSalary != null ||
                          loginController.selectedCategories.isNotEmpty)
                        GetBuilder<LoginController>(
                            builder: (_) {
                              return  Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Wrap(
                                  spacing: 3,
                                  runSpacing: 4,
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
                                        await loginController.getProfileDetails(
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          context,
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
                if(loginController.profileList.isNotEmpty)
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: SizedBox(
                            height: size * 0.1,
                            child: ElevatedButton.icon(
                              onPressed: isExporting
                                  ? null
                                  : () async {
                                setState(() {
                                  isExporting = true;
                                });

                                await exportExcelMobile(loginController.profileList);

                                setState(() {
                                  isExporting = false;
                                });
                              },

                              icon: isExporting
                                  ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Icon(Icons.download, size: 18, color: Colors.white),

                              label: Text(
                                isExporting ? "Exporting..." : "Export Excel",
                                style: const TextStyle(color: Colors.white),
                              ),

                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      if (loginController.profileList.isEmpty)
                        Center(child: Text('No data found', style: AppTextStyles.caption(context))),
                      if (loginController.profileList.isNotEmpty)
                        AnimationLimiter(
                          child: Column(
                            // children: List.generate(filteredProfiles.length, (index) {
                            //        final profile = filteredProfiles[index];
                                   children: List.generate(loginController.profileList.length, (index) {
                                   final profile = loginController.profileList[index];
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
                                      Api.userInfo.write('selectUId',profile.userId ?? '');

                                      if (PlatformHelper.platform != "Web") {
                                       //await loginController.getProfileByUserId( profile.userId ?? '', context);
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
