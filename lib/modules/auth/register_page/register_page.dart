import 'dart:io' show File, Platform;
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/profiles/pdf_path_view_page.dart';
import '../../../common_widgets/color_code.dart';
import '../../../common_widgets/common_textfield.dart';
import '../../../common_widgets/common_textstyles.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:video_compress/video_compress.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  final _formKeyRegister = GlobalKey<FormState>();
  final loginController=Get.put(LoginController());
  final ImagePicker _picker = ImagePicker();
  int? selectedStateId;
  String? selectedStateCode;
  Map<String, dynamic> data = {};
  final jobController=Get.put(JobController());
  final allItems = [
    "admin",
    "superAdmin",
    "Dental Clinic",
    "Dental Lab",
    "Dental Shop",
    "Dental Mechanic",
    "Job Seekers",
    "Dental Consultant"
  ];
  String uploadImages(String userType) {
    String imageText;
    switch (userType) {
      case "Dental Clinic":
        imageText = "Upload Clinic Images";
        break;
      case "Dental Shop":
        imageText = "Upload Shop Images";
        break;
      case "Dental Mechanic":
        imageText = "Upload Mechanic Shop Images";
        break;
      case "Dental Lab":
        imageText = "Upload Lab Images";
        break;
      default:
        imageText = "";
    }
    return imageText;
  }
  String userTypes(String userType) {
    String prefix;
    switch (userType) {
      case "Dental Clinic":
        prefix = "Upload Clinic Certificate/Degree certificate";
        break;
      case "Dental Shop":
        prefix = "Upload Shop Certificate/Degree certificate";
        break;
      case "Dental Lab":
        prefix = "Upload Lab Certificate";
        break;
      case "Dental Consultant":
        prefix = "Upload Degree certificate";
        break;
      case "Job Seekers":
        prefix = "Upload Resume";
        break;
      default:
        prefix = "";
    }
    return prefix;
  }
  String? confirmPasswordValidator(String? value, TextEditingController passwordController) {
    if (value == null || value.isEmpty) return "Confirm Password cannot be empty";
    if (value != passwordController.text) return "Passwords do not match";
    //if(passwordController.text.length>6) return "Password length must be 6 characters";
    return null;
  }
  final int maxFiles = 3;
  Future<void> pickImages() async {
    if (loginController.images.length >= maxFiles) {
      Get.snackbar("Error", "Maximum $maxFiles files allowed");
      return;
    }
    try {
      final source = await Get.dialog(
        SimpleDialog(
          title: Center(child: Text("Pick Media",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),)),
          children: [
            SimpleDialogOption(
              child: Row(
                children: [
                  const Icon(Icons.image,color: AppColors.grey,size:20,),
                  const SizedBox(width: 10,),
                  Text("Image",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),
                ],
              ),
              onPressed: () => Get.back(result: "image"),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 0.3,color: AppColors.grey,),
            ),
            SimpleDialogOption(
              child: Row(
                children: [const Icon(Icons.image,color: AppColors.grey,size:20,),
                  const SizedBox(width: 10,),
                  Text("Video",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),
                ],
              ),
              onPressed: () => Get.back(result: "video",),
            ),
          ],
        ),
      );
      print('sou$source');
      if (source == null) return;

      XFile? pickedFile;

      if (source == "image") {
        pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
      } else if (source == "video") {
        pickedFile = await _picker.pickVideo(
          source: ImageSource.gallery,
        );
      }

      if (pickedFile == null) return;

      File selectedFile = File(pickedFile.path);

      if (pickedFile.path.endsWith(".mp4") ||
          pickedFile.path.endsWith(".mov")) {
        final compressed = await VideoCompress.compressVideo(
          pickedFile.path,
          quality: VideoQuality.MediumQuality,
        );

        if (compressed?.file != null) {
          selectedFile = compressed!.file!;
          print('videeo$selectedFile');
        }
      }

      loginController.images.add(selectedFile);

    } catch (e) {
      print("Pick media failed: $e");
      Get.snackbar("Error", "Failed to pick media $e");
    }
  }
  Future<void> pickCertificates() async {
    if (loginController.certificates.length >= 3) {
      Get.snackbar("Error", "Maximum three certificates allowed");
      print("Maximum 3 images allowed.");
      return;
    }

    if (Platform.isAndroid || Platform.isIOS || Platform.isWindows) {
      try {
        final List<XFile>? selectedCertificates = await _picker.pickMultiImage();
        if (selectedCertificates != null) {
          int currentCount = loginController.certificates.length;
          int remainingSlots = 3 - currentCount;
          final limitedCertificates = selectedCertificates.take(remainingSlots).toList();
          setState(() {
            loginController.certificates.addAll(
              limitedCertificates.map((x) => File(x.path)),
            );
          });
          if (selectedCertificates.length > remainingSlots) {
            Get.snackbar("Error", "Maximum three images allowed");
            print("Only $remainingSlots more images allowed (max 3).");
          }
        }
      } catch (e) {
        print('Error picking images: $e');
      }
    } else {
      print('pickMultiImage not supported on this platform');
    }
  }
  Future<void> pickSingleImage1() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      final selectedImageFile = File(pickedImage.path);
      loginController.logoImage.clear();
      loginController.logoImages.add(selectedImageFile);
      //loginController.logoImages.clear();
      loginController.update();
    }
  }
  // void getLocation()async{
  //   final position = await LocationService.getCurrentLocation();
  //
  //   if (position != null) {
  //     loginController.latitude = position.latitude;
  //     loginController.longitude = position.longitude;
  //     print('latt${loginController.latitude}long${loginController.longitude}');
  //     //  Get.snackbar('Location', 'Your location: $address');
  //   } else {
  //     // Get.snackbar('Location', 'Unable to get location');
  //   }
  // }
  Widget _buildSingleImageWidget1({File? file, String? url}) {
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
              loginController.logoImages.clear();
              loginController.logoImage.clear();
              loginController.update();
            },
            child: const Icon(Icons.cancel, color: Colors.white,),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: GestureDetector(
            onTap: () => pickSingleImage1(),
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
    loginController.clearProfileData();
    loginController.fetchStates();
    jobController.getJobCategoryLists("",context);
    // getLocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final userType=Api.userInfo.read('userType');
    final adminItems = allItems;
    final otherItems = allItems.where((e) => e != "admin" && e != "superAdmin").toList();
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body:  Form(
        key:_formKeyRegister ,
        child: GetBuilder<LoginController>(
          builder: (controller) {
            return LayoutBuilder(
                builder: (context, constraints) {
                  return  SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size * 0.05),

                                  Text(
                                    "LYD",
                                    style: AppTextStyles.headline1(context, color: AppColors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: size * 0.01),
                                  Text(
                                    "Create an Account",
                                    style: AppTextStyles.subtitle(context, color: AppColors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: size * 0.01),
                                  Text(
                                    "Let's get started by filling out the form below",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.caption(context, color: AppColors.grey),
                                  ),
                                  SizedBox(height: size * 0.04),

                                  CustomTextField(
                                    hint: "Name",
                                    icon: Icons.person,
                                    controller: loginController.fullNameController,
                                  ),
                                  SizedBox(height: size * 0.01),
                                  // CustomDropdownField(
                                  //   hint: "Select Martial Status",
                                  //  // icon: Icons.place,
                                  //   fillColor: Colors.grey[100],borderColor: AppColors.white,
                                  //   items: const ["Single","Married","Widow"],
                                  //   selectedValue: (loginController.selectedMartialStatus != null &&
                                  //       ["Single", "Married", "Widow"]
                                  //           .contains(loginController.selectedMartialStatus))
                                  //       ? loginController.selectedMartialStatus
                                  //       : null,
                                  //   onChanged: (value) {
                                  //     setState(() {
                                  //       loginController.selectedMartialStatus = value;
                                  //     });
                                  //   },
                                  // ),
                                  SizedBox(height: size * 0.01),
                                  CustomTextField(
                                    hint: "Date of Birth",
                                    controller: loginController.dobController,  fillColor: Colors.grey[100],
                                    borderColor: AppColors.white,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime(2000),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (pickedDate != null) {
                                        loginController.dobController.text =
                                        "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                      }
                                    },
                                  ),
                                  SizedBox(height: size * 0.03),
                                  CustomTextField(
                                    hint: "Email",
                                    icon: Icons.email,
                                    controller: loginController.emailController,
                                    keyboardType: TextInputType.emailAddress
                                  ),
                                  SizedBox(height: size * 0.03),

                                  CustomTextField(
                                    hint: "Mobile Number",
                                    icon: Icons.phone,
                                    controller: loginController.mobileController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 10,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Mobile Number cannot be empty";
                                      }
                                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                                        return "Enter a valid 10-digit mobile number starting with 6-9";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: size * 0.03),
                                  CustomTextField(
                                    hint: "Password",
                                    icon: Icons.lock,
                                    isPassword: true,
                                    controller: loginController.passwordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Password cannot be empty";
                                      }

                                      if (value.length < 4) {
                                        return "Password must be at least 4 characters";
                                      }

                                      // if (!RegExp(r'[a-z]').hasMatch(value)) {
                                      //   return "Password must contain at least one lowercase letter";
                                      // }
                                      //
                                      // if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                      //   return "Password must contain at least one uppercase letter";
                                      // }
                                      //
                                      // if (!RegExp(r'[0-9]').hasMatch(value)) {
                                      //   return "Password must contain at least one number";
                                      // }

                                      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                                        return "Password must contain at least one special character";
                                      }

                                      return null;
                                    },
                                  ),
                                  SizedBox(height: size * 0.03),

                                  CustomTextField(
                                    hint: "Confirm Password",
                                    icon: Icons.lock,
                                    isPassword: true,
                                    controller: loginController.confirmPasswordController,
                                    validator: (value) => confirmPasswordValidator(value, loginController.passwordController),
                                  ),

                                  SizedBox(height: size * 0.03),
                                 // if(userType!='superAdmin')
                                CustomDropdownField(
                                  hint: "Select UserType",
                                  fillColor: Colors.grey[100],
                                  borderColor: AppColors.white,
                                  items: userType=='superAdmin'||userType=='admin'?adminItems:otherItems,
                                  selectedValue: loginController.selectedUserType,
                                  onChanged: (value) {
                                    setState(() {
                                      loginController.selectedUserType = value;
                                      print('Selected UserType: ${loginController.selectedUserType}');
                                    });
                                  },
                                ),
                                  if (loginController.selectedUserType != null &&
                                      loginController.selectedUserType!.isNotEmpty&&loginController.selectedUserType !='Job Seekers')
                                    Column(children: [
                                  SizedBox(height: size * 0.01),
                                 // if(loginController.selectedUserType !='Job Seekers')
                                  CustomTextField(
                                    hint: loginController.selectedUserType == 'Dental Shop'? "College Name":"${loginController.selectedUserType?.split(' ').sublist(1).join(' ')} Name",
                                    icon: Icons.store,
                                    controller: loginController.typeNameController,
                                  ),
                                  ]),
                                  SizedBox(height: size * 0.03),

                                  GetBuilder<LoginController>(
                                    builder: (controller) {
                                      return CustomDropdown<String>.search(
                                        hintText: "Select State",
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
                                        items: controller.states.map((s) => s.toString()).toList(),
                                        //initialItem: controller.selectedState,
                                        onChanged: (val) {
                                          if (val != null) {
                                            controller.selectedState = val;
                                            controller.districts.clear();
                                            controller.selectedDistrict = null;
                                            controller.selectedTaluka = null;
                                            controller.selectedVillage = null;
                                            final state = controller.states.firstWhere((s) => s == val);
                                            print('state  selected$state');
                                            controller.fetchDistricts(state.toString());
                                            controller.update();
                                          }
                                        },
                                      );
                                    },
                                  ),

                                SizedBox(height: size * 0.03),

                                  GetBuilder<LoginController>(
                                    builder: (controller) {
                                      return CustomDropdown<String>.search(
                                        hintText: "Select District",
                                        items: controller.districts.map((d) => d.toString()).toList(),
                                        //initialItem: controller.selectedDistrict,
                                        decoration: CustomDropdownDecoration(
                                          hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                                          headerStyle: AppTextStyles.caption(context, color: Colors.black),
                                          listItemStyle: AppTextStyles.caption(context, color: Colors.black),
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
                                        ),
                                        onChanged: (val) {
                                          if (val != null) {
                                            controller.selectedDistrict = val;
                                            controller.talukas.clear();
                                            controller.selectedTaluka = null;
                                            controller.selectedVillage = null;
                                            final district = controller.districts.firstWhere((d) => d == val);
                                            print('sub district selected$district');
                                            controller.fetchTalukas(district.toString());
                                            controller.update();
                                          }
                                        },
                                      );
                                    },
                                  ),

                                  SizedBox(height: size * 0.03),

                                  GetBuilder<LoginController>(
                                      builder: (controller) {
                                        return  DefaultTextStyle(
                                          style: AppTextStyles.caption(context, color: Colors.black,fontWeight: FontWeight.normal),
                                          child: CustomDropdown<String>.search(
                                          hintText: "Select  taluka/town",
                                          items: loginController.talukas.map((t) => t.toString()).toList(),
                                            decoration: CustomDropdownDecoration(
                                              hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                                              headerStyle: AppTextStyles.caption(context, color: Colors.black),
                                              listItemStyle: AppTextStyles.caption(context, color: Colors.black),
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
                                            ),
                                            //initialItem: loginController.selectedTaluka,
                                            excludeSelected: false,
                                          onChanged: (val) {
                                          setState(() => loginController.selectedTaluka = val);
                                          if (val != null) {
                                            final taluka =
                                            loginController. talukas.firstWhere((t) => t == val);
                                            controller.villages.clear();
                                            loginController.fetchVillages(taluka.toString());
                                            loginController.update();
                                            print('taluka${loginController.selectedTaluka}');
                                          }
                                          },),
                                        );
                                    }
                                  ),

                                  SizedBox(height: size * 0.03),
                                  GetBuilder<LoginController>(
                                      builder: (controller) {
                                        final items = controller.villages.map((v) => v.toString()).toList();
                                        return DefaultTextStyle(
                                          style: AppTextStyles.caption(context, color: Colors.black,fontWeight: FontWeight.normal),
                                          child: CustomDropdown<String>.search(
                                            hintText: "Select Area",
                                           // items: loginController.villages.map((v) => v['name'].toString()).toList(),
                                            items: items,
                                            decoration: CustomDropdownDecoration(
                                              hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                                              headerStyle: AppTextStyles.caption(context, color: Colors.black),
                                              listItemStyle: AppTextStyles.caption(context, color: Colors.black),
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

                                            ),
                                            // initialItem: items.contains(controller.selectedVillage)
                                            //     ? controller.selectedVillage
                                            //     : null,
                                            excludeSelected: false,
                                            onChanged: (val) {
                                          setState(() => loginController.selectedVillage = val);
                                          loginController.update();
                                          print('Area${loginController.selectedArea}');
                                                                                        },
                                          ),
                                        );
                                    }
                                  ),
                                  SizedBox(height: size * 0.03),
                                  CustomTextField(
                                    hint: "PinCode",
                                    icon: Icons.pin,
                                    controller: loginController.pinCodeController,
                                    keyboardType: TextInputType.number,maxLength: 6,
                                  ),
                                  if(loginController.selectedUserType=="Job Seekers")
                                    Column(children: [
                                  SizedBox(height: size * 0.03),
                                  Text("Job Category Preferences",
                                    style: AppTextStyles.caption(fontWeight: FontWeight.bold,context),),
                                  SizedBox(height: size * 0.01),
                                  GetBuilder<JobController>(
                                    builder: (jobController) {
                                      final List<MultiSelectItem<String>> categoryItems =
                                      jobController!.jobCategoryAdmin
                                          .map((e) => MultiSelectItem<String>(
                                          e.name.trim(),
                                          e.name.trim(),
                                        ),
                                      ).toList();
                                      return MultiSelectDialogField<String>(
                                        items: categoryItems,
                                        selectedColor: AppColors.primary,
                                        initialValue: loginController.selectedCategories,

                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.grey, width: 0.1),
                                        ),
                                        buttonText: Text(
                                          "Select Job Categories",
                                          style: AppTextStyles.caption(
                                            context,
                                            color: AppColors.grey,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        onConfirm: (results) {
                                          loginController.selectedCategories = results;
                                          loginController.update();
                                        },
                                      );
                                    },
                                  ),
                                   ]),
                                  SizedBox(height: size * 0.01),
                                  if(loginController.selectedUserType!="Job Seekers")
                                  CustomTextField(
                                    hint: "location Link",
                                    icon: Icons.pin,
                                    controller: loginController.locationController,
                                  ),
                                  SizedBox(height: size * 0.01),
                                  if (loginController.selectedUserType!=null&&loginController.selectedUserType != "Dental Mechanic") ...[
                                   SizedBox(height: size * 0.02),
                                    ElevatedButton(
                                    onPressed: ()async {
                                      //Get.toNamed('/registerPage');
                                      pickCertificates();
                                     // loginController.certificates.clear();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      side: const BorderSide(
                                          color:AppColors.primary,
                                        width: 0.34,
                                      ),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5,),
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.upload, color: AppColors.primary, size: size * 0.05),
                                          const SizedBox(width: 5),
                                          Text(userTypes(loginController.selectedUserType.toString()),
                                            style: TextStyle(fontSize: size*0.025,fontWeight: FontWeight.bold,color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size * 0.01),
                                  ],
                                  if (loginController.selectedUserType != null &&
                                      loginController.selectedUserType != "Dental Mechanic") ...[

                                SizedBox(
                                    height: loginController.certificates.isNotEmpty? size*0.35:30,
                                    child: loginController.certificates.isEmpty
                                        ?  Center(child: Text("No certificate selected",style: AppTextStyles.caption(context,color: AppColors.black),))
                                        : GridView.builder(
                                      padding: const EdgeInsets.all(10),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: loginController.certificates.length,
                                        itemBuilder: (context, index) {
                                          final file = loginController.certificates[index];
                                          final path = file.path;
                                          final isPdf = path.toLowerCase().endsWith(".pdf");

                                          return Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => ViewPDFPage(pdfUrl: path),
                                                    ),
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: isPdf
                                                      ? Container(
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child: Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                                                    ),
                                                  )
                                                      : Image.file(
                                                    file,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      loginController.certificates.removeAt(index);
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.cancel,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                        ),),
                           Center(child: Text("** maximum 3 images/pdf allowed",
                           style: TextStyle(color: Colors.redAccent,fontSize: size*0.019,fontWeight: FontWeight.normal),))
                                  ],
                                  //SizedBox(height: size * 0.03),
                                  if (loginController.selectedUserType == 'Dental Clinic'||loginController.selectedUserType=='Dental Shop'||loginController.selectedUserType=='Dental Mechanic'||loginController.selectedUserType=='Dental Lab') ...[
                                    SizedBox(height: size * 0.02),
                                    ElevatedButton(
                                      onPressed: ()async {
                                        //Get.toNamed('/registerPage');
                                        pickImages();
                                        //loginController.images.clear();

                                      },
                                      style: ElevatedButton.styleFrom(
                                        side: const BorderSide(
                                          color:AppColors.primary,
                                          width: 0.34,
                                        ),
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5,),
                                        ),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.upload, color: AppColors.primary, size: size * 0.05),
                                            const SizedBox(width: 5),
                                            Text(
                                              uploadImages(loginController.selectedUserType.toString()),
                                              // "Upload Proof / Certificate / Resume",
                                              style: TextStyle(fontSize: size*0.025,fontWeight: FontWeight.bold,color: AppColors.primary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size * 0.03),
                                  ],
                                  if (loginController.selectedUserType == 'Dental Clinic'||loginController.selectedUserType=='Dental Shop'||loginController.selectedUserType=='Dental Mechanic'||loginController.selectedUserType=='Dental Lab') ...[
                                    SizedBox(
                                      height: loginController.images.isNotEmpty? size*0.35:30,
                                      child: loginController.images.isEmpty
                                          ?  Center(child: Text("No images selected",style: AppTextStyles.caption(context,color: AppColors.black),))
                                          : GridView.builder(
                                        padding: const EdgeInsets.all(10),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                        itemCount: loginController.images.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:BorderRadius.circular(10),
                                                child: Image.file(
                                                  loginController.images[index],
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      loginController.images.removeAt(index);
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.cancel,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    if(loginController.selectedUserType != "Job Seekers")
                                    Center(child: Text("** maximum 3 images allowed **",style: TextStyle(color: Colors.redAccent,fontSize: size*0.019,fontWeight: FontWeight.normal),))
                                  ],
                                  SizedBox(height: size * 0.03),
                                  Text(loginController.selectedUserType == "Job Seekers"
                                      ? "Upload Profile Image"
                                      : "Upload Logo Image",
                                    style: AppTextStyles.caption(fontWeight: FontWeight.bold,context),),
                                  SizedBox(height: size * 0.03),

                                  SizedBox(
                                    height: size * 0.5,
                                    child: GetBuilder<LoginController>(
                                      builder: (controller) {
                                        if (controller.logoImages.isNotEmpty) {
                                          final File file = controller.logoImages.first;
                                          return _buildSingleImageWidget1(file: file);
                                        }
                                        if (controller.logoImage.isNotEmpty) {
                                          final AppImage img = controller.logoImage.first;
                                          return _buildSingleImageWidget1(url: img.url);
                                        }
                                        return GestureDetector(
                                          onTap: () => pickSingleImage1(),
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
                                  SizedBox(height: size * 0.03),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: Container(
                                    decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                    colors: [AppColors.primary,AppColors.secondary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    ),
                                    ),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (_formKeyRegister.currentState!.validate()) {
                                          final position = await LocationService.getCurrentLocation();
                                          if (position == null) {
                                          return;
                                          }
                                          debugPrint('User location: Lat ${position.latitude}, Lng ${position.longitude}');
                                          print("FULL NAME = ${loginController.fullNameController.text}");
                                            print("MOBILE = ${loginController.mobileController.text}");
                                            print("EMAIL = ${loginController.emailController.text}");
                                            print("STATE = ${loginController.selectedState.toString()}");
                                            print("DISTRICT = ${loginController.selectedDistrict.toString()}");
                                            print("CITY = ${loginController.selectedTaluka.toString()}");
                                            print("PINCODE = ${loginController.selectedVillage.toString()}");
                                            print("LAB NAME = ${loginController.typeNameController.text}");
                                            print("IMAGES = ${loginController.images}");
                                            print('logo${loginController.logoImages}');
                                            print("CERTIFICATES = ${loginController.certificates}");
                                            print('dob ${loginController.dobController}');
                                            if(loginController.selectedUserType==null){
                                              showCustomToast(context,"Please Select usertype",);
                                            }
                                          if(loginController.selectedState==null){
                                            showCustomToast(context,"Please  Select State",);
                                          }
                                          if(loginController.selectedDistrict==null){
                                            showCustomToast(context,"Please Select District",);
                                          }
                                          if(loginController.selectedTaluka==null){
                                            showCustomToast(context,"Please Select Taluka",);
                                          }
                                          if(loginController.selectedVillage==null){
                                            showCustomToast(context,"Please Select Village",);
                                          }
                                            //print('usertype${loginController.selectedUserType} married${loginController.selectedMartialStatus!}');
                                            await loginController.registerUser(
                                              userId: "0",
                                              userType: loginController.selectedUserType!,
                                              //martialStatus: loginController.selectedMartialStatus!,
                                              fullName: loginController.fullNameController.text,
                                              dob: loginController.dobController.text,
                                              mobile: loginController.mobileController.text,
                                              email: loginController.emailController.text,
                                              confirmPassword: loginController.confirmPasswordController.text,
                                              taluk: loginController.selectedState ?? '',
                                              district: loginController.selectedDistrict ?? '',
                                              city: loginController.selectedTaluka ?? '',
                                              area: loginController.selectedVillage ?? '',
                                              pinCode: loginController.pinCodeController.text,
                                              typeName: loginController.typeNameController.text??"",
                                              image: loginController.selectedUserType=="Job Seekers"?controller.logoImages ?? []:loginController.images ?? [],
                                              certificate: loginController.certificates ?? [],
                                              location: loginController.locationController.text,
                                              website: loginController.websiteController.text,
                                              description: loginController.descriptionController.text??"N/A",
                                              logoImage: loginController.selectedUserType!="Job Seekers"?controller.logoImages ?? []:[],
                                              latitude: loginController.latitude.toString()??"",
                                              longitude: loginController.longitude.toString()??"",
                                              jobCategory:loginController.selectedCategories,
                                              isAdmin: "false",
                                              context: context,
                                            );

                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          backgroundColor: AppColors.transparent,
                                        ),
                                        child: Text(
                                          "Create Account",
                                          style: AppTextStyles.body(context, color: AppColors.white,fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size * 0.03),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an account? ",
                                        style: AppTextStyles.caption(context, color: Colors.black54),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.toNamed('/loginPage');

                                        },
                                        child:  Text(
                                          "Sign in here",
                                          style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold)
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            );
          }
        ),
      ),
    );
  }
}
