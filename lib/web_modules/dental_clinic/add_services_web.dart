import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../common_widgets/color_code.dart';


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

class AddProductWebPage extends StatefulWidget {
  const AddProductWebPage({super.key});

  @override
  State<AddProductWebPage> createState() => _AddProductWebPageState();
}

class _AddProductWebPageState extends State<AddProductWebPage> {
  final _formKeyAddProductWeb = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final serviceController = Get.put(ServiceController());
  final loginController = Get.put(LoginController());

  String? selectedUserType;
  List<Map<String, String>> addList = [];
  //List<Uint8List> serviceFileImages = [];
  List<AppImage> serviceFileImages = [];
  @override
  void initState() {
    super.initState();
    _updateFields();
    selectedUserType = Api.userInfo.read('userType') ?? "";
    loginController.getProfileByUserId(Api.userInfo.read('userId') ?? "", context);
    serviceController.selectedServiceId.toString().isNotEmpty ? serviceController.selectedServiceId.toString() : "0";
    //serviceFileImages =serviceFileImages ?? <AppImage>[];
  }
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
  Future<void> _refresh() async {
    _updateFields();
    selectedUserType = Api.userInfo.read('userType') ?? "";
    //await loginController.getProfileByUserId(Api.userInfo.read('userId') ?? "", context);
    serviceController.selectedServiceId.toString().isNotEmpty ? serviceController.selectedServiceId.toString() : "0";
  }
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
  Future<void> confirmRemoveImage(BuildContext ctx, int index) async {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title:  Text("Remove Image",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
        content:  Text("Are you sure you want to remove this image?",style: AppTextStyles.caption(context),),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child:  Text("Cancel",style: AppTextStyles.caption(context),)),
          TextButton(onPressed: () {
           serviceFileImages.removeAt(index);
            loginController.update();
            Navigator.pop(c);
          }, child:  Text("Remove",style: AppTextStyles.caption(context,),)),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    selectedUserType = Api.userInfo.read('userType') ?? "";
    return Scaffold(
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Row(
          children: [
            const AdminSideBar(),
            Expanded(
              child: Center(
                child: Form(
                  key: _formKeyAddProductWeb,
                  child: GetBuilder<LoginController>(
                    builder: (controller) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1000),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        selectedUserType == 'Dental Clinic' ? 'Service Details' : 'Product Details',
                                        style: AppTextStyles.subtitle(context, color: AppColors.black),
                                      ),
                                    ),
                                    SizedBox(height: size*0.01),

                                    Text('Title', style: AppTextStyles.caption(context, color: AppColors.black, fontWeight: FontWeight.bold)),
                                    SizedBox(height: size*0.01),
                                    CustomTextField(
                                      hint: addList.isNotEmpty ? addList[0]["fieldName"]! : "",
                                      controller: serviceController.titleController,
                                      borderColor: AppColors.white,
                                      fillColor: Colors.grey.shade100,
                                    ),

                                    // Description
                                    SizedBox(height: size*0.01),
                                    Text('Description', style: AppTextStyles.caption(context, color: AppColors.black, fontWeight: FontWeight.bold)),
                                    SizedBox(height: size*0.01),
                                    CustomTextField(
                                      hint: addList.length > 1 ? addList[1]["fieldName"]! : "",
                                      controller: serviceController.descriptionController,
                                      borderColor: AppColors.white,
                                      fillColor: Colors.grey.shade100,
                                      maxLines: 4,
                                    ),

                                    // Price
                                    SizedBox(height: size*0.01),
                                    Text('Price', style: AppTextStyles.caption(context, color: AppColors.black, fontWeight: FontWeight.bold)),
                                    SizedBox(height: size*0.01),
                                    CustomTextField(
                                      hint: addList.length > 2 ? addList[2]["fieldName"]! : "",
                                      controller: serviceController.costController,
                                      borderColor: AppColors.white,
                                      fillColor: Colors.grey.shade100,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                    ),

                                    // Images
                                    SizedBox(height: size*0.01),
                                    Text('Images', style: AppTextStyles.caption(context, color: AppColors.black, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    SizedBox(
                                      height: size * 0.135,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: loginController.serviceFileImages.length<3?loginController.serviceFileImages.length+1 :loginController.serviceFileImages.length ,
                                        itemBuilder: (context, index) {
                                          if (index == loginController.serviceFileImages.length && loginController.serviceFileImages.length < 3) {
                                            return GestureDetector(
                                              onTap: pickImages,
                                              child: Container(
                                                margin: const EdgeInsets.all(8),
                                                width: size * 0.095,
                                                height: size * 0.21,
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
                                            imageWidget = Image.memory(img.bytes!, fit: BoxFit.cover,width: size * 0.095,
                                              height: size * 0.21,);
                                          } else if (img.file != null) {
                                            imageWidget = Image.file(img.file!, fit: BoxFit.cover,width: size * 0.095,
                                              height: size * 0.21,);
                                          } else if (img.url != null && img.url!.isNotEmpty) {
                                            imageWidget = Image.network(
                                              img.url!,
                                              fit: BoxFit.cover,width: size * 0.095,
                                              height: size * 0.21,
                                              errorBuilder: (_, __, ___) =>  Icon(Icons.broken_image,size: size*0.012),
                                            );
                                          } else {
                                            imageWidget =  Container(child: Center(child: Icon(Icons.image_not_supported,color: Colors.red, size: size*0.02)));
                                          }
                                          return Container(
                                            margin: const EdgeInsets.all(8),
                                            width: size * 0.095,
                                            height: size * 0.021,
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
                                                    child:  Icon(Icons.cancel, color: Colors.red, size: size*0.012),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Center(child: Text("** maximum 3 images allowed", style: AppTextStyles.caption(context, color: Colors.red))),

                                    const SizedBox(height: 20),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: ()async {
                                          if (_formKeyAddProductWeb.currentState!.validate()) {
                                            final existingUrls = loginController.serviceFileImages
                                                .where((img) => img.url != null && img.url!.isNotEmpty)
                                                .map((img) => img.url!)
                                                .toList();
                                            print('new existingUrls img${existingUrls}');
                                            final newImageBytes = loginController.serviceFileImages
                                                .where((img) => img.bytes != null)
                                                .map((img) => img.bytes!)
                                                .toList();
                                            print('new service img${newImageBytes}');
                                            final newImageFiles = serviceFileImages
                                                .where((img) => img.file != null)
                                                .map((img) => img.file!)
                                                .toList();

                                         await   serviceController.createServiceAdmin(
                                              serviceController.selectedServiceId.toString(),
                                              loginController.selectUserId!,
                                              loginController.selectedUserType.toString(),
                                              serviceController.titleController.text,
                                              serviceController.descriptionController.text,
                                              serviceController.costController.text,
                                              newImageBytes,
                                              existingUrls,
                                              context,
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: Text(
                                          selectedUserType == 'Dental Clinic' ? 'Add Service' : 'Add Product',
                                          style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}