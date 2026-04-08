import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:get/get.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';



class CreateNotificationAdmin extends StatefulWidget {
  const CreateNotificationAdmin({super.key});

  @override
  State<CreateNotificationAdmin> createState() => _CreateNotificationAdminState();
}

class _CreateNotificationAdminState extends State<CreateNotificationAdmin> {
  final notificationController=Get.put(NotificationController());
  final loginController=Get.put(LoginController());
  final ImagePicker _picker = ImagePicker();
  File? selectedImageFile;
  final _formKeyCreateNotification = GlobalKey<FormState>();
  Uint8List? notificationImage;

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      selectedImageFile = File(pickedFile.path);
      notificationController.notificationImage.clear();
    }
  }
  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      selectedImageFile = File(pickedFile.path);
    }
  }
  Future<void> pickSingleImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80);
    if (pickedImage != null) {
      final selectedImageFile = File(pickedImage.path);
      notificationController.notificationImage.clear();
      notificationController.notificationFileImages.clear();
      notificationController.notificationImage.add(selectedImageFile);
      //notificationController.notificationImage.clear();
      notificationController.update();
    }
  }

  Widget _buildSingleImageWidget({File? file, String? url}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: file != null
              ? Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
              : Image.network(url!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              notificationController.notificationImage.clear();
              notificationController.notificationFileImages.clear();
              notificationController.update();
            },
            child: const Icon(Icons.cancel, color: Colors.black,size: 25

              ,),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: GestureDetector(
            onTap: () => pickSingleImage(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
  @override
  void initState(){
    super.initState();
    notificationController.notificationFileImages=[];
    loginController.fetchStates();
    loginController.selectedState=null;
    loginController.selectedDistrict=null;
    loginController.selectedTaluka=null;
    loginController.selectedVillage=null;
  }
  @override
  Widget build(BuildContext context) {
    double s=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
        appBar: AppBar(
          centerTitle: true,backgroundColor: AppColors.white,
          iconTheme: const IconThemeData(color: AppColors.white),
          title: Text('Create Notification',style: AppTextStyles.subtitle(context,color: AppColors.black),),
          automaticallyImplyLeading: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
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
      body: GetBuilder<NotificationController>(
        builder: (controller) {
          return Form(
            key: _formKeyCreateNotification,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: s*0.01,),
                    GetBuilder<NotificationController>(
                        builder: (controller) {
                          return  SizedBox(
                            width: double.infinity,
                            child: CustomDropdownField(
                              hint: "Select User Type",
                              //icon: Icons.person_outline,
                              // borderColor: AppColors.grey,
                              // fillColor: AppColors.white,
                              items: const [
                                "All",
                                "Dental Clinic",
                                "Dental Lab",
                                "Dental Shop",
                                "Dental Mechanic",
                                "Dental Consultant",
                                "Job Seekers"
                              ],
                              selectedValue: notificationController.selectedUserType?.isEmpty == true ? null:
                              notificationController.selectedUserType,
                              onChanged: (value) {
                                  notificationController.selectedUserType = value;
                                  notificationController.update();
                              },
                            ),
                          );
                        }
                    ),
                    SizedBox(height: s*0.02,),

                    CustomDropdownField(
                      hint: "Select Title",
                      //fillColor: Colors.grey[100],borderColor: AppColors.white,
                      items: const ["Offers", "Wishes", "Jobs","Webinars","Others"],
                      selectedValue: notificationController.selectedTitle,
                      onChanged: (value) {
                        setState(() {
                          notificationController.selectedTitle = value;
                        });
                      },
                    ),
                    if(notificationController.selectedTitle=='Others')
                      CustomTextField(
                        hint: "Title",
                        controller: notificationController.titleController,
                        // borderColor: AppColors.grey,
                        // fillColor: AppColors.white,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Title cannot be empty";
                          }
                          return null;
                        },
                      ),
                    SizedBox(height: s*0.02,),

                    CustomTextField(
                      hint: "Message",
                      controller:  notificationController.messageController,
                      // borderColor: AppColors.grey,
                      // fillColor: AppColors.white,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Message cannot be empty";
                        }
                        return null;
                      },
                    ),
                   SizedBox(height: s*0.02,),
                    GetBuilder<LoginController>(
                        builder: (controller) {
                          return DefaultTextStyle(
                            style: AppTextStyles.caption(context, color: Colors.black,fontWeight: FontWeight.normal),
                            child: CustomDropdown<String>.search(
                              hintText: "Select State",
                              items: loginController.states
                                  .map((s) => s.toString())
                                  .toList(),
                              //initialItem: loginController.selectedState,
                              onChanged: (val) {
                                loginController.districts.clear();
                                loginController.talukas.clear();
                                loginController.villages.clear();
                                loginController.selectedVillage=null;
                                loginController.selectedTaluka=null;
                                loginController.selectedDistrict = null;
                                loginController.selectedState = val;
                                if (val != null) {

                                  if (Api.userInfo.read('userType') == 'superAdmin') {
                                    final state = loginController.states
                                        .firstWhere((s) =>
                                    s == val);
                                    loginController.fetchDistricts(
                                        state.toString());
                                    loginController.selectedVillage=null;
                                    loginController.selectedTaluka=null;
                                    loginController.selectedDistrict = null;
                                    print('state${loginController
                                        .selectedState}');
                                    loginController.update();
                                  }
                                  else{
                                    //final state = Api.userInfo.read('state')??"";
                                    final state = loginController.states
                                        .firstWhere((s) =>
                                    s == val);
                                    loginController.fetchDistricts(
                                        state.toString());
                                    loginController.fetchDistricts(
                                        state.toString());
                                    print('states  code${state.toString()}');
                                    loginController.update();
                                  }
                                }
                              },  decoration: CustomDropdownDecoration(
                              closedFillColor: Colors.grey[100],
                              expandedFillColor: Colors.white,
                              closedBorder: Border.all(
                                color: AppColors.white,
                                width: 1.5,
                              ),
                              expandedBorder: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              closedBorderRadius: BorderRadius.circular(10),
                              expandedBorderRadius: BorderRadius.circular(10),
                              hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                              headerStyle: AppTextStyles.caption(context, color: Colors.black),
                              listItemStyle: AppTextStyles.caption(context, color: Colors.black),),

                            ),
                          );
                        }
                    ),
                    SizedBox(height: s * 0.02),

                    DefaultTextStyle(
                      style: AppTextStyles.caption(context, color: Colors.black,fontWeight: FontWeight.normal),
                      child:GetBuilder<LoginController>(
                          builder: (controller) {
                            return CustomDropdown<String>.search(
                              hintText: "Select District",
                              decoration: CustomDropdownDecoration(
                                closedFillColor: Colors.grey[100],
                                expandedFillColor: Colors.white,
                                closedBorder: Border.all(
                                  color: AppColors.white,
                                  width: 1.5,
                                ),
                                expandedBorder: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                                closedBorderRadius: BorderRadius.circular(10),
                                expandedBorderRadius: BorderRadius.circular(10),
                                hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                                headerStyle: AppTextStyles.caption(context, color: Colors.black),
                                listItemStyle: AppTextStyles.caption(context, color: Colors.black),),
                              items: loginController.districts.map((d) => d.toString()).toList(),
                              //initialItem: loginController.selectedDistrict,
                              onChanged: (val) {
                                loginController.talukas.clear();
                                loginController.villages.clear();
                                loginController.selectedVillage=null;
                                loginController.selectedTaluka=null;
                                loginController.selectedDistrict = val;
                                if (val != null) {
                                  final district =
                                  loginController.districts.firstWhere((d) => d == val);
                                  loginController.fetchTalukas(district.toString());
                                  print('selectedDistrict${loginController.selectedDistrict}');

                                  loginController.update();

                                }
                              },
                            );
                          }
                      ),
                    ),
                    SizedBox(height: s*0.02,),

                    GetBuilder<LoginController>(
                        builder: (controller) {
                          return  DefaultTextStyle(
                            style: AppTextStyles.caption(context, color: Colors.black,fontWeight: FontWeight.normal),
                            child: GetBuilder<LoginController>(
                                builder: (controller) {
                                  return CustomDropdown<String>.search(
                                    hintText: "Select  taluka/town",
                                    decoration: CustomDropdownDecoration(
                                      closedFillColor: Colors.grey[100],
                                      expandedFillColor: Colors.white,
                                      closedBorder: Border.all(
                                        color: AppColors.white,
                                        width: 1.5,
                                      ),
                                      expandedBorder: Border.all(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                      closedBorderRadius: BorderRadius.circular(10),
                                      expandedBorderRadius: BorderRadius.circular(10),
                                      hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                                      headerStyle: AppTextStyles.caption(context, color: Colors.black),
                                      listItemStyle: AppTextStyles.caption(context, color: Colors.black),),
                                    items: loginController.talukas.map((t) => t.toString()).toList(),
                                   // initialItem: loginController.selectedTaluka,
                                    excludeSelected: false,
                                    onChanged: (val) {
                                      loginController.selectedTaluka = val;
                                      if (val != null) {
                                        final taluka =
                                        loginController. talukas.firstWhere((t) => t == val);
                                        loginController.fetchVillages(taluka.toString());
                                        loginController.update();
                                        print('taluka${loginController.selectedTaluka}');
                                      }
                                    },);
                                }
                            ),
                          );
                        }
                    ),
                    SizedBox(height: s*0.02,),

                    GetBuilder<LoginController>(
                        builder: (controller) {
                          return DefaultTextStyle(
                            style: AppTextStyles.caption(context, color: Colors.black,fontWeight: FontWeight.normal),
                            child: GetBuilder<LoginController>(
                                builder: (controller) {
                                  return CustomDropdown<String>.search(
                                    hintText: "Select Area",
                                    decoration: CustomDropdownDecoration(
                                      closedFillColor: Colors.grey[100],
                                      expandedFillColor: Colors.white,
                                      closedBorder: Border.all(
                                        color: AppColors.white,
                                        width: 1.5,
                                      ),
                                      expandedBorder: Border.all(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                      closedBorderRadius: BorderRadius.circular(10),
                                      expandedBorderRadius: BorderRadius.circular(10),
                                      hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                                      headerStyle: AppTextStyles.caption(context, color: Colors.black),
                                      listItemStyle: AppTextStyles.caption(context, color: Colors.black),),
                                    items: loginController.villages.map((v) => v.toString()).toList(),
                                    //initialItem: loginController.selectedVillage,
                                    excludeSelected: false,
                                    onChanged: (val) {
                                      loginController.selectedVillage = val;
                                      loginController.update();
                                      print('Area${loginController.selectedArea}');
                                    },
                                  );
                                }
                            ),
                          );
                        }
                    ),

                    SizedBox(height: s * 0.03),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Add Image',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                      SizedBox(height: s * 0.03),
                      SizedBox(
                      height: s * 0.5,
                      child: GetBuilder<NotificationController>(
                        builder: (controller) {
                          if (controller.notificationImage.isNotEmpty) {
                            final file = notificationController.notificationImage.first;
                            return _buildSingleImageWidget(file: file);
                          }
                          if (notificationController.notificationFileImages.isNotEmpty) {
                            final img = notificationController.notificationFileImages.first;
                            print('img url${img.url}');
                            return _buildSingleImageWidget(url: "${img.url}");
                          }
                          return GestureDetector(
                            onTap: () => pickSingleImage(),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                                color: Colors.grey.shade200,
                              ),
                              child: const Center(
                                child: Icon(Icons.add, size: 40, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor:Colors.transparent,shadowColor: Colors.transparent),
                        onPressed: () async {
                          //if (_formKeyCreateNotification.currentState!.validate()) {
                          if(notificationController.selectedUserType==null){
                            showCustomToast(context,  "Please Choose user Type",);
                            return;
                          }
                          if(notificationController.selectedTitle==null){
                            showCustomToast(context,  "Please Give title",);
                            return;
                          }
                          if(notificationController.messageController.text.isEmpty){
                            showCustomToast(context,  "Please Give message",);
                            return;
                          }
                          notificationController.createNotification(
                              Api.userInfo.read('userId'),
                              notificationController.selectedUserType!,
                            notificationController.selectedTitle=="Others"? notificationController.titleController.text:notificationController.selectedTitle.toString(),
                              notificationController.messageController.text,
                              loginController.selectedState.toString(),
                              loginController.selectedDistrict.toString(),
                              loginController.selectedTaluka.toString(),
                              loginController.selectedVillage.toString(),
                              context,
                              // notificationImage1: notificationController
                              //     .notificationImage.isNotEmpty
                              //     ? notificationController.notificationImage
                              //     : [],
                            notificationImage1: notificationImage
                          );
                          },
                       child: Text("Post",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white),),
                      ),
                    ),
                      const SizedBox(height: 30,)
                  ],
                ),
                          ]),
              )
            ),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),

    );
  }
}
