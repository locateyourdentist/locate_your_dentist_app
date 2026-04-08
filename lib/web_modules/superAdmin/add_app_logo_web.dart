import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../common_widgets/color_code.dart';
import '../../../common_widgets/common_textstyles.dart';
import '../../../modules/auth/login_screen/login_controller.dart';

class ChangeAppLogoWeb extends StatefulWidget {
  const ChangeAppLogoWeb({super.key});

  @override
  State<ChangeAppLogoWeb> createState() => _ChangeAppLogoWebState();
}

class _ChangeAppLogoWebState extends State<ChangeAppLogoWeb> {
  final LoginController loginController = Get.find();
  final ImagePicker picker = ImagePicker();
  Uint8List? webImage;
  // Future<void> pickImage() async {
  //   final XFile? pickedImage =
  //   await picker.pickImage(source: ImageSource.gallery);
  //
  //   if (pickedImage != null) {
  //     if (kIsWeb) {
  //       webImage = await pickedImage.readAsBytes();
  //       loginController.appLogoFile = File(pickedImage.path);
  //       print('dfdgfgfdg${loginController.appLogoFile}');
  //     } else {
  //       loginController.appLogoFile = File(pickedImage.path);
  //       print('dfdgfgfdg${loginController.appLogoFile}');
  //     }
  //
  //     loginController.update();
  //   }
  // }
  Future<void> pickImage() async {
    final XFile? pickedImage =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      if (kIsWeb) {
        Uint8List bytes = await pickedImage.readAsBytes();
        webImage = bytes;
        String fileName = pickedImage.name;
        print('Web image selected: ${fileName}');
      } else {
        loginController.appLogoFile = File(pickedImage.path);
        print('Mobile image path: ${loginController.appLogoFile}');
      }
      loginController.update();
    }
  }
  void removeLogo() {
    loginController.deleteAwsFile(
        loginController.appLogoUrl.toString(), 'appLogo', context);
    loginController.appLogoFile = null;
    loginController.appLogoUrl = null;
    webImage = null; // clear web image
    loginController.update();
  }

  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }
  Widget uploadPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
        SizedBox(height: 10),
        Text("Click to upload logo"),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    double s=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: GetBuilder<LoginController>(
            builder: (controller) {
              return Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    /// TITLE
                    Text(
                      "Upload App Logo",
                      style: AppTextStyles.body(
                        context,
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// IMAGE PREVIEW
                    // GestureDetector(
                    //   onTap: pickImage,
                    //   child: Container(
                    //     height: 220,
                    //     width: 220,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(16),
                    //       border: Border.all(
                    //           color: Colors.grey.shade300, width: 2),
                    //     ),
                    //     child: controller.appLogoFile != null
                    //         ? ClipRRect(
                    //       borderRadius: BorderRadius.circular(14),
                    //       child: kIsWeb
                    //     ? webImage != null
                    //     ? Image.memory(
                    //       webImage!,
                    //       fit: BoxFit.cover,
                    //     )
                    //         : controller.appLogoUrl != null
                    //         ? Image.network(controller.appLogoUrl!)
                    //         : uploadPlaceholder()
                    //         : controller.appLogoFile != null
                    //   ? Image.file(
                    //     controller.appLogoFile!,
                    //     fit: BoxFit.cover,
                    //   )
                    //         : controller.appLogoUrl != null
                    // ? Image.network(controller.appLogoUrl!)
                    //   : uploadPlaceholder(),
                    //       // Image.file(
                    //       //   controller.appLogoFile!,
                    //       //   fit: BoxFit.cover,
                    //       // ),
                    //     )
                    //         : controller.appLogoUrl != null
                    //         ? ClipRRect(
                    //       borderRadius: BorderRadius.circular(14),
                    //       child: Image.network(
                    //         controller.appLogoUrl!,
                    //         fit: BoxFit.cover,
                    //       ),
                    //     )
                    //         : Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: const [
                    //         Icon(Icons.cloud_upload,
                    //             size: 40, color: Colors.grey),
                    //         SizedBox(height: 10),
                    //         Text("Click to upload logo")
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 220,
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: kIsWeb
                              ? webImage != null
                              ? Image.memory(webImage!, fit: BoxFit.cover)
                              : controller.appLogoUrl != null
                              ? Image.network(controller.appLogoUrl!, fit: BoxFit.cover)
                              : uploadPlaceholder()
                              : controller.appLogoFile != null
                              ? Image.file(controller.appLogoFile!, fit: BoxFit.cover)
                              : controller.appLogoUrl != null
                              ? Image.network(controller.appLogoUrl!, fit: BoxFit.cover)
                              : uploadPlaceholder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: pickImage,
                          icon:  Icon(Icons.upload,color: AppColors.white,size: s*0.008,),
                          label:  Text("Upload",style: AppTextStyles.caption(context,color: AppColors.white),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        if (controller.appLogoFile != null ||
                            controller.appLogoUrl != null)
                          ElevatedButton.icon(
                            onPressed: removeLogo,
                            icon:  Icon(Icons.delete,color: AppColors.white,size: s*0.008),
                            label:  Text("Remove",style: AppTextStyles.caption(context,color: AppColors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    SizedBox(
                      width: 200,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          await loginController.addAppLogoImage(webImage!, context);
                          await loginController.getAppLogoImage(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:  Text(
                          "Save Changes",
                          style: AppTextStyles.caption(context,color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}