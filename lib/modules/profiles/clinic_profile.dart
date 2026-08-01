import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/common_widgets/watsapp_utils.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:locate_your_dentist/modules/profiles/view_profileImages.dart';
import '../../api/api.dart';
import '../../common_widgets/common_bottom_navigation.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_quill/flutter_quill.dart';

class Media {
  final String? url;
  final bool isVideo;

  Media({required this.url, this.isVideo = false});
}

class ClinicProfile extends StatefulWidget {
  const ClinicProfile({super.key});
  @override
  State<ClinicProfile> createState() => _ClinicProfileState();
}

class _ClinicProfileState extends State<ClinicProfile>
    with SingleTickerProviderStateMixin {
  final loginController = Get.put(LoginController());
  String imgUrl = "";
  dynamic planActive;
  late TabController _tabController1;
  final userType = Api.userInfo.read('userType')?.toString() ?? "";
  final serviceController = Get.put(ServiceController());
  final ScrollController _scrollController = ScrollController();
  late QuillController _controller;
  void loadJobDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [];

      if (data == null ||
          data.toString().trim().isEmpty ||
          data.toString() == "[]") {
        delta = [
          {"insert": "\n"},
        ];
      } else if (data is List) {
        delta = data.isEmpty
            ? [
                {"insert": "\n"},
              ]
            : List<Map<String, dynamic>>.from(data);
      } else if (data is String) {
        final decoded = jsonDecode(data);

        if (decoded is List && decoded.isNotEmpty) {
          delta = List<Map<String, dynamic>>.from(decoded);
        } else {
          delta = [
            {"insert": "\n"},
          ];
        }
      }

      _controller = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );

      if (mounted) setState(() {});
    } catch (e) {
      print("Quill load error: $e");

      _controller = QuillController(
        document: Document.fromJson([
          {"insert": "\n"},
        ]),
        selection: const TextSelection.collapsed(offset: 0),
      );

      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController1 = TabController(
      length: userType == 'superAdmin' ? 2 : 1,
      vsync: this,
    );
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  bool getPlanActive() {
    final userData = loginController.userData;
    if (userData.isEmpty) return false;
    final raw = userData.first.details["plan"]?["basePlan"]?["isActive"] ?? "";
    return raw == true || raw == "true";
  }

  void _loadPlanStatus() async {
    planActive = getPlanActive();
    print('planStatus $planActive');
  }

  Future<void> _refresh() async {
    _loadPlanStatus();
    await serviceController.getServiceListAdmin(
      Api.userInfo.read('selectUId') ?? "",
      context,
    );
    await loginController.getProfileByUserId(
      Api.userInfo.read('selectUId') ?? "",
      context,
    );
    loadJobDescription(loginController.descriptionData);
  }

  @override
  void dispose() {
    _tabController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final planActive = getPlanActive();
    String userType = Api.userInfo.read('userType') ?? "";
    String userId = Api.userInfo.read('userId') ?? "";
    String editUserId = loginController.userData.isNotEmpty
        ? loginController.userData.first.userId.toString()
        : "";
    print('userIdfds$editUserId');
    final user = loginController.userData.isNotEmpty
        ? loginController.userData.first
        : null;
    final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
    Future<void> refresh() async {
      _tabController1 = TabController(
        length: (userType == 'superAdmin' || userType == 'admin') ? 2 : 1,
        vsync: this,
      );
      await serviceController.getServiceListAdmin(
        loginController.userData.isNotEmpty
            ? loginController.userData.first.userId.toString()
            : "",
        context,
      );
      await loginController.getProfileByUserId(
        Api.userInfo.read('selectUId') ?? "",
        context,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: GetBuilder<LoginController>(
        init: LoginController(),
        builder: (controller) {
          print("Final images list: ${loginController.editImages}");
          return RefreshIndicator(
            onRefresh: refresh,
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (loginController.userData.isEmpty)
                      //Center(child: Text('No data found',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),),
                      // if (loginController.isLoading)
                      Column(
                        children: [
                          shimmerBox(height: size * 0.35, radius: 0),

                          SizedBox(height: size * 0.02),

                          shimmerBox(height: 20, width: size * 0.5),

                          SizedBox(height: 10),

                          shimmerBox(height: 16, width: size * 0.3),

                          SizedBox(height: size * 0.03),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              shimmerBox(height: 50, width: 90),
                              shimmerBox(height: 50, width: 90),
                              shimmerBox(height: 50, width: 90),
                            ],
                          ),

                          SizedBox(height: size * 0.03),

                          ListView.builder(
                            itemCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (_, index) {
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: shimmerBox(
                                  height: size * 0.25,
                                  radius: 12,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    //if(loginController.isLoading)
                    //const CircularProgressIndicator(color: AppColors.primary,),
                    if (loginController.userData.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              // MediaCarousel(
                              //   images: loginController.editImages
                              //       .where((img) =>
                              //   img.url != null &&
                              //       img.url!.startsWith('http') &&
                              //       !img.url!.contains('undefined'))
                              //       .toList(),
                              // ),
                              if ((planActive == true &&
                                      user?.details["plan"]?["basePlan"]?["details"]?["images"] ==
                                          true) ||
                                  isAdminUser ||
                                  userId == editUserId)
                                MediaCarousel(
                                  images: loginController.editImages
                                      .where(
                                        (img) =>
                                            img.url != null &&
                                            img.url!.startsWith('http') &&
                                            !img.url!.contains('undefined'),
                                      )
                                      .toList(),
                                )
                              else
                                Container(
                                  color: Colors.grey[200],
                                  width: double.infinity,
                                  height: 220,
                                  child: Icon(Icons.image, size: 15),
                                ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Material(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => Get.back(),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (userType == 'admin' ||
                                  userType == 'superAdmin' ||
                                  userId == editUserId)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.toNamed('/clinicEditProfile');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "Edit",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Transform.translate(
                            offset: const Offset(0, -24),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                20,
                                18,
                                16,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          user?.userType ?? "",
                                          style: AppTextStyles.caption(
                                            context,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (userType == 'superAdmin' ||
                                          userType == 'admin')
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                (user?.isActive == true
                                                        ? Colors.green
                                                        : Colors.redAccent)
                                                    .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            user?.isActive == true
                                                ? 'Active'
                                                : 'Inactive',
                                            style: TextStyle(
                                              color: user?.isActive == true
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: size * 0.03,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: size * 0.01),
                                  if (isAdminUser)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Active/Inactive",
                                              style: AppTextStyles.caption(
                                                context,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          GetBuilder<LoginController>(
                                            init: LoginController(),
                                            builder: (controller) {
                                              return Switch(
                                                value: user?.isActive == true,
                                                activeThumbColor:
                                                    user?.isActive == true
                                                    ? Colors.green
                                                    : Colors.red,
                                                activeTrackColor: AppColors
                                                    .primary
                                                    .withValues(alpha: 0.5),
                                                inactiveThumbColor: Colors.red,
                                                inactiveTrackColor:
                                                    Colors.grey.shade400,
                                                onChanged: (value) {
                                                  showDeactivateConfirmDialog(
                                                    context: context,
                                                    isActivating: value,
                                                    onConfirm: () async {
                                                      user?.isActive == true
                                                          ? await loginController
                                                                .deactivateUserAdmin(
                                                                  user?.userId ??
                                                                      "",
                                                                  false,
                                                                  context,
                                                                )
                                                          : await loginController
                                                                .deactivateUserAdmin(
                                                                  user?.userId ??
                                                                      "",
                                                                  true,
                                                                  context,
                                                                );
                                                      print(
                                                        "${loginController.userData.first.isActive ?? ""} "
                                                        "active status",
                                                      );
                                                      // await loginController.getProfileByUserId(loginController.userData.first.userId??"", context);
                                                      loginController.update();
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: size * 0.01),
                                  Center(
                                    child: Text(
                                      (user?.details["name"] ?? "")
                                              .toString() ??
                                          "",
                                      // "Catchy Dental Clinic",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.subtitle(context),
                                    ),
                                  ),
                                  SizedBox(height: size * 0.005),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (loginController
                                                  .userData
                                                  .first
                                                  .location
                                                  .toString()
                                                  .isNotEmpty &&
                                              (planActive == true &&
                                                      user?.details["plan"]?["basePlan"]?["details"]?["location"] ==
                                                          true ||
                                                  isAdminUser ||
                                                  userId == editUserId)) {
                                            if (PlatformHelper.platform ==
                                                    'Android' ||
                                                PlatformHelper.platform ==
                                                    'iOS') {
                                              Get.toNamed(
                                                '/webViewProfilePage',
                                                arguments: {
                                                  "url":
                                                      loginController
                                                          .userData
                                                          .first
                                                          .location
                                                          .toString() ??
                                                      "",
                                                  "clinicName":
                                                      loginController
                                                          .userData
                                                          .first
                                                          .details["name"]
                                                          .toString() ??
                                                      "",
                                                },
                                              );
                                            }
                                          }
                                        },
                                        icon: Icon(
                                          Icons.place,
                                          color: AppColors.primary,
                                          size: size * 0.05,
                                        ),
                                      ),
                                      // Expanded(
                                      //   child: Text(
                                      //     loginController.userData.isNotEmpty && user?.address != null
                                      //         ? "${user?.address['addressLine1'] ?? ''}, ${user?.address['addressLine2'] ?? ''},"
                                      //         : "", maxLines: 2,
                                      //     overflow: TextOverflow.ellipsis,  style: const TextStyle(color: Colors.grey),
                                      //   ),
                                      // ),
                                      //SizedBox(height: size*0.01,),
                                      Expanded(
                                        child: Text(
                                          loginController.userData.isNotEmpty &&
                                                  user?.address != null
                                              ? "${user?.address['addressLine1'] ?? ''}, ${user?.address['addressLine2'] ?? ''},"
                                                    "${user?.address['state'] ?? ''}, ${user?.address['district'] ?? ''},${user?.address['city'] ?? ''}"
                                              : "",
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size * 0.02),

                                  if (loginController
                                      .userData
                                      .first
                                      .name
                                      .isNotEmpty)
                                    Center(
                                      child: Text(
                                        "Name: Dr.${user?.name.toString() ?? ""}",
                                        // "Catchy Dental Clinic",
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.caption(
                                          context,
                                          color: AppColors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: size * 0.02),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildActionButton(
                                        icon: Icons.chat_rounded,
                                        label: "WhatsApp",
                                        onTap: () async {
                                          final userData =
                                              loginController
                                                  .userData
                                                  .isNotEmpty
                                              ? loginController.userData.first
                                              : null;

                                          if (userData == null) return;

                                          final bool isMobileAllowed =
                                              userData
                                                  .details["plan"]?["basePlan"]?["details"]?["mobileNumber"] ==
                                              true;

                                          final bool isAdminUser =
                                              userType == 'admin' ||
                                              userType == 'superAdmin' ||
                                              userId == editUserId;

                                          final bool isMobilePlatform =
                                              PlatformHelper.platform ==
                                                  'Android' ||
                                              PlatformHelper.platform == 'iOS';

                                          if (!isMobilePlatform) return;
                                          if (!planActive) return;
                                          if (!isMobileAllowed && !isAdminUser)
                                            return;

                                          WhatsAppUtils.openWhatsApp(
                                            phoneNumber:
                                                userData.mobileNumber
                                                    .toString() ??
                                                '',
                                            message:
                                                "Hi Message From ${userData.details["name"] ?? ''}",
                                          );
                                        },
                                        context: context,
                                      ),

                                      buildActionButton(
                                        icon: Icons.language_rounded,
                                        label: "Website",
                                        onTap: () async {
                                          if ((planActive == true &&
                                                  user?.details["plan"]?["basePlan"]?["details"]?["location"] ==
                                                      true) ||
                                              isAdminUser ||
                                              userId == editUserId) {
                                            final website =
                                                user?.details["website"]
                                                    ?.toString() ??
                                                "";

                                            if (website.isEmpty) {
                                              showCustomToast(
                                                context,
                                                "Website not available",
                                                backgroundColor:
                                                    AppColors.secondary,
                                              );
                                              return;
                                            }

                                            Get.toNamed(
                                              '/webViewProfilePage',
                                              arguments: {
                                                "url": website,
                                                "clinicName":
                                                    user?.details["name"]
                                                        ?.toString() ??
                                                    "",
                                              },
                                            );
                                          }
                                        },
                                        context: context,
                                      ),

                                      /// Call
                                      buildActionButton(
                                        icon: Icons.call_rounded,
                                        label: "Call",
                                        onTap: () {
                                          if ((planActive == true &&
                                                  user?.details["plan"]?["basePlan"]?["details"]?["mobileNumber"] ==
                                                      true) ||
                                              isAdminUser ||
                                              userId == editUserId) {
                                            launchCall(
                                              user?.mobileNumber.toString() ??
                                                  "",
                                            );
                                          }
                                        },
                                        context: context,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size * 0.02),
                                  if (loginController.userData.isNotEmpty &&
                                      user?.details["description"] != null)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Description",
                                            style: AppTextStyles.caption(
                                              context,
                                              color: AppColors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          IgnorePointer(
                                            child: QuillEditor(
                                              controller: _controller,
                                              scrollController:
                                                  _scrollController,
                                              focusNode: FocusNode(),
                                              config: const QuillEditorConfig(
                                                showCursor: false,
                                                expands: false,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: size * 0.05),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: TabBar(
                                      controller: _tabController1,
                                      indicator: BoxDecoration(
                                        borderRadius: BorderRadius.circular(26),
                                        color: AppColors.primary,
                                      ),
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      dividerColor: Colors.transparent,
                                      labelColor: Colors.white,
                                      unselectedLabelColor:
                                          Colors.grey.shade600,
                                      labelStyle: AppTextStyles.caption(
                                        context,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      unselectedLabelStyle:
                                          AppTextStyles.caption(
                                            context,
                                            fontWeight: FontWeight.normal,
                                          ),
                                      tabs: [
                                        const Tab(text: 'Our Services'),
                                        if (userType == 'superAdmin' ||
                                            userType == 'admin')
                                          const Tab(text: 'Certificate'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.8,
                                    child: GetBuilder<ServiceController>(
                                      builder: (controller) {
                                        return TabBarView(
                                          controller: _tabController1,
                                          children: [
                                            // if(serviceController.serviceList.isNotEmpty&&planActive==true&&loginController.userData.first.details["plan"]?["basePlan"]?["details"]["services"]==true|| isAdminUser||userId==editUserId)
                                            //    if (serviceController.serviceList.isNotEmpty && (
                                            //        planActive == true && loginController.userData.first.details["plan"]?["basePlan"]?["details"]["services"] == true ||
                                            //            isAdminUser == true || userId == editUserId))
                                            ListView(
                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                //Text('Services',style: AppTextStyles.body(context,fontWeight: FontWeight.bold),),
                                                GetBuilder<ServiceController>(
                                                  builder: (controller) {
                                                    return Column(
                                                      children: [
                                                        SizedBox(
                                                          height: size * 0.02,
                                                        ),

                                                        if (serviceController
                                                            .serviceList
                                                            .isEmpty)
                                                          Center(
                                                            child: Center(
                                                              child: Text(
                                                                'No services found',
                                                                style: AppTextStyles.caption(
                                                                  context,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        if (serviceController
                                                                .serviceList
                                                                .isNotEmpty &&
                                                            ((planActive ==
                                                                        true &&
                                                                    user?.details["plan"]?["basePlan"]?["details"]["services"] ==
                                                                        true) ||
                                                                isAdminUser ==
                                                                    true ||
                                                                userId ==
                                                                    editUserId))
                                                          if (serviceController
                                                              .isLoading)
                                                            const Center(
                                                              child: CircularProgressIndicator(
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                            ),

                                                        if (serviceController
                                                            .serviceList
                                                            .isNotEmpty)
                                                          AnimationLimiter(
                                                            child: ListView.builder(
                                                              itemCount:
                                                                  serviceController
                                                                      .serviceList
                                                                      .length,
                                                              shrinkWrap: true,
                                                              physics:
                                                                  const NeverScrollableScrollPhysics(),
                                                              itemBuilder:
                                                                  (
                                                                    BuildContext
                                                                    context,
                                                                    int index,
                                                                  ) {
                                                                    final service =
                                                                        serviceController
                                                                            .serviceList[index];
                                                                    print(
                                                                      service.image
                                                                              .toString() ??
                                                                          "",
                                                                    );
                                                                    if (service.image !=
                                                                            null &&
                                                                        service
                                                                            .image!
                                                                            .isNotEmpty) {
                                                                      // imgUrl = AppConstants.baseUrl + service.image!.first.replaceAll("\\", "/");
                                                                      imgUrl = service
                                                                          .image!
                                                                          .first
                                                                          .replaceAll(
                                                                            "\\",
                                                                            "/",
                                                                          );
                                                                    }
                                                                    return AnimationConfiguration.staggeredList(
                                                                      position:
                                                                          index,
                                                                      duration: const Duration(
                                                                        milliseconds:
                                                                            1300,
                                                                      ),
                                                                      child: SlideAnimation(
                                                                        verticalOffset:
                                                                            120.0,
                                                                        curve: Curves
                                                                            .easeOutBack,
                                                                        child: FadeInAnimation(
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.all(
                                                                              10.0,
                                                                            ),
                                                                            child: Container(
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                borderRadius: BorderRadius.circular(
                                                                                  14,
                                                                                ),
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors.black.withValues(
                                                                                      alpha: 0.05,
                                                                                    ),
                                                                                    blurRadius: 10,
                                                                                    offset: const Offset(
                                                                                      0,
                                                                                      4,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              height:
                                                                                  size *
                                                                                  0.31,
                                                                              width: double.infinity,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.all(
                                                                                  8.0,
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Text(
                                                                                            service.serviceTitle.toString() ??
                                                                                                "",
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            maxLines: 2,
                                                                                            style: AppTextStyles.body(
                                                                                              context,
                                                                                              fontWeight: FontWeight.bold,
                                                                                              color: AppColors.black,
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            "Price Starts from ₹ ${service.serviceCost.toString() ?? ""}",
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: AppTextStyles.caption(
                                                                                              context,
                                                                                              color: AppColors.grey,
                                                                                            ),
                                                                                          ),
                                                                                          Center(
                                                                                            child: IconButton(
                                                                                              onPressed: () {
                                                                                                serviceController.getServiceDetailAdmin(
                                                                                                  service.serviceId.toString() ??
                                                                                                      "",
                                                                                                  context,
                                                                                                );
                                                                                                Get.toNamed(
                                                                                                  '/viewServicePage',
                                                                                                  arguments: {
                                                                                                    "serviceId":
                                                                                                        service.serviceId.toString() ??
                                                                                                        "",
                                                                                                  },
                                                                                                );
                                                                                              },
                                                                                              icon: Icon(
                                                                                                Icons.arrow_forward,
                                                                                                color: Colors.black54,
                                                                                                size:
                                                                                                    size *
                                                                                                    0.07,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 10,
                                                                                    ),

                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(
                                                                                        8,
                                                                                      ),
                                                                                      child: Image.network(
                                                                                        imgUrl,
                                                                                        fit: BoxFit.cover,
                                                                                        height:
                                                                                            size *
                                                                                            0.18,
                                                                                        width:
                                                                                            size *
                                                                                            0.18,
                                                                                        errorBuilder:
                                                                                            (
                                                                                              context,
                                                                                              error,
                                                                                              stackTrace,
                                                                                            ) {
                                                                                              return Container(
                                                                                                height:
                                                                                                    size *
                                                                                                    0.18,
                                                                                                width:
                                                                                                    size *
                                                                                                    0.18,
                                                                                                decoration: BoxDecoration(
                                                                                                  color: const Color(
                                                                                                    0xFFF1F3F6,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius.circular(
                                                                                                    16,
                                                                                                  ),
                                                                                                ),
                                                                                                child: Icon(
                                                                                                  Icons.image_outlined,
                                                                                                  color: Colors.grey.shade400,
                                                                                                  size:
                                                                                                      size *
                                                                                                      0.08,
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            if (isAdminUser)
                                              GetBuilder<LoginController>(
                                                builder: (controller) {
                                                  return Column(
                                                    children: [
                                                      SizedBox(
                                                        height: size * 0.02,
                                                      ),
                                                      if (loginController
                                                          .editCertificates
                                                          .isEmpty)
                                                        Center(
                                                          child: Text(
                                                            'No data found',
                                                            style:
                                                                AppTextStyles.caption(
                                                                  context,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                          ),
                                                        ),
                                                      if (loginController
                                                          .isLoading)
                                                        const CircularProgressIndicator(
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      if (loginController
                                                          .editCertificates
                                                          .isNotEmpty)
                                                        AnimationLimiter(
                                                          child: ListView.builder(
                                                            itemCount:
                                                                loginController
                                                                    .editCertificates
                                                                    .length,
                                                            shrinkWrap: true,
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemBuilder:
                                                                (
                                                                  BuildContext
                                                                  context,
                                                                  int index,
                                                                ) {
                                                                  return AnimationConfiguration.staggeredList(
                                                                    position:
                                                                        index,
                                                                    duration: const Duration(
                                                                      milliseconds:
                                                                          1300,
                                                                    ),
                                                                    child: SlideAnimation(
                                                                      verticalOffset:
                                                                          120.0,
                                                                      curve: Curves
                                                                          .easeOutBack,
                                                                      child: FadeInAnimation(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(
                                                                            10.0,
                                                                          ),
                                                                          child: GestureDetector(
                                                                            onTap: () {
                                                                              Get.toNamed(
                                                                                '/viewImagePage',
                                                                                arguments: {
                                                                                  'url':
                                                                                      loginController.editCertificates[index].url ??
                                                                                      "",
                                                                                },
                                                                              );
                                                                              print(
                                                                                'fgf${loginController.editCertificates[index]}',
                                                                              );
                                                                            },
                                                                            child: Card(
                                                                              elevation: 2,
                                                                              // height: size * 0.65,
                                                                              // width: double.infinity,
                                                                              // decoration: BoxDecoration(
                                                                              //   borderRadius: BorderRadius.circular(30),),
                                                                              child: Column(
                                                                                children: [
                                                                                  Text(
                                                                                    "${loginController.userData.first.userType} Certificate",
                                                                                    //labProfile['address'].toString(),
                                                                                    // "Catchy Dental Clinic",
                                                                                    textAlign: TextAlign.center,
                                                                                    style: AppTextStyles.caption(
                                                                                      context,
                                                                                      color: AppColors.black,
                                                                                    ),
                                                                                  ),
                                                                                  ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      10,
                                                                                    ),
                                                                                    child: Image.network(
                                                                                      loginController.editCertificates[index].url ??
                                                                                          "",
                                                                                      fit: BoxFit.cover,
                                                                                      height:
                                                                                          size *
                                                                                          0.6,
                                                                                      width: double.infinity,
                                                                                      errorBuilder:
                                                                                          (
                                                                                            context,
                                                                                            error,
                                                                                            stackTrace,
                                                                                          ) => Container(
                                                                                            decoration: BoxDecoration(
                                                                                              border: Border.all(
                                                                                                color: AppColors.grey,
                                                                                                width: 0.6,
                                                                                              ),
                                                                                            ),
                                                                                            height:
                                                                                                size *
                                                                                                0.55,
                                                                                            width: double.infinity,
                                                                                            child: Center(
                                                                                              child: Icon(
                                                                                                Icons.image,
                                                                                                color: AppColors.grey,
                                                                                                size:
                                                                                                    size *
                                                                                                    0.09,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                },
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
