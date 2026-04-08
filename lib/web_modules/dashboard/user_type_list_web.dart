import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/web_modules/common/filter_side_bar.dart';

class ModernUserTable extends StatefulWidget {
  @override
  State<ModernUserTable> createState() => _ModernUserTableState();
}

class _ModernUserTableState extends State<ModernUserTable> {
  final loginController = Get.put(LoginController());
  String?userType;
  List<ProfileModel> filteredProfiles = [];
  final TextEditingController searchController = TextEditingController();

  List<ProfileModel> getFilteredProfiles() {
    if (userType == null || userType!.isEmpty) {
      print('length web userlist${loginController.profileList.length}');
      return loginController.profileList;
    }
    print('length web userlist${loginController.profileList.length}');
    return loginController.profileList
        .where((p) => p.userType.toLowerCase() == userType!.toLowerCase())
        .toList();
  }
  @override
  void initState(){
    super.initState();
    _refresh();
    getFilteredProfiles();
  }
  Future<void> _refresh() async {
    await  loginController.getProfileDetails(
      Api.userInfo.read('sUserType1'),
      '',
      '',
      '','true',
      '','','','',
      context,
    );
   await loginController.fetchStates();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
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
      return WillPopScope(
      onWillPop: () async {
        Get.toNamed('/${pageUserTypeWeb(Api.userInfo.read('userType') ?? "")}');
        if( Api.userInfo.read('userType')=="superAdmin") {
          loginController.getProfileDetails('', '', '', '', '','','','','',  context);
        }
        if( Api.userInfo.read('userType')=="admin") {
          loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", '', '', '','','','','', context);
        }
        return true;
      },
      child: Scaffold(
        appBar: buildAppBar(),
        // appBar: CommonWebAppBar(
        //   height: size * 0.08,
        //   title: "LYD",
        //   onLogout: () {
        //   },
        //   onNotification: () {
        //   },
        // ),
        body: GetBuilder<LoginController>(
            builder: (controller) {
              final filteredProfiles = (userType == null || userType!.isEmpty)
                  ? controller.profileList
                  : controller.profileList
                  .where((p) => p.userType.toLowerCase() == userType!.toLowerCase())
                  .toList();
              print("Filtered profiles length: ${filteredProfiles.length}");
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminSideBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child:Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1300),
                          child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: size*0.15,
                                child: FilterSidebar(),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [

                                      Align(
                                        alignment: Alignment.topRight,
                                        child:   Padding(
                                          padding: const EdgeInsets.all(30.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: size * 0.35,
                                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.15),
                                                      blurRadius: 6,
                                                    )
                                                  ],
                                                ),
                                                child: TextField(
                                                  controller: searchController,
                                                  onChanged: (value)async {
                                                    Api.userInfo.read('userType')!='superAdmin'?
                                                    await loginController.getProfileDetails(
                                                      userType ?? "",
                                                      loginController.selectedState,
                                                      loginController.selectedDistrict,
                                                      loginController.selectedTaluka,"true",'','','',searchController.text.toString(),
                                                      context,
                                                    )
                                                        :await loginController.getProfileDetails(
                                                      userType ?? "",
                                                      loginController.selectedState,
                                                      loginController.selectedDistrict,
                                                      loginController.selectedTaluka,"",'','','',searchController.text.toString(),
                                                      context,
                                                    );
                                                  },
                                                  decoration: InputDecoration(
                                                    icon: Icon(
                                                      Icons.search,
                                                      color: AppColors.grey,
                                                      size: size * 0.008,
                                                    ),
                                                    hintText: "Search by name, userId, mobile number...",
                                                    hintStyle:
                                                    AppTextStyles.caption(context, color: AppColors.grey),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 10),


                                            //   Container(
                                            //     height: 45,
                                            //     width: 45,
                                            //     decoration: BoxDecoration(
                                            //       color: AppColors.primary,
                                            //       borderRadius: BorderRadius.circular(10),
                                            //       boxShadow: [
                                            //         BoxShadow(
                                            //           color: AppColors.primary.withOpacity(0.3),
                                            //           blurRadius: 6,
                                            //         )
                                            //       ],
                                            //     ),
                                            //     child: IconButton(
                                            //       icon:  Icon(Icons.filter_list, color: Colors.white,size: size*0.012,),
                                            //       onPressed: () {
                                            //
                                            // showFilterDialog(context,onApply: ()async{
                                            //
                                            //   print("Selected State: ${loginController.selectedState}");
                                            //   print("Selected District: ${loginController.selectedDistrict}");
                                            //   print("Selected Area: ${loginController.selectedArea}");
                                            //
                                            //   print("ssuser$userType");
                                            //   filteredProfiles.map((e) => searchController.text.toString());
                                            //   await loginController.getProfileDetails(
                                            //     Api.userInfo.read('selectedUserType1'),
                                            //     loginController.selectedState,
                                            //     loginController.selectedDistrict,
                                            //     loginController.selectedTaluka,"",'','','','',
                                            //     context,
                                            //   );
                                            //   Get.back();
                                            // },onReset: (){
                                            //
                                            //   loginController.selectedArea = null;
                                            //   loginController.selectedUserType=null;
                                            //   loginController.selectedState=null;
                                            //   loginController.selectedDistrict=null;
                                            // });
                                            //
                                            //       },
                                            //     ),
                                            //   ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20,),
                                      if(filteredProfiles.length==0)
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Center(child: Text('No data found',style: AppTextStyles.caption(context),)),
                                        ),
                                      if(filteredProfiles.length>0)

                                      Padding(
                                        padding: const EdgeInsets.only(left: 35.0,right: 35),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.85),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(flex: 1, child: Center(child: Text("S.No", style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold)))),
                                              Expanded(flex: 2, child: Center(child: Text("Name", style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold)))),
                                              Expanded(flex: 2, child: Center(child: Text("User ID",style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold)))),
                                              Expanded(flex: 2, child: Center(child: Text("User Type",style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold)))),
                                              Expanded(flex: 2, child: Center(child: Text("Mobile", style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold)))),
                                              Expanded(flex: 1, child: Center(child: Text("View", style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold)))),
                                              Expanded(flex: 1, child: Center(child: Text("Status", style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold)))),
                                              Expanded(flex: 1, child: Center(child: Text("Actions", style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold)))),

                                            ],
                                          ),
                                        ),
                                      ),

                                      AnimationLimiter(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:filteredProfiles.length,
                                          //users.length,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final user = filteredProfiles[index];
                                            final isEven = index % 2 == 0;
                                            return AnimationConfiguration.staggeredList(
                                              position: index,
                                              duration: const Duration(milliseconds: 1300),
                                              child: SlideAnimation(
                                                verticalOffset: 120.0,
                                                curve: Curves.linear,
                                                child: FadeInAnimation(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 35.0,right: 35),
                                                    child: Container(
                                                      color: isEven ? Colors.grey[100] : Colors.white,
                                                      padding:  const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                      child: Row(
                                                        children: [
                                                          Expanded(flex: 1, child: Center(child: Text( "${index + 1}", style: AppTextStyles.caption(context)))),
                                                          Expanded(flex: 2, child: Center(child: Text(user.name, style: AppTextStyles.caption(context)))),
                                                          Expanded(flex: 2, child: Center(child: Text(user.userId, style: AppTextStyles.caption(context)))),
                                                          Expanded(flex: 2, child: Center(child: Text(user.userType, style: AppTextStyles.caption(context)))),
                                                          Expanded(flex: 2, child: Center(child: Text(user.mobileNumber, style: AppTextStyles.caption(context)))),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Center(
                                                              child: IconButton(
                                                              icon: Icon(Icons.remove_red_eye, color: Colors.grey, size: size * 0.012),
                                                              onPressed: ()async {
                                                                Api.userInfo.write('selectUId',user.userId.toString());
                                                              await  loginController.getProfileByUserId(user.userId.toString(), context);
                                                              Get.toNamed('/clinicProfileWebPage');
                                                               }),
                                                            )
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                              decoration: BoxDecoration(
                                                                color: user.isActive ? Colors.green : Colors.red,
                                                                borderRadius: BorderRadius.circular(20),
                                                              ),
                                                              child: Text(
                                                                user.isActive ? "Active" : "Inactive",
                                                                textAlign: TextAlign.center,
                                                                style: AppTextStyles.caption(context),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: IconButton(
                                                              icon: Icon(Icons.delete, color: Colors.red, size: size * 0.012),
                                                              onPressed: ()async {
                                                                showDeleteDialog(
                                                                  context: context,
                                                                  title: "Want to Deactivate User?",
                                                                  message: "This User will be permanently removed.",
                                                                  onConfirm: () async {
                                                                    user.isActive==true?
                                                                    await  loginController.deactivateUserAdmin(user.userId,false,context)
                                                                        : await  loginController.deactivateUserAdmin(user.userId,true,context);
                                                                    await loginController.getProfileDetails(
                                                                        '', '', '', '', "", '', '', '', '', context);
                                                                    loginController.update();
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 40,)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
          }
        ),
      ),
    );
  }
}