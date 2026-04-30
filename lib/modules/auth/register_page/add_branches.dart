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
                                        loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
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
                      // const SizedBox(height: 20,),
                      // Center(
                      //   child: SizedBox(
                      //     width: size*0.65,
                      //     height: size*0.12,
                      //     child: Container(
                      //       decoration: BoxDecoration(
                      //         gradient: const LinearGradient(
                      //           colors: [AppColors.primary, AppColors.secondary],
                      //           begin: Alignment.topLeft,
                      //           end: Alignment.bottomRight,
                      //         ),
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //       child: ElevatedButton(onPressed: ()async
                      //       {
                      //         if (_formKeyBranchProfile.currentState!.validate()) {
                      //           print("FULL NAME = ${loginController.fullNameController.text}");
                      //           print("type NAME = ${loginController.typeNameController.text}");
                      //           print("MOBILE = ${loginController.mobileController.text}");
                      //           print("EMAIL = ${loginController.emailController.text}");
                      //           print("ADDRESS = ${loginController.addressController.text}");
                      //           print("STATE = ${loginController.stateController.text}");
                      //           print("DISTRICT = ${loginController.districtController.text}");
                      //           print("CITY = ${loginController.cityController.text}");
                      //           print("PINCODE = ${loginController.pinCodeController.text}");
                      //           print("LAB NAME = ${loginController.typeNameController.text}");
                      //           print("IMAGES = ${loginController.images}");
                      //           print("CERTIFICATES = ${loginController.certificates}");
                      //           print('userid${ loginController.selectUserId }');
                      //           print('services name${loginController.servicesOfferedController.text}');
                      //           print('website${loginController.websiteController.text}');
                      //           print('google location${loginController.locationController.text}');
                      //           List<File> fileImages = loginController.editImages
                      //               .where((img) => img.file != null)
                      //               .map((img) => img.file!)
                      //               .toList();
                      //           List<File> fileCertificate = loginController.editCertificates
                      //               .where((img) => img.file != null)
                      //               .map((img) => img.file!)
                      //               .toList();
                      //           final oldImageUrls = loginController.editImages
                      //               .where((e) => e.url != null)
                      //               .map((e) => e.url!)
                      //               .toList();
                      //
                      //           final oldCertificateUrls = loginController.editCertificates
                      //               .where((e) => e.url != null)
                      //               .map((e) => e.url!)
                      //               .toList();
                      //
                      //           List<Map<String, dynamic>> branchJson = loginController.branchList.map((e) {
                      //             print("Experience Field: ${e.branchName.text}, ${e.state.text}, ${e.district.text}");
                      //             return {
                      //               "branchName": e.branchName.text??"",
                      //               "state" : e.state.text??"",
                      //               "district" :e.district.text??"",
                      //               "city" : e.city.text??"",
                      //               "area" :e.area.text??"",
                      //               "pincode" :e.pincode.text??"",
                      //               "location" : e.location.text??"",
                      //             };
                      //           }).toList();
                      //
                      //           print('fileCertificate count: ${fileCertificate.length}');
                      //           for (final img in fileCertificate) {
                      //             debugPrint('before upload Certificate path: ${img.path}');
                      //           }
                      //           final primaryBranch =
                      //           branchJson.isNotEmpty ? branchJson.first : {};
                      //
                      //           await loginController.registerUser(
                      //             //userId:loginController.selectUserId!,
                      //             userId:"0",
                      //             userType: loginController.selectedUserType!,
                      //             fullName: loginController.fullNameController.text,
                      //             martialStatus:loginController.selectedMartialStatus!,
                      //             dob:loginController.dobController.text,
                      //             mobile: loginController.mobileController.text,
                      //             email: loginController.emailController.text,
                      //             // address: loginController.addressController.text,
                      //             confirmPassword: loginController.passwordController.text,
                      //            // taluk:loginController.stateController.text,
                      //             // district: loginController.districtController.text,
                      //             // city: loginController.cityController.text,
                      //             // area: loginController.areaController.text,
                      //             // pinCode: loginController.pinCodeController.text,
                      //             taluk: primaryBranch["state"] ?? "",
                      //             district: primaryBranch["district"] ?? "",
                      //             city: primaryBranch["city"] ?? "",
                      //             area: primaryBranch["area"] ?? "",
                      //             pinCode: primaryBranch["pincode"] ?? "",
                      //             location: primaryBranch["location"] ?? "",
                      //             typeName: loginController.typeNameController.text,
                      //             image: fileImages,
                      //             certificate: fileCertificate,
                      //             logoImage: loginController.logoImages ?? [],
                      //             oldImageUrl:oldImageUrls ,
                      //             oldCertificatesUrl: oldCertificateUrls,
                      //             description: loginController.descriptionController.text??"N/A",
                      //             // services: loginController.servicesOfferedController.text,
                      //             //location: loginController.locationController.text,
                      //             website: loginController.websiteController.text,
                      //             adminId:loginController.selectUserId! ,
                      //             isAdmin: "true",
                      //             latitude: loginController.latitude.toString()??"",
                      //             longitude: loginController.longitude.toString()??"",
                      //             context: context,
                      //           );
                      //         }
                      //       },
                      //           style: ElevatedButton.styleFrom(
                      //             backgroundColor: Colors.transparent,
                      //             shadowColor: AppColors.primary.withOpacity(0.5),
                      //             elevation: 4,
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(12),
                      //             ),
                      //             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),),
                      //           child: Text(
                      //             'Update',style: AppTextStyles.body(context,color: AppColors.white,fontWeight: FontWeight.bold),)
                      //
                      //       ),
                      //     ),
                      //   ),
                      // )
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
          ),            SizedBox(height: size * 0.03),
          CustomTextField(
            hint: "Location",
            controller: exp.location,
          ),            SizedBox(height: size * 0.03),

        ],
      ),
    );
  }


}
