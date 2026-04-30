import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/modules/profiles/vedio_plays.dart';
import 'package:path/path.dart' as path;
// import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:geocoding/geocoding.dart';


  class ClinicEditProfile extends StatefulWidget {
  const ClinicEditProfile({super.key});
  @override
  State<ClinicEditProfile> createState() => _ClinicEditProfileState();
  }
  class _ClinicEditProfileState extends State<ClinicEditProfile> {
    final loginController = Get.put(LoginController());
    final _formKeyEditProfile = GlobalKey<FormState>();
    late final TextEditingController countryCont = TextEditingController();
    final TextEditingController stateCont = TextEditingController();
    final TextEditingController cityCont = TextEditingController();
    String? userId;
    String? branchId;
    late QuillController _controller;
    final ScrollController _scrollController = ScrollController();
    final FocusNode _focusNode = FocusNode();
    @override
    final ImagePicker _picker = ImagePicker();
    final planController = Get.put(PlanController());
    void removeMedia(int index) {
      loginController.editImages.removeAt(index);
      loginController.update();
    }
  Future<void> pickCertificates() async {
    if (loginController.editCertificates.length >= 3) {
      Get.snackbar("Error", "Maximum 3 images allowed");
      return;
    }
    try {
      final List<XFile> selected = await _picker.pickMultiImage();
      int remaining = 3 - loginController.editCertificates.length;
      final limited = selected.take(remaining);
      setState(() {
        loginController.editCertificates.addAll(
          limited.map((x) => AppImage(file: File(x.path))),
        );
      });
      if (selected.length > remaining) {
        showCustomToast(context,  "error, Only $remaining more images allowed",);
      }
        } catch (e) {
      print("Error picking images: $e");
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
            child:  Icon(Icons.cancel,size: 12, color: Colors.white,),
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
              child: const Icon(Icons.edit,  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
    void loadJobDescription(dynamic data) {
      try {
        List<Map<String, dynamic>> delta;

        if (data == null || data.toString().trim().isEmpty) {
          delta = [
            {"insert": "\n"}
          ];
        }

        else if (data is String) {
          final trimmed = data.trim();

          if (trimmed.isEmpty || trimmed == "[]") {
            delta = [
              {"insert": "\n"}
            ];
          } else {
            final decoded = jsonDecode(trimmed);

            if (decoded is List && decoded.isNotEmpty) {
              delta = List<Map<String, dynamic>>.from(decoded);
            } else {
              delta = [
                {"insert": "\n"}
              ];
            }
          }
        }

        else if (data is List && data.isNotEmpty) {
          delta = List<Map<String, dynamic>>.from(data);
        }

        else {
          delta = [
            {"insert": "\n"}
          ];
        }

        _controller.document = Document.fromJson(delta);
        setState(() {});
      } catch (e) {
        print("Quill load error: $e");

        _controller.document = Document.fromJson([
          {"insert": "\n"}
        ]);

        setState(() {});
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
    Future<void> getLocation() async {
      final position = await LocationService.getCurrentLocation();

      if (position != null) {
        loginController.latitude = position.latitude;
        loginController.longitude = position.longitude;

        final address = await getAddressFromLatLng(loginController.latitude!, loginController.longitude!);

        print('latitude ${loginController.latitude}');
        print('longitude ${loginController.longitude}');

        planController.currentLocation = address;
      } else {
        Get.snackbar('Location', 'Unable to get location');
      }
    }
  @override
  void initState(){
    super.initState();
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
        ),

      ),
    );
    _refresh();

  }
    Future<void> _refresh() async {
      userId=Get.arguments?["userId"]??"";
      branchId = Get.arguments?['branchId'] ??"";
      countryCont!='India';
      print('sd$userId');
      //loginController.getProfileByUserId(userId!, context);
      await loginController.fetchStates();
      loadJobDescription(loginController.descriptionData);

      await getPlanLimits();
    }
    bool getPlanActive() {
      final userData = loginController.userData;
      if (userData.isEmpty) return false;
      final raw = userData.first.details["plan"]?["basePlan"]?["isActive"]??"";
      return raw == true || raw == "true";
    }
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return  Scaffold(
        appBar:AppBar(
          automaticallyImplyLeading: false,centerTitle: true,
          title: Text(
            'Profile',
            style: AppTextStyles.subtitle(context, color: AppColors.black),
          ),
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
          iconTheme: const IconThemeData(color: AppColors.white),
        ),
      body: GetBuilder<LoginController>(
        builder: (controller) {
          final planActive = getPlanActive();
          return Form(
            key: _formKeyEditProfile,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Details',style: AppTextStyles.subtitle(context,color: AppColors.black),),
                    SizedBox(height: size*0.03,),
                    CustomTextField(
                      hint: "Name",
                      icon: Icons.location_on,
                      controller: loginController.fullNameController,
                      // fillColor: AppColors.white,
                      // borderColor: AppColors.grey,
                    ),
                    SizedBox(height: size*0.03,),
                    CustomTextField(
                      hint: "Date of Birth",
                      controller: loginController.dobController,
                      // fillColor: AppColors.white,
                      // borderColor: AppColors.grey,
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
                      hint: "Clinic Name",
                      icon: Icons.location_on,
                      controller: loginController.typeNameController,
                      // fillColor: AppColors.white,
                      // borderColor: AppColors.grey,
                    ),
                    SizedBox(height: size*0.03,),

                    // CustomTextField(
                    //   hint: "Clinic Description",
                    //   icon: Icons.location_on,
                    //   controller: loginController.descriptionController,maxLines: 4,
                    //   // fillColor: AppColors.white,
                    //   // borderColor: AppColors.grey,
                    // ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),),
                          height: size*0.4,
                          width: double.infinity,
                          child: QuillSimpleToolbar(
                            controller: _controller,
                            config: QuillSimpleToolbarConfig(
                              // embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                              embedButtons: [],
                              showBackgroundColorButton: false,
                            ),
                          ),
                        ),
                        Container(
                          height: size*0.5,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),),
                          child: QuillEditor(
                            controller: _controller,
                            scrollController: _scrollController,
                            focusNode: _focusNode,
                            config: QuillEditorConfig(
                              placeholder: "Enter  description...",
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size*0.03,),
                    if(branchId!="0")
                    CustomTextField(
                      hint: "Email",
                      icon: Icons.location_on,
                      controller: loginController.emailController,readOnly: true,
                      // fillColor: AppColors.white,
                      // borderColor: AppColors.grey,
                    ),
                    SizedBox(height: size*0.03,),
                    CustomTextField(
                      hint: "Mobile Number",
                      icon: Icons.location_on,
                      controller: loginController.mobileController,
                      // fillColor: AppColors.white,
                      // borderColor: AppColors.grey,
                      maxLength: 10,
                    ),
                    SizedBox(height: size*0.03,),

                    CustomTextField(
                      hint: "Google map Link",
                      icon: Icons.location_on,
                      controller: loginController.locationController,
                      // fillColor: AppColors.white,
                      // borderColor: AppColors.grey,
                    ),
                    SizedBox(height: size*0.03,),
                    CustomTextField(
                      hint: "Website Link",
                      icon: Icons.web,
                      controller: loginController.websiteController,
                      // fillColor: AppColors.white,
                      // borderColor: AppColors.grey,
                    ),
                     SizedBox(height: size*0.03,),

                    // CustomTextField(
                    //   hint: "Area",
                    //   icon: Icons.location_on,
                    //   controller: loginController.areaController,
                    //   // fillColor: AppColors.white,
                    //   // borderColor: AppColors.grey,
                    // ),
                    // SizedBox(height: size * 0.03),
               //if(Api.userInfo.read('userType')=="admin" || Api.userInfo.read('userType')=="superAdmin")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: CountryStateCityPicker(
                  //       country: countryCont,
                  //       state: stateCont,
                  //       city: cityCont,
                  //       dialogColor: Colors.grey.shade200,
                  //       textFieldDecoration: const InputDecoration(
                  //           suffixIcon: Icon(Icons.arrow_drop_down_outlined),
                  //           border: OutlineInputBorder())),
                  // ),
                  GetBuilder<LoginController>(
                    builder: (controller) {
                      final items = controller.states.map((v) => v.toString()).toList();
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
                        initialItem: items.contains(controller.selectedState) ? controller.selectedState : null,
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
                      final items = controller.districts.map((v) => v.toString()).toList();
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
                            controller.villages.clear();
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
                        final items = controller.talukas.map((v) => v.toString()).toList();
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
                                loginController.villages.clear();
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
                  SizedBox(height: size * 0.03),
                    CustomTextField(
                      hint: "PinCode",
                      icon: Icons.pin,
                      controller: loginController.pinCodeController,
                      keyboardType: TextInputType.number,
                      // fillColor: AppColors.white,
                      // borderColor: AppColors.grey,
                    ),
                    ]),
                    SizedBox(height: size * 0.02),
             if (Api.userInfo.read('userType') != 'superAdmin' && Api.userInfo.read('userType') != 'admin')
               GetBuilder<LoginController>(
                   builder: (controller) {
                   return Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                    Text("Images", style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,)),
                    SizedBox(
                      height: size * 0.35,
                      child: GetBuilder<LoginController>(
                        builder: (controller) {
                          final images = controller.editImages.where((e) => !e.isVideo).toList();
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: loginController.maxFilesImage,
                            itemBuilder: (_, index) {
                              if (index < images.length) {
                                final media = images[index];
                                return buildMediaItem(media, size, () {
                                  controller.editImages.remove(media);
                                  controller.update();
                                },context);
                              }
                              return buildAddButton(() {
                                if(planActive==true&&(loginController.userData.first.details["plan"]?["basePlan"]?["details"]["images"]==true)) {
                                  pickMedia("image", context);
                                }
                                else{
                                  showSuccessDialog(
                                      context,
                                      title: "Alert",
                                      message: "Please activate Base Plan to Edit/Upload Image",
                                      onOkPressed: () {});
                                }

                              }, size);
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "** Maximum ${loginController.maxFilesImage} images allowed",
                        style:AppTextStyles.caption(context,color: Colors.redAccent)
                      ),
                    ),

                    Text("Videos",
                        style: AppTextStyles.caption(context,fontWeight: FontWeight.bold)),
                    if(Api.userInfo.read('userType')!='admin'||Api.userInfo.read('userType')!='superAdmin')

                    SizedBox(
                      height: size * 0.35,
                      child: GetBuilder<LoginController>(
                        builder: (controller) {
                          final videos = controller.editImages
                              .where((e) => e.isVideo)
                              .toList();

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: loginController.maxFilesVideo,
                            itemBuilder: (_, index) {
                              if (index < videos.length) {
                                final media = videos[index];

                                return buildMediaItem(media, size, () {
                                  controller.editImages.remove(media);
                                  controller.update();
                                },context);
                              }

                              return buildAddButton(() {
                                if(planActive==true&&(loginController.userData.first.details["plan"]?["basePlan"]?["details"]["video"]==true)) {
                                  pickMedia("video", context);
                                }
                                else{
                                  showSuccessDialog(
                                      context,
                                      title: "Alert",
                                      message: "Please activate Base Plan to Edit/Upload Video",
                                      onOkPressed: () {
                                        Get.toNamed('/viewPlanPage');
                                      });
                                }
                              }, size);
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: Text(
                        "** Maximum ${loginController.maxFilesVideo} videos allowed",
                          style:AppTextStyles.caption(context,color: Colors.redAccent)

                      ),
                    ),
                       Text('Certificate:',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                       // SizedBox(height: size*0.03,),

                      // SizedBox(height: size*0.02,),
                                       SizedBox(
                                         height: size * 0.35,
                                         child: ListView.builder(
                       scrollDirection: Axis.horizontal,
                       itemCount: 3,
                       itemBuilder: (_, index) {
                         if (index < loginController.editCertificates.length) {
                           final cert = loginController.editCertificates[index];
                           return Container(
                             margin: const EdgeInsets.all(8),
                             width: size * 0.3,
                             height: size * 0.3,
                             child: Stack(
                               children: [
                                 ClipRRect(
                                   borderRadius: BorderRadius.circular(10),
                                   child: _buildCertificatePreview(cert, size),
                                 ),
                                 Positioned(
                                   right: 0,
                                   top: 0,
                                   child: GestureDetector(
                                     onTap: () {
                                       // confirmRemoveImage(context, index, () {
                                       //   loginController.editCertificates.removeAt(index);
                                       //   final certToDelete = loginController.editCertificates[index];
                                       //   loginController.deleteAwsFile(certToDelete.url.toString(), context);
                                       //   print('deleteFile ${certToDelete.url}');
                                       //   loginController.update();
                                       //   Get.back();
                                       // });
                                       confirmRemoveImage(context, index, () async {
                                         final certToDelete = loginController.editCertificates[index];
                                         if (certToDelete.url != null) {
                                           await loginController.deleteAwsFile(certToDelete.url.toString(),'user', context);
                                           print('deleteFile ${certToDelete.url}');
                                         }
                                         loginController.editCertificates.removeAt(index);
                                         loginController.editCertificates.forEach((img) {
                                           print('after delete URL: ${img.url}');
                                         });
                                         loginController.update();
                                         Get.back();
                                       });
                                       },
                                     child:  Icon(Icons.cancel,size: size*0.06, color: Colors.white),
                                   ),
                                 ),
                                 Positioned(
                                   right: 5,
                                   bottom: 5,
                                   child: Container(
                                     padding: const EdgeInsets.all(4),
                                     decoration: BoxDecoration(
                                       color: Colors.black54,
                                       borderRadius: BorderRadius.circular(8),
                                     ),
                                     child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                   ),
                                 ),
                               ],
                             ),
                           );
                         }
                         return GestureDetector(
                           onTap: () => pickCertificates(),
                           child: Container(
                             margin: const EdgeInsets.all(8),
                             width: size * 0.3,
                             height: size * 0.3,
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(10),
                               border: Border.all(color: Colors.grey),
                               color: Colors.grey.shade200,
                             ),
                             child:  Center(
                               child: Icon(Icons.add, size: size*0.016, color: Colors.grey),
                             ),
                           ),
                         );
                       },
                                         ),
                                       ),

                       Center(child: Text("** maximum 3 images/pdf allowed",  style:AppTextStyles.caption(context,color: Colors.redAccent)
                       )),

                       SizedBox(height: size*0.03,),
                        Text('Upload  Logo Image:',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                        SizedBox(height: size*0.03,),

                       SizedBox(
                         height: size * 0.3,
                         width: size * 0.3,
                         child: GetBuilder<LoginController>(
                           builder: (controller) {
                             if (controller.logoImages.isNotEmpty) {
                               final File file = controller.logoImages.first;
                               return _buildSingleImageWidget1(file: file);
                             }
                             if (controller.logoImage.isNotEmpty) {
                               final  img = controller.logoImage.first;
                               //final AppImage img = controller.logoImage.first;
                               return _buildSingleImageWidget1(url: img);
                             }
                             return GestureDetector(
                               onTap: () => pickSingleImage1(),
                               child: Container(
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(10),
                                   border: Border.all(color: Colors.grey),
                                   color: Colors.grey.shade200,
                                 ),
                                 child:  Center(
                                   child: Icon(Icons.add, size: size*0.016, color: Colors.grey),
                                 ),
                               ),
                             );
                           },
                         ),
                       )
                        ]);
                 }
               ),
                    SizedBox(height: size*0.06,),
                    Center(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                            onPressed: ()async
                        {
                          if (_formKeyEditProfile.currentState!.validate()) {
                            final position = await LocationService.getCurrentLocation();
                            if (position == null) {
                              showCustomToast(context,"Please enable location");
                              return;
                            }
                            loginController.latitude = position.latitude;
                            loginController.longitude = position.longitude;
                            print('lat:${position.latitude} lon:${position.longitude}');
                            print("FULL NAME = ${loginController.fullNameController.text}");
                            print("type NAME = ${loginController.typeNameController.text}");
                            print("MOBILE = ${loginController.mobileController.text}");
                            print("EMAIL = ${loginController.emailController.text}");
                            print("ADDRESS = ${loginController.addressController.text}");
                            print("STATE = ${loginController.stateController.text}");
                            print("DISTRICT = ${loginController.districtController.text}");
                            print("CITY = ${loginController.cityController.text}");
                            print("PINCODE = ${loginController.pinCodeController.text}");
                            print("LAB NAME = ${loginController.typeNameController.text}");
                            print("IMAGES = ${loginController.images}");
                            print("CERTIFICATES = ${loginController.certificates}");
                            print('userid${ loginController.selectUserId }');
                            print('services name${loginController.servicesOfferedController.text}');
                            print('website${loginController.websiteController.text}');
                            print('google location${loginController.locationController.text}');
                            print('lat${loginController.latitude}lon${loginController.longitude}');
                            final descriptionAbout =
                            jsonEncode(_controller.document.toDelta().toJson());

                            List<File> fileImages = loginController.editImages
                                .where((img) => img.file != null)
                                .map((img) => img.file!)
                                .toList();
                            List<File> fileCertificate = loginController.editCertificates
                                .where((img) => img.file != null)
                                .map((img) => img.file!)
                                .toList();
                            final oldImageUrls = loginController.editImages
                                .where((e) => e.url != null)
                                .map((e) => e.url!)
                                .toList();

                            final oldCertificateUrls = loginController.editCertificates
                                .where((e) => e.url != null)
                                .map((e) => e.url!)
                                .toList();


                            print('fileCertificate count: ${fileCertificate.length}');
                            for (final img in fileCertificate) {
                              debugPrint('before upload Certificate path: ${img.path}');
                            }
                            Future<List<Uint8List>> convertFilesToBytes(List<File> files) async {
                              return await Future.wait(files.map((file) => file.readAsBytes()));
                            }
                            final imageBytes = loginController.selectedUserType == "Job Seekers"
                                ? await convertFilesToBytes(controller.logoImages)
                                : await convertFilesToBytes(loginController.images);

                            final logoBytes = loginController.selectedUserType != "Job Seekers"
                                ? await convertFilesToBytes(controller.logoImages)
                                : [];

                            final certBytes = await convertFilesToBytes(loginController.certificates);
                             print('branch id${branchId?.isNotEmpty == true
                                 ? branchId!
                                 : loginController.selectUserId!}');
                            await loginController.registerUser(
                              userId: branchId?.isNotEmpty == true ? branchId! : loginController.selectUserId!,
                              userType: branchId=="0"?Api.userInfo.read('userType'):loginController.selectedUserType!,
                              fullName: loginController.fullNameController.text,
                              martialStatus:loginController.selectedMartialStatus!,
                              dob:loginController.dobController.text,
                              mobile: loginController.mobileController.text,
                              email:branchId=="0"?Api.userInfo.read('email'): loginController.emailController.text,
                              // address: loginController.addressController.text,
                              confirmPassword: branchId=="0"?Api.userInfo.read('password'):loginController.confirmPasswordController.text,
                              taluk: loginController.selectedState ?? '',
                              district: loginController.selectedDistrict ?? '',
                              city: loginController.selectedTaluka ?? '',
                              area: loginController.selectedVillage ?? '',
                              pinCode: loginController.pinCodeController.text,
                              typeName: loginController.typeNameController.text,
                              image: imageBytes,
                              //fileImages,
                              certificate: certBytes,
                              //fileCertificate,
                              logoImage:logoBytes,
                              //controller.logoImages ?? [],
                              oldImageUrl:oldImageUrls ,
                              oldCertificatesUrl: oldCertificateUrls,
                              description: descriptionAbout,
                              //loginController.descriptionController.text,
                              // services: loginController.servicesOfferedController.text,
                              location: loginController.locationController.text,
                              website: loginController.websiteController.text,
                                          adminId:branchId=="0"?Api.userInfo.read('userId'):loginController.selectUserId! ,
                                          isAdmin: branchId=="0"?"true":"false",
                                          latitude: loginController.latitude.toString()??"",
                                          longitude: loginController.longitude.toString()??"",
                              // specialisation: loginController.specialisationController.text,
                              context: context,
                            );
                          }
                        },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: AppColors.transparent,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),),
                              child: Text(
                                'Update',style: AppTextStyles.body(context,color: AppColors.white,fontWeight: FontWeight.bold),)

                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
    Map<String, int> getPlanLimits() {
      if (loginController.userData.isEmpty) {
        loginController.maxFilesImage = 2;
        loginController.maxFilesVideo = 1;
        loginController.filesImageSize = 0;
        loginController.filesVideoSize = 0;

        loginController.update();
        return {};
      }

      final userData = loginController.userData.first;

      final planDetails =
      userData.details?["plan"]?["basePlan"]?["details"];

      loginController.maxFilesImage =
          int.tryParse(planDetails?["imageCount"]?.toString() ?? "2") ?? 2;

      loginController.maxFilesVideo =
          int.tryParse(planDetails?["videoCount"]?.toString() ?? "1") ?? 1;

      loginController.filesImageSize =
          int.tryParse(planDetails?["imageSize"]?.toString() ?? "0") ?? 0;

      loginController.filesVideoSize =
          int.tryParse(planDetails?["videoSize"]?.toString() ?? "0") ?? 0;

      loginController.update();

      print('Max Images: ${loginController.maxFilesImage}');
      print('Max Videos: ${loginController.maxFilesVideo}');

      return {};
    }
    Future<void> pickMedia(String source,BuildContext context) async {
      try {

        if (source == null) return;
        final imageCount =
            loginController.editImages.where((e) => !e.isVideo).length;
        final videoCount =
            loginController.editImages.where((e) => e.isVideo).length;
        if (source == "image" && imageCount >= loginController.maxFilesImage) {
          showCustomToast(context,"Maximum ${loginController.maxFilesImage} images allowed",);
          //Get.snackbar("Error", "Maximum ${loginController.maxFilesImage} images allowed");
          return;
        }
        if (source == "video" && videoCount >= loginController.maxFilesVideo) {
          showCustomToast(context,"Maximum ${loginController.maxFilesVideo} videos allowed",);
          return;
        }
        XFile? pickedFile;
        if (source == "image") {
          pickedFile = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
          );
        } else {
          pickedFile = await _picker.pickVideo(
            source: ImageSource.gallery,
          );
        }

        if (pickedFile == null) return;

        File selectedFile = File(pickedFile.path);
        bool isVideo = source == "video";

        Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,);
        if (isVideo) {
          final compressed = await VideoCompress.compressVideo(
            pickedFile.path,
            quality: VideoQuality.MediumQuality,
          );

          if (compressed?.file != null) {
            selectedFile = compressed!.file!;
          }
        }

        int bytes = await selectedFile.length();
        double mb = bytes / (1024 * 1024);

        print("Final File Size: ${mb.toStringAsFixed(2)} MB");
        if (!isVideo && mb > loginController.filesImageSize) {
          Get.back();
          showCustomToast(context,"Image must be less than ${loginController.filesImageSize}MB",);
          return;
        }
        if (mb > loginController.filesVideoSize) {
          Get.back();
          showCustomToast(context,"File must be less than ${loginController.filesVideoSize}MB",);
          return;
        }
        loginController.editImages.add(
          AppImage(
            file: selectedFile,
            isVideo: isVideo,
          ),
        );

        loginController.update();

        Get.back();
      } catch (e) {
        if (Get.isDialogOpen ?? false) Get.back();
        print("Pick media error: $e");
        Get.snackbar("Error", "Failed to pick media");
      }
    }
}
String getCertificateFileName(cert) {
  if (cert.file != null) {
    // Use the local file path
    return path.basename(cert.file!.path);
  } else if (cert.url != null && cert.url!.isNotEmpty) {
    // Use the network URL
    return path.basename(cert.url!);
  } else {
    return "Unknown file";
  }
}
Widget _buildCertificatePreview(cert, double size) {
  String fileName = getCertificateFileName(cert);

  if (cert.file != null) {
    final filePath = cert.file!.path.toLowerCase();
    if (filePath.endsWith(".pdf")) {
      return _pdfPlaceholder(size, fileName);
    }
    return Image.file(cert.file!, fit: BoxFit.cover,

      width: size * 0.3,
      height: size * 0.3,);
  }

  if (cert.url != null && cert.url!.isNotEmpty) {
    final url = cert.url!.toLowerCase();
    if (url.endsWith(".pdf")) {
      return _pdfPlaceholder(size, fileName);
    }
    return Image.network(cert.url!, fit: BoxFit.cover, width: size * 0.3,
      height: size * 0.3,);
  }

  return _errorPlaceholder(size);
}
Widget _pdfPlaceholder(double size, String fileName) {
  return Container(
    color: Colors.grey.shade300,
    width: size * 0.3,
    height: size * 0.3,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Icon(Icons.picture_as_pdf, color: Colors.red, size: size*0.15),
        const SizedBox(height: 4),
        Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:  TextStyle(fontSize: size*0.012,fontWeight: FontWeight.normal,color: AppColors.black),
        ),
      ],
    ),
  );
}
Widget _errorPlaceholder(double size) {
  return Container(
    color: Colors.grey.shade200,
    width: size * 0.15,
    height: size * 0.15,
    child:  Center(
      child: Icon(Icons.broken_image, size: size*0.015, color: Colors.grey),
    ),
  );
}

Widget buildMediaItem(AppImage media, double size, VoidCallback onDelete, BuildContext context) {
  Widget content;

  if (media.isVideo) {
    content = Container(
      height: size * 0.15,
      width: size * 0.15,
      color: Colors.black12,
      child: const Center(child: Icon(Icons.play_circle_fill)),
    );
  }

  else if (media.bytes != null) {
    content = Image.memory(
      media.bytes!,
      height: size * 0.15,
      width: size * 0.15,
      fit: BoxFit.cover,
    );
  }

  else if (media.file != null) {
    content = Image.file(
      media.file!,
      height: size * 0.15,
      width: size * 0.15,
      fit: BoxFit.cover,
    );
  }

  else if (media.url != null && media.url!.isNotEmpty) {
    content = Image.network(media.url!,
      height: size * 0.15,
      width: size * 0.15,
      fit: BoxFit.cover,);
  }

  else {
    content = const Icon(Icons.broken_image);
  }

  return Stack(
    children: [
      ClipRRect(borderRadius: BorderRadius.circular(10), child: content),
      Positioned(
        right: 0,
        child: GestureDetector(
          onTap: onDelete,
          child: const Icon(Icons.cancel, color: Colors.red),
        ),
      )
    ],
  );
}
// Widget buildMediaItem(AppImage media, double size, VoidCallback onDelete,BuildContext context) {
//   double s=MediaQuery.of(context).size.width;
//   return Container(
//     margin: const EdgeInsets.all(8),
//     height: size * 0.15,
//     width: size * 0.15,
//     child: Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: MediaPreviewWidget(
//             media: media,
//             size: s * 0.15,
//           ),
//         ),
//         Positioned(
//           right: 0,
//           top: 0,
//           child: GestureDetector(
//             onTap: onDelete,
//             child:  Icon(Icons.cancel,size: size*0.0016, color: Colors.black),
//           ),
//         ),
//       ],
//     ),
//   );
// }


Widget buildAddButton(VoidCallback onTap, double size) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin:  EdgeInsets.all(8),
      width: size * 0.15,
      height: size * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
        color: Colors.grey.shade200,
      ),
      child:  Center(
        child: Icon(Icons.add, size: size*0.016, color: Colors.grey),
      ),
    ),
  );
}
// class MediaPreviewWidget extends StatefulWidget {
//   final AppImage media;
//   final double size;
//
//   const MediaPreviewWidget({super.key, required this.media, required this.size});
//
//   @override
//   State<MediaPreviewWidget> createState() => _MediaPreviewWidgetState();
// }
//
// class _MediaPreviewWidgetState extends State<MediaPreviewWidget> {
//   String? thumbnailPath;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.media.isVideo && widget.media.file != null) {
//       generateThumbnail();
//     }
//   }
//
//   Future<void> generateThumbnail() async {
//     final thumb = await VideoThumbnail.thumbnailFile(
//       video: widget.media.file!.path,
//       imageFormat: ImageFormat.JPEG,
//       maxWidth: 300,
//       quality: 75,
//     );
//     setState(() {
//       thumbnailPath = thumb;
//     });
//   }
//
//   // void _openMedia() {
//   //   if (widget.media.isVideo) {
//   //     print('vedeo file${widget.media}');
//   //     Get.to(() => VideoPlayerScreen(media: widget.media));
//   //   } else {
//   //
//   //     Get.toNamed('/viewImagePage',arguments: {'url': widget.media.url, 'file': widget.media.file});
//   //    // Get.to(() => ViewImage(url: widget.media.url, file: widget.media.file));
//   //   }
//   // }
//   void _openMedia() {
//     print("Tapped media: isVideo=${widget.media.isVideo}, file=${widget.media.file}, url=${widget.media.url}");
//     if (widget.media.isVideo) {
//       if (widget.media.file != null || (widget.media.url != null && widget.media.url!.isNotEmpty)) {
//         Get.to(() => VideoPlayerScreen(media: widget.media));
//       } else {
//         Get.snackbar("Error", "Video not available");
//       }
//     } else {
//       Get.toNamed('/viewImagePage', arguments: {'url': widget.media.url, 'file': widget.media.file});
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _openMedia,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: widget.media.isVideo
//             ? Stack(
//           children: [
//             thumbnailPath == null
//                 ? Container(
//               width: widget.size,
//               height: widget.size,
//               color: Colors.black12,
//               child: const Center(child: CircularProgressIndicator()),
//             )
//                 : Image.file(
//               File(thumbnailPath!),
//               width: widget.size,
//               height: widget.size,
//               fit: BoxFit.cover,
//             ),
//             const Positioned.fill(
//               child: Center(
//                 child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
//               ),
//             ),
//           ],
//         )
//             : widget.media.file != null
//             ? Image.file(
//           widget.media.file!,
//           width: widget.size,
//           height: widget.size,
//           fit: BoxFit.cover,
//         )
//             : Image.network(
//           widget.media.url ?? "",
//           width: widget.size,
//           height: widget.size,
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// }
class MediaPreviewWidget extends StatefulWidget {
  final AppImage media;
  final double size;

  const MediaPreviewWidget({
    super.key,
    required this.media,
    required this.size,
  });

  @override
  State<MediaPreviewWidget> createState() => _MediaPreviewWidgetState();
}

class _MediaPreviewWidgetState extends State<MediaPreviewWidget> {
  Uint8List? thumbnailBytes;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  void _generateThumbnail() async {
    if (!widget.media.isVideo) return;

    try {
      if (widget.media.file == null) return;

      final bytes = await VideoThumbnail.thumbnailData(
        video: widget.media.file!.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      );

      if (mounted) {
        setState(() {
          thumbnailBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Thumbnail error: $e");
    }
  }

  void _open() {
    Get.toNamed('/viewImagePage', arguments: {
      'url': widget.media.url,
      'file': widget.media.file,
      'bytes': widget.media.bytes,
      'isVideo': widget.media.isVideo,
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (widget.media.isVideo) {
      child = Stack(
        children: [
          if (thumbnailBytes != null)
            Image.memory(
              thumbnailBytes!,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
            )
          else
            Container(
              width: widget.size,
              height: widget.size,
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),

          const Positioned.fill(
            child: Center(
              child: Icon(Icons.play_circle_fill,
                  color: Colors.white, size: 40),
            ),
          ),
        ],
      );
    }

    else if (kIsWeb && widget.media.bytes != null) {
      child = Image.memory(
        widget.media.bytes!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
      );
    }

    else if (!kIsWeb && widget.media.file != null) {
      child = Image.file(
        widget.media.file!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
      );
    }

    else if (widget.media.url != null && widget.media.url!.isNotEmpty) {
      child = Image.network(
        widget.media.url!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
      );
    }

    else {
      child = Container(
        width: widget.size,
        height: widget.size,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported),
      );
    }

    return GestureDetector(
      onTap: _open,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: child,
      ),
    );
  }
}
