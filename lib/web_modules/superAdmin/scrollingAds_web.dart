// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:get/get.dart';
// import 'package:locate_your_dentist/api/api.dart';
// import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
// import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
// import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
// import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
// import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
// import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
//
// import '../../common_widgets/color_code.dart';
//
//
// class UploadImagesWeb extends StatefulWidget {
//   const UploadImagesWeb({super.key});
//
//   @override
//   State<UploadImagesWeb> createState() => _UploadImagesWebState();
// }
//
// class _UploadImagesWebState extends State<UploadImagesWeb> {
//   final ImagePicker picker = ImagePicker();
//   final PlanController planController = Get.put(PlanController());
//   String ? startDate;
//   String ? endDate;
//   @override
//   void initState() {
//     super.initState();
//     String userType = Api.userInfo.read('userType') ?? "";
//     planController.selectedUserType = "Dental Clinic";
//     planController.getUploadImages(
//       userId: userType == 'superAdmin' ? "" : Api.userInfo.read('userId') ?? "",
//       userType: planController.selectedUserType!,
//       context: context,
//     );
//     planController.checkPlansStatus(Api.userInfo.read('userId') ?? "", context);
//   }
//   List<Uint8List> images = [];
//
//   Future<void> pickImages() async {
//     final List<XFile>? picked = await picker.pickMultiImage();
//     if (picked == null) return;
//
//     for (var file in picked) {
//       final bytes = await file.readAsBytes();
//       final appImage2 = AppImage2(bytes: bytes, isActive: true);
//
//       setState(() {
//         planController.editUploadImage1.add(appImage2);
//       });
//     }
//     planController.update();
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
//   final List<String> userTypes = const [
//     "Dental Clinic",
//     "Dental Lab",
//     "Dental Shop",
//     "Dental Mechanic",
//     "Dental Consultant",
//     "Job Seekers"
//   ];
//   Future<void> editImage(int index) async {
//     final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked == null) return;
//
//     final bytes = await picked.readAsBytes();
//
//     planController.editUploadImage1[index] = AppImage2(bytes: bytes, isActive: true);
//     planController.update();
//   }
//   // Future<void> editImage(int index) async {
//   //   final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
//   //   if (picked == null) return;
//   //
//   //   planController.editUploadImage[index] = AppImage(file: File(picked.path));
//   //   planController.update();
//   // }
//   void deleteImage(int index) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Delete Image"),
//         content: const Text("Are you sure you want to delete this image?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               planController.editUploadImage.removeAt(index);
//               planController.update();
//               Navigator.pop(context);
//             },
//             child: const Text("Delete"),
//           )
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     String userType=  Api.userInfo.read('userType')??"";
//     return Scaffold(
//       appBar: CommonWebAppBar(
//         height: width * 0.08,
//         title: "LOCATE YOUR DENTIST",
//         onLogout: () {},
//         onNotification: () {},
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: pickImages,
//         child: const Icon(Icons.add),
//       ),
//       body: GetBuilder<PlanController>(
//         builder: (controller) {
//           return Row(
//             children: [
//
//               const AdminSideBar(),
//               Expanded(
//                 child: Center(
//                   child: Container(
//                     width: 1200,
//                     padding: const EdgeInsets.all(30),
//
//                     //     : GridView.builder(
//                     //   itemCount: controller.editUploadImage1.length,
//                     //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     //     crossAxisCount: 3,
//                     //     crossAxisSpacing: 25,
//                     //     mainAxisSpacing: 25,
//                     //     childAspectRatio: 1.3,
//                     //   ),
//                     //   itemBuilder: (context, index) {
//                     //     final img = controller.editUploadImage1[index];
//                     //     return _imageCard(img, index);
//                     //   },
//                     // ),
//                  child:   Column(
//                       children: [
//                         SizedBox(
//                           width: width * 0.35,
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
//                                     await  planController.getPostImagePlanList(controller.selectedUserType!,context);
//                                     planController.update();
//                                   },
//                                 );
//                               }
//                           ),
//                         ),
//                         SizedBox(height: width*0.02,),
//                         if(controller.editUploadImage1.isEmpty)
//                           const Center(
//                             child: Text(
//                               "No Images Found",
//                               style: TextStyle(fontSize: 20),
//                             ),
//                           ),
//                        Flexible(
//                          child:
//                          GridView.builder(
//                           itemCount: controller.editUploadImage1.length < 20
//                               ? controller.editUploadImage1.length + 1
//                               : controller.posterImage.length,
//                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 3,
//                             crossAxisSpacing: 25,
//                             mainAxisSpacing: 25,
//                             childAspectRatio: 1.3,
//                           ),
//                           itemBuilder: (context, index) {
//                             // if (index < controller.editUploadImage1.length) {
//                             //   final img1 = controller.editUploadImage1[index];
//                             //   return _imageCard(img1, index);
//                             // } else {
//                             //   final image = controller.posterImage[index];
//                             //   final img = index < controller.editUploadImage1.length
//                             //       ? controller.editUploadImage1[index]
//                             //       : null;
//                             if (index < controller.editUploadImage1.length) {
//                               final img1 = controller.editUploadImage1[index];
//                               return _imageCard(img1, index);
//                             } else {
//                             final image = controller.posterImage[index];
//                             final img = index < controller.editUploadImage1.length
//                                 ? controller.editUploadImage1[index]
//                                 : null;
//                             return GestureDetector(
//                                 onTap: ()async{
//                                   final List<XFile>? picked = await picker.pickMultiImage();
//                                   if (picked == null) return;
//
//                                   for (var file in picked) {
//                                     final bytes = await file.readAsBytes();
//                                     final appImage2 = AppImage2(bytes: bytes, isActive: true);
//
//                                     setState(() {
//                                       planController.editUploadImage1.add(appImage2);
//                                     });
//                                     final image = planController.posterImage[index];
//
//                                     final posterId = planController.posterImage.isNotEmpty
//                                         ? image.id.toString()
//                                         : "0";
//                                     List<File> filesToUpload = planController.editUploadImage1
//                                         .where((img) => img.file != null)
//                                         .map((img) => img.file!)
//                                         .toList();
//
//                                     if (planController.posterImage.isNotEmpty) {
//                                       final path = planController.posterImage.first?.path;
//                                       if (path != null) filesToUpload.add(File(path));
//                                     }
//                                     await planController.uploadImagesUserType(
//                                       Api.userInfo.read('userId'),
//                                       planController.selectedUserType!,
//                                       posterId,
//                                       "1",
//                                       startDate.toString(),
//                                       endDate.toString(),
//                                       'true',
//                                       filesToUpload,
//                                       context,
//                                     );
//
//                                   }
//
//                                   planController.update();
//                                 },
//                                 child: Column(
//                                   children: [
//                                     Row(
//                                       children: <Widget>[
//                                         SizedBox(
//                                           width:width*0.5,
//                                           child: GetBuilder<PlanController>(
//                                               builder: (controller) {
//                                                 // void setInitialSelectedPlan() {
//                                                 //   if (controller.posterImage.isEmpty || controller.postImagePlanList.isEmpty) return;
//                                                 //
//                                                 //   final image = controller.posterImage.first;
//                                                 //   if (image.startDate == null || image.endDate == null) return;
//                                                 //
//                                                 //   int imageDuration = calculateDuration(image.startDate!, image.endDate!);
//                                                 //   for (var plan in controller.postImagePlanList) {
//                                                 //     if (plan.duration == imageDuration) {
//                                                 //       controller.selectedPlanId = plan.id;
//                                                 //       break;
//                                                 //     }
//                                                 //   }
//                                                 //
//                                                 //   controller.update();
//                                                 // }
//                                                 // setInitialSelectedPlan();
//                                                 return GestureDetector(
//                                                   child: DropdownButtonFormField<String>(
//                                                     //value: controller.selectedPlanId,
//                                                     value:controller.selectedPlanId,
//                                                     // controller.postImagePlanList
//                                                     //     .any((plan) => plan.id == controller.selectedPlanId)
//                                                     //     ? controller.selectedPlanId
//                                                     //     : null,
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
//                                                       List<File> filesToUpload = planController.editUploadImage1
//                                                           .where((img) => img.file != null)
//                                                           .map((img) => img.file!)
//                                                           .toList();
//                                                       if (img != null && img.file != null) {
//                                                         filesToUpload.add(img.file!);
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
//                                                       List<File> filesToUpload = planController.editUploadImage1
//                                                           .where((img) => img.file != null)
//                                                           .map((img) => img.file!)
//                                                           .toList();
//
//                                                       if (planController.posterImage.isNotEmpty) {
//                                                         final path = planController.posterImage.first?.path;
//                                                         if (path != null) filesToUpload.add(File(path));
//                                                       }
//                                                       await planController.uploadImagesUserType(
//                                                         Api.userInfo.read('userId'),
//                                                         planController.selectedUserType!,
//                                                         posterId,
//                                                         "1",
//                                                         startDate.toString(),
//                                                         endDate.toString(),
//                                                         value.toString(),
//                                                         filesToUpload,
//                                                         context,
//                                                       );
//
//                                                       // **Update local state**
//                                                       setState(() {
//                                                         if (controller.posterImage.isNotEmpty) {
//                                                           image.isActive = value;
//                                                         }
//                                                       });
//                                                     },
//                                                   );
//                                                 },
//
//                                                 //  onChanged: (value) {
//                                                 //   showDeactivateConfirmDialog(
//                                                 //     context: context,
//                                                 //     isActivating: value,
//                                                 //     onConfirm: () async{
//                                                 //       final posterId = planController.posterImage.isNotEmpty
//                                                 //           ? planController.posterImage.first.id.toString()
//                                                 //           : "0";
//                                                 //       List<File> filesToUpload = planController.editUploadImage
//                                                 //           .where((img) => img.file != null)
//                                                 //           .map((img) => img.file!)
//                                                 //           .toList();
//                                                 //         if (planController.posterImage.isNotEmpty) {
//                                                 //         final path = planController.posterImage.first?.path;
//                                                 //         if (path != null) {
//                                                 //           filesToUpload.add(File(path));
//                                                 //         }}
//                                                 //       if(controller.posterImage.first.isActive==true)
//                                                 //       await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,posterId,"1",startDate.toString(),endDate.toString(),"false",filesToUpload, context);
//                                                 //       else{
//                                                 //         await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,posterId,"1",startDate.toString(),endDate.toString(),"true",filesToUpload, context);
//                                                 //         planController.getUploadImages(userId:userType=='superAdmin'?"":Api.userInfo.read('userId')??"",userType: Api.userInfo.read('userType')??"",context: context);
//                                                 //
//                                                 //       }
//                                                 //
//                                                 //     },
//                                                 //   );
//                                                 // },
//                                               );
//                                             }
//                                         ),
//                                       ],
//                                     ),
//                                     Container(
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(15),
//                                         border: Border.all(color: Colors.grey),
//                                         color: Colors.grey.shade200,
//                                       ),
//                                       child: const Center(
//                                         child: Icon(Icons.add, size: 40, color: Colors.grey),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }
//                           },
//                                                ),
//                        ),]
//                     )
//
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   /// IMAGE CARD WIDGET
//   Widget _imageCard(AppImage2 img, int index) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
//       ),
//       child: Column(
//         children: [
//           /// IMAGE PREVIEW
//           Expanded(
//             child: ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//               child: img.bytes != null
//                   ? Image.memory(img.bytes!, width: double.infinity, fit: BoxFit.cover)
//                   : (img.url != null && img.url!.isNotEmpty)
//                   ? Image.network(img.url!, width: double.infinity, fit: BoxFit.cover)
//                   : Container(
//                 color: Colors.grey.shade200,
//                 child:  Center(child: Icon(Icons.image,size: 12,color: AppColors.grey,)),
//               ),
//             ),
//           ),
//
//           /// CONTROLS
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 /// ACTIVE SWITCH
//                 // Switch(
//                 //   value: img.isActive ?? true,
//                 //   onChanged: (val) {
//                 //     setState(() {
//                 //       img.isActive = val;
//                 //     });
//                 //   },
//                 // ),
//
//                 /// EDIT BUTTON
//                 IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.blue),
//                   onPressed: () => editImage(index),
//                 ),
//
//                 /// DELETE BUTTON
//                 IconButton(
//                   icon:  Icon(Icons.delete, color: Colors.red,),
//                   onPressed: () => deleteImage(index),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:get/get.dart';
// import 'package:locate_your_dentist/api/api.dart';
// import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
// import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
// import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
// import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
// import '../../common_widgets/color_code.dart';
//
// class UploadImagesWeb extends StatefulWidget {
//   const UploadImagesWeb({super.key});
//
//   @override
//   State<UploadImagesWeb> createState() => _UploadImagesWebState();
// }
//
// class _UploadImagesWebState extends State<UploadImagesWeb> {
//   final ImagePicker picker = ImagePicker();
//   final PlanController planController = Get.put(PlanController());
//   String? startDate;
//   String? endDate;
//
//   @override
//   void initState() {
//     super.initState();
//     String userType = Api.userInfo.read('userType') ?? "";
//     planController.selectedUserType = "Dental Clinic";
//     planController.getUploadImages(
//       userId: userType == 'superAdmin' ? "" : Api.userInfo.read('userId') ?? "",
//       userType: planController.selectedUserType!,
//       context: context,
//     );
//     planController.checkPlansStatus(Api.userInfo.read('userId') ?? "", context);
//   }
//
//   Future<void> pickImages() async {
//     final List<XFile>? picked = await picker.pickMultiImage();
//     if (picked == null) return;
//
//     for (var file in picked) {
//       final bytes = await file.readAsBytes();
//       final appImage2 = AppImage2(bytes: bytes, isActive: true);
//       setState(() {
//         planController.editUploadImage1.add(appImage2);
//       });
//     }
//     planController.update();
//   }
//
//   void deleteImage(int index) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Delete Image"),
//         content: const Text("Are you sure you want to delete this image?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               planController.editUploadImage1.removeAt(index);
//               planController.update();
//               Navigator.pop(context);
//             },
//             child: const Text("Delete"),
//           )
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       appBar: CommonWebAppBar(
//         height: width * 0.08,
//         title: "LOCATE YOUR DENTIST",
//         onLogout: () {},
//         onNotification: () {},
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: pickImages,
//         child: const Icon(Icons.add),
//       ),
//       body: GetBuilder<PlanController>(
//         builder: (controller) {
//           return Row(
//             children: [
//               const AdminSideBar(),
//               Expanded(
//                 child: Center(
//                   child: Container(
//                     width: 1200,
//                     padding: const EdgeInsets.all(30),
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: width * 0.35,
//                           child: CustomDropdownField(
//                             hint: "Select User Type",
//                             borderColor: AppColors.grey,
//                             fillColor: AppColors.white,
//                             items: const [
//                               "Dental Clinic",
//                               "Dental Lab",
//                               "Dental Shop",
//                               "Dental Mechanic",
//                               "Dental Consultant",
//                               "Job Seekers"
//                             ],
//                             selectedValue: controller.selectedUserType,
//                             onChanged: (value) async {
//                               controller.selectedUserType = value;
//                               await planController.getUploadImages(
//                                   userType: controller.selectedUserType!,
//                                   context: context);
//                               await planController.getPostImagePlanList(
//                                   controller.selectedUserType!, context);
//                               planController.update();
//                             },
//                           ),
//                         ),
//                         SizedBox(height: width * 0.02),
//                         if (controller.editUploadImage1.isEmpty)
//                           const Center(
//                             child: Text(
//                               "No Images Found",
//                               style: TextStyle(fontSize: 20),
//                             ),
//                           ),
//                         Flexible(
//                           child: GridView.builder(
//                             itemCount: controller.editUploadImage1.length + 1,
//                             gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               crossAxisSpacing: 25,
//                               mainAxisSpacing: 25,
//                               childAspectRatio: 1.3,
//                             ),
//                             itemBuilder: (context, index) {
//                               if (index < controller.editUploadImage1.length) {
//                                 final img = controller.editUploadImage1[index];
//                                 return _imageCard(img, index);
//                               }
//                               return GestureDetector(
//                                 onTap: pickImages,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(15),
//                                     border: Border.all(color: Colors.grey),
//                                     color: Colors.grey.shade200,
//                                   ),
//                                   child: const Center(
//                                     child: Icon(Icons.add,
//                                         size: 40, color: Colors.grey),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//   Widget _imageCard(AppImage2 img, int index) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
//       ),
//       child: Column(
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius:
//               const BorderRadius.vertical(top: Radius.circular(15)),
//               child: img.bytes != null
//                   ? Image.memory(img.bytes!,
//                   width: double.infinity, fit: BoxFit.cover)
//                   : (img.url != null && img.url!.isNotEmpty)
//                   ? Image.network(img.url!,
//                   width: double.infinity, fit: BoxFit.cover)
//                   : Container(
//                 color: Colors.grey.shade200,
//                 child: Center(
//                   child: Icon(Icons.image,
//                       size: 40, color: AppColors.grey),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.blue),
//                   onPressed: () => editImage(index),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () => deleteImage(index),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> editImage(int index) async {
//     final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked == null) return;
//     final bytes = await picked.readAsBytes();
//     planController.editUploadImage1[index] =
//         AppImage2(bytes: bytes, isActive: true);
//     planController.update();
//   }
// }
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
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
  // Future<void> pickImages() async {
  //   final List<XFile>? pickedImages = await picker.pickMultiImage();
  //   if (pickedImages == null || pickedImages.isEmpty) return;
  //
  //   const int maxImages = 20;
  //   final int availableSlots = maxImages - planController.editUploadImage.length;
  //
  //   if (availableSlots <= 0) {
  //     Get.snackbar("Limit reached", "You can upload only $maxImages images");
  //     return;
  //   }
  //
  //   final limited = pickedImages.take(availableSlots);
  //
  //   for (var file in limited) {
  //     final bytes = await file.readAsBytes();
  //     final appImage2 = AppImage2(
  //       bytes: bytes,
  //       file: kIsWeb ? null : File(file.path),
  //       isActive: true,
  //       url: kIsWeb ? file.path : null,
  //     );
  //
  //     setState(() {
  //       planController.editUploadImage1.add(appImage2);
  //     });
  //   }
  //
  //   planController.update();
  // }
  List<Uint8List> images = [];
//
  Future<void> pickImages() async {
    final List<XFile>? picked = await picker.pickMultiImage();
    if (picked == null) return;
    if (kIsWeb) {
      for (var file in picked) {
        final bytes = await file.readAsBytes();
        final appImage2 = AppImage2(bytes: bytes, isActive: true);

        setState(() {
          planController.editUploadImage1.add(appImage2);
        });
      }
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
        height: size * 0.08,
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
                                  // SizedBox(
                                  //   height: size * 1.4,
                                  //   child: GetBuilder<PlanController>(
                                  //       builder: (controller) {
                                  //         return ListView.builder(
                                  //           scrollDirection: Axis.vertical,
                                  //           physics: const AlwaysScrollableScrollPhysics(),
                                  //           shrinkWrap: true,
                                  //           itemCount: controller.editUploadImage1.length < 20 ? controller.editUploadImage1.length + 1
                                  //               : controller.editUploadImage1.length,
                                  //           itemBuilder: (_, index) {
                                  //             if (index < controller.editUploadImage1.length) {
                                  //               //final img = controller.editUploadImage[index];
                                  //               // final image = controller.posterImage[index];
                                  //               final image = controller.posterImage[index];
                                  //               final img = index < controller.editUploadImage1.length
                                  //                   ? controller.editUploadImage1[index]
                                  //                   : null;
                                  //               return Column(
                                  //                 children: [
                                  //                   Row(
                                  //                     children: [
                                  //                       SizedBox(
                                  //                         width:size*0.5,
                                  //                         child: GetBuilder<PlanController>(
                                  //                             builder: (controller) {
                                  //
                                  //                               return GestureDetector(
                                  //                                 child: DropdownButtonFormField<String>(
                                  //                                   //value: controller.selectedPlanId,
                                  //                                   value:controller.selectedPlanId,
                                  //                                   // controller.postImagePlanList
                                  //                                   //     .any((plan) => plan.id == controller.selectedPlanId)
                                  //                                   //     ? controller.selectedPlanId
                                  //                                   //     : null,
                                  //                                   hint: Text(
                                  //                                     "Select Plan",
                                  //                                     style: AppTextStyles.caption(context),
                                  //                                   ),
                                  //                                   items: controller.postImagePlanList.map((plan) {
                                  //                                     var dates=  calculatePlanDates(plan.duration.toString());
                                  //                                     //var dates=  calculatePlanDates("5");
                                  //                                     print(dates["startDate"]);
                                  //                                     print("duration${plan.duration.toString()}");
                                  //                                     print("endDate ${dates["endDate"]}");
                                  //                                     startDate=dates["startDate"].toString();
                                  //                                     endDate=dates["endDate"].toString();
                                  //                                     return DropdownMenuItem<String>(
                                  //                                       value: plan.id,
                                  //                                       child: Text(
                                  //                                         "${plan.postPlanName} - (${plan.duration} days)",
                                  //                                         style: AppTextStyles.caption(context),
                                  //                                       ),
                                  //                                     );
                                  //                                   }).toList(),
                                  //                                   onChanged: (value) async{
                                  //                                     //setState(()async {
                                  //                                     //controller.selectedPlanId = value;
                                  //                                     image.id=value;
                                  //                                     String? isActive1;
                                  //                                     String?  startDate1;
                                  //                                     String? endDate1;
                                  //                                     if(userType!='superAdmin') {
                                  //                                       isActive1  = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["isActive"] ?? "false";
                                  //                                       startDate1 = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["startDate"] ?? "";
                                  //                                       endDate1   = planController.checkPlanList[0]["details"]?["plan"]["posterPlan"]?["endDate"] ?? "";
                                  //                                     }
                                  //                                     List<File> filesToUpload = planController.editUploadImage1
                                  //                                         .where((img) => img.file != null)
                                  //                                         .map((img) => img.file!)
                                  //                                         .toList();
                                  //                                     if (img != null && img.file != null) {
                                  //                                       filesToUpload.add(img.file!);
                                  //                                     }
                                  //                                     final posterId = planController.posterImage.isNotEmpty
                                  //                                         ? image.id.toString() : "0";
                                  //
                                  //                                     print('FDGFN $posterId fgf');
                                  //                                     final isActive = planController.posterImage.isNotEmpty
                                  //                                         ? image.isActive.toString()
                                  //                                         : "false";
                                  //
                                  //                                     print('ffvxcb $isActive');
                                  //                                     userType=='superAdmin'?
                                  //                                     // await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,"0","0",startDate.toString(),endDate.toString(),"true",filesToUpload, context):
                                  //                                     await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,posterId,"1",startDate.toString(),endDate.toString(),isActive,filesToUpload, context):
                                  //                                     // await  planController.uploadImagesUserType(Api.userInfo.read('userId'), userType,planController.posterImage.first.id.toString().isNotEmpty?planController.posterImage.first.id.toString():"0",planController.posterImage.first.preference.toString(),startDate1.toString(),endDate1.toString(),isActive1.toString(),filesToUpload,context);
                                  //                                     await  planController.uploadImagesUserType(Api.userInfo.read('userId'), userType,posterId,"1",startDate1.toString(),endDate1.toString(),isActive1.toString(),filesToUpload,context);
                                  //                                   },),
                                  //                               );
                                  //                             }
                                  //                         ),
                                  //                       ),
                                  //
                                  //                       GetBuilder<PlanController>(
                                  //                           builder: (controller) {
                                  //                             return Switch(
                                  //                               value: image.isActive ?? true,
                                  //                               activeColor: (image.isActive == true) ? AppColors.primary : Colors.red,
                                  //                               activeTrackColor: AppColors.primary.withOpacity(0.5),
                                  //                               inactiveThumbColor: Colors.red,
                                  //                               inactiveTrackColor: Colors.grey.shade400,
                                  //                               onChanged: (value) {
                                  //                                 showDeactivateConfirmDialog(
                                  //                                   context: context,
                                  //                                   isActivating: value,
                                  //                                   onConfirm: () async {
                                  //                                     final posterId = planController.posterImage.isNotEmpty
                                  //                                         ? image.id.toString()
                                  //                                         : "0";
                                  //                                     List<File> filesToUpload = planController.editUploadImage1
                                  //                                         .where((img) => img.file != null)
                                  //                                         .map((img) => img.file!)
                                  //                                         .toList();
                                  //
                                  //                                     if (planController.posterImage.isNotEmpty) {
                                  //                                       final path = planController.posterImage.first?.path;
                                  //                                       if (path != null) filesToUpload.add(File(path));
                                  //                                     }
                                  //                                     await planController.uploadImagesUserType(
                                  //                                       Api.userInfo.read('userId'),
                                  //                                       planController.selectedUserType!,
                                  //                                       posterId,
                                  //                                       "1",
                                  //                                       startDate.toString(),
                                  //                                       endDate.toString(),
                                  //                                       value.toString(),
                                  //                                       filesToUpload,
                                  //                                       context,
                                  //                                     );
                                  //                                     setState(() {
                                  //                                       if (controller.posterImage.isNotEmpty) {
                                  //                                         image.isActive = value;
                                  //                                       }
                                  //                                     });
                                  //                                   },
                                  //                                 );
                                  //                               },
                                  //
                                  //                               //  onChanged: (value) {
                                  //                               //   showDeactivateConfirmDialog(
                                  //                               //     context: context,
                                  //                               //     isActivating: value,
                                  //                               //     onConfirm: () async{
                                  //                               //       final posterId = planController.posterImage.isNotEmpty
                                  //                               //           ? planController.posterImage.first.id.toString()
                                  //                               //           : "0";
                                  //                               //       List<File> filesToUpload = planController.editUploadImage
                                  //                               //           .where((img) => img.file != null)
                                  //                               //           .map((img) => img.file!)
                                  //                               //           .toList();
                                  //                               //         if (planController.posterImage.isNotEmpty) {
                                  //                               //         final path = planController.posterImage.first?.path;
                                  //                               //         if (path != null) {
                                  //                               //           filesToUpload.add(File(path));
                                  //                               //         }}
                                  //                               //       if(controller.posterImage.first.isActive==true)
                                  //                               //       await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,posterId,"1",startDate.toString(),endDate.toString(),"false",filesToUpload, context);
                                  //                               //       else{
                                  //                               //         await  planController.uploadImagesUserType(Api.userInfo.read('userId'), planController.selectedUserType!,posterId,"1",startDate.toString(),endDate.toString(),"true",filesToUpload, context);
                                  //                               //         planController.getUploadImages(userId:userType=='superAdmin'?"":Api.userInfo.read('userId')??"",userType: Api.userInfo.read('userType')??"",context: context);
                                  //                               //
                                  //                               //       }
                                  //                               //
                                  //                               //     },
                                  //                               //   );
                                  //                               // },
                                  //                             );
                                  //                           }
                                  //                       ),
                                  //                     ],
                                  //                   ),
                                  //                   Container(
                                  //                     margin: const EdgeInsets.all(8),
                                  //                     width: size ,
                                  //                     height: size * 0.3,
                                  //                     child: Stack(
                                  //                       children: [
                                  //                         ClipRRect(
                                  //                           borderRadius: BorderRadius.circular(10),
                                  //                           child: img!.file != null
                                  //                               ? Image.file(
                                  //                             img.file!,
                                  //                             fit: BoxFit.cover,
                                  //                             width: size ,
                                  //                             height: size * 0.35,
                                  //                           )
                                  //                               : (img.url != null && img.url!.isNotEmpty
                                  //                               ? Image.network(
                                  //                             img.url!, width: size ,
                                  //
                                  //                             fit: BoxFit.cover,
                                  //                           )
                                  //                               : Container(
                                  //                             color: Colors.grey.shade200,
                                  //                             child: const Center(child: Icon(Icons.image)),
                                  //                           )),
                                  //                         ),
                                  //                         Positioned(
                                  //                           right: 0,
                                  //                           top: 0,
                                  //                           child: GestureDetector(
                                  //                             onTap: () {
                                  //                               showDialog(
                                  //                                 context: context,
                                  //                                 builder: (_) => AlertDialog(
                                  //                                   title:  Text("Remove Image?",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                                  //                                   actions: [
                                  //                                     TextButton(
                                  //                                         onPressed: () =>
                                  //                                             Navigator.pop(context),
                                  //                                         child:  Text("Cancel",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),)),
                                  //                                     TextButton(
                                  //                                       onPressed: () async{
                                  //                                         if (index >= controller.editUploadImage1.length) return;
                                  //                                         final removedImage = controller.editUploadImage1[index];
                                  //                                         setState(() {
                                  //                                           controller.editUploadImage1.removeAt(index);
                                  //                                         });
                                  //                                         if (removedImage.url != null && removedImage.url!.isNotEmpty) {
                                  //                                           await loginController.deleteAwsFile(removedImage.url!,'postImage', context);
                                  //                                         }
                                  //                                         loginController.update();
                                  //                                         // setState(() async{
                                  //                                         //   controller.editUploadImage.removeAt(index);
                                  //                                         //   final certToDelete = loginController.editCertificates[index];
                                  //                                         //   if (certToDelete.url != null) {
                                  //                                         //     await loginController.deleteAwsFile(certToDelete.toString(), context);
                                  //                                         //     print('deleteFile ${certToDelete.url}');
                                  //                                         //   }
                                  //                                         //   controller.editUploadImage.removeAt(index);
                                  //                                         //   controller.editUploadImage.forEach((img) {
                                  //                                         //     print('after delete URL: ${img.url}');
                                  //                                         //   });
                                  //                                         //   loginController.update();
                                  //                                         //   Get.back();
                                  //                                         // });
                                  //                                         // Navigator.pop(context);
                                  //                                       },
                                  //                                       child:  Text("Remove",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: Colors.red),),
                                  //                                     ),
                                  //                                   ],
                                  //                                 ),
                                  //                               );
                                  //                             },
                                  //                             child: const Icon(Icons.cancel,
                                  //                                 color: Colors.black),
                                  //                           ),
                                  //                         ),
                                  //                         Positioned(
                                  //                           right: 5,
                                  //                           bottom: 5,
                                  //                           child: Container(
                                  //                             padding: const EdgeInsets.all(4),
                                  //                             decoration: BoxDecoration(
                                  //                               color: Colors.black54,
                                  //                               borderRadius: BorderRadius.circular(8),
                                  //                             ),
                                  //                             child:  IconButton(
                                  //                               onPressed:  () async {
                                  //                                 editingIndex = index;
                                  //                                 final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                                  //                                 if (picked != null) {
                                  //                                   setState(() {
                                  //                                     controller.editUploadImage1[index] = AppImage2(
                                  //                                       file: File(picked.path),
                                  //                                     );
                                  //
                                  //                                     controller.update();
                                  //                                   });
                                  //                                 }},
                                  //                               icon:Icon(Icons.edit,
                                  //                                   color: Colors.white, size: size*0.03),
                                  //                             ),
                                  //                           ),
                                  //                         )],
                                  //                     ),
                                  //                   ),
                                  //                 ],
                                  //               );
                                  //             }
                                  //             // Add image button
                                  //             return GestureDetector(
                                  //               onTap: pickImages,
                                  //               child: Container(
                                  //                 margin: const EdgeInsets.all(8),
                                  //                 width: size * 0.3,
                                  //                 height: size * 0.3,
                                  //                 decoration: BoxDecoration(
                                  //                   borderRadius: BorderRadius.circular(10),
                                  //                   border: Border.all(color: Colors.grey),
                                  //                   color: Colors.grey.shade200,
                                  //                 ),
                                  //                 child: const Center(
                                  //                   child: Icon(Icons.add, size: 40, color: Colors.grey),
                                  //                 ),
                                  //               ),
                                  //             );
                                  //           },
                                  //         );
                                  //       }
                                  //   ),
                                  // ),
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
                                                onPressed: pickImages,
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
                                            itemCount: controller.editUploadImage1.length,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 20,
                                              mainAxisSpacing: 20,
                                              childAspectRatio: 1.2,
                                            ),
                                            itemBuilder: (_, index) {
                                              final img = controller.editUploadImage1[index];
                                              final image = controller.editUploadImage1[index];

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
                                                  children: [

                                                    Expanded(
                                                      child: ClipRRect(
                                                        borderRadius: const BorderRadius.vertical(
                                                            top: Radius.circular(15)),
                                                    //     child: img.bytes != null
                                                    //         ? Image.memory(img.bytes!, fit: BoxFit.cover,
                                                    //     height: size*0.35,
                                                    //     width: size*0.35,
                                                    //     )
                                                    //         : Image.network(img.url ?? "",
                                                    //         height: size*0.35,
                                                    //         width: size*0.35,
                                                    //         fit: BoxFit.cover),
                                                    //   ),
                                                    // ),
                                                        child: img.bytes != null
                                                            ? Image.memory(
                                                          img.bytes!,
                                                          fit: BoxFit.cover,
                                                          width: double.infinity,
                                                          height: double.infinity,
                                                        )
                                                            : img.url != null
                                                            ? Image.network(
                                                          img.url!,
                                                          fit: BoxFit.cover,
                                                          width: double.infinity,
                                                          height: double.infinity,
                                                          errorBuilder: (_, __, ___) =>
                                                          const Icon(Icons.broken_image),
                                                        )
                                                            : const Icon(Icons.image_not_supported),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10),
                                                      child: Column(
                                                        children: [

                                                          // DropdownButtonFormField<String>(
                                                          //   //value: image.id,
                                                          //   value: controller.postImagePlanList
                                                          //       .any((plan) => plan.id == image.id)
                                                          //       ? image.id
                                                          //       : null,
                                                          //   hint: const Text("Select Plan"),
                                                          //   items: controller.postImagePlanList.map((plan) {
                                                          //     return DropdownMenuItem(
                                                          //       value: plan.id,
                                                          //       child: Text(
                                                          //           "${plan.postPlanName} (${plan.duration} days)"),
                                                          //     );
                                                          //   }).toList(),
                                                          //   onChanged: (value) {
                                                          //     image.id = value;
                                                          //   },
                                                          // ),
                                                          DropdownButtonFormField<String>(
                                                            value: controller.postImagePlanList
                                                                .any((plan) => plan.id == image.id)
                                                                ? image.id
                                                                : null,
                                                            hint:  Text("Select Plan",style: AppTextStyles.caption(context),),
                                                            items: {
                                                              for (var plan in controller.postImagePlanList) plan.id: plan
                                                            }.values.map((plan) {
                                                              return DropdownMenuItem<String>(
                                                                value: plan.id,
                                                                child: Text("${plan.postPlanName} (${plan.duration} days)",style: AppTextStyles.caption(context),),
                                                              );
                                                            }).toList(),
                                                            onChanged: (value)async {
                                                              image.id = value;
                                                              controller.update();
                                                              //image.id=value;
                                                              String? isActive1;
                                                              String?  startDate1;
                                                              String? endDate1;
                                                              // if(userType!='superAdmin') {
                                                              //   isActive1  = planController.checkPlanList[index]["details"]?["plan"]["posterPlan"]?["isActive"] ?? "false";
                                                              //   startDate1 = planController.checkPlanList[index]["details"]?["plan"]["posterPlan"]?["startDate"] ?? "";
                                                              //   endDate1   = planController.checkPlanList[index]["details"]?["plan"]["posterPlan"]?["endDate"] ?? "";
                                                              // }
                                                              if (userType != 'superAdmin' &&
                                                                  planController.checkPlanList.isNotEmpty &&
                                                                  index < planController.checkPlanList.length) {

                                                                final planData = planController.checkPlanList[index];

                                                                isActive1  = planData["details"]?["plan"]?["posterPlan"]?["isActive"] ?? "false";
                                                                startDate1 = planData["details"]?["plan"]?["posterPlan"]?["startDate"] ?? "";
                                                                endDate1   = planData["details"]?["plan"]?["posterPlan"]?["endDate"] ?? "";
                                                              } else {
                                                                isActive1 = "false";
                                                                startDate1 = "";
                                                                endDate1 = "";
                                                              }
                                                              List<Uint8List> filesToUpload = planController.editUploadImage1
                                                                  .where((img) => img.bytes != null)
                                                                  .map((img) => img.bytes!)
                                                                  .toList();
                                                              if (img != null && img.bytes != null) {
                                                                filesToUpload.add(img.bytes!);
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

                                                            },
                                                          ),
                                                          const SizedBox(height: 10),

                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Switch(
                                                                value: image.isActive ?? true,
                                                                onChanged: (val) async{
                                                                  image.isActive = val;
                                                                  final posterId = planController.posterImage.isNotEmpty
                                                                      ? image.id.toString()
                                                                      : "0";
                                                                  List<Uint8List> filesToUpload = planController.editUploadImage1
                                                                      .where((img) => img.bytes != null)
                                                                      .map((img) => img.bytes!)
                                                                      .toList();

                                                                  // if (planController.posterImage.isNotEmpty) {
                                                                  //   final path = planController.posterImage.first?.path;
                                                                  //   if (path != null) filesToUpload.add(File(path!));
                                                                  // }
                                                                  await planController.uploadImagesUserType(
                                                                    Api.userInfo.read('userId'),
                                                                    planController.selectedUserType!,
                                                                    posterId,
                                                                    "1",
                                                                    startDate.toString(),
                                                                    endDate.toString(),
                                                                    val.toString(),
                                                                    filesToUpload,
                                                                    context,
                                                                  );
                                                                  // setState(() {
                                                                  //   if (controller.posterImage.isNotEmpty) {
                                                                  //     image.isActive = val;
                                                                  //   }
                                                                  // });
                                                                  // controller.update();
                                                                },
                                                              ),

                                                              Row(
                                                                children: [
                                                                  IconButton(
                                                                    icon: const Icon(Icons.edit),
                                                                    onPressed: () async {
                                                                      final picked = await picker.pickImage(
                                                                          source: ImageSource.gallery);
                                                                      if (picked != null) {
                                                                        controller.editUploadImage1[index] =
                                                                            AppImage2(
                                                                              file: File(picked.path),
                                                                            );
                                                                        controller.update();
                                                                      }
                                                                    },
                                                                  ),

                                                                  // Delete
                                                                  IconButton(
                                                                    icon:  Icon(Icons.delete,
                                                                        color: Colors.red,size: size*0.012,),
                                                                    onPressed: () {
                                                                      controller.editUploadImage1
                                                                          .removeAt(index);
                                                                      controller.update();
                                                                    },
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
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