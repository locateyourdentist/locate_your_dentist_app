import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import '../../common_widgets/color_code.dart';
import '../../common_widgets/common_textstyles.dart';
import '../plans/plan_controller.dart';
import 'package:image_picker/image_picker.dart';


class UploadImages extends StatefulWidget {
  const UploadImages({super.key});
  @override
  State<UploadImages> createState() => _UploadImagesState();
}
class _UploadImagesState extends State<UploadImages> {
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
  // Future<void> pickImages() async {
  //   final List<XFile>? pickedImages = await picker.pickMultiImage();
  //
  //   if (pickedImages != null && pickedImages.isNotEmpty) {
  //     const int maxImages = 20;
  //     final int availableSlots = maxImages - planController.editUploadImage.length;
  //     if (availableSlots <= 0) {
  //       Get.snackbar("Limit reached", "You can upload only $maxImages images");
  //       return;
  //     }
  //     final limited = pickedImages.take(availableSlots);
  //     setState(() {
  //       planController.editUploadImage.addAll(
  //         limited.map((x) => AppImage(file: File(x.path))),
  //       );
  //     });
  //     print('upload img${planController.editUploadImage}');
  //     String? isActive1;
  //     String?  startDate1;
  //     String? endDate1;
  //     String userType=Api.userInfo.read('userType');
  //     // List<File> filesToUpload = [];
  //     // int? selectedImageIndex;
  //     //
  //     // if (selectedImageIndex != null) {
  //     //   final selectedImage =
  //     //   planController.editUploadImage[selectedImageIndex!];
  //     //   if (selectedImage.file != null) {
  //     //     filesToUpload.add(selectedImage.file!);
  //     //   }
  //     // }
  //     List<File> filesToUpload = planController.editUploadImage
  //         .where((img) => img.file != null).map((img) => img.file!).toList();
  //     if(userType!='superAdmin') {
  //       isActive1  = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["isActive"] ?? "false";
  //       startDate1 = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["startDate"] ?? "";
  //       endDate1   = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["endDate"] ?? "";
  //     }
  //     final posterId = planController.posterImage.isNotEmpty ? planController.posterImage.first.id.toString() : "0";
  //     print('FDGFN $posterId fgfile upload $filesToUpload');
  //     userType=='superAdmin'?
  //     // await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,"0","0",startDate.toString(),endDate.toString(),"true",filesToUpload, context):
  //     await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,"0","1",startDate.toString(),endDate.toString(),planController.posterImage.first.isActive.toString(),filesToUpload, context):
  //    // await  planController.uploadImagesUserType(Api.userInfo.read('userId'), userType,planController.posterImage.first.id.toString(),planController.posterImage.first.preference.toString(),startDate1.toString(),endDate1.toString(),isActive1.toString(),filesToUpload,context);
  //     await  planController.uploadImagesUserType(Api.userInfo.read('userId'), userType,"0","1",startDate1.toString(),endDate1.toString(),isActive1.toString(),filesToUpload,context);
  //   }
  // }
  Future<void> pickImages() async {
    final List<XFile>? pickedImages = await picker.pickMultiImage();
    if (pickedImages == null || pickedImages.isEmpty) return;

    const int maxImages = 20;
    final int availableSlots = maxImages - planController.editUploadImage.length;

    if (availableSlots <= 0) {
      Get.snackbar("Limit reached", "You can upload only $maxImages images");
      return;
    }

    final limited = pickedImages.take(availableSlots);

    for (var file in limited) {
      final bytes = await file.readAsBytes();
      final appImage2 = AppImage2(
        bytes: bytes,
        file: kIsWeb ? null : File(file.path),
        isActive: true,
        url: kIsWeb ? file.path : null,
      );

      setState(() {
        planController.editUploadImage1.add(appImage2);
      });
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
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        title: Text('Upload Images',
          style: AppTextStyles.subtitle(context,color: AppColors.black),),automaticallyImplyLeading: true,iconTheme: IconThemeData(color: AppColors.black,size: size*0.05),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration:  const BoxDecoration(
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
      body: GetBuilder<PlanController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh:_refresh ,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                    width: size * 0.55,
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
                  SizedBox(
                    height: size * 1.4,
                    child: GetBuilder<PlanController>(
                        builder: (controller) {
                          return ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                        itemCount: controller.editUploadImage1.length < 20 ? controller.editUploadImage1.length + 1
                             : controller.editUploadImage1.length,
                          itemBuilder: (_, index) {
                            if (index < controller.editUploadImage1.length) {
                              //final img = controller.editUploadImage[index];
                             // final image = controller.posterImage[index];
                              final image = controller.posterImage[index];
                              final img = index < controller.editUploadImage1.length
                                  ? controller.editUploadImage1[index]
                                  : null;
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width:size*0.5,
                                        child: GetBuilder<PlanController>(
                                            builder: (controller) {
                                              // void setInitialSelectedPlan() {
                                              //   if (controller.posterImage.isEmpty || controller.postImagePlanList.isEmpty) return;
                                              //
                                              //   final image = controller.posterImage.first;
                                              //   if (image.startDate == null || image.endDate == null) return;
                                              //
                                              //   int imageDuration = calculateDuration(image.startDate!, image.endDate!);
                                              //   for (var plan in controller.postImagePlanList) {
                                              //     if (plan.duration == imageDuration) {
                                              //       controller.selectedPlanId = plan.id;
                                              //       break;
                                              //     }
                                              //   }
                                              //
                                              //   controller.update();
                                              // }
                                              // setInitialSelectedPlan();
                                              return GestureDetector(
                                                child: DropdownButtonFormField<String>(
                                                //value: controller.selectedPlanId,
                                                  value:controller.selectedPlanId,
                                                  // controller.postImagePlanList
                                                  //     .any((plan) => plan.id == controller.selectedPlanId)
                                                  //     ? controller.selectedPlanId
                                                  //     : null,
                                                  hint: Text(
                                                  "Select Plan",
                                                  style: AppTextStyles.caption(context),
                                                ),
                                                items: controller.postImagePlanList.map((plan) {
                                                  var dates=  calculatePlanDates(plan.duration.toString());
                                                  //var dates=  calculatePlanDates("5");
                                                  print(dates["startDate"]);
                                                  print("duration${plan.duration.toString()}");
                                                  print("endDate ${dates["endDate"]}");
                                                  startDate=dates["startDate"].toString();
                                                  endDate=dates["endDate"].toString();
                                                  return DropdownMenuItem<String>(
                                                    value: plan.id,
                                                    child: Text(
                                                      "${plan.postPlanName} - (${plan.duration} days)",
                                                      style: AppTextStyles.caption(context),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) async{
                                                  //setState(()async {
                                                    //controller.selectedPlanId = value;
                                                    image.id=value;
                                                    String? isActive1;
                                                    String?  startDate1;
                                                    String? endDate1;
                                                    if(userType!='superAdmin') {
                                                       isActive1  = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["isActive"] ?? "false";
                                                       startDate1 = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["startDate"] ?? "";
                                                       endDate1   = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["endDate"] ?? "";
                                                    }
                                                    // List<File> filesToUpload = planController.editUploadImage1
                                                    //     .where((img) => img.file != null)
                                                    //     .map((img) => img.file!)
                                                    //     .toList();
                                                    // if (img != null && img.file != null) {
                                                    //   filesToUpload.add(img.file!);
                                                    // }
                                                    List<Uint8List> filesToUpload = [];
                                                    for (var img in planController.editUploadImage1) {
                                                      if (img.file != null) {
                                                        filesToUpload.add(await img.file!.readAsBytes());
                                                      }
                                                    }

                                                    // Optionally include first posterImage file
                                                    if (planController.posterImage.isNotEmpty) {
                                                      final path = planController.posterImage.first?.path;
                                                      if (path != null) {
                                                        filesToUpload.add(await File(path).readAsBytes());
                                                      }
                                                    }
                                                    final posterId = planController.posterImage.isNotEmpty
                                                        ? image.id.toString() : "0";

                                                    print('FDGFN $posterId fgf');
                                                    final isActive = planController.posterImage.isNotEmpty
                                                        ? image.isActive.toString()
                                                        : "false";

                                                    print('ffvxcb $isActive');
                                                    userType=='superAdmin'?
                                                    // await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,"0","0",startDate.toString(),endDate.toString(),"true",filesToUpload, context):
                                                    await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,posterId,"1",startDate.toString(),endDate.toString(),isActive,filesToUpload, context):
                                                   // await  planController.uploadImagesUserType(Api.userInfo.read('userId'), userType,planController.posterImage.first.id.toString().isNotEmpty?planController.posterImage.first.id.toString():"0",planController.posterImage.first.preference.toString(),startDate1.toString(),endDate1.toString(),isActive1.toString(),filesToUpload,context);
                                                    await  planController.uploadImagesUserType(Api.userInfo.read('userId'), userType,posterId,"1",startDate1.toString(),endDate1.toString(),isActive1.toString(),filesToUpload,context);
                                                    },),
                                              );
                                          }
                                        ),
                                      ),

                                      GetBuilder<PlanController>(
                                          builder: (controller) {
                                            return Switch(
                                            value: image.isActive ?? true,
                                              activeColor: (image.isActive == true) ? AppColors.primary : Colors.red,
                                              activeTrackColor: AppColors.primary.withOpacity(0.5),
                                              inactiveThumbColor: Colors.red,
                                              inactiveTrackColor: Colors.grey.shade400,
                                              onChanged: (value) {
                                                showDeactivateConfirmDialog(
                                                  context: context,
                                                  isActivating: value,
                                                  onConfirm: () async {
                                                    final posterId = planController.posterImage.isNotEmpty
                                                        ? image.id.toString()
                                                        : "0";
                                                    // List<File> filesToUpload = planController.editUploadImage1
                                                    //     .where((img) => img.file != null)
                                                    //     .map((img) => img.file!)
                                                    //     .toList();

                                                    // if (planController.posterImage.isNotEmpty) {
                                                    //   final path = planController.posterImage.first?.path;
                                                    //   if (path != null) filesToUpload.add(File(path));
                                                    // }
                                                    List<Uint8List> filesToUpload = [];
                                                    for (var img in planController.editUploadImage1) {
                                                      if (img.file != null) {
                                                        filesToUpload.add(await img.file!.readAsBytes());
                                                      }
                                                    }

                                                    // Optionally include first posterImage file
                                                    if (planController.posterImage.isNotEmpty) {
                                                      final path = planController.posterImage.first?.path;
                                                      if (path != null) {
                                                        filesToUpload.add(await File(path).readAsBytes());
                                                      }
                                                    }

                                                    await planController.uploadImagesUserType(
                                                      Api.userInfo.read('userId'),
                                                      planController.selectedUserType!,
                                                      posterId,
                                                      "1",
                                                      startDate.toString(),
                                                      endDate.toString(),
                                                      value.toString(),
                                                      filesToUpload,
                                                      context,
                                                    );
                                                    setState(() {
                                                      if (controller.posterImage.isNotEmpty) {
                                                        image.isActive = value;
                                                      }
                                                    });
                                                  },
                                                );
                                              },

                                              //  onChanged: (value) {
                                            //   showDeactivateConfirmDialog(
                                            //     context: context,
                                            //     isActivating: value,
                                            //     onConfirm: () async{
                                            //       final posterId = planController.posterImage.isNotEmpty
                                            //           ? planController.posterImage.first.id.toString()
                                            //           : "0";
                                            //       List<File> filesToUpload = planController.editUploadImage
                                            //           .where((img) => img.file != null)
                                            //           .map((img) => img.file!)
                                            //           .toList();
                                            //         if (planController.posterImage.isNotEmpty) {
                                            //         final path = planController.posterImage.first?.path;
                                            //         if (path != null) {
                                            //           filesToUpload.add(File(path));
                                            //         }}
                                            //       if(controller.posterImage.first.isActive==true)
                                            //       await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,posterId,"1",startDate.toString(),endDate.toString(),"false",filesToUpload, context);
                                            //       else{
                                            //         await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,posterId,"1",startDate.toString(),endDate.toString(),"true",filesToUpload, context);
                                            //         planController.getUploadImages(userId:userType=='superAdmin'?"":Api.userInfo.read('userId')??"",userType: Api.userInfo.read('userType')??"",context: context);
                                            //
                                            //       }
                                            //
                                            //     },
                                            //   );
                                            // },
                                          );
                                        }
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    width: size ,
                                    height: size * 0.3,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: img!.file != null
                                              ? Image.file(
                                            img.file!,
                                            fit: BoxFit.cover,
                                            width: size ,
                                            height: size * 0.35,
                                          )
                                              : (img.url != null && img.url!.isNotEmpty
                                              ? Image.network(
                                            img.url!, width: size ,

                                            fit: BoxFit.cover,
                                          )
                                              : Container(
                                            color: Colors.grey.shade200,
                                            child: const Center(child: Icon(Icons.image)),
                                          )),
                                          // Image.network(
                                          //   img.url!,
                                          //   // img.url!,
                                          //   fit: BoxFit.cover,
                                          //   width: size ,
                                          //   height: size * 0.35,
                                          // ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title:  Text("Remove Image?",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(context),
                                                        child:  Text("Cancel",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),)),
                                                    TextButton(
                                                      onPressed: () async{
                                                      if (index >= controller.editUploadImage1.length) return;
                                                      final removedImage = controller.editUploadImage1[index];
                                                      setState(() {
                                                      controller.editUploadImage1.removeAt(index);
                                                      });
                                                      if (removedImage.url != null && removedImage.url!.isNotEmpty) {
                                                      await loginController.deleteAwsFile(removedImage.url!,'postImage', context);
                                                      }
                                                       loginController.update();
                                                        // setState(() async{
                                                        //   controller.editUploadImage.removeAt(index);
                                                        //   final certToDelete = loginController.editCertificates[index];
                                                        //   if (certToDelete.url != null) {
                                                        //     await loginController.deleteAwsFile(certToDelete.toString(), context);
                                                        //     print('deleteFile ${certToDelete.url}');
                                                        //   }
                                                        //   controller.editUploadImage.removeAt(index);
                                                        //   controller.editUploadImage.forEach((img) {
                                                        //     print('after delete URL: ${img.url}');
                                                        //   });
                                                        //   loginController.update();
                                                        //   Get.back();
                                                        // });
                                                        // Navigator.pop(context);
                                                      },
                                                      child:  Text("Remove",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: Colors.red),),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: const Icon(Icons.cancel,
                                                color: Colors.black),
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
                                            child:  IconButton(
                                                onPressed:  () async {
                                                          editingIndex = index;
                                                          final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                                                          if (picked != null) {
                                                          setState(() {
                                                            controller.editUploadImage1[index] = AppImage2(
                                                              file: File(picked.path),
                                                             // id: controller.editUploadImage[index].id,
                                                              //isActive: controller.editUploadImage[index].isActive,
                                                            );

                                                            controller.update();
                                                          //controller.editUploadImage[index] = AppImage(file: File(picked.path));
                                                          });
                                                          }},
                                                icon:Icon(Icons.edit,
                                                color: Colors.white, size: size*0.03),
                                          ),
                                        ),
                                        )],
                                    ),
                                  ),
                                ],
                              );
                            }
                            // Add image button
                            return GestureDetector(
                              onTap: pickImages,
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
                        );
                      }
                    ),
                  ),

                  const SizedBox(height: 15,),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),

    );
  }
}
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:locate_your_dentist/api/api.dart';
// import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
// import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
// import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
// import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
// import '../../common_widgets/color_code.dart';
// import '../../common_widgets/common_textstyles.dart';
// import '../plans/plan_controller.dart';
// import 'package:image_picker/image_picker.dart';
//
//
// class UploadImages extends StatefulWidget {
//   const UploadImages({super.key});
//   @override
//   State<UploadImages> createState() => _UploadImagesState();
// }
// class _UploadImagesState extends State<UploadImages> {
//   final PlanController planController = Get.put(PlanController());
//   final LoginController loginController=Get.put(LoginController());
//   final List<String> userTypes = const [
//     "Dental Clinic",
//     "Dental Lab",
//     "Dental Shop",
//     "Dental Mechanic",
//     "Dental Consultant",
//     "Job Seekers"
//   ];
//   final ImagePicker picker = ImagePicker();
//   int? editingIndex;
//   String ? startDate;
//   String ? endDate;
//   Future<void> pickImages() async {
//     final List<XFile>? pickedImages = await picker.pickMultiImage();
//
//     if (pickedImages != null && pickedImages.isNotEmpty) {
//       const int maxImages = 20;
//       final int availableSlots = maxImages - planController.editUploadImage.length;
//       if (availableSlots <= 0) {
//         Get.snackbar("Limit reached", "You can upload only $maxImages images");
//         return;
//       }
//       for (var file in pickedImages) {
//         final bytes = await file.readAsBytes();
//         final appImage2 = AppImage2(bytes: bytes, isActive: true);
//         setState(() {
//           planController.editUploadImage1.add(appImage2);
//         });
//       }
//       print('upload img${planController.editUploadImage1}');
//       String? isActive1;
//       String?  startDate1;
//       String? endDate1;
//       String userType=Api.userInfo.read('userType');
//       // List<File> filesToUpload = [];
//       // int? selectedImageIndex;
//       //
//       // if (selectedImageIndex != null) {
//       //   final selectedImage =
//       //   planController.editUploadImage[selectedImageIndex!];
//       //   if (selectedImage.file != null) {
//       //     filesToUpload.add(selectedImage.file!);
//       //   }
//       // }
//       List<Uint8List> filesToUpload = planController.editUploadImage1
//           .where((img) => img.bytes != null).map((img) => img.bytes!).toList();
//       if(userType!='superAdmin') {
//         isActive1  = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["isActive"] ?? "false";
//         startDate1 = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["startDate"] ?? "";
//         endDate1   = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["endDate"] ?? "";
//       }
//       final posterId = planController.posterImage.isNotEmpty ? planController.posterImage.first.id.toString() : "0";
//       print('FDGFN $posterId fgfile upload $filesToUpload');
//       userType=='superAdmin'?
//       // await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,"0","0",startDate.toString(),endDate.toString(),"true",filesToUpload, context):
//       await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,"0","1",startDate.toString(),endDate.toString(),planController.posterImage.first.isActive.toString(),filesToUpload.cast<AppImage2>(), context):
//       // await  planController.uploadImagesUserType(Api.userInfo.read('userId'), userType,planController.posterImage.first.id.toString(),planController.posterImage.first.preference.toString(),startDate1.toString(),endDate1.toString(),isActive1.toString(),filesToUpload,context);
//       await  planController.uploadImagesUserType(Api.userInfo.read('userId'), userType,"0","1",startDate1.toString(),endDate1.toString(),isActive1.toString(),filesToUpload.cast<AppImage2>(),context);
//     }
//   }
//   Map<String, String> calculatePlanDates(String durationStr) {
//     int duration = int.tryParse(durationStr) ?? 0;
//     DateTime start = DateTime.now();
//     DateTime end = start.add(Duration(days: duration));
//     return {
//       "startDate": "${start.day}-${start.month}-${start.year}",
//       "endDate": "${end.day}-${end.month}-${end.year}",
//     };
//   }
//   DateTime parseDate(String date) {
//     final parts = date.split("-");
//     return DateTime(
//       int.parse(parts[2]),
//       int.parse(parts[1]),
//       int.parse(parts[0]),
//     );
//   }
//   int calculateDuration(String start, String end) {
//     final startDate = parseDate(start);
//     final endDate = parseDate(end);
//     return endDate.difference(startDate).inDays;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     String userType=  Api.userInfo.read('userType')??"";
//     planController.selectedUserType="Dental Clinic";
//     planController.getUploadImages(userId:userType=='superAdmin'?"":Api.userInfo.read('userId')??"",userType: planController.selectedUserType!,context: context);
//     planController.checkPlansStatus(Api.userInfo.read('userId')??"",context);
//   }
//   Future<void> _refresh() async {
//     planController.selectedUserType=null;
//     Api.userInfo.read('userType')=='superAdmin'? planController.getUploadImages(userType: Api.userInfo.read('userType')??"",context: context):
//     planController.getUploadImages(userId:Api.userInfo.read('userId')??"",userType: Api.userInfo.read('userType')??"", context: context);
//   }
//   @override
//   Widget build(BuildContext context) {
//     double size = MediaQuery.of(context).size.width;
//     String userType=  Api.userInfo.read('userType')??"";
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,backgroundColor: AppColors.white,
//         title: Text('Upload Images',
//           style: AppTextStyles.subtitle(context,color: AppColors.black),),automaticallyImplyLeading: true,iconTheme: IconThemeData(color: AppColors.black,size: size*0.05),
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//             },
//             child: Container(
//               decoration:  const BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [AppColors.primary, AppColors.secondary],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: const Center(
//                 child: Icon(
//                   Icons.arrow_back,
//                   color: AppColors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: GetBuilder<PlanController>(
//         builder: (controller) {
//           return RefreshIndicator(
//             onRefresh:_refresh ,
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if(userType=='superAdmin')
//                     Row(
//                       children: [
//                         Text(
//                           "Select User Type",
//                           style: AppTextStyles.caption(
//                             context,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//
//                         const SizedBox(width: 10),
//                         SizedBox(
//                           width: size * 0.55,
//                           child: GetBuilder<PlanController>(
//                               builder: (controller) {
//                                 return CustomDropdownField(
//                                   hint: "Select User Type",
//                                   borderColor: AppColors.grey,
//                                   fillColor: AppColors.white,
//                                   items: userTypes,
//                                   selectedValue: controller.selectedUserType,
//                                   onChanged: (value)async {
//                                     controller.selectedUserType = value;
//                                     await planController.getUploadImages(userType:controller.selectedUserType!,context: context);
//                                     await  planController.getPostImageList(controller.selectedUserType!,context);
//                                     planController.update();
//                                   },
//                                 );
//                               }
//                           ),
//                         ),
//                       ],
//                     ),
//                   SizedBox(height: size*0.03),
//                   SizedBox(
//                     height: size * 1.4,
//                     child: GetBuilder<PlanController>(
//                         builder: (controller) {
//                           return ListView.builder(
//                             scrollDirection: Axis.vertical,
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             itemCount: controller.editUploadImage1.length < 20 ? controller.editUploadImage1.length + 1
//                                 : controller.editUploadImage1.length,
//                             itemBuilder: (_, index) {
//                               if (index < controller.editUploadImage1.length) {
//                                 final image = controller.posterImage[index];
//                                 final img = index < controller.editUploadImage1.length
//                                     ? controller.editUploadImage1[index]
//                                     : null;
//                                 return Column(
//                                   children: [
//                                     Row(
//                                       children: [
//                                         SizedBox(
//                                           width:size*0.5,
//                                           child: GetBuilder<PlanController>(
//                                               builder: (controller) {
//                                                 return GestureDetector(
//                                                   child: DropdownButtonFormField<String>(
//                                                     value:controller.selectedPlanId,
//                                                     hint: Text(
//                                                       "Select Plan",
//                                                       style: AppTextStyles.caption(context),
//                                                     ),
//                                                     items: controller.postImagePlanList.map((plan) {
//                                                       var dates=  calculatePlanDates(plan.duration.toString());
//                                                       //var dates=  calculatePlanDates("5");
//                                                       print(dates["startDate"]);
//                                                       print("duration${plan.duration.toString()}");
//                                                       print("endDate ${dates["endDate"]}");
//                                                       startDate=dates["startDate"].toString();
//                                                       endDate=dates["endDate"].toString();
//                                                       return DropdownMenuItem<String>(
//                                                         value: plan.id,
//                                                         child: Text(
//                                                           "${plan.postPlanName} - (${plan.duration} days)",
//                                                           style: AppTextStyles.caption(context),
//                                                         ),
//                                                       );
//                                                     }).toList(),
//                                                     onChanged: (value) async{
//                                                       //setState(()async {
//                                                       //controller.selectedPlanId = value;
//                                                       image.id=value;
//                                                       String? isActive1;
//                                                       String?  startDate1;
//                                                       String? endDate1;
//                                                       if(userType!='superAdmin') {
//                                                         isActive1  = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["isActive"] ?? "false";
//                                                         startDate1 = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["startDate"] ?? "";
//                                                         endDate1   = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["endDate"] ?? "";
//                                                       }
//                                                       List<AppImage2> filesToUpload = planController.editUploadImage1
//                                                           .where((img) => img != null)
//                                                           .map((img) => img!)
//                                                           .toList();
//                                                       if (img != null && img != null) {
//                                                         filesToUpload.add(img!);
//                                                       }
//                                                       final posterId = planController.posterImage.isNotEmpty
//                                                           ? image.id.toString() : "0";
//
//                                                       print('FDGFN $posterId fgf');
//                                                       final isActive = planController.posterImage.isNotEmpty
//                                                           ? image.isActive.toString()
//                                                           : "false";
//
//                                                       print('ffvxcb $isActive');
//                                                       userType=='superAdmin'?
//                                                       // await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,"0","0",startDate.toString(),endDate.toString(),"true",filesToUpload, context):
//                                                       await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,posterId,"1",startDate.toString(),endDate.toString(),isActive,filesToUpload, context):
//                                                       // await  planController.uploadImagesUserType(Api.userInfo.read('userId'), userType,planController.posterImage.first.id.toString().isNotEmpty?planController.posterImage.first.id.toString():"0",planController.posterImage.first.preference.toString(),startDate1.toString(),endDate1.toString(),isActive1.toString(),filesToUpload,context);
//                                                       await  planController.uploadImagesUserType(Api.userInfo.read('userId'), userType,posterId,"1",startDate1.toString(),endDate1.toString(),isActive1.toString(),filesToUpload,context);
//                                                     },),
//                                                 );
//                                               }
//                                           ),
//                                         ),
//
//                                         GetBuilder<PlanController>(
//                                             builder: (controller) {
//                                               return Switch(
//                                                 value: image.isActive ?? true,
//                                                 activeColor: (image.isActive == true) ? AppColors.primary : Colors.red,
//                                                 activeTrackColor: AppColors.primary.withOpacity(0.5),
//                                                 inactiveThumbColor: Colors.red,
//                                                 inactiveTrackColor: Colors.grey.shade400,
//                                                 onChanged: (value) {
//                                                   showDeactivateConfirmDialog(
//                                                     context: context,
//                                                     isActivating: value,
//                                                     onConfirm: () async {
//                                                       final posterId = planController.posterImage.isNotEmpty
//                                                           ? image.id.toString()
//                                                           : "0";
//                                                       // List<AppImage2> filesToUpload = planController.editUploadImage
//                                                       //     .where((img) => img != null)
//                                                       //     .map((img) => img!)
//                                                       //     .toList();
//                                                       //
//                                                       // if (planController.posterImage.isNotEmpty) {
//                                                       //   final path = planController.posterImage.first?.path;
//                                                       //   if (path != null) filesToUpload.add(File(path));
//                                                       // }
//                                                       // await planController.uploadImagesUserType(
//                                                       //   Api.userInfo.read('userId'),
//                                                       //   planController.selectedUserType!,
//                                                       //   posterId,
//                                                       //   "1",
//                                                       //   startDate.toString(),
//                                                       //   endDate.toString(),
//                                                       //   value.toString(),
//                                                       //   filesToUpload,
//                                                       //   context,
//                                                       // );
//                                                       // 1. Convert AppImage2 objects to Uint8List
//                                                       List<Uint8List> filesToUpload = planController.editUploadImage1
//                                                           .where((img) => img.bytes != null)
//                                                           .map((img) => img.bytes!)
//                                                           .toList();
//
// // 2. Include poster image if exists (convert File to Uint8List)
//                                                       if (planController.posterImage.isNotEmpty) {
//                                                         final path = planController.posterImage.first?.path;
//                                                         if (path != null) {
//                                                           final posterBytes = await File(path).readAsBytes();
//                                                           filesToUpload.add(posterBytes);
//                                                         }
//                                                       }
//
// // 3. Call upload
//                                                       await planController.uploadImagesUserType(
//                                                         Api.userInfo.read('userId'),
//                                                         planController.selectedUserType!,
//                                                         posterId,
//                                                         "1",
//                                                         startDate.toString(),
//                                                         endDate.toString(),
//                                                         value.toString(),
//                                                         filesToUpload.cast<AppImage2>(),
//                                                         context,
//                                                       );
//                                                       setState(() {
//                                                         if (controller.posterImage.isNotEmpty) {
//                                                           image.isActive = value;
//                                                         }
//                                                       });
//                                                     },
//                                                   );
//                                                 },
//                                               );
//                                             }
//                                         ),
//                                       ],
//                                     ),
//                                     Container(
//                                       margin: const EdgeInsets.all(8),
//                                       width: size ,
//                                       height: size * 0.3,
//                                       child: Stack(
//                                         children: [
//                                           ClipRRect(
//                                             borderRadius: BorderRadius.circular(10),
//                                             child: img! != null
//                                                 ? Image.memory(
//                                               img as Uint8List,
//                                               fit: BoxFit.cover,
//                                               width: size ,
//                                               height: size * 0.35,
//                                             )
//                                                 : (img.url != null && img.url!.isNotEmpty
//                                                 ? Image.network(
//                                               img.url!, width: size ,
//
//                                               fit: BoxFit.cover,
//                                             )
//                                                 : Container(
//                                               color: Colors.grey.shade200,
//                                               child: const Center(child: Icon(Icons.image)),
//                                             )),
//                                           ),
//                                           Positioned(
//                                             right: 0,
//                                             top: 0,
//                                             child: GestureDetector(
//                                               onTap: () {
//                                                 showDialog(
//                                                   context: context,
//                                                   builder: (_) => AlertDialog(
//                                                     title: const Text("Remove Image?"),
//                                                     actions: [
//                                                       TextButton(
//                                                           onPressed: () =>
//                                                               Navigator.pop(context),
//                                                           child: const Text("Cancel")),
//                                                       TextButton(
//                                                         onPressed: () async{
//                                                           if (index >= controller.editUploadImage1.length) return;
//                                                           final removedImage = controller.editUploadImage1[index];
//                                                           setState(() {
//                                                             controller.editUploadImage1.removeAt(index);
//                                                           });
//                                                           if (removedImage.url != null && removedImage.url!.isNotEmpty) {
//                                                             await loginController.deleteAwsFile(removedImage.url!,'postImage', context);
//                                                           }
//                                                           loginController.update();
//                                                         },
//                                                         child: const Text("Remove"),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 );
//                                               },
//                                               child: const Icon(Icons.cancel,
//                                                   color: Colors.black),
//                                             ),
//                                           ),
//                                           Positioned(
//                                             right: 5,
//                                             bottom: 5,
//                                             child: Container(
//                                               padding: const EdgeInsets.all(4),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.black54,
//                                                 borderRadius: BorderRadius.circular(8),
//                                               ),
//                                               child:  IconButton(
//                                                 onPressed:  () async {
//                                                   editingIndex = index;
//                                                   final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
//                                                   if (picked != null) {
//                                                     setState(() async{
//                                                       final bytes = await picked.readAsBytes(); // works on web
//                                                       controller.editUploadImage1[index] = AppImage2(
//                                                         bytes: bytes,
//                                                       );
//
//                                                       controller.update();
//                                                       //controller.editUploadImage[index] = AppImage(file: File(picked.path));
//                                                     });
//                                                   }},
//                                                 icon:Icon(Icons.edit,
//                                                     color: Colors.white, size: size*0.03),
//                                               ),
//                                             ),
//                                           )],
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               }
//                               // Add image button
//                               return GestureDetector(
//                                 onTap: pickImages,
//                                 child: Container(
//                                   margin: const EdgeInsets.all(8),
//                                   width: size * 0.3,
//                                   height: size * 0.3,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: Border.all(color: Colors.grey),
//                                     color: Colors.grey.shade200,
//                                   ),
//                                   child: const Center(
//                                     child: Icon(Icons.add, size: 40, color: Colors.grey),
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         }
//                     ),
//                   ),
//
//                   const SizedBox(height: 15,),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
//
//     );
//   }
// }
