import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import '../../../common_widgets/color_code.dart';


class AddBranches extends StatefulWidget {
  const AddBranches({super.key});
  @override
  State<AddBranches> createState() => _AddBranchesState();
}
class _AddBranchesState extends State<AddBranches> {
  final loginController=Get.put(LoginController());
  final planController=Get.put(PlanController());
  final _formKeyBranchProfile = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _refresh();
  } Future<void> _refresh() async {
    loginController.getBranchDetails(context);
    //loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
    final position = await LocationService.getCurrentLocation();
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
    double size = MediaQuery.of(context).size.width;
    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        title: Text('Add Branches',
          style: AppTextStyles.subtitle(context,color: AppColors.black),),automaticallyImplyLeading: true,iconTheme: IconThemeData(color: AppColors.black,size: size*0.05),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration:  const BoxDecoration(
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
      body: GetBuilder<LoginController>(
          init: LoginController(),
          builder: (controller) {
            return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              child: Form(
                key: _formKeyBranchProfile,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      GetBuilder<LoginController>(
                          init: LoginController(),
                          builder: (controller) {
                            return Column(
                                children: [
                                  // CustomTextField(
                                  //   hint: "Email",
                                  //   icon: Icons.location_on,
                                  //   controller: loginController.emailController,
                                  //   // fillColor: AppColors.white,
                                  //   // borderColor: AppColors.grey,
                                  // ),
                                  // SizedBox(height: size*0.03,),
                                  // CustomTextField(
                                  //   hint: "Mobile Number",
                                  //   icon: Icons.location_on,
                                  //   controller: loginController.mobileController,
                                  //   // fillColor: AppColors.white,
                                  //   // borderColor: AppColors.grey,
                                  //   maxLength: 10,
                                  // ),
                                //  SizedBox(height: size*0.03,),
                                  for (int i = 0; i < loginController.branchList.length; i++)
                                    _branchListFields(i,size),
                                  Container(
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
                                        await loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
                                        Get.toNamed('/clinicEditProfile',arguments: {'branchId':'0'});
                                      },
                                          //loginController.addBranchList(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: AppColors.transparent,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add, size: size * 0.05, color: AppColors.white),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Add Branches",
                                            style: AppTextStyles.caption(context, color: AppColors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ), ]);
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
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
                      icon:  Icon(Icons.edit, color: Colors.red,size: MediaQuery.of(context).size.width*0.06,),
                      onPressed: () {
                        print('id ${exp.userId ?? ""}');

                        if (exp.userId != null && exp.userId!.isNotEmpty) {
                          loginController.getProfileByUserId(exp.userId!, context);
                          Get.toNamed('/clinicEditProfile',);
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
          SizedBox(height: size * 0.03),
          CustomTextField(
            hint: "State",
            controller: exp.state,
          ),
          SizedBox(height: size * 0.03),
          CustomTextField(
            hint: "District",
            controller: exp.district,
          ),
          SizedBox(height: size * 0.03),
          CustomTextField(
            hint: "City",
            controller: exp.city,
          ),
          SizedBox(height: size * 0.03),
          CustomTextField(
            hint: "Area",
            controller: exp.area,
          ),
          SizedBox(height: size * 0.03),
          CustomTextField(
            hint: "Pin Code",
            controller: exp.pincode,
          ),
          SizedBox(height: size * 0.03),
          CustomTextField(
            hint: "Location",
            controller: exp.location,
          ),
          SizedBox(height: size * 0.03),

        ],
      ),
    );
  }


}
