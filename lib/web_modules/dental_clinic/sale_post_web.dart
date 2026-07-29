import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/modules/product_services/sale_post_controller.dart';
import '../../common_widgets/color_code.dart';


class _HoverLift extends StatefulWidget {
  final Widget child;
  final double liftScale;
  final BorderRadius? borderRadius;
  const _HoverLift({required this.child, this.liftScale = 1.02, this.borderRadius});

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

class SalePostWebPage extends StatefulWidget {
  const SalePostWebPage({super.key});

  @override
  State<SalePostWebPage> createState() => _SalePostWebPageState();
}

class _SalePostWebPageState extends State<SalePostWebPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<ScaffoldState> _scaffoldKeySalePost = GlobalKey<ScaffoldState>();
  final salePostController = Get.put(SalePostController());

  final mobileController = TextEditingController();
  final messageController = TextEditingController();
  final priceController = TextEditingController();
  final PlanController planController = Get.put(PlanController());

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
    messageController.dispose();
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

    bool isBasePlanActive = false;
    bool isPosterPlanActive = false;
    if (planController.checkPlanList.isNotEmpty) {
      final planDetails = planController.checkPlanList[0]["details"]?["plan"];
      isBasePlanActive = planDetails?["basePlan"]?["isActive"] ?? false;
      isPosterPlanActive = planDetails?["posterPlan"]?["isActive"] ?? false;
    }

    if (Api.userInfo.read('userType')=='superAdmin'||!isBasePlanActive) {
      showSuccessDialog(
        context,
        title: "Alert",
        message: "Oops! Base plan not Activated.please activate base plan..",
        onOkPressed: () {
          Get.toNamed('/viewPlanPageWeb');
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
          Get.toNamed('/viewPlanPageWeb');
        },
      );
      return;
    }

    final imageBytes = await Future.wait(images.map((img) async {
      return img.bytes ?? await img.file!.readAsBytes();
    }));

    try {
      final response = await Api().createSalePost(
        Api.userInfo.read('userId') ?? "",
        selectedUserType!,
        mobileController.text.trim(),
        messageController.text.trim(),
        priceController.text.trim(),
        imageBytes,
      );
      debugPrint("create sale post status: ${response.statusCode}");
    } catch (e) {
      debugPrint("create sale post error: $e");
    }

    salePostController.addPost(
      SalePostItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        mobileNumber: mobileController.text.trim(),
        message: messageController.text.trim(),
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

  Widget _sectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.body(context, color: AppColors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
        style: AppTextStyles.caption(context, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    return Scaffold(
      key: _scaffoldKeySalePost,
      backgroundColor: const Color(0xFFF6F8FC),
      drawer: (isLoggedIn && !isDesktop)
          ? const Drawer(width: 250, child: AdminSideBar())
          : null,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: Row(
        children: [
          if (isDesktop && isLoggedIn) const AdminSideBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLoggedIn && !isDesktop)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.menu, color: AppColors.black),
                              onPressed: () =>
                                  _scaffoldKeySalePost.currentState?.openDrawer(),
                            ),
                          ),

                
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: isDesktop ? 36 : 26,
                            horizontal: isDesktop ? 40 : 22,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.sell_outlined, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Sell an Item",
                                      style: AppTextStyles.subtitle(context, color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Post details for buyers to reach you",
                                      style: AppTextStyles.caption(context, color: Colors.white.withOpacity(0.85)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _sectionCard(
                          title: "Photos",
                          icon: Icons.photo_camera_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  for (int index = 0; index < images.length; index++)
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: images[index].preview(size: 120),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (images.length < maxImages)
                                    _HoverLift(
                                      liftScale: 1.04,
                                      borderRadius: BorderRadius.circular(14),
                                      child: GestureDetector(
                                        onTap: pickImages,
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            color: AppColors.primary.withOpacity(0.06),
                                            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                                          ),
                                          child: Icon(
                                            Icons.add_a_photo_outlined,
                                            color: AppColors.primary,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Up to $maxImages photos",
                                style: AppTextStyles.caption(context, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _sectionCard(
                          title: "Listing Details",
                          icon: Icons.sell_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final twoColumn = constraints.maxWidth > 600;
                                  final userTypeField = Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _fieldLabel("Posting As"),
                                      CustomDropdownField(
                                        hint: "Select user type",
                                        items: userTypes,
                                        selectedValue: selectedUserType,
                                        onChanged: (val) => setState(() => selectedUserType = val),
                                        fillColor: Colors.grey.shade100,
                                        borderColor: Colors.white,
                                      ),
                                    ],
                                  );
                                  final priceField = Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _fieldLabel("Price"),
                                      CustomTextField(
                                        hint: "Enter price",
                                        controller: priceController,
                                        keyboardType: TextInputType.number,
                                        fillColor: Colors.grey.shade100,
                                        borderColor: Colors.white,
                                      ),
                                    ],
                                  );
                                  if (!twoColumn) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        userTypeField,
                                        const SizedBox(height: 16),
                                        priceField,
                                      ],
                                    );
                                  }
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: userTypeField),
                                      const SizedBox(width: 20),
                                      Expanded(child: priceField),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              _fieldLabel("Message"),
                              CustomTextField(
                                hint: "Describe the item you're selling...",
                                controller: messageController,
                                maxLines: 4,
                                fillColor: Colors.grey.shade100,
                                borderColor: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => setState(() => negotiable = !negotiable),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Price is negotiable",
                                        style: AppTextStyles.caption(context, color: AppColors.black, fontWeight: FontWeight.w600),
                                      ),
                                      const Spacer(),
                                      Switch(
                                        value: negotiable,
                                        activeColor: AppColors.primary,
                                        onChanged: (val) => setState(() => negotiable = val),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _sectionCard(
                          title: "Contact Information",
                          icon: Icons.call_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel("Mobile Number"),
                              SizedBox(
                                width: isDesktop ? 360 : double.infinity,
                                child: CustomTextField(
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
                                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                                      return "Enter a valid 10-digit mobile number";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),
                        Center(
                          child: _HoverLift(
                            liftScale: 1.03,
                            borderRadius: BorderRadius.circular(14),
                            child: ElevatedButton(
                              onPressed: _submitSalePost,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "Post Sale Instruments",
                                style: AppTextStyles.body(context, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
