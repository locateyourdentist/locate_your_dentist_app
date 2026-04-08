import 'dart:io';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import '../../common_widgets/common_textfield.dart';
import 'package:get/get.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final contactController=Get.put(ContactController());
  final loginController=Get.put(LoginController());
  final args = Get.arguments as Map<String, dynamic>?;
  String receiverUserId = '';
  String senderUserId = '';
  String clinicName = '';
  String mobileNumber = '';
  String email = '';
  String doctorName = '';
  String state = '';
  String district = '';
  String city = '';
  final ImagePicker _picker = ImagePicker();
  final _formKeyContactProfile = GlobalKey<FormState>();
  Future<void> pickImages() async {
    if (loginController.contactImages.length >= 3) {
      Get.snackbar("Error", "Maximum 3 images allowed");
      return;
    }
    try {
      final List<XFile> selected = await _picker.pickMultiImage();
      if (selected != null) {
        int remaining = 3 - loginController.contactImages.length;
        final limited = selected.take(remaining);
        setState(() {
          loginController.contactImages.addAll(
            limited.map((x) => AppImage2(file: File(x.path))),
          );
        });
        if (selected.length > remaining) {
          showCustomToast(context,  "error, Only $remaining more images allowed",);
        }
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }
  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    receiverUserId = args?['receiverUserId'] ?? '';
    senderUserId   = args?['senderUserId'] ?? '';
    clinicName     = args?['clinicName'] ?? '';
    mobileNumber   = args?['mobileNumber'] ?? '';
    print('mobile$mobileNumber');
    print('email$email');
    email          = args?['email'] ?? '';
    doctorName     = args?['doctorName'] ?? '';
    final address = args?['address'] as Map<String, dynamic>? ?? {};
    city     = address['city'] ?? '';
    district = address['district'] ?? '';
    state    = address['state'] ?? '';
    contactController.doctorNameController.text = doctorName;
    contactController.contactClinicNameController.text = clinicName;
    contactController.clinicAddressController.text = "$state, $district, $city";
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,iconTheme: IconThemeData(color: AppColors.white,size: size*0.05),
        backgroundColor: AppColors.white,flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary,AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
        //title: Text('Contact Form',style: AppTextStyles.subtitle(context,color: AppColors.white),),
      ),
      body: GetBuilder<LoginController>(
          builder: (controller) {
            return Form(
              key: _formKeyContactProfile,
              child: SingleChildScrollView(
                child: Padding(
                  padding:  const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact Form',style: AppTextStyles.subtitle(context,),),
                      SizedBox(height: size*0.02,),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonContactContainer(icons: Icons.call,onTap: (){
                              launchCall(mobileNumber);
                            },title: 'Call Us',),
                            CommonContactContainer(icons: Icons.email,onTap: (){
                              //_launch('contact@catchytechnologies.com');
                            },title: 'Email Us',),
                            CommonContactContainer(icons: Icons.search,onTap: (){},title: 'Search FAQs',),
                          ]),
                      SizedBox(height: size*0.04,),

                      CustomTextField(
                        hint: "Doctor Name",
                        controller: contactController.doctorNameController,
                        borderColor: AppColors.grey,
                        fillColor: AppColors.white,readOnly: true,
                      ),
                      SizedBox(height: size*0.04,),

                      CustomTextField(
                        hint: "Clinic Name",
                        controller: contactController.contactClinicNameController,borderColor: AppColors.grey,
                        fillColor: AppColors.white,readOnly: true,
                      ),
                      SizedBox(height: size*0.04,),

                      CustomTextField(
                        hint: "Clinic Address",
                        controller:  contactController.clinicAddressController,
                        borderColor: AppColors.grey,readOnly: true,
                        fillColor: AppColors.white,
                      ),
                      SizedBox(height: size*0.04,),

                      CustomTextField(
                        hint: "Details on material requirement",
                        controller: contactController.contactDetailsController,
                        borderColor: AppColors.grey,
                        fillColor: AppColors.white,maxLines: 4,
                      ),
                      SizedBox(height: size*0.04,),
                      Text('upload image',style: AppTextStyles.body(context,fontWeight: FontWeight.bold),),
                      SizedBox(
                        height: size * 0.35,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (_, index) {
                            if (index < loginController.contactImages.length) {
                              final img = loginController.contactImages[index];
                              return Container(
                                margin: const EdgeInsets.all(8),
                                width: size * 0.3,
                                height: size * 0.3,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: img.file != null
                                          ? Image.file(
                                        img.file!,
                                        fit: BoxFit.cover,
                                        width: size * 0.3,
                                        height: size * 0.3,
                                      )
                                          : Image.network(
                                        img.url!,
                                        fit: BoxFit.cover,
                                        width: size * 0.3,
                                        height: size * 0.3,
                                      ),
                                    ),

                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          confirmRemoveImage(context, index, () {
                                            loginController.editImages.removeAt(index);
                                            loginController.update();
                                            Navigator.of(context).pop();
                                          });
                                        },
                                        child: const Icon(Icons.cancel, color: Colors.white),
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
                              onTap: () => pickImages(),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                width: size * 0.3,
                                height: size * 0.3,
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

                      Center(child: Text("** maximum 3 images allowed",style: TextStyle(color: Colors.redAccent,fontSize: size*0.019,fontWeight: FontWeight.normal),)),
                      const SizedBox(height: 10,),

                      Center(
                        child: Container(
                          width: size*0.5,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  onPressed: () {
                                if (_formKeyContactProfile.currentState!
                                    .validate()) {
                                  List<File> fileImages = loginController.contactImages
                                      .where((img) => img.file != null)
                                      .map((img) => img.file!)
                                      .toList();
                                  contactController.postContactDetail(
                                      senderUserId.toString() ?? "",
                                      receiverUserId.toString() ?? "",
                                      email.toString() ?? "",
                                      mobileNumber.toString(),
                                      contactController.contactClinicNameController.text,
                                      contactController.doctorNameController.text,
                                      contactController.contactDetailsController.text.toString(),
                                      state,
                                      district,
                                      city,
                                      fileImages.isNotEmpty ? fileImages : null,
                                      context);
                                }
                              },
                              child: Text('Submit',style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),
                      const SizedBox(height: 20,),
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
}
