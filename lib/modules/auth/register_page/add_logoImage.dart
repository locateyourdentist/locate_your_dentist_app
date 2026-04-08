import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import '../../../common_widgets/common_textstyles.dart';

class ChangeAppLogoImage extends StatefulWidget {
  const ChangeAppLogoImage({super.key});

  @override
  State<ChangeAppLogoImage> createState() => _ChangeAppLogoImageState();
}

class _ChangeAppLogoImageState extends State<ChangeAppLogoImage> {
  final ImagePicker _picker = ImagePicker();
  final LoginController loginController = Get.find();
  Uint8List? webImage;

  Future<void> pickSingleImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    //loginController.appLogoFile = null;
    //loginController.appLogoUrl = null;
   await loginController.deleteAwsFile(loginController.appLogoUrl.toString(),'appLogo',context);
    if (pickedImage != null) {
      // File file = File(pickedImage.path);
      // loginController.setAppLogo(file);

      File? pickedImageFile = File(pickedImage.path);
      Uint8List bytes = await pickedImageFile.readAsBytes();
      webImage = bytes;
     // await loginController.addAppLogo(bytes, pickedImageFile.path.split('/').last);
    }
  }

  Widget buildImageWidget({File? file, String? url}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: file != null
              ? Image.file(file,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity)
              : Image.network(
            url ?? '',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        /// Remove Button
        Positioned(
          right: 5,
          top: 5,
          child: GestureDetector(
            onTap: () {
             removeAppLogo();
            },
            child: const CircleAvatar(
              backgroundColor: Colors.black54,
              radius: 14,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),

        /// Edit Button
        Positioned(
          right: 10,
          bottom: 10,
          child: GestureDetector(
            onTap: pickSingleImage,
            child: Container(
              padding: const EdgeInsets.all(6),
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
  void removeAppLogo() {
    //loginController.appLogoFile = null;
   // loginController.appLogoUrl = null;
    print('sdelete${loginController.appLogoUrl.toString()}');
    loginController.deleteAwsFile(loginController.appLogoUrl.toString(),'appLogo',context);
    loginController.update();
  }
  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.white,
        title: Text(
          'Change App Logo',
          style: AppTextStyles.subtitle(context, color: AppColors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// Logo Preview Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "App Logo",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Image Preview
                      GetBuilder<LoginController>(
                          builder: (controller) {
                            return GestureDetector(
                            onTap: pickSingleImage,
                            child: Container(
                              height: size * 0.45,
                              width: size * 0.45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: controller.appLogoFile != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.file(
                                  controller.appLogoFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : controller.appLogoUrl != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  controller.appLogoUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : const Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_outlined,
                                      size: 40, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text(
                                    "Tap to upload logo",
                                    style: TextStyle(
                                        color: Colors.grey),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      ),

                      const SizedBox(height: 15),

                      if (controller.appLogoFile != null ||
                          controller.appLogoUrl != null)
                        TextButton.icon(
                          onPressed: () {
                            removeAppLogo();
                          },
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          label: const Text(
                            "Remove Logo",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),

                const Spacer(),

                /// Save Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async{
                   //   await  loginController.addAppLogoImage(controller.appLogoFile,context) ;
                      await  loginController.addAppLogoImage(webImage!,context) ;

                      await loginController.getAppLogoImage(context);

                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff004958),
                            Color(0xff00A8A8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,color: AppColors.white
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}