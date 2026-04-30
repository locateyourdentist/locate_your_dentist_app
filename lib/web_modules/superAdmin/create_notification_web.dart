import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';



class CreateNotificationWeb extends StatefulWidget {
  const CreateNotificationWeb({super.key});

  @override
  State<CreateNotificationWeb> createState() => _CreateNotificationWebState();
}

class _CreateNotificationWebState extends State<CreateNotificationWeb> {
  final notificationController=Get.put(NotificationController());
  final loginController=Get.put(LoginController());
  final ImagePicker _picker = ImagePicker();
  File? selectedImageFile;
  final _formKeyCreateNotificationWeb = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  File? notificationFileImage;
  Uint8List? notificationWebImage;

  Future<void> pickImage() async {
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (kIsWeb) {
       notificationWebImage = await pickedImage.readAsBytes();
        print('Web image selected: ${pickedImage.name}');
      } else {
        notificationFileImage = File(pickedImage.path);
        print('Mobile image path: ${pickedImage.path}');
      }

      notificationController.update();
    }
  }
  Widget _buildSingleImageWidget({File? file, Uint8List? bytes, String? url}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: kIsWeb
              ? (bytes != null
              ? Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
              : Container(color: Colors.grey.shade200))
              : (file != null
              ? Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
              : Container(color: Colors.grey.shade200)),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              notificationFileImage = null;
              notificationWebImage = null;
              notificationController.update();
            },
            child: const Icon(Icons.cancel, color: Colors.black, size: 25),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: GestureDetector(
            onTap: () => pickImage(),
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
  }
  @override
  Widget build(BuildContext context) {
    double s=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: s * 0.03,
        title: "LYD",
        onLogout: () {
        },
        onNotification: () {
        },
      ),
      body: GetBuilder<NotificationController>(
          builder: (controller) {
            return Form(
              key: _formKeyCreateNotificationWeb,
              child: Row(
                children: [
                  const AdminSideBar(),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child:ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Container(
                            width: double.infinity,
                            //color: Colors.grey[100],
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                    children: [
                                      SizedBox(height: s*0.01,),
                                      Text('Create Notification',style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                                      SizedBox(height: s*0.01,),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: GetBuilder<NotificationController>(
                                                builder: (controller) {
                                                  return  CustomDropdownField(
                                                    hint: "Select User Type",
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
                                                  );
                                                }
                                            ),
                                          ),
                                          SizedBox(width: s*0.05,),
                                          Expanded(
                                            child: CustomDropdownField(
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
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: s*0.01,),

                                      if(notificationController.selectedTitle=='Others')
                                        Column(
                                          children: [
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
                                            SizedBox(height: s*0.01,),

                                          ],
                                        ),
                                      //  SizedBox(height: s*0.01,),
                                      CustomTextField(
                                        hint: "Message",
                                        controller:  notificationController.messageController,
                                        // borderColor: AppColors.grey,
                                        // fillColor: AppColors.white,
                                        maxLines: 6,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Message cannot be empty";
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: s*0.01,),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GetBuilder<LoginController>(
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
                                                            final state = loginController.states.firstWhere((s) =>
                                                            s == val);
                                                            loginController.fetchDistricts(state.toString());
                                                            loginController.selectedVillage=null;
                                                            loginController.selectedTaluka=null;
                                                            loginController.selectedDistrict = null;
                                                            print('state${loginController.selectedState}');
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
                                          ),
                                          SizedBox(width: s * 0.02),

                                          Expanded(
                                            child: DefaultTextStyle(
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
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: s*0.01,),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: GetBuilder<LoginController>(
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
                                          ),
                                          SizedBox(width: s*0.02,),
                                          Expanded(
                                            child: GetBuilder<LoginController>(
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
                                          ),
                                        ],
                                      ),



                                      SizedBox(height: s*0.01,),
                                      Column(
                                        children: [
                                          Text('Add Image',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                                          SizedBox(height: s * 0.001),
                                          SizedBox(
                                            height: s * 0.11,
                                            width: s*0.12,
                                            child: GetBuilder<NotificationController>(
                                              builder: (controller) {
                                                if (kIsWeb && notificationWebImage != null) {
                                                  return _buildSingleImageWidget(bytes: notificationWebImage);
                                                }
                                                if (!kIsWeb && notificationFileImage != null) {
                                                  return _buildSingleImageWidget(file: notificationFileImage);
                                                }
                                                return GestureDetector(
                                                  onTap: () => pickImage(),
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
                                            width: s*0.35,
                                            height: s*0.02,
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
                                                    notificationImage1: notificationWebImage
                                                  );
                                              },
                                              child: Text("Create Post",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white),),
                                            ),
                                          ),
                                          const SizedBox(height: 30,)
                                        ],
                                      ),
                                    ]),
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
    );
  }
}
