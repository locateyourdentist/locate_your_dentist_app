import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/crop_screen.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../common_widgets/color_code.dart';
import '../../common_widgets/common_textstyles.dart';
import 'package:image_picker/image_picker.dart';

class UploadImagesWeb extends StatefulWidget {
  const UploadImagesWeb({super.key});
  @override
  State<UploadImagesWeb> createState() => _UploadImagesWebState();
}
class _UploadImagesWebState extends State<UploadImagesWeb> {
  final PlanController planController = Get.put(PlanController());
  final LoginController loginController=Get.put(LoginController());
  final List<String> userTypes = const [
    "Dental Clinic",
    "Dental Lab",
    "Dental Shop",
    "Dental Mechanic",
    "Dental Consultant",
    "Job Seekers"
  ];
  final ImagePicker picker = ImagePicker();
  int? editingIndex;
  String ? startDate;
  String ? endDate;

  List<Uint8List> images = [];
  // Future<void> pickImages() async {
  //   final List<XFile>? picked = await picker.pickMultiImage();
  //   if (picked == null) return;
  //   if (kIsWeb) {
  //     for (var file in picked) {
  //       final bytes = await file.readAsBytes();
  //       final appImage2 = AppImage2(bytes: bytes, isActive: true);
  //
  //       setState(() {
  //         planController.editUploadImage1.add(appImage2);
  //       });
  //     }
  //   }
  //   planController.update();
  // }
  // Future<void> pickImages() async {
  //   final List<XFile>? picked = await picker.pickMultiImage();
  //   if (picked == null) return;
  //
  //   for (var file in picked) {
  //     Uint8List? finalBytes;
  //
  //     if (kIsWeb) {
  //       finalBytes = await file.readAsBytes();
  //     } else {
  //       final cropped = await ImageCropper().cropImage(
  //         sourcePath: file.path,
  //         compressQuality: 80,
  //         uiSettings: [
  //           AndroidUiSettings(
  //             toolbarTitle: 'Crop Image',
  //             toolbarColor: Colors.blue,
  //             toolbarWidgetColor: Colors.white,
  //             lockAspectRatio: false,
  //           ),
  //           IOSUiSettings(
  //             title: 'Crop Image',
  //           ),
  //         ],
  //       );
  //
  //       if (cropped == null) continue;
  //
  //       finalBytes = await cropped.readAsBytes();
  //     }
  //
  //     final appImage2 = AppImage2(
  //       bytes: finalBytes,
  //       isActive: true,
  //     );
  //
  //     setState(() {
  //       planController.editUploadImage1.add(appImage2);
  //     });
  //   }
  //
  //   planController.update();
  // }

  Future<void> pickImages(BuildContext context) async {
    final List<XFile>? pickedImages = await picker.pickMultiImage();

    if (pickedImages == null || pickedImages.isEmpty) return;

    for (var file in pickedImages) {
      final bytes = await file.readAsBytes();

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CropScreen(imageBytes: bytes),
        ),
      );

      if (result == null) continue;
      final Uint8List croppedBytes = result;

      final appImage2 = AppImage2(
        bytes: croppedBytes,
        isActive: true,
      );

      planController.editUploadImage1.add(appImage2);
    }

    planController.update();
  }
  Map<String, String> calculatePlanDates(String durationStr) {
    int duration = int.tryParse(durationStr) ?? 0;
    DateTime start = DateTime.now();
    DateTime end = start.add(Duration(days: duration));
    return {
      "startDate": "${start.day}-${start.month}-${start.year}",
      "endDate": "${end.day}-${end.month}-${end.year}",
    };
  }
  DateTime parseDate(String date) {
    final parts = date.split("-");
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }
  int calculateDuration(String start, String end) {
    final startDate = parseDate(start);
    final endDate = parseDate(end);
    return endDate.difference(startDate).inDays;
  }

  @override
  void initState() {
    super.initState();
    String userType=  Api.userInfo.read('userType')??"";
    planController.selectedUserType="Dental Clinic";
    planController.getUploadImages(userId:userType=='superAdmin'?"":Api.userInfo.read('userId')??"",userType: planController.selectedUserType!,context: context);
    planController.checkPlansStatus(Api.userInfo.read('userId')??"",context);
    planController.getPostImagePlanList( planController.selectedUserType.toString(),context);
  }
  Future<void> _refresh() async {
    planController.selectedUserType=null;
    Api.userInfo.read('userType')=='superAdmin'? planController.getUploadImages(userType: Api.userInfo.read('userType')??"",context: context):
    planController.getUploadImages(userId:Api.userInfo.read('userId')??"",userType: Api.userInfo.read('userType')??"", context: context);
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    String userType=  Api.userInfo.read('userType')??"";
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LYD",
        onLogout: () {
        },
        onNotification: () {
        },
      ),
      body: GetBuilder<PlanController>(
        builder: (controller) {

          return RefreshIndicator(
            onRefresh:_refresh ,
            child: Row(
              children: [
                const AdminSideBar(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1300),
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
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if(userType=='superAdmin')
                                    Row(
                                      children: [
                                        Text(
                                          "Select User Type",
                                          style: AppTextStyles.caption(
                                            context,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: size * 0.35,
                                          child: GetBuilder<PlanController>(
                                              builder: (controller) {
                                                return CustomDropdownField(
                                                  hint: "Select User Type",
                                                  borderColor: AppColors.grey,
                                                  fillColor: AppColors.white,
                                                  items: userTypes,
                                                  selectedValue: controller.selectedUserType,
                                                  onChanged: (value)async {
                                                    controller.selectedUserType = value;
                                                    await planController.getUploadImages(userType:controller.selectedUserType!,context: context);
                                                    await  planController.getPostImagePlanList(controller.selectedUserType!,context);
                                                    planController.update();
                                                  },
                                                );
                                              }
                                          ),
                                        ),
                                      ],
                                    ),
                                  SizedBox(height: size*0.03),
                                  Center(
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 1200),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Manage Uploads",
                                                style: AppTextStyles.subtitle(context),
                                              ),
                                              ElevatedButton.icon(
                                                onPressed:() {
                                                  pickImages(context);
                                                },
                                                icon: const Icon(Icons.add),
                                                label: const Text("Upload Images"),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 20, vertical: 15),
                                                ),
                                              )
                                            ],
                                          ),

                                          const SizedBox(height: 20),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            //itemCount: controller.editUploadImage1.length,
                                              itemCount: controller.editUploadImage1.isNotEmpty
                                                  ? controller.editUploadImage1.length
                                                  : 0,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 20,
                                              mainAxisSpacing: 20,
                                              childAspectRatio: 1.2,
                                            ),
                                              itemBuilder: (_, index) {
                                                if (index >= controller.editUploadImage1.length) {
                                                  return const SizedBox();
                                                }

                                                final image = controller.editUploadImage1[index];
                                                Map<String, dynamic>? getSafePosterPlan(PlanController controller) {
                                                  if (controller.checkPlanList.isEmpty) return null;

                                                  final data = controller.checkPlanList.first;

                                                  if (data == null || data is! Map<String, dynamic>) return null;

                                                  return data["details"]?["plan"]?["posterPlan"];
                                                }
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 10,
                                                        color: Colors.grey.withOpacity(0.2),
                                                      )
                                                    ],
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Expanded(
                                                        child: ClipRRect(
                                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                                          child: image.bytes != null
                                                              ? Image.memory(image.bytes!, fit: BoxFit.cover)
                                                              : image.url != null
                                                              ? Image.network(image.url!, fit: BoxFit.cover)
                                                              : const Icon(Icons.image_not_supported),
                                                        ),
                                                      ),

                                                      Flexible(
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              DropdownButtonFormField<String>(
                                                                value: controller.postImagePlanList
                                                                    .any((plan) => plan.id == image.id)
                                                                    ? image.id
                                                                    : null,
                                                               // value:image.id,
                                                                hint: const Text("Select Plan"),
                                                                items: controller.postImagePlanList.map((plan) {
                                                                  return DropdownMenuItem<String>(
                                                                    value: plan.id,
                                                                    child: Text("${plan.postPlanName} (${plan.duration} days)",style: AppTextStyles.caption(context),),
                                                                  );
                                                                }).toList(),
                                                                // items: controller.postImagePlanList.map((plan) {
                                                                //   return DropdownMenuItem(
                                                                //     value: plan.id,
                                                                //     child: Text("${plan.postPlanName}"),
                                                                //   );
                                                                // }).toList(),
                                                                onChanged: (value) {

                                                                },
                                                              ),

                                                              const SizedBox(height: 10),

                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Switch(
                                                                    value: image.isActive ?? false,
                                                                    onChanged: (val) async {
                                                                      image.isActive = val;
                                                                      controller.editUploadImage1[index] = image;
                                                                      controller.update();

                                                                      if (image.id == null) {
                                                                        Get.snackbar("Error", "Please select plan first");
                                                                        return;
                                                                      }

                                                                      final posterPlan = getSafePosterPlan(controller);

                                                                      final startDate = posterPlan?["startDate"]?.toString() ?? "";
                                                                      final endDate = posterPlan?["endDate"]?.toString() ?? "";

                                                                      // final filesToUpload = controller.editUploadImage1
                                                                      //     .where((img) => img.bytes != null)
                                                                      //     .map((img) => img.bytes!)
                                                                      //     .toList();
                                                                      List<Uint8List> filesToUpload = planController.editUploadImage1
                                                                          .where((img) => img.bytes != null)
                                                                          .map((img) => img.bytes!)
                                                                          .toList();
                                                                      await controller.uploadImagesUserType(
                                                                        Api.userInfo.read('userId'),
                                                                        controller.selectedUserType ?? "",
                                                                        image.id!,
                                                                        "1",
                                                                        startDate,
                                                                        endDate,
                                                                        val.toString(),
                                                                        filesToUpload,
                                                                        context,
                                                                      );
                                                                    },
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      IconButton(
                                                                        icon: const Icon(Icons.edit),
                                                                        onPressed: () {},
                                                                      ),
                                                                      IconButton(
                                                                        icon: const Icon(Icons.delete, color: Colors.red),
                                                                        onPressed: () {},
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }
                                            // itemBuilder: (_, index) {
                                            //   final img = controller.editUploadImage1[index];
                                            //   final image = controller.editUploadImage1[index];
                                            //   Map<String, dynamic>? getSafePosterPlan() {
                                            //     if (planController.checkPlanList.isEmpty) return null;
                                            //
                                            //     final data = planController.checkPlanList.first;
                                            //
                                            //     if (data == null || data.isEmpty) return null;
                                            //
                                            //     return data["details"]?["plan"]?["posterPlan"];
                                            //   }
                                            //   return Container(
                                            //     decoration: BoxDecoration(
                                            //       borderRadius: BorderRadius.circular(15),
                                            //       color: Colors.white,
                                            //       boxShadow: [
                                            //         BoxShadow(
                                            //           blurRadius: 10,
                                            //           color: Colors.grey.withOpacity(0.2),
                                            //         )
                                            //       ],
                                            //     ),
                                            //     child: Column(
                                            //       children: [
                                            //
                                            //         Expanded(
                                            //           child: ClipRRect(
                                            //             borderRadius: const BorderRadius.vertical(
                                            //                 top: Radius.circular(15)),
                                            //         //     child: img.bytes != null
                                            //         //         ? Image.memory(img.bytes!, fit: BoxFit.cover,
                                            //         //     height: size*0.35,
                                            //         //     width: size*0.35,
                                            //         //     )
                                            //         //         : Image.network(img.url ?? "",
                                            //         //         height: size*0.35,
                                            //         //         width: size*0.35,
                                            //         //         fit: BoxFit.cover),
                                            //         //   ),
                                            //         // ),
                                            //             child: img.bytes != null
                                            //                 ? Image.memory(
                                            //               img.bytes!,
                                            //               fit: BoxFit.cover,
                                            //               width: double.infinity,
                                            //               height: double.infinity,
                                            //             )
                                            //                 : img.url != null
                                            //                 ? Image.network(
                                            //               img.url!,
                                            //               fit: BoxFit.cover,
                                            //               width: double.infinity,
                                            //               height: double.infinity,
                                            //               errorBuilder: (_, __, ___) =>
                                            //               const Icon(Icons.broken_image),
                                            //             )
                                            //                 : const Icon(Icons.image_not_supported),
                                            //           ),
                                            //         ),
                                            //         Padding(
                                            //           padding: const EdgeInsets.all(10),
                                            //           child: Column(
                                            //             children: [
                                            //
                                            //               // DropdownButtonFormField<String>(
                                            //               //   //value: image.id,
                                            //               //   value: controller.postImagePlanList
                                            //               //       .any((plan) => plan.id == image.id)
                                            //               //       ? image.id
                                            //               //       : null,
                                            //               //   hint: const Text("Select Plan"),
                                            //               //   items: controller.postImagePlanList.map((plan) {
                                            //               //     return DropdownMenuItem(
                                            //               //       value: plan.id,
                                            //               //       child: Text(
                                            //               //           "${plan.postPlanName} (${plan.duration} days)"),
                                            //               //     );
                                            //               //   }).toList(),
                                            //               //   onChanged: (value) {
                                            //               //     image.id = value;
                                            //               //   },
                                            //               // ),
                                            //               DropdownButtonFormField<String>(
                                            //                 value: controller.postImagePlanList
                                            //                     .any((plan) => plan.id == image.id)
                                            //                     ? image.id
                                            //                     : null,
                                            //                 hint:  Text("Select Plan",style: AppTextStyles.caption(context),),
                                            //                 items: {
                                            //                   for (var plan in controller.postImagePlanList) plan.id: plan
                                            //                 }.values.map((plan) {
                                            //                   return DropdownMenuItem<String>(
                                            //                     value: plan.id,
                                            //                     child: Text("${plan.postPlanName} (${plan.duration} days)",style: AppTextStyles.caption(context),),
                                            //                   );
                                            //                 }).toList(),
                                            //                   onChanged: (value) async {
                                            //                     image.id = value;
                                            //                     controller.update();
                                            //                     final posterPlan = getSafePosterPlan();
                                            //
                                            //                     String isActive1 = posterPlan?["isActive"]?.toString() ?? "false";
                                            //                     String startDate1 = posterPlan?["startDate"]?.toString() ?? "";
                                            //                     String endDate1 = posterPlan?["endDate"]?.toString() ?? "";
                                            //
                                            //                     final posterId = image.id?.toString() ?? "0";
                                            //
                                            //                     List<Uint8List> filesToUpload = planController.editUploadImage1
                                            //                         .where((img) => img.bytes != null)
                                            //                         .map((img) => img.bytes!)
                                            //                         .toList();
                                            //
                                            //                     print("SAFE DATA:");
                                            //                     print("PosterId: $posterId");
                                            //                     print("Active: $isActive1");
                                            //                     print("Start: $startDate1 End: $endDate1");
                                            //
                                            //                     await planController.uploadImagesUserType(
                                            //                       Api.userInfo.read('userId'),
                                            //                       userType == 'superAdmin'
                                            //                           ? planController.selectedUserType!
                                            //                           : userType,
                                            //                       posterId,
                                            //                       "1",
                                            //                       startDate1,
                                            //                       endDate1,
                                            //                       isActive1,
                                            //                       filesToUpload,
                                            //                       context,
                                            //                     );
                                            //                   }
                                            //               ),
                                            //               const SizedBox(height: 10),
                                            //
                                            //               Row(
                                            //                 mainAxisAlignment:
                                            //                 MainAxisAlignment.spaceBetween,
                                            //                 children: [
                                            //                   // Switch(
                                            //                   //   value: image.isActive ?? true,
                                            //                   //   onChanged: (val) async{
                                            //                   //     image.isActive = val;
                                            //                   //     final posterId = planController.posterImage.isNotEmpty
                                            //                   //         ? image.id.toString()
                                            //                   //         : "0";
                                            //                   //     List<Uint8List> filesToUpload = planController.editUploadImage1
                                            //                   //         .where((img) => img.bytes != null)
                                            //                   //         .map((img) => img.bytes!)
                                            //                   //         .toList();
                                            //                   //     await planController.uploadImagesUserType(
                                            //                   //       Api.userInfo.read('userId'),
                                            //                   //       planController.selectedUserType!,
                                            //                   //       posterId,
                                            //                   //       "1",
                                            //                   //       startDate.toString()??"",
                                            //                   //       endDate.toString()??"",
                                            //                   //       val.toString(),
                                            //                   //       filesToUpload,
                                            //                   //       context,
                                            //                   //     );
                                            //                   //     // setState(() {
                                            //                   //     //   if (controller.posterImage.isNotEmpty) {
                                            //                   //     //     image.isActive = val;
                                            //                   //     //   }
                                            //                   //     // });
                                            //                   //     // controller.update();
                                            //                   //   },
                                            //                   // ),
                                            //                   Switch(
                                            //                     value: image.isActive ?? false,
                                            //                     onChanged: (val) async {
                                            //                       image.isActive = val;
                                            //                       controller.update();
                                            //
                                            //                       final posterId = image.id?.toString() ?? "0";
                                            //
                                            //                       if (posterId == "0") {
                                            //                         Get.snackbar("Error", "Please select plan first");
                                            //                         return;
                                            //                       }
                                            //
                                            //                       final posterPlan = getSafePosterPlan();
                                            //
                                            //                       String startDate1 = posterPlan?["startDate"]?.toString() ?? "";
                                            //                       String endDate1   = posterPlan?["endDate"]?.toString() ?? "";
                                            //
                                            //                       List<Uint8List> filesToUpload = planController.editUploadImage1
                                            //                           .where((img) => img.bytes != null)
                                            //                           .map((img) => img.bytes!)
                                            //                           .toList();
                                            //
                                            //                       await planController.uploadImagesUserType(
                                            //                         Api.userInfo.read('userId'),
                                            //                         planController.selectedUserType!,
                                            //                         posterId,
                                            //                         "1",
                                            //                         startDate1,
                                            //                         endDate1,
                                            //                         val.toString(),
                                            //                         filesToUpload,
                                            //                         context,
                                            //                       );
                                            //                     },
                                            //                   ),
                                            //                   Row(
                                            //                     children: [
                                            //                       IconButton(
                                            //                         icon: const Icon(Icons.edit),
                                            //                         onPressed: () async {
                                            //                           final picked = await picker.pickImage(
                                            //                               source: ImageSource.gallery);
                                            //                           if (picked != null) {
                                            //                             controller.editUploadImage1[index] =
                                            //                                 AppImage2(
                                            //                                   file: File(picked.path),
                                            //                                 );
                                            //                             controller.update();
                                            //                           }
                                            //                         },
                                            //                       ),
                                            //
                                            //                       // Delete
                                            //                       IconButton(
                                            //                         icon:  Icon(Icons.delete,
                                            //                             color: Colors.red,size: size*0.012,),
                                            //                         onPressed: () {
                                            //                           controller.editUploadImage1
                                            //                               .removeAt(index);
                                            //                           controller.update();
                                            //                         },
                                            //                       ),
                                            //                     ],
                                            //                   )
                                            //                 ],
                                            //               )
                                            //             ],
                                            //           ),
                                            //         )
                                            //       ],
                                            //     ),
                                            //   );
                                            // },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15,),
                                ],
                              ),
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
        },
      ),

    );
  }
}