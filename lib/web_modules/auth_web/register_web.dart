import 'dart:io';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import '../../common_widgets/color_code.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:file_picker/file_picker.dart';

class RegisterWebPage extends StatefulWidget {
 // const RegisterWebPage({super.key});

  @override
  State<RegisterWebPage> createState() => _RegisterWebPageState();
}

class _RegisterWebPageState extends State<RegisterWebPage> {

  int currentStep = 0;
  final ImagePicker _picker = ImagePicker();
  final _formKeyRegisterWeb = GlobalKey<FormState>();
  final loginController = Get.put(LoginController());
  final jobController=Get.put(JobController());
  String? branchId;

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
  final int maxFiles = 3;
  String? selectName;
  bool isPicking = false;

  Future<void> pickLogo() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;
    loginController.logoImages1.clear();
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      loginController.logoImages1.add(AppImage2(bytes: bytes));
    } else {
      loginController.logoImages1.add(AppImage2(file: File(image.path)));
    }

    loginController.update();
  }
  Future<List<Uint8List>> convertImages(List<AppImage2> images) async {
    List<Uint8List> result = [];

    for (var img in images) {
      if (kIsWeb) {
        if (img.bytes != null) {
          result.add(img.bytes!);
        }
      } else {
        if (img.file != null) {
          final bytes = await img.file!.readAsBytes();
          result.add(bytes);
        }
      }
    }

    return result;
  }
  Future<void> pickCertificates() async {
    if (isPicking) return;
    isPicking = true;

    const maxFiles = 3;
    final existingCount = loginController.certificates1.length;
    final remaining = maxFiles - existingCount;

    if (remaining <= 0) {
      Get.snackbar("Error", "Maximum $maxFiles files allowed");
      isPicking = false;
      return;
    }
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png','jpeg'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final limited = result.files.take(remaining);

        for (final file in limited) {
          if (kIsWeb) {
            if (file.bytes != null) {
              loginController.certificates1.add(
                AppImage2(bytes: file.bytes,name: file.name,),
              );
            }
          } else {
            if (file.path != null) {
              loginController.certificates1.add(
                AppImage2(file: File(file.path!)),
              );
            }
          }
        }
        loginController.update();
        if (result.files.length > remaining) {
          Get.snackbar("Info", "Only $remaining more files allowed");
        }
      }
    } catch (e) {
      debugPrint("Error picking files: $e");
      Get.snackbar("Error", "Failed to pick files");
    } finally {
      isPicking = false;
    }
  }
  Future<void> pickClinicImages() async {
    if (isPicking) return;
    isPicking = true;

    const maxImages = 3;
    final existingCount = loginController.images1.length;
    //final remaining = maxImages - existingCount;
    final remaining = maxFiles - existingCount;

    if (remaining <= 0) {
      Get.snackbar("Error", "Maximum $maxImages images allowed");
      isPicking = false;
      return;
    }

    try {
      final List<XFile>? selected = await _picker.pickMultiImage();

      if (selected != null && selected.isNotEmpty) {
        final limited = selected.take(remaining).toList();

        for (final x in limited) {
          if (kIsWeb) {
            final bytes = await x.readAsBytes();
            loginController.images1.add(AppImage2(bytes: bytes));
          } else {
            loginController.images1.add(AppImage2(file: File(x.path)));
          }
        }
        loginController.update();
        if (selected.length > remaining) {
          Get.snackbar("Info", "Only $remaining more images allowed");
        }
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
      Get.snackbar("Error", "Failed to pick images");
    } finally {
      isPicking = false;
    }
  }
  Future<void> confirmRemoveImage(BuildContext ctx, int index,VoidCallback onTab) async {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title:  Text("Remove Image",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
        content:  Text("Are you sure you want to remove this image?",style: AppTextStyles.caption(context),),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child:  Text("Cancel",style: AppTextStyles.caption(context),)),
          TextButton(onPressed: onTab,
          //     () {
          //   loginController.images1.removeAt(index);
          //   loginController.update();
          //   Navigator.pop(c);
          // },
              child:  Text("Remove",style: AppTextStyles.caption(context,),)),
        ],
      ),
    );
  }
  // Future<void> pickClinicImages() async {
  //   if (loginController.images1.length >= maxFiles) {
  //     Get.snackbar("Error", "Maximum $maxFiles images allowed");
  //     return;
  //   }
  //
  //   final List<XFile>? pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
  //   if (pickedFiles == null || pickedFiles.isEmpty) return;
  //
  //   int remaining = maxFiles - loginController.images1.length;
  //   loginController.images1.addAll(pickedFiles.take(remaining));
  //
  //   if (pickedFiles.length > remaining) {
  //     Get.snackbar("Error", "Only $remaining more images allowed");
  //   }
  //   loginController.update();
  // }
  Widget buildImageXFile(XFile file) {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        },
      );
    } else {
      return Image.file(File(file.path), fit: BoxFit.cover);
    }
  }
  String? confirmPasswordValidator(String? value, TextEditingController passwordController) {
    if (value == null || value.isEmpty) return "Confirm Password cannot be empty";
    if (value != passwordController.text) return "Passwords do not match";
    //if(passwordController.text.length>6) return "Password length must be 6 characters";
    return null;
  }
  List<Step> getSteps() {
    final stepsList = <Step>[
      Step(
        title: Text("Personal Info", style: AppTextStyles.body(context)),
        isActive: currentStep >= 0,
        content: _step1(),
      ),
      Step(
        title: Text("Professional Details", style: AppTextStyles.body(context)),
        isActive: currentStep >= 1,
        content: _step2(),
      ),
      Step(
        title: Text("Uploads", style: AppTextStyles.body(context)),
        isActive: currentStep >= 2,
        content: _step3(),
      ),
    ];

    // Only add Education step for Job Seekers
    if (loginController.selectedUserType == 'Job Seekers') {
      stepsList.add(
        Step(
          title: Text("Education Details", style: AppTextStyles.body(context)),
          isActive: currentStep >= 3,
          //  isActive: currentStep >= stepsList.length,
          content: _step4(),
        ),
      );
    }

    return stepsList;
  }
  Widget _buildSingleImageWidget({required AppImage2 image}) {
    final s = MediaQuery.of(context).size.width;
    return Container(
      width: s * 0.35,
      height: s * 0.35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(image),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                loginController.logoImages1.clear();
                loginController.update();
              },
              child: const Icon(Icons.cancel, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }  Widget _buildImage(AppImage2 image) {
    if (kIsWeb) {
      if (image.bytes != null) {
        return Image.memory(
          image.bytes!,
          fit: BoxFit.cover,
        );
      } else if (image.url != null && image.url!.isNotEmpty) {
        return Image.network(
          image.url!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
        );
      }
    } else {
      if (image.file != null) {
        return Image.file(
          image.file!,
          fit: BoxFit.cover,
        );
      } else if (image.url != null && image.url!.isNotEmpty) {
        return Image.network(
          image.url!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
        );
      }
    }

    return const Center(
      child: Icon(Icons.image_not_supported, color: Colors.red),
    );
  }
  Widget buildGridXFile(List<XFile> files) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final file = files[index];
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: buildImageXFile(file),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  files.removeAt(index);
                  loginController.update();
                },
                child: const Icon(Icons.cancel, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
  @override
  void initState(){
    //loginController.clearProfileData();
    loginController.fetchStates();
    jobController.getJobCategoryLists("",context);
    branchId = Get.arguments?['branchId'] ??"";
    //getLocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Row(
        children: [
         if(Api.userInfo.read('token')!=null)
          const AdminSideBar(),
          Expanded(
            child: Form(
              key:_formKeyRegisterWeb ,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(35.0),
                  child:ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: size*0.02),

                          Text(
                              loginController.fullNameController.text.isNotEmpty? "Register New User":"Edit Details",
                              style: AppTextStyles.body(context,fontWeight: FontWeight.bold,color: AppColors.black)
                          ),
                          SizedBox(height: size*0.01),
                          if(loginController.fullNameController.text.isEmpty)
                          Text(
                              "Fill in the details to create a new account",
                              style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.grey)
                          ),
                          SizedBox(height: size*0.01),

                          Expanded(
                            child: Stepper(
                              type: StepperType.horizontal,
                              currentStep: currentStep,connectorColor: MaterialStateProperty.all(AppColors.primary),
                              onStepContinue: () async{
                               // if (currentStep == 3)
                                  if((loginController.selectedUserType == 'Job Seekers'
                                      ? currentStep == 3
                                      : currentStep == 2))
                                  if (_formKeyRegisterWeb.currentState!.validate()) {
                                  // final position = await LocationService.getCurrentLocation();
                                  // if (position == null) {
                                  //   return;
                                  // }
                                  //debugPrint('User location: Lat ${position.latitude}, Lng ${position.longitude}');
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
                                  print('dob ${loginController.dobController.text}');

                                  final imageBytes = await convertImages(loginController.images1 ?? []);
                                  final logoBytes = await convertImages(loginController.logoImages1 ?? []);
                                  final certificateBytes = await convertImages(loginController.certificates1 ?? []);

                                  if(loginController.selectedUserType==null){
                                    await showSuccessDialog(context, title:"Error",message :"Please Select usertype", onOkPressed: () {
                                      Get.back();});
                                  }
                                  // if(currentStep==2)
                                  // if(loginController.selectedUserType!='admin'||loginController.selectedUserType!='superAdmin'||loginController.selectedUserType!='Job Seekers')
                                  //   if (loginController.images == null || loginController.images.isEmpty) {
                                  //   await showSuccessDialog(context, title:"Error",message :"Please Select Image", onOkPressed: () {
                                  //     Get.back();});
                                  // }
                                  if (currentStep == (loginController.selectedUserType == 'Job Seekers' ? 3 : 2)) {
                                    if (loginController.selectedUserType != 'admin' &&
                                        loginController.selectedUserType != 'superAdmin' &&
                                        loginController.selectedUserType != 'Job Seekers') {

                                      if (loginController.images1 == null || loginController.images1.isEmpty) {
                                        await showSuccessDialog(
                                          context,
                                          title: "Error",
                                          message: "Please Select Image",
                                          onOkPressed: () {
                                            Get.back();
                                          },
                                        );
                                      }
                                    }
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
                                    userId: Api.userInfo.read('token')==null?"0":loginController.userData.first.userId??"",
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
                                    image: imageBytes,
                                    logoImage: logoBytes,
                                    certificate: certificateBytes,
                                    //image: loginController.selectedUserType=="Job Seekers"?loginController.logoImages1 ?? []:loginController.images1 ?? [],
                                   // certificate: loginController.certificates1 ?? [],
                                    location: loginController.locationController.text,
                                    website: loginController.websiteController.text,
                                    description: loginController.descriptionController.text??"N/A",
                                   // logoImage: loginController.selectedUserType!="Job Seekers"?loginController.logoImages1 ?? []:[],
                                    adminId:branchId=="0"?Api.userInfo.read('userId'):loginController.selectUserId! ,
                                    isAdmin: branchId=="0"?"true":"false",
                                    latitude: loginController.latitude.toString()??"",
                                    longitude: loginController.longitude.toString()??"",
                                    jobCategory:loginController.selectedCategories,
                                   // isAdmin: Api.userInfo.read('isAdmin')=='true'? "true": "false",
                                    context: context,
                                  );

                                }
                                if (currentStep < (loginController.selectedUserType == 'Job Seekers' ? 3 : 2)) {
                                  setState(() => currentStep++);
                                }
                              },
                              onStepCancel: () {
                                if (currentStep > 0) {
                                  setState(() => currentStep--);
                                }
                              },
                              controlsBuilder: (context, details) {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      if (currentStep != 0)
                                        ElevatedButton(
                                          onPressed: details.onStepCancel,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.black,
                                            side: const BorderSide(color:  AppColors.white,),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          child:  Text("Back",style: AppTextStyles.caption(context,color: AppColors.white),),
                                        ),


                                      const SizedBox(width: 20),

                                      ElevatedButton(
                                        onPressed: details.onStepContinue,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(color:  AppColors.white,),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          textStyle: AppTextStyles.caption(context,color: AppColors.white)
                                        ),
                                        child: Text(
                                          (loginController.selectedUserType == 'Job Seekers'
                                              ? currentStep == 3
                                              : currentStep == 2)
                                              ? "Submit"
                                              : "Next",
                                          style: AppTextStyles.caption(context, color: AppColors.white),
                                        ),                                      ),

                                    ],
                                  ),
                                );
                              },
                              steps: getSteps(),

                              // steps: [
                              //   Step(
                              //     title:  Text("Personal Info",style: AppTextStyles.body(context,),),
                              //     isActive: currentStep >= 0,
                              //     content: _step1(),
                              //   ),
                              //   Step(
                              //     title:  Text("Professional Details",style: AppTextStyles.body(context,)),
                              //     isActive: currentStep >= 1,
                              //     content: _step2(),
                              //   ),
                              //
                              //   Step(
                              //     title:  Text("Uploads",style: AppTextStyles.body(context,)),
                              //     isActive: currentStep >= 2,
                              //     content: _step3(),
                              //   ),
                              //
                              //   // if( loginController.selectedUserType == 'Job Seekers')
                              //   // Step(
                              //   //   title:  Text("Education Details",style: AppTextStyles.body(context,)),
                              //   //   isActive: currentStep >= 3,
                              //   //  // content: _step4(),
                              //   //   content: loginController.selectedUserType == 'Job Seekers'
                              //   //       ? _step4()
                              //   //       : SizedBox(),
                              //   // ),
                              // ],
                            ),
                          ),
                        ],
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
  Widget _step1() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hint: "Full Name",
                controller: loginController.fullNameController,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child:  CustomTextField(
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
            )
          ],
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            if(branchId!="0")
              Expanded(
              child: CustomTextField(
                hint: "Email",
                controller: loginController.emailController,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: CustomTextField(
                hint: "Mobile",
                controller: loginController.mobileController,
                maxLength: 10,keyboardType: TextInputType.number,
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
            )
          ],
        ),

        const SizedBox(height: 20),
        if(Api.userInfo.read('token')==null)

        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hint: "Password",
                controller: loginController.passwordController,
                isPassword: true,
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
            ),

            const SizedBox(width: 20),
            Expanded(
              child:  CustomTextField(
                hint: "Confirm Password",
                icon: Icons.lock,
                isPassword: true,
                controller: loginController.confirmPasswordController,
                validator: (value) => confirmPasswordValidator(value, loginController.passwordController),
              ),
            )
          ],
        )
      ],
    );
  }
  Widget _step2() {
    final userType=Api.userInfo.read('userType');
    final adminItems = allItems;
    final otherItems = allItems.where((e) => e != "admin" && e != "superAdmin").toList();
    final size = MediaQuery.of(context).size.width;
    final items = (userType == 'superAdmin' || userType == 'admin')
        ? adminItems
        : otherItems;
    final selectedValue = items.contains(loginController.selectedUserType)
        ? loginController.selectedUserType
        : null;

    return Column(
      children: [
        const SizedBox(height: 20),
        CustomDropdownField(
          hint: "Select UserType",
          fillColor: Colors.grey[100],
          borderColor: AppColors.white,
          items: userType=='superAdmin'||userType=='admin'?adminItems:otherItems,
          //selectedValue: loginController.selectedUserType,
          selectedValue: selectedValue,
          onChanged: (value) {
            setState(() {
              loginController.selectedUserType = value;
              print('Selected UserType: ${loginController.selectedUserType}');
            });
          },
        ),
        if ((loginController.selectedUserType != null &&
            loginController.selectedUserType!.isNotEmpty)&&loginController.selectedUserType !='Job Seekers')
          Column(children: [
            const SizedBox(height: 10),
            // if(loginController.selectedUserType !='Job Seekers')
            CustomTextField(
              hint: "${loginController.selectedUserType?.split(' ').sublist(1).join(' ')} Name",
              icon: Icons.store,
              controller: loginController.typeNameController,
            ),
          ]),
        const SizedBox(height: 10),
     Text('Address',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
        const SizedBox(height: 10),

        Row(
          children: [

            Expanded(
              child:  GetBuilder<LoginController>(
                builder: (controller) {
                  final items=controller.states.map((d) => d.toString()).toList();
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
                    initialItem: items.contains(controller.selectedState)
                        ? controller.selectedState
                        : null,
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
            ),

            const SizedBox(width: 20),

            Expanded(
              child:   GetBuilder<LoginController>(
                builder: (controller) {
                  final items=controller.districts.map((d) => d.toString()).toList();
                  return CustomDropdown<String>.search(
                    hintText: "Select District",
                    items: controller.districts.map((d) => d.toString()).toList(),
                    //initialItem: controller.selectedDistrict,
                    initialItem: items.contains(controller.selectedDistrict)
                        ? controller.selectedDistrict
                        : null,
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
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          children: [

            Expanded(
              child:  GetBuilder<LoginController>(
                  builder: (controller) {
                  final items=  loginController.talukas.map((t) => t.toString()).toList();
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
                        initialItem: items.contains(controller.selectedTaluka)
                            ? controller.selectedTaluka
                            : null,
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
            ),

            const SizedBox(width: 20),

            Expanded(
              child:  GetBuilder<LoginController>(
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
                        initialItem: items.contains(controller.selectedVillage)
                            ? controller.selectedVillage
                            : null,
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
            ),
          ],
        ),

        const SizedBox(height: 20),

        CustomTextField(
          hint: "Pin code",
          controller: loginController.pinCodeController,maxLength: 6,
        ),
        if(loginController.selectedUserType!="Job Seekers")
          CustomTextField(
            hint: "location Link",
            icon: Icons.pin,
            controller: loginController.locationController,
          ),
        if(loginController.selectedUserType=="Job Seekers")
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            //SizedBox(height: size * 0.03),
                Text("Job Category Preferences",
                  style: AppTextStyles.caption(fontWeight: FontWeight.w400,context),),
                SizedBox(height: size * 0.01),
                CustomTextField(
                  hint: "About Me",
                  icon: Icons.location_on,maxLines: 5,
                  controller: loginController.descriptionController,
                ),
                SizedBox(height: size*0.03,),
            Text("Job Category Preferences",
              style: AppTextStyles.caption(fontWeight: FontWeight.w400,context),),
            SizedBox(height: size * 0.01),
            GetBuilder<JobController>(
              builder: (jobController) {
                // final List<MultiSelectItem<String>> categoryItems =
                // jobController!.jobCategoryAdmin
                //     .map((e) => MultiSelectItem<String>(
                //   e.name.trim(),
                //   e.name.trim(),
                // ),
                // ).toList();
                final List<MultiSelectItem<String>> categoryItems =
                (jobController?.jobCategoryAdmin ?? [])
                    .map((e) => MultiSelectItem<String>(e.name.trim(), e.name.trim()))
                    .toList();
                return MultiSelectDialogField<String>(
                  items: categoryItems,
                  selectedColor: AppColors.primary,
                  dialogHeight: MediaQuery.of(context).size.height * 0.5,
                  dialogWidth: MediaQuery.of(context).size.width * 0.25,
                  initialValue: loginController.selectedCategories.isNotEmpty
                      ? loginController.selectedCategories
                      : [],
                  //initialValue: loginController.selectedCategories,
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
      ],
    );
  }

  Widget _step3() {
    double s=MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (loginController.selectedUserType == 'Dental Clinic'||loginController.selectedUserType == 'Job Seekers'||loginController.selectedUserType=='Dental Shop'||loginController.selectedUserType=='Dental Mechanic'||loginController.selectedUserType=='Dental Lab') ...[
        Column(children: [
        Center(
          child: Text(loginController.selectedUserType == 'Job Seekers'?"Upload Resume":"Upload Certificates",
              style: AppTextStyles.caption(fontWeight: FontWeight.bold, context)),
        ),
        const SizedBox(height: 10),
        // GetBuilder<LoginController>(
        //   builder: (controller) {
        //     return GridView.builder(
        //       shrinkWrap: true,
        //       physics: const NeverScrollableScrollPhysics(),
        //       itemCount: loginController.selectedUserType == 'Job Seekers'?1:maxFiles,
        //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //         crossAxisCount: 3,
        //         crossAxisSpacing: 10,
        //         mainAxisSpacing: 10,
        //         childAspectRatio: 1,
        //       ),
        //       itemBuilder: (context, index) {
        //        // if (index < controller.certificates1.length) {
        //         if (controller.certificates1 != null && index < controller.certificates1.length) {
        //           final file = controller.certificates1[index];
        //         //   return buildImageXFile(file);
        //         // } else {
        //           return GestureDetector(
        //             onTap: pickCertificates,
        //             child: Container(
        //               margin: const EdgeInsets.all(8),
        //               width: s * 0.095,
        //               height: s * 0.021,
        //               decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(10),
        //                 border: Border.all(color: Colors.grey),
        //                 color: Colors.grey.shade200,
        //               ),
        //               child:  Center(
        //                 child: Icon(Icons.add, size: s*0.012, color: Colors.grey),
        //               ),
        //             ),
        //             // Container(
        //             //   height: 150,
        //             //   width: 200,
        //             //   alignment: Alignment.center,
        //             //   decoration: BoxDecoration(
        //             //     border: Border.all(color: Colors.grey),
        //             //     borderRadius: BorderRadius.circular(10),
        //             //   ),
        //             //   child:   Center(child: Icon(Icons.add,color: AppColors.grey,size:s*0.014,)),
        //             // ),
        //           );
        //         }
        //         final img = loginController.certificates1[index];
        //         Widget imageWidget;
        //         if (kIsWeb && img.bytes != null) {
        //           imageWidget = Image.memory(img.bytes!, fit: BoxFit.cover,width: s * 0.095,
        //             height: s * 0.021,);
        //         } else if (img.file != null) {
        //           imageWidget = Image.file(img.file!, fit: BoxFit.cover,width: s * 0.095,
        //             height: s * 0.021,);
        //         } else if (img.url != null && img.url!.isNotEmpty) {
        //           imageWidget = Image.network(
        //             img.url!,
        //             fit: BoxFit.cover,width: s * 0.095,
        //             height: s * 0.021,
        //             errorBuilder: (_, __, ___) =>  Icon(Icons.broken_image,size: s*0.012),
        //           );
        //         } else {
        //           imageWidget =  Container(child: Center(child: Icon(Icons.image_not_supported,color: Colors.red, size: s*0.02)));
        //         }
        //         return Container(
        //           margin: const EdgeInsets.all(8),
        //           width: s * 0.095,
        //           height: s * 0.021,
        //           child: Stack(
        //             children: [
        //               ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
        //               Positioned(
        //                 right: 0,
        //                 top: 0,
        //                 child: GestureDetector(
        //                   onTap: () {
        //                     loginController.certificates1.removeAt(index);
        //                     loginController.update();
        //                   },
        //                   child:  Icon(Icons.cancel, color: Colors.red, size: s*0.012),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         );
        //       },
        //     );
        //   },
        // ),
          GetBuilder<LoginController>(
            builder: (controller) {
              final certs = controller.certificates1 ?? [];
              final gridCount = certs.length < maxFiles ? certs.length + 1 : maxFiles;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gridCount,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  if (index >= certs.length) {
                    return GestureDetector(
                      onTap: pickCertificates,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Icon(Icons.add, size: s * 0.012, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  final img = certs[index];
                  Widget imageWidget;
                  bool isPdf = (img.name != null && img.name!.toLowerCase().endsWith('.pdf')) ||
                      (img.url != null && img.url!.toLowerCase().endsWith('.pdf'));
                  if (isPdf) {
                    imageWidget = Container(
                      color: Colors.red.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
                          SizedBox(height: 5),
                          Text(
                            "PDF",
                            style: AppTextStyles.caption(context),
                          ),
                        ],
                      ),
                    );
                  }
                  else if (kIsWeb && img.bytes != null) {
                    imageWidget = Image.memory(img.bytes!, fit: BoxFit.cover,  width: s * 0.35,
                      height: s * 0.35,);
                  }
                  else if (img.file != null) {
                    imageWidget = Image.file(img.file!, fit: BoxFit.cover,  width: s * 0.35,
                      height: s * 0.35,
                    );
                  }
                  else if (img.url != null && img.url!.isNotEmpty) {
                    imageWidget = Image.network(
                      img.url!,
                      fit: BoxFit.cover,
                      width: s * 0.35,
                      height: s * 0.35,
                      errorBuilder: (_, __, ___) => Icon(Icons.broken_image,color: AppColors.grey,size: s*0.012,),
                    );
                  }
                  else {
                    imageWidget = Icon(Icons.image_not_supported, color: Colors.red,size: s*0.012);
                  }
                  return Container(
                    margin: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              controller.certificates1.removeAt(index);
                              controller.update();
                            },
                            child: Icon(Icons.cancel, color: Colors.red,size: s*0.012),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: s*0.01,)
    ]),],

    if (loginController.selectedUserType == 'Dental Clinic'||loginController.selectedUserType=='Dental Shop'||loginController.selectedUserType=='Dental Mechanic'||loginController.selectedUserType=='Dental Lab') ...[

    Column(children: [

       SizedBox(height: s*0.01),
        Center(
          child: Text("Upload ${loginController.selectedUserType} Images",
              style: AppTextStyles.caption(fontWeight: FontWeight.bold, context)),
        ),
      SizedBox(height: s*0.01),
        // GetBuilder<LoginController>(
        //   builder: (controller) {
        //     return GridView.builder(
        //       shrinkWrap: true,
        //       physics: const NeverScrollableScrollPhysics(),
        //       itemCount: maxFiles,
        //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //         crossAxisCount: 3,
        //         crossAxisSpacing: 10,
        //         mainAxisSpacing: 10,
        //         childAspectRatio: 1,
        //       ),
        //       itemBuilder: (context, index) {
        //         if (index < controller.images1.length)
        //         //   final file = controller.images1[index];
        //         //   return buildImageXFile(file);
        //         // } else {
        //           return GestureDetector(
        //             onTap: pickClinicImages,
        //             child: Container(
        //               // height: 150,
        //               // width: 200,
        //               width: s * 0.095,
        //               height: s * 0.021,
        //               alignment: Alignment.center,
        //               decoration: BoxDecoration(
        //                 border: Border.all(color: Colors.grey),
        //                 borderRadius: BorderRadius.circular(10),
        //               ),
        //               child:   Center(child: Icon(Icons.add,color: AppColors.grey,size:s*0.012,)),
        //             ),
        //           );
        //        // }
        //       },
        //     );
        //   },
        // ),
      GetBuilder<LoginController>(
        builder: (controller) {
          final images = controller.images1;
          final gridCount = images.length < maxFiles ? images.length + 1 : maxFiles;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index >= images.length) {
                return GestureDetector(
                  onTap: pickClinicImages,
                  child: Container(
                    width: s * 0.095,
                    height: s * 0.021,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Icon(Icons.add, color: AppColors.grey, size: s * 0.012),
                    ),
                  ),
                );
              }
              final img = images[index];
              Widget imageWidget;
              if (kIsWeb && img.bytes != null) {
                imageWidget = Image.memory(img.bytes!, fit: BoxFit.cover, width: s * 0.35,
                  height: s * 0.35,);
              } else if (img.file != null) {
                imageWidget = Image.file(img.file!, fit: BoxFit.cover,  width: s * 0.35,
                  height: s * 0.35,);
              } else if (img.url != null && img.url!.isNotEmpty) {
                imageWidget = Image.network(
                  img.url!,
                  fit: BoxFit.cover,  width: s * 0.35,
                  height: s * 0.35,
                  errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: Colors.red,size: s*0.012),
                );
              } else {
                imageWidget = Icon(Icons.image_not_supported, color: Colors.grey.shade100,size: s*0.012);
              }
              return Container(
                margin: const EdgeInsets.all(8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageWidget,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          controller.images1.removeAt(index);
                          controller.update();
                        },
                        child: Icon(Icons.cancel, color: Colors.red,size: s*0.012),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      SizedBox(height: s*0.01,)]),],


        Center(
          child: Text(loginController.selectedUserType == "Job Seekers"||loginController.selectedUserType == "admin"||loginController.selectedUserType == "superAdmin"
              ? "Upload Profile Image"
              : "Upload Logo Image",
              style: AppTextStyles.caption(fontWeight: FontWeight.bold, context)),
        ),
        const SizedBox(height: 10),
        // GetBuilder<LoginController>(
        //   builder: (controller) {
        //     return SizedBox(
        //       height: 200,
        //       child: controller.logoImages1.isNotEmpty
        //           ? _buildSingleImageWidget(image: controller.logoImages1.first)
        //           : GestureDetector(
        //         onTap: pickLogo,
        //         child: Container(
        //           height: s*0.12,
        //           width: s*0.13,
        //           alignment: Alignment.center,
        //           decoration: BoxDecoration(
        //             border: Border.all(color: Colors.grey),
        //             borderRadius: BorderRadius.circular(10),
        //           ),
        //           child:   Center(child: Icon(Icons.add,color: AppColors.grey,size:s*0.012,)),
        //         ),
        //       ),
        //     );
        //   },
        // ),
        GetBuilder<LoginController>(
          builder: (controller) {
            return SizedBox(
              height: 200,
              child: controller.logoImages1.isNotEmpty
                  ? _buildSingleImageWidget(image: controller.logoImages1.first)
                  : GestureDetector(
                onTap: pickLogo,
                child: Container(
                  width: s * 0.35,
                  height: s * 0.35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(Icons.add, color: AppColors.grey, size: s * 0.012),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: s*0.01,)
      ],
    );
  }


  Widget _step4() {
    final size = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Text("Educational Details", style: AppTextStyles.body(context,fontWeight: FontWeight.bold)),
        Text("UG Details", style: AppTextStyles.body(context,fontWeight: FontWeight.bold)),
        SizedBox(height: size * 0.02),
        CustomTextField(
    hint: "College Name",
    controller: loginController.ugCollege,
    ),
    SizedBox(height: size * 0.01),
    CustomTextField(
    hint: "Degree",
    controller: loginController.ugDegree,
    ),
    SizedBox(height: size * 0.01),
    CustomTextField(
    hint: "Percentage",
    controller: loginController.ugPercentage,
    ),
    SizedBox(height: size * 0.01),

    GetBuilder<LoginController>(
    builder: (controller) {
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    ElevatedButton(
    onPressed: () {
    loginController.togglePGDetails();
    },
    style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    // shadowColor: AppColors.primary.withOpacity(0.5),
    elevation: 4,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),),
    child: Text(
    loginController.showPGDetails ? "Hide PG Details" : "Add PG Details",textAlign: TextAlign.right,
    style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white)
    )
    ),
      SizedBox(height: size * 0.01),

    // PG Details section
    loginController.showPGDetails
    ? GetBuilder<LoginController>(
    builder: (controller) {
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    "PG Details", style: AppTextStyles.body(context,fontWeight: FontWeight.bold)

    ),
      SizedBox(height: size * 0.01),

    CustomTextField(
    hint: "College Name",
    controller: loginController.pgDetails.collegeName,
    ),
      SizedBox(height: size * 0.01),

    CustomTextField(
    hint: "Degree",
    controller: loginController.pgDetails.degree,
    ),
      SizedBox(height: size * 0.01),

    CustomTextField(
    hint: "Percentage",
    controller: loginController.pgDetails.percentage,
    ),
      SizedBox(height: size * 0.01),

    // CustomTextField(
    //   hint: "About Me",
    //   icon: Icons.location_on,
    //   controller: loginController.descriptionController,
    // ),
      SizedBox(height: size * 0.01),
    ],
    );
    }
    )
        : const SizedBox.shrink(),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),)),
        onPressed: () => loginController.addExperienceField(),
        icon:  Icon(Icons.add,size: size*0.012,color: AppColors.white),
        label:  Text("Add Experience",style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold),),
      ),
      SizedBox(height: size * 0.01),

    ],
    );
    }),

    GetBuilder<LoginController>(
    builder: (controller) {
    return Column(
    children: [
    for (int i = 0; i < loginController.experienceList.length; i++)
    _experienceFields(i,size),]);}),

      ]
    );
  }

}
Widget _experienceFields(int index,size) {
  final loginController=Get.put(LoginController());
  final exp = loginController.experienceList[index];

  return Container(
    margin: const EdgeInsets.only(bottom: 20),
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
            Text("Experience ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: size*0.02,),
            if (index > 0)
              GetBuilder<LoginController>(
                  builder: (controller) {
                    return IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => loginController.removeExperienceField(index),
                    );
                  }
              ),
          ],
        ),

        CustomTextField(
          hint: "Company Name",
          controller: exp.companyName,
        ),
        SizedBox(height: size * 0.01),
        CustomTextField(
          hint: "Experience (e.g. 4 years)",
          controller: exp.experience,
        ),
        SizedBox(height: size * 0.01),
        CustomTextField(
          hint: "Job Description",
          controller: exp.jobDescription,
        ),
        SizedBox(height: size * 0.01),

      ],
    ),
  );
}
