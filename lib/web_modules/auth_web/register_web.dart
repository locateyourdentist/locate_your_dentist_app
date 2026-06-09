import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import '../../common_widgets/color_code.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'dart:io' show File;

class RegisterWebPage extends StatefulWidget {
  const RegisterWebPage({super.key});
  @override
  State<RegisterWebPage> createState() => _RegisterWebPageState();
}

class _RegisterWebPageState extends State<RegisterWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKeyRegister = GlobalKey<ScaffoldState>();
  int currentStep = 0;
  final ImagePicker _picker = ImagePicker();
  final _formKeyRegisterWeb = GlobalKey<FormState>();
  final loginController = Get.put(LoginController());
  final jobController = Get.put(JobController());
  String? branchId;
  final planController = Get.put(PlanController());
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
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

  List<String> get filteredItems {
    final userType = Api.userInfo.read('userType');

    if (userType != 'superAdmin') {
      return allItems
          .where((e) => e != "admin" && e != "superAdmin")
          .toList();
    }

    return allItems;
  }  final int maxFiles = 3;
  bool isPicking = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> setProfileData(user) async {
    loginController.selectedState = user.address?.state ?? "";
    loginController.selectedDistrict = user.address?.district ?? "";
    loginController.selectedTaluka = user.address?.city ?? "";
    loginController.selectedVillage = user.address?.area ?? "";

    await loginController.fetchStates();

    if (loginController.selectedState!.isNotEmpty) {
      await loginController.fetchDistricts(loginController.selectedState!);
    }
    if (loginController.selectedDistrict!.isNotEmpty) {
      await loginController.fetchTalukas(loginController.selectedDistrict!);
    }
    if (loginController.selectedTaluka!.isNotEmpty) {
      await loginController.fetchVillages(loginController.selectedTaluka!);
    }

    loginController.update();
  }

  Future<void> _refresh() async {
    await getLocation();
    loadJobDescription(loginController.descriptionData);
    await loginController.fetchStates();
    await setProfileData(loginController.userData);
    if (loginController.userData.isNotEmpty) getPlanLimits();
    await jobController.getJobCategoryLists("", context);
    branchId = Get.arguments?['branchId'] ?? "";
    if (Get.arguments?['userId'] == "0") loginController.clearProfileData();
  }

  Future<void> getLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      loginController.latitude = position.latitude;
      loginController.longitude = position.longitude;
      final address = await getAddressFromLatLng(position.latitude, position.longitude);
      planController.currentLocation = address;
    }
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks.first;
      return '${place.subLocality}, ${place.locality} ${place.postalCode}';
    } catch (e) {
      return '';
    }
  }

  void loadJobDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [{"insert": "\n"}];
      if (data != null && data.toString().trim().isNotEmpty) {
        if (data is String) {
          delta = List<Map<String, dynamic>>.from(jsonDecode(data.trim()));
        } else if (data is List) {
          delta = List<Map<String, dynamic>>.from(data);
        }
      }
      _controller.document = Document.fromJson(delta);
      if (mounted) setState(() {});
    } catch (e) {
      _controller.document = Document.fromJson([{"insert": "\n"}]);
      if (mounted) setState(() {});
    }
  }

  void getPlanLimits() {
    final userData = loginController.userData.first;
    final planDetails = userData.details?["plan"]?["basePlan"]?["details"];
    if (planDetails != null) {
      loginController.maxFilesImage = int.tryParse(planDetails["imageCount"]?.toString() ?? "") ?? 2;
     // loginController.maxFilesImage = int.tryParse(planDetails["imageCount"]?.toString() ?? "0") ?? 2;
      loginController.maxFilesVideo = int.tryParse(planDetails["videoCount"]?.toString() ?? "0") ?? 1;
    }
  }

  Future<void> pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    loginController.logoImages1.clear();
    if (kIsWeb) {
      loginController.logoImages1.add(AppImage2(bytes: await image.readAsBytes()));
    } else {
      loginController.logoImages1.add(AppImage2(file: File(image.path)));
    }
    loginController.update();
  }

  Future<void> pickCertificates() async {
    if (isPicking) return;
    isPicking = true;
    final remaining = maxFiles - loginController.certificates1.length;
    if (remaining <= 0) {
      Get.snackbar("Error", "Maximum $maxFiles files allowed");
      isPicking = false;
      return;
    }
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
        allowMultiple: true,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files.take(remaining)) {
          if (kIsWeb) {
            loginController.certificates1.add(AppImage2(bytes: file.bytes, name: file.name));
          } else if (file.path != null) {
            loginController.certificates1.add(AppImage2(file: File(file.path!)));
          }
        }
        loginController.update();
      }
    } finally {
      isPicking = false;
    }
  }

  // Future<void> pickMedia(String source) async {
  //   bool isVideo = source == "video";
  //   if (kIsWeb) {
  //     final result = await FilePicker.platform.pickFiles(type: isVideo ? FileType.video : FileType.image, withData: true);
  //     if (result == null || result.files.isEmpty) return;
  //     final file = result.files.first;
  //     loginController.editImages.add(AppImage(bytes: file.bytes, isVideo: isVideo));
  //   } else {
  //     XFile? pickedFile = isVideo
  //         ? await _picker.pickVideo(source: ImageSource.gallery)
  //         : await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  //     if (pickedFile == null) return;
  //     loginController.editImages.add(AppImage(file: File(pickedFile.path), isVideo: isVideo));
  //     loginController.update();
  //
  //   }
  //   loginController.update();
  // }
  Future<void> pickMedia(String source) async {
    bool isVideo = source == "video";

    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: isVideo ? FileType.video : FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      loginController.images1.add(
        AppImage2(
          bytes: file.bytes,
        ),
      );
    } else {
      XFile? pickedFile = isVideo
          ? await _picker.pickVideo(source: ImageSource.gallery)
          : await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (pickedFile == null) return;

      loginController.images1.add(
        AppImage2(file: File(pickedFile.path)),
      );
    }

    loginController.update(); // MUST be once at end
  }
  List<Step> getSteps(bool isMobile) {
    return [
      Step(title: Text(isMobile ? "" : "Personal"), content: _step1(isMobile), isActive: currentStep >= 0),
      Step(title: Text(isMobile ? "" : "Professional"), content: _step2(isMobile), isActive: currentStep >= 1),
      Step(title: Text(isMobile ? "" : "Uploads"), content: _step3(), isActive: currentStep >= 2),
      if (loginController.selectedUserType == 'Job Seekers')
        Step(title: Text(isMobile ? "" : "Education"), content: _step4(), isActive: currentStep >= 3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    return Scaffold(
      key: _scaffoldKeyRegister,
      backgroundColor: AppColors.scaffoldBg,
      drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      body: Row(
        children: [
          if (isLoggedIn && isDesktop) const AdminSideBar(),
          Expanded(
            child: Form(
              key: _formKeyRegisterWeb,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: isMobile ? 10.0 : 35.0,
                          right: isMobile ? 10.0 : 35.0,
                          top: (isLoggedIn && !isDesktop) ? 56.0 : (isMobile ? 10.0 : 35.0),
                          bottom: isMobile ? 10.0 : 35.0,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 20),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 0),
                                  child: Text(
                                    loginController.fullNameController.text.isNotEmpty ? "Edit Details" : "Register New User",
                                    style: AppTextStyles.body(context, fontWeight: FontWeight.bold, color: AppColors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (loginController.fullNameController.text.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 0),
                                    child: Text(
                                      "Fill in the details to create a new account",
                                      style: AppTextStyles.caption(context, fontWeight: FontWeight.bold, color: AppColors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(primary: AppColors.primary),
                                  ),
                                  child: Stepper(
                                    key: ValueKey(loginController.selectedUserType),
                                    type: StepperType.vertical,
                                    physics: const NeverScrollableScrollPhysics(),
                                    steps: getSteps(isMobile),
                                    currentStep: currentStep,
                                    onStepContinue: () async {
                                      int lastStep = loginController.selectedUserType == 'Job Seekers' ? 3 : 2;
                                      if (currentStep == lastStep) {
                                        if (_formKeyRegisterWeb.currentState!.validate()) {
                                          await _handleRegistration();
                                        }
                                      } else {
                                        setState(() => currentStep++);
                                      }
                                    },
                                    onStepCancel: () {
                                      if (currentStep > 0) setState(() => currentStep--);
                                    },
                                    controlsBuilder: (context, details) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (currentStep != 0)
                                              OutlinedButton(
                                                onPressed: details.onStepCancel,
                                                child: const Text("Back"),
                                              ),
                                            const SizedBox(width: 20),
                                            ElevatedButton(
                                              onPressed: details.onStepContinue,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: Text(
                                                currentStep == (loginController.selectedUserType == 'Job Seekers' ? 3 : 2)
                                                    ? "Submit"
                                                    : "Next",
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isLoggedIn && !isDesktop)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        icon: Icon(Icons.menu, color: AppColors.black),
                        onPressed: () => _scaffoldKeyRegister.currentState?.openDrawer(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegistration() async {
   // final imageBytes = await _convertAppImages(loginController.editImages);
    final imageBytes = await _convertAppImage2s(loginController.images1);
    final logoBytes = await _convertAppImage2s(loginController.logoImages1);
    final certBytes = await _convertAppImage2s(loginController.certificates1);

    final oldImageUrls = loginController.editImages.where((e) => e.url != null).map((e) => e.url!).toList();
    final oldCertUrls = loginController.certificates1.where((e) => e.url != null).map((e) => e.url!).toList();

    await loginController.registerUser(
      userId: (Api.userInfo.read('token') == null || Get.arguments?['userId'] == "0")
          ? "0"
          : loginController.userData.first.userId ?? "",
      userType: loginController.selectedUserType!,
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
      typeName: loginController.typeNameController.text,
      image: imageBytes,
      logoImage: logoBytes,
      certificate: certBytes,
      oldImageUrl: oldImageUrls,
      oldCertificatesUrl: oldCertUrls,
      location: loginController.locationController.text,
      website: loginController.websiteController.text,
      description: jsonEncode(_controller.document.toDelta().toJson()),
      adminId: branchId == "0" ? (Api.userInfo.read('userId') ?? "") : (loginController.selectUserId ?? ""),
      isAdmin: branchId == "0" ? "true" : "false",
      latitude: loginController.latitude?.toString() ?? "",
      longitude: loginController.longitude?.toString() ?? "",
      jobCategory: loginController.selectedUserType == 'Job Seekers' ? (loginController.selectedCategories ?? []) : [],
      context: context,
    );
  }

  Future<List<Uint8List>> _convertAppImages(List<AppImage> images) async {
    List<Uint8List> res = [];
    for (var img in images) {
      if (kIsWeb && img.bytes != null) res.add(img.bytes!);
      else if (img.file != null) res.add(await img.file!.readAsBytes());
    }
    return res;
  }

  Future<List<Uint8List>> _convertAppImage2s(List<AppImage2> images) async {
    List<Uint8List> res = [];
    for (var img in images) {
      if (kIsWeb && img.bytes != null) res.add(img.bytes!);
      else if (img.file != null) res.add(await img.file!.readAsBytes());
    }
    return res;
  }

  Widget _responsiveRow(bool isMobile, Widget first, Widget second) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [first, const SizedBox(height: 15), second],
      );
    }
    return Row(
      children: [Expanded(child: first), const SizedBox(width: 15), Expanded(child: second)],
    );
  }

  Widget _step1(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _responsiveRow(
          isMobile,
          CustomTextField(hint: "Full Name", controller: loginController.fullNameController),
          CustomTextField(
            hint: "DOB",
            controller: loginController.dobController,
            readOnly: true,
            onTap: () async {
              DateTime? p = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (p != null) loginController.dobController.text = "${p.day}-${p.month}-${p.year}";
            },
          ),
        ),
        const SizedBox(height: 15),
        if (branchId != "0")
          _responsiveRow(
            isMobile,
            CustomTextField(hint: "Email", controller: loginController.emailController),
            CustomTextField(hint: "Mobile", controller: loginController.mobileController, maxLength: 10, keyboardType: TextInputType.number),
          )
        else
          CustomTextField(hint: "Mobile", controller: loginController.mobileController, maxLength: 10, keyboardType: TextInputType.number),
        if (Api.userInfo.read('token') == null) ...[
          const SizedBox(height: 15),
          _responsiveRow(
            isMobile,
            CustomTextField(hint: "Password", controller: loginController.passwordController, isPassword: true),
            CustomTextField(hint: "Confirm Password", controller: loginController.confirmPasswordController, isPassword: true),
          ),
        ],
      ],
    );
  }

  Widget _step2(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomDropdownField(
          hint: "User Type",
          items: filteredItems,
          selectedValue: loginController.selectedUserType,
          onChanged: (v) => setState(() => loginController.selectedUserType = v),
        ),
        const SizedBox(height: 15),

        if (loginController.selectedUserType != 'Job Seekers' && loginController.selectedUserType != null)
          Padding(
            padding: const EdgeInsets.only(top: 15,bottom: 15),
            child:   CustomTextField(
              hint: loginController.selectedUserType == 'Dental Shop'? "College Name":"${loginController.selectedUserType?.split(' ').sublist(1).join(' ')} Name",
              icon: Icons.store,
              controller: loginController.typeNameController,
            ),
          ),
       // const SizedBox(height: 15),
        _responsiveRow(isMobile, _buildStateDropdown(), _buildDistrictDropdown()),
        const SizedBox(height: 15),
        _responsiveRow(isMobile, _buildTalukaDropdown(), _buildAreaDropdown()),
        const SizedBox(height: 15),
        CustomTextField(hint: "Pin Code", controller: loginController.pinCodeController, maxLength: 6),
        const SizedBox(height: 15),
        _buildRichTextEditor(),
      ],
    );
  }

  Widget _buildRichTextEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Description"),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              QuillSimpleToolbar(
                controller: _controller,
                config: const QuillSimpleToolbarConfig(embedButtons: [], showBackgroundColorButton: false),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 300,
                child: QuillEditor(
                  controller: _controller,
                  scrollController: _scrollController,
                  focusNode: _focusNode,
                  config: const QuillEditorConfig(placeholder: "Description...", padding: EdgeInsets.all(10)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStateDropdown() {
    return GetBuilder<LoginController>(
      builder: (c) {
        final stateItems = c.states.map((e) => e.toString()).toList();
        return CustomDropdown<String>.search(
          hintText: "State",
          items: stateItems,
          decoration: CustomDropdownDecoration(
            closedFillColor: Colors.grey[100],
            expandedFillColor: Colors.white,
            closedBorder: Border.all(color: AppColors.white, width: 1.5),
            expandedBorder: Border.all(color: AppColors.primary, width: 1.5),
            closedBorderRadius: BorderRadius.circular(10),
            expandedBorderRadius: BorderRadius.circular(10),
            hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
            headerStyle: AppTextStyles.caption(context, color: Colors.black),
            listItemStyle: AppTextStyles.caption(context, color: Colors.black),
          ),
          initialItem: stateItems.contains(c.selectedState) ? c.selectedState : null,
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
        final districtItems = c.districts.map((e) => e.toString()).toList();
        return CustomDropdown<String>.search(
          hintText: "District",
          items: districtItems,
          decoration: CustomDropdownDecoration(
            closedFillColor: Colors.grey[100],
            expandedFillColor: Colors.white,
            closedBorder: Border.all(color: AppColors.white, width: 1.5),
            expandedBorder: Border.all(color: AppColors.primary, width: 1.5),
            closedBorderRadius: BorderRadius.circular(10),
            expandedBorderRadius: BorderRadius.circular(10),
            hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
            headerStyle: AppTextStyles.caption(context, color: Colors.black),
            listItemStyle: AppTextStyles.caption(context, color: Colors.black),
          ),
          initialItem: districtItems.contains(c.selectedDistrict) ? c.selectedDistrict : null,
          onChanged: (v) {
            if (v != null) {
              c.selectedDistrict = v;
              c.selectedTaluka = null;
              c.talukas.clear();
              c.fetchTalukas(v);
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
        final talukaItems = c.talukas.map((e) => e.toString()).toList();
        final selectedTaluka = talukaItems.contains(c.selectedTaluka) ? c.selectedTaluka : null;
        return CustomDropdown<String>.search(
          hintText: "Taluka",
          items: talukaItems,
          initialItem: selectedTaluka,
          decoration: CustomDropdownDecoration(
            closedFillColor: Colors.grey[100],
            expandedFillColor: Colors.white,
            closedBorder: Border.all(color: AppColors.white, width: 1.5),
            expandedBorder: Border.all(color: AppColors.primary, width: 1.5),
            closedBorderRadius: BorderRadius.circular(10),
            expandedBorderRadius: BorderRadius.circular(10),
            hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
            headerStyle: AppTextStyles.caption(context, color: Colors.black),
            listItemStyle: AppTextStyles.caption(context, color: Colors.black),
          ),
          onChanged: (v) {
            if (v != null) {
              c.selectedTaluka = v;
              c.villages.clear();
              c.selectedVillage = null;
              c.fetchVillages(v);
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
          decoration: CustomDropdownDecoration(
            closedFillColor: Colors.grey[100],
            expandedFillColor: Colors.white,
            closedBorder: Border.all(color: AppColors.white, width: 1.5),
            expandedBorder: Border.all(color: AppColors.primary, width: 1.5),
            closedBorderRadius: BorderRadius.circular(10),
            expandedBorderRadius: BorderRadius.circular(10),
            hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
            headerStyle: AppTextStyles.caption(context, color: Colors.black),
            listItemStyle: AppTextStyles.caption(context, color: Colors.black),
          ),
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

  Widget _step3() {
    return Column(
      children: [
        const Text("Upload Certificate"),
        const SizedBox(height: 10),
        _buildCertificatePicker(),
        const SizedBox(height: 20),
        const Text("Upload Image"),
        const SizedBox(height: 10),

        _buildImagePicker(),
        const SizedBox(height: 20),
        const Text("Logo / Profile Image"),
        const SizedBox(height: 10),
        _buildLogoPicker(),
      ],
    );
  }

  Widget _buildCertificatePicker() {
    return GetBuilder<LoginController>(builder: (c) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ...c.certificates1.map((img) => _buildThumb(img, () {
                c.certificates1.remove(img);
                c.update();
              })),
          if (c.certificates1.length < maxFiles) _buildAddThumb(pickCertificates),
        ],
      );
    });
  }
  Widget _buildImagePicker() {
    return GetBuilder<LoginController>(builder: (c) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ...c.images1.map((img) {
            return _buildThumb(img, () {
              c.images1.remove(img);
              c.update();
            });
          }).toList(),

          if (c.images1.length < maxFiles)
            _buildAddThumb(() => pickMedia("image")),
        ],
      );
    });
  }
  Widget _buildLogoPicker() {
    return GetBuilder<LoginController>(builder: (c) {
      return Center(
        child: c.logoImages1.isEmpty
            ? _buildAddThumb(pickLogo)
            : _buildThumb(c.logoImages1.first, () {
                c.logoImages1.clear();
                c.update();
              }),
      );
    });
  }

  Widget _buildThumb(AppImage2 img, VoidCallback onRem) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildImage(img)),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(onTap: onRem, child: const Icon(Icons.cancel, color: Colors.red, size: 20)),
        ),
      ],
    );
  }

  Widget _buildAddThumb(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add, color: Colors.grey),
      ),
    );
  }

  Widget _buildImage(AppImage2 image) {
    if (kIsWeb && image.bytes != null) return Image.memory(image.bytes!, fit: BoxFit.cover);
    if (image.file != null) return Image.file(image.file!, fit: BoxFit.cover);
    if (image.url != null && image.url!.isNotEmpty) return Image.network(image.url!, fit: BoxFit.cover);
    return const Icon(Icons.image);
  }

  Widget _step4() {
    return Column(
      children: [
        const Text("Education Details", style: TextStyle(fontWeight: FontWeight.bold)),
        CustomTextField(hint: "UG College", controller: loginController.ugCollege),
        const SizedBox(height: 10),
        CustomTextField(hint: "UG Degree", controller: loginController.ugDegree),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => loginController.addExperienceField(),
          child: const Text("Add Experience"),
        ),
        GetBuilder<LoginController>(
          builder: (c) => Column(
            children: [for (int i = 0; i < c.experienceList.length; i++) _expField(i)],
          ),
        ),
      ],
    );
  }

  Widget _expField(int i) {
    final exp = loginController.experienceList[i];
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Experience ${i + 1}"),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => loginController.removeExperienceField(i),
                ),
              ],
            ),
            CustomTextField(hint: "Company", controller: exp.companyName),
            const SizedBox(height: 10),
            CustomTextField(hint: "Years", controller: exp.experience),
          ],
        ),
      ),
    );
  }
}
