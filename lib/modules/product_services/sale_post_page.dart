import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/modules/product_services/sale_post_controller.dart';
import '../../common_widgets/color_code.dart';
import '../../common_widgets/common_bottom_navigation.dart';

/// Hover/lift affordance (desktop & web pointers) used purely for a modern,
/// tactile feel on tappable cards/tiles; does not intercept taps.
class _HoverLift extends StatefulWidget {
  final Widget child;
  final double liftScale;
  final BorderRadius? borderRadius;
  const _HoverLift({
    required this.child,
    this.liftScale = 1.02,
    this.borderRadius,
  });

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _hovering ? -4.0 : 0.0)
          ..scale(_hovering ? widget.liftScale : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_hovering ? 0.18 : 0.0),
              blurRadius: _hovering ? 20 : 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// One picked photo, holding either raw bytes (web) or a local File
/// (mobile/desktop) so the same UI can render either source.
class _PickedImage {
  final Uint8List? bytes;
  final File? file;
  const _PickedImage({this.bytes, this.file});

  Widget preview({required double size}) {
    if (kIsWeb && bytes != null) {
      return Image.memory(bytes!, width: size, height: size, fit: BoxFit.cover);
    }
    if (file != null) {
      return Image.file(file!, width: size, height: size, fit: BoxFit.cover);
    }
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFF1F3F6),
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}

class SalePostPage extends StatefulWidget {
  const SalePostPage({super.key});

  @override
  State<SalePostPage> createState() => _SalePostPageState();
}

class _SalePostPageState extends State<SalePostPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final salePostController = Get.put(SalePostController());
  final PlanController planController = Get.put(PlanController());

  final mobileController = TextEditingController();
  final QuillController messageQuillController = QuillController.basic();
  final priceController = TextEditingController();

  final List<String> userTypes = const [
    "Dental Clinic",
    "Dental Shop",
    "Dental Lab",
    "Dental Mechanic",
    "Dental Professional",
  ];
  String? selectedUserType;
  bool negotiable = false;

  final List<_PickedImage> images = [];
  bool _isPicking = false;

  static const int maxImages = 3;

  @override
  void initState() {
    super.initState();
    planController.checkPlansStatus(Api.userInfo.read('userId') ?? "", context);
  }

  @override
  void dispose() {
    mobileController.dispose();
    messageQuillController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    if (_isPicking) return;
    _isPicking = true;

    final remaining = maxImages - images.length;
    if (remaining <= 0) {
      Get.snackbar("Limit reached", "Maximum $maxImages images allowed");
      _isPicking = false;
      return;
    }

    try {
      final List<XFile> selected = await _picker.pickMultiImage();
      if (selected.isNotEmpty) {
        final limited = selected.take(remaining).toList();
        for (final x in limited) {
          if (kIsWeb) {
            final bytes = await x.readAsBytes();
            images.add(_PickedImage(bytes: bytes));
          } else {
            images.add(_PickedImage(file: File(x.path)));
          }
        }
        if (selected.length > remaining) {
          Get.snackbar("Info", "Only $remaining more image(s) allowed");
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
      Get.snackbar("Error", "Failed to pick images");
    } finally {
      _isPicking = false;
    }
  }

  void _removeImage(int index) {
    setState(() => images.removeAt(index));
  }
  Future<void> _submitSalePost() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedUserType == null) {
      Get.snackbar("Missing info", "Please select a user type");
      return;
    }
    if (messageQuillController.document.toPlainText().trim().isEmpty) {
      Get.snackbar("Missing info", "Please describe the item you're selling");
      return;
    }
    final messageJson = jsonEncode(
      messageQuillController.document.toDelta().toJson(),
    );

    final bool isSuperAdmin = Api.userInfo.read('userType') == 'superAdmin';
    bool isBasePlanActive = false;
    bool isPosterPlanActive = false;
    if (planController.checkPlanList.isNotEmpty) {
      final planDetails = planController.checkPlanList[0]["details"]?["plan"];
      isBasePlanActive = planDetails?["basePlan"]?["isActive"] ?? false;
      isPosterPlanActive = planDetails?["posterPlan"]?["isActive"] ?? false;
    }
    if (!isSuperAdmin) {
      if (!isBasePlanActive) {
        showSuccessDialog(
          context,
          title: "Alert",
          message: "Oops! Base plan not Activated.please activate base plan..",
          onOkPressed: () {
            Get.toNamed('/viewPlanPage');
          },
        );
        return;
      }

      if (!isPosterPlanActive) {
        showSuccessDialog(
          context,
          title: "Poster Plan Required",
          message:
          "You need an active poster plan to post a sale listing. Please choose a plan to continue.",
          onOkPressed: () {
            Get.toNamed('/viewPlanPage');
          },
        );
        return;
      }
    }
    final imageBytes = await Future.wait(
      images.map((img) async {
        return img.bytes ?? await img.file!.readAsBytes();
      }),
    );

    Map<String, dynamic> responseData = {};
    try {
      final response = await Api().createSalePost(
        Api.userInfo.read('userId') ?? "",
        selectedUserType!,
        mobileController.text.trim(),
        messageJson,
        priceController.text.trim(),
        imageBytes,
      );
      debugPrint("create sale post status: ${response.statusCode}");
      responseData = jsonDecode(response.body);
    } catch (e) {
      debugPrint("create sale post error: $e");
      if (mounted) {
        Get.snackbar("Error", "Failed to post listing: $e");
      }
      return;
    }

    if (responseData['status']?.toString().toLowerCase() != 'success') {
      if (mounted) {
        showCustomToast(
          context,
          responseData['message']?.toString() ?? "Failed to post listing",
          backgroundColor: Colors.redAccent,
        );
      }
      return;
    }

    salePostController.addPost(
      SalePostItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        mobileNumber: mobileController.text.trim(),
        message: messageJson,
        price: priceController.text.trim(),
        negotiable: negotiable,
        userType: selectedUserType!,
        images: images
            .map((img) => PickedSaleImage(bytes: img.bytes, file: img.file))
            .toList(),
        postedAt: DateTime.now(),
      ),
    );

    showCustomToast(
      context,
      "Listing posted",
      backgroundColor: AppColors.primary,
    );
    Get.offNamed('/salePostListWebPage');
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 15, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.caption(
                  context,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.caption(
          context,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// GRADIENT HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _HoverLift(
                    liftScale: 1.08,
                    borderRadius: BorderRadius.circular(50),
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.18),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sell an Item",
                          style: TextStyle(
                            fontSize: size * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Post details for buyers to reach you",
                          style: TextStyle(
                            fontSize: size * 0.03,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        title: "Photos",
                        icon: Icons.photo_camera_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 96,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: images.length < maxImages
                                    ? images.length + 1
                                    : images.length,
                                itemBuilder: (context, index) {
                                  if (index == images.length &&
                                      images.length < maxImages) {
                                    return _HoverLift(
                                      liftScale: 1.04,
                                      borderRadius: BorderRadius.circular(14),
                                      child: GestureDetector(
                                        onTap: pickImages,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            color: AppColors.primary
                                                .withOpacity(0.06),
                                            border: Border.all(
                                              color: AppColors.primary
                                                  .withOpacity(0.25),
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.add_a_photo_outlined,
                                            color: AppColors.primary,
                                            size: 26,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  final img = images[index];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 90,
                                    height: 90,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: img.preview(size: 90),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Up to $maxImages photos",
                              style: AppTextStyles.caption(
                                context,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      _sectionCard(
                        title: "Listing Details",
                        icon: Icons.sell_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("Posting As"),
                            CustomDropdownField(
                              hint: "Select user type",
                              items: userTypes,
                              selectedValue: selectedUserType,
                              onChanged: (val) =>
                                  setState(() => selectedUserType = val),
                              fillColor: Colors.grey.shade100,
                              borderColor: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            _fieldLabel("Message"),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  QuillSimpleToolbar(
                                    controller: messageQuillController,
                                    config: const QuillSimpleToolbarConfig(
                                      embedButtons: [],
                                      showBackgroundColorButton: false,
                                      showSearchButton: false,
                                      multiRowsDisplay: false,
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  SizedBox(
                                    height: 300,
                                    child: QuillEditor.basic(
                                      controller: messageQuillController,
                                      config: const QuillEditorConfig(
                                        placeholder:
                                            "Describe the item you're selling...",
                                        padding: EdgeInsets.all(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _fieldLabel("Price"),
                            CustomTextField(
                              hint: "Enter price",
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              fillColor: Colors.grey.shade100,
                              borderColor: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            _HoverLift(
                              liftScale: 1.0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () =>
                                    setState(() => negotiable = !negotiable),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Price is negotiable",
                                          style: AppTextStyles.caption(
                                            context,
                                            color: AppColors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: negotiable,
                                        activeColor: AppColors.primary,
                                        onChanged: (val) =>
                                            setState(() => negotiable = val),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      _sectionCard(
                        title: "Contact Information",
                        icon: Icons.call_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("Mobile Number"),
                            CustomTextField(
                              hint: "Enter mobile number",
                              controller: mobileController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              fillColor: Colors.grey.shade100,
                              borderColor: Colors.white,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Mobile number cannot be empty";
                                }
                                if (!RegExp(
                                  r'^[0-9]{10}$',
                                ).hasMatch(value.trim())) {
                                  return "Enter a valid 10-digit mobile number";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      _HoverLift(
                        liftScale: 1.02,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _submitSalePost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              "Post Sale Instruments",
                              style: AppTextStyles.body(
                                context,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
