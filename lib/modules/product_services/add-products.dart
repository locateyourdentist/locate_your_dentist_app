import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import '../../common_widgets/color_code.dart';
import 'package:get/get.dart';
class AppImage {
  Uint8List? bytes;
  String? url;
  final File? file;
  bool isActive;

  AppImage({this.bytes, this.url, this.file, this.isActive = true});

  Widget buildWidget({
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    placeholder ??= Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: width * 0.5),
    );

    if (kIsWeb) {
      if (bytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(bytes!, width: width, height: height, fit: fit),
        );
      }
      if (url != null && url!.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(url!, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) => placeholder!),
        );
      }
      return placeholder;
    }

    if (file != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(file!, width: width, height: height, fit: fit),
      );
    }
    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bytes!, width: width, height: height, fit: fit),
      );
    }
    if (url != null && url!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(url!, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) => placeholder!),
      );
    }
    return placeholder;
  }
}

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});
  @override
  State<AddProduct> createState() => _AddProductState();
}
class _AddProductState extends State<AddProduct> {
  final _formKeyAddProduct = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  List<AppImage> serviceFileImages = [];
  final serviceController = Get.put(ServiceController());
  final loginController = Get.put(LoginController());
  String? selectedUserType;
  List<Map<String, String>> addList = [];

  void _updateFields() {
    if (Api.userInfo.read('userType') == 'Dental Clinic') {
      addList = [
        {"fieldName": "Service Title"},
        {"fieldName": "Service Description"},
        {"fieldName": "Service Cost"},
      ];
    } else {
      addList = [
        {"fieldName": "Product Title"},
        {"fieldName": "Product Description"},
        {"fieldName": "Product Cost"},
      ];
    }
    setState(() {});
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _updateFields();
    selectedUserType = Api.userInfo.read('userType') ?? "";
    // loginController.getProfileByUserId(
    //     Api.userInfo.read('userId') ?? "", context);
    serviceController.selectedServiceId
        .toString()
        .isNotEmpty ? serviceController.selectedServiceId.toString() : "0";
  }

  Future<void> _refresh() async {
    _updateFields();
    selectedUserType = Api.userInfo.read('userType') ?? "";
    loginController.getProfileByUserId(
        Api.userInfo.read('userId') ?? "", context);
    serviceController.selectedServiceId
        .toString()
        .isNotEmpty ? serviceController.selectedServiceId.toString() : "0";
  }
  // Future<void> pickImages() async {
  //   const maxImages = 3;
  //   final existingCount = loginController.serviceFileImages.length;
  //   final remaining = maxImages - existingCount;
  //   if (remaining <= 0) {
  //     Get.snackbar("Error", "Maximum $maxImages images allowed");
  //     return;
  //   }
  //   try {
  //     final List<XFile>? selected = await _picker.pickMultiImage();
  //     if (selected != null && selected.isNotEmpty) {
  //       final limited = selected.take(remaining).toList();
  //       for (final x in limited) {
  //         if (kIsWeb) {
  //           final bytes = await x.readAsBytes();
  //           serviceFileImages.add(AppImage(bytes: bytes));
  //         } else {
  //           serviceFileImages.add(AppImage(file: File(x.path)));
  //         }
  //       }
  //       loginController.update();
  //       if (selected.length > remaining) {
  //         Get.snackbar("Info", "Only $remaining more images allowed");
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Error picking images: $e");
  //     Get.snackbar("Error", "Failed to pick images");
  //   }
  // }
  bool isPicking = false;

  Future<void> pickImages() async {
    if (isPicking) return;
    isPicking = true;

    const maxImages = 3;
    final existingCount = loginController.serviceFileImages.length;
    final remaining = maxImages - existingCount;

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
            loginController.serviceFileImages.add(AppImage2(bytes: bytes));
          } else {
            loginController.serviceFileImages.add(AppImage2(file: File(x.path)));
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
  Future<List<Uint8List>> getImageBytes() async {
    List<Uint8List> imageBytes = [];

    for (var img in loginController.serviceFileImages) {
      if (img.bytes != null) {
        imageBytes.add(img.bytes!);
      } else if (img.file != null) {
        final bytes = await img.file!.readAsBytes();
        imageBytes.add(bytes);
      }
    }
    return imageBytes;
  }
  Future<void> confirmRemoveImage(BuildContext ctx, int index) async {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title:  Text("Remove Image",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold)),
        content:  Text("Are you sure you want to remove this image?",style: AppTextStyles.caption(context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child:  Text("Cancel",style: AppTextStyles.caption(context))),
          TextButton(onPressed: ()async {
            serviceFileImages.removeAt(index);
          //  await loginController.deleteAwsFile(loginController.appLogoUrl.toString(),'appLogo',context);

            loginController.update();
            Navigator.pop(c);
          }, child:  Text("Remove",style: AppTextStyles.caption(context),)),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: Text(
          selectedUserType == 'Dental Clinic'
              ? 'Add New Service'
              : 'Add New Product',
          style: AppTextStyles.subtitle(context, color: AppColors.black),
        ),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: AppColors.black, size: size * 0.05),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Get.back();
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
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Form(
            key: _formKeyAddProduct,
            child: GetBuilder<LoginController>(
                builder: (controller) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dropdown to select user type
                            const SizedBox(height: 5),

                            //                        Text(
                            //   selectedUserType == 'Dental Clinic'
                            //       ? 'Service Details'
                            //       : 'Product Details',
                            //   style: AppTextStyles.subtitle(context, color: AppColors.black),
                            // ),
                            // SizedBox(height: size * 0.01),

                            Text('Title',
                              style: AppTextStyles.caption(
                                  context, color: AppColors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: size * 0.02),

                            CustomTextField(
                              hint: addList.isNotEmpty
                                  ? addList[0]["fieldName"]!
                                  : "",
                              controller: serviceController.titleController,
                              borderColor: AppColors.white,
                              fillColor: Colors.grey.shade100,
                            ),
                            SizedBox(height: size * 0.02),
                            Text('Description',
                              style: AppTextStyles.caption(
                                  context, color: AppColors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: size * 0.02),
                            CustomTextField(
                              hint: addList.length > 1
                                  ? addList[1]["fieldName"]!
                                  : "",
                              controller: serviceController
                                  .descriptionController,
                              borderColor: AppColors.white,
                              fillColor: Colors.grey.shade100,
                              maxLines: 4,
                            ),
                            SizedBox(height: size * 0.02),
                            Text('Price',
                              style: AppTextStyles.caption(
                                  context, color: AppColors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: size * 0.02),
                            CustomTextField(
                              hint: addList.length > 2
                                  ? addList[2]["fieldName"]!
                                  : "",
                              controller: serviceController.costController,
                              borderColor: AppColors.white,
                              fillColor: Colors.grey.shade100,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                            ),
                            SizedBox(height: size * 0.01),

                            Text('Images',
                              style: AppTextStyles.caption(
                                  context, color: AppColors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: size * 0.02),
                            Column(
                                children: [
                                  // SizedBox(
                                  //   height: size * 0.35,
                                  //   child: GetBuilder<LoginController>(
                                  //       builder: (controller) {
                                  //         return ListView.builder(
                                  //           scrollDirection: Axis.horizontal,
                                  //           itemCount: 3,
                                  //           itemBuilder: (_, index) {
                                  //             if (index < loginController.serviceFileImages.length) {
                                  //               final img = loginController.serviceFileImages[index];
                                  //               print('imhd url${img.url}');
                                  //               return Container(
                                  //                 margin: const EdgeInsets.all(8),
                                  //                 width: size * 0.3,
                                  //                 height: size * 0.3,
                                  //                 child: Stack(
                                  //                   children: [
                                  //                     ClipRRect(
                                  //                       borderRadius: BorderRadius
                                  //                           .circular(10),
                                  //                       child: img.file != null
                                  //                           ? Image.file(
                                  //                         img.file!,
                                  //                         fit: BoxFit.cover,
                                  //                         width: size * 0.3,
                                  //                         height: size * 0.3,
                                  //                       )
                                  //                           : Image.network(
                                  //                           img.url!,
                                  //                           fit: BoxFit.cover,
                                  //                           width: size * 0.3,
                                  //                           height: size * 0.3,
                                  //                           errorBuilder: (
                                  //                               context, error,
                                  //                               stackTrace) =>
                                  //                               Container(
                                  //                                 width: size * 0.3,
                                  //                                 height: size * 0.3,
                                  //                                 decoration: BoxDecoration(
                                  //                                   color: const Color(0xFFF1F3F6),
                                  //                                   borderRadius: BorderRadius.circular(16),
                                  //                                 ),
                                  //                                 child: Icon(
                                  //                                   Icons.image_outlined,
                                  //                                   color: Colors.grey.shade400,
                                  //                                   size: size * 0.08,
                                  //                                 ),
                                  //                               )),
                                  //                     ),
                                  //                     Positioned(
                                  //                       right: 0,
                                  //                       top: 0,
                                  //                       child: GestureDetector(
                                  //                         onTap: () async{
                                  //                           confirmRemoveImage(context, index, ()async {
                                  //                             String? pathToDelete;
                                  //                             if (img.url != null) {
                                  //                               pathToDelete = img.url;
                                  //                             }
                                  //                             if (pathToDelete != null) {
                                  //                               await loginController.deleteAwsFile(pathToDelete, '', context);
                                  //                             }
                                  //                             loginController.serviceFileImages.removeAt(index);
                                  //                             loginController.update();
                                  //                             Navigator.of(context).pop();
                                  //                           });
                                  //                         },
                                  //                         child:  Icon(Icons.cancel, color: Colors.black,size: size*0.06,),
                                  //                       ),
                                  //                     ),
                                  //                     Positioned(
                                  //                       right: 5,
                                  //                       bottom: 5,
                                  //                       child: Container(padding: const EdgeInsets.all(4),
                                  //                         decoration: BoxDecoration(
                                  //                             color: Colors.black54,
                                  //                             borderRadius: BorderRadius.circular(8)),
                                  //                         child: const Icon(Icons.edit,color: Colors.white,
                                  //                             size: 20),
                                  //                       ),
                                  //                     ),
                                  //                   ],
                                  //                 ),
                                  //               );
                                  //             }
                                  //             return GestureDetector(
                                  //               onTap: () => pickImages(),
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

                                  SizedBox(
                                    height: size * 0.35,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: loginController.serviceFileImages.length<3?loginController.serviceFileImages.length+1 :loginController.serviceFileImages.length ,
                                      itemBuilder: (context, index) {
                                        if (index == loginController.serviceFileImages.length && loginController.serviceFileImages.length < 3) {
                                          return GestureDetector(
                                            onTap: pickImages,
                                            child: Container(
                                              margin: const EdgeInsets.all(8),
                                              width: size * 0.35,
                                              height: size * 0.3,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: Colors.grey),
                                                color: Colors.grey.shade200,
                                              ),
                                              child:  Center(
                                                child: Icon(Icons.add, size: size*0.012, color: Colors.grey),
                                              ),
                                            ),
                                          );
                                        }
                                        final img = loginController.serviceFileImages[index];
                                        Widget imageWidget;
                                        if (kIsWeb && img.bytes != null) {
                                          imageWidget = Image.memory(img.bytes!, fit: BoxFit.cover,width: size * 0.35,
                                            height: size * 0.3,);
                                        } else if (img.file != null) {
                                          imageWidget = Image.file(img.file!, fit: BoxFit.cover,width: size * 0.35,
                                            height: size * 0.3,);
                                        } else if (img.url != null && img.url!.isNotEmpty) {
                                          imageWidget = Image.network(
                                            img.url!,
                                            fit: BoxFit.cover,width: size * 0.35,
                                            height: size * 0.3,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                          );
                                        } else {
                                          imageWidget =  Container(
                                              height: size * 0.012,
                                              child: Center(child: Icon(Icons.image_not_supported,color: Colors.red, size: size*0.02)));
                                        }
                                        return Container(
                                          margin: const EdgeInsets.all(8),
                                          width: size * 0.35,
                                          height: size * 0.3,
                                          child: Stack(
                                            children: [
                                              ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    loginController.serviceFileImages.removeAt(index);
                                                    loginController.update();
                                                  },
                                                  child:  Icon(Icons.cancel, color: Colors.grey, size: size*0.05),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: size * 0.35,
                                  //   child:  GetBuilder<ServiceController>(
                                  //       builder: (controller) {
                                  //         return  ListView.builder(
                                  //         scrollDirection: Axis.horizontal,
                                  //         itemCount: loginController.serviceFileImages.length<3?loginController.serviceFileImages.length+1 :loginController.serviceFileImages.length ,
                                  //         itemBuilder: (context, index) {
                                  //           if (index == loginController.serviceFileImages.length && loginController.serviceFileImages.length < 3) {
                                  //             return GestureDetector(
                                  //               onTap: pickImages,
                                  //               child: Container(
                                  //                 margin: const EdgeInsets.all(8),
                                  //                 width: size * 0.35,
                                  //                 height: size * 0.3,
                                  //                 decoration: BoxDecoration(
                                  //                   borderRadius: BorderRadius.circular(10),
                                  //                   border: Border.all(color: Colors.grey),
                                  //                   color: Colors.grey.shade200,
                                  //                 ),
                                  //                 child:  Center(
                                  //                   child: Icon(Icons.add, size: size*0.012, color: Colors.grey),
                                  //                 ),
                                  //               ),
                                  //             );
                                  //           }
                                  //           final img = loginController.serviceFileImages[index];
                                  //           Widget imageWidget;
                                  //           if (kIsWeb && img.bytes != null) {
                                  //             imageWidget = Image.memory(img.bytes!, fit: BoxFit.cover,width: size * 0.35,
                                  //               height: size * 0.3,);
                                  //           } else if (img.file != null) {
                                  //             imageWidget = Image.file(img.file!, fit: BoxFit.cover,width: size * 0.35,
                                  //               height: size * 0.3,);
                                  //           } else if (img.url != null && img.url!.isNotEmpty) {
                                  //             imageWidget = Image.network(
                                  //               img.url!,
                                  //               fit: BoxFit.cover,width: size * 0.35,
                                  //               height: size * 0.3,
                                  //               errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                  //             );
                                  //           } else {
                                  //             imageWidget =  Icon(Icons.image_not_supported,color: Colors.red, size: size*0.02);
                                  //           }
                                  //           return Container(
                                  //             margin: const EdgeInsets.all(8),
                                  //             width: size * 0.35,
                                  //             height: size * 0.3,
                                  //             child: Stack(
                                  //               children: [
                                  //                 ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
                                  //                 Positioned(
                                  //                   right: 0,
                                  //                   top: 0,
                                  //                   child: GestureDetector(
                                  //                     onTap: () {
                                  //                       loginController.serviceFileImages.removeAt(index);
                                  //                       loginController.update();
                                  //                     },
                                  //                     child:  Icon(Icons.cancel, color: Colors.red, size: size*0.05),
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           );
                                  //         },
                                  //       );
                                  //     }
                                  //   ),
                                  // ),
                                  Center(child: Text(
                                    "** maximum 3 images allowed",
                                    style: TextStyle(color: Colors.redAccent,
                                        fontSize: size * 0.019,
                                        fontWeight: FontWeight.normal),)),

                                  const SizedBox(height: 20),
                                  Center(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.secondary
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: ()async {
                                          if (_formKeyAddProduct.currentState!.validate()) {
                                            final existingUrls = loginController.serviceFileImages
                                                .where((img) => img.url != null && img.url!.isNotEmpty)
                                                .map((img) => img.url!)
                                                .toList();

                                            print('new existingUrls img${existingUrls}');

                                            final newImageFiles = serviceFileImages
                                                .where((img) => img.file != null)
                                                .map((img) => img.file!)
                                                .toList();
                                            final newImageBytes = await getImageBytes();

                                            print("Uploading images count: ${newImageBytes.length}");
                                           await serviceController
                                                .createServiceAdmin(
                                                serviceController.selectedServiceId.toString(),
                                                loginController.selectUserId!,
                                                loginController.selectedUserType.toString(),
                                                serviceController.titleController.text.toString(),
                                                serviceController.descriptionController.text.toString(),
                                                serviceController.costController.text.toString(),
                                               newImageBytes,
                                               existingUrls,
                                                context
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: AppColors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10),
                                          ),
                                        ),
                                        child: Text(
                                          selectedUserType == 'Dental Clinic'
                                              ? 'Add Service'
                                              : 'Add Product',
                                          style: AppTextStyles.caption(
                                            context,
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Buttons Row
                                ]),
                          ]
                      ),
                    ),);
                }
            )),
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
  Future<void> pickImages1() async {
    const maxImages = 3;
    int remaining = maxImages - loginController.serviceFileImages.length;
    if (remaining <= 0) {
      Get.snackbar("Error", "Maximum $maxImages images allowed");
      return;
    }

    try {
      final List<XFile>? selected = await _picker.pickMultiImage();
      if (selected != null && selected.isNotEmpty) {
        final limited = selected.take(remaining).toList();
        final newImages = limited.map((x) => AppImage2(file: File(x.path))).toList();
        loginController.serviceFileImages.addAll(newImages);
        loginController.update();
        if (selected.length > remaining) {
          showCustomToast(context, "Only $remaining more images allowed");
        }
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }
}
