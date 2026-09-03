import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/plan_model.dart';
import 'package:locate_your_dentist/model/addOns_plan_model.dart';
import 'package:locate_your_dentist/model/jobPlan_model.dart';
import 'package:locate_your_dentist/model/webinarPlan_model.dart';
import 'package:locate_your_dentist/model/postImage_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../common_widgets/blinks_texts.dart';
import '../../common_widgets/color_code.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

/// Reads markPrice out of a raw plan `details` map.
///
/// Some older create-plan API calls saved markPrice as `{markPrice: markPrice}`
/// instead of `{'markPrice': markPrice}` (a map-literal bug), so the value ended
/// up as a self-referential key (e.g. `{"150": "150"}`) instead of under the
/// `markPrice` key. Falls back to detecting that shape for plans saved before
/// the bug was fixed.
String? _readMarkPrice(Map<String, dynamic>? details) {
  if (details == null) return null;
  if (details['markPrice'] != null) return details['markPrice'].toString();
  const knownKeys = {
    'state',
    'district',
    'city',
    'area',
    'postImageCount',
    'markPrice',
  };
  for (final entry in details.entries) {
    if (!knownKeys.contains(entry.key) &&
        entry.key == entry.value?.toString()) {
      return entry.key;
    }
  }
  return null;
}

class ViewPlanWeb extends StatefulWidget {
  const ViewPlanWeb({super.key});
  @override
  State<ViewPlanWeb> createState() => _ViewPlanWebState();
}

class _ViewPlanWebState extends State<ViewPlanWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKeyPlan = GlobalKey<ScaffoldState>();
  int? selectedIndex;
  String? selectedString;
  final PlanController planController = Get.put(PlanController());
  final LoginController loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    selectedIndex = 1;
    selectedString = "Buy Plans";
    _initData();
  }

  void _initData() async {
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    final userId =
        Get.arguments?['selectedUserId'] ?? Api.userInfo.read('userId');

    if (userType != "admin" && userType != "superAdmin") {
      await loadData(userType);
    } else {
      planController.selectedUserType = "Dental Clinic";
      await loadData(planController.selectedUserType);
    }

    if (!mounted) return;
    await planController.checkPlansStatus(userId, context);
  }

  Future<void> loadData(userType) async {
    if (!mounted) return;
    await planController.getBasePlanList(userType, context);
    if (!mounted) return;
    await planController.getAddOnPlansList(userType, context);
    if (!mounted) return;
    await planController.getJobPlansList(userType, context);
    if (!mounted) return;
    await planController.getWebinarPlansList(userType, context);
    if (!mounted) return;
    await planController.getPostImagePlanList(userType, context);
    if (!mounted) return;
    await loginController.getBranchDetails(context);
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

  void resetPlanFields() {
    planController.planNameController.clear();
    planController.priceController.clear();
    planController.durationDaysController.clear();
    planController.selectedUserType = "";
    planController.isStateWise = false;
    planController.isDistrictWise = false;
    planController.isCityWise = false;
    planController.isAreaWise = false;
    planController.selectedFeatures.clear();
    planController.isImageAndroid = false;
    planController.isLocationAndroid = false;
    planController.isMobileNumber = false;
    planController.isServices = false;
    planController.selectJobId = '';
  }

  void _showUserTypeDialog() {
    final types = [
      "Dental Clinic",
      "Dental Lab",
      "Dental Shop",
      "Dental Mechanic",
      "Dental Consultant",
      "Job Seekers",
    ];
    String? tempSelectedState = planController.selectedUserType;
    showDialog(
      context: context,
      builder: (context) {
        double s = MediaQuery.of(context).size.width;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Select UserType",
            style: AppTextStyles.caption(context, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: s * 0.2,
            height: s * 0.23,
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return ListView(
                  children: types.map((state) {
                    return RadioListTile<String>(
                      title: Text(
                        state,
                        style: AppTextStyles.caption(
                          context,
                          fontWeight: FontWeight.bold,
                          color: tempSelectedState == state
                              ? AppColors.primary
                              : Colors.black,
                        ),
                      ),
                      value: state,
                      groupValue: tempSelectedState,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setStateDialog(() {
                          tempSelectedState = value;
                        });
                        loadData(value);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: AppTextStyles.caption(context)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  planController.selectedUserType = tempSelectedState;
                });
                Navigator.pop(context);
              },
              child: Text("OK", style: AppTextStyles.caption(context)),
            ),
          ],
        );
      },
    );
  }

  Widget _modernFilterBox({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    double s = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: isDesktop(context) ? s * 0.012 : 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption(
                  context,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    final bool isDesktop = width >= 1100;
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    final bool isMobile = width < 700;

    bool isPosterActive = false;
    if (planController.checkPlanList.isNotEmpty) {
      final firstPlanDetails =
          planController.checkPlanList[0]["details"]?["plan"];
      isPosterActive = firstPlanDetails?["posterPlan"]?["isActive"] ?? false;
    }

    return Scaffold(
      key: _scaffoldKeyPlan,
      backgroundColor: AppColors.scaffoldBg,
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 10 : 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        if (!isDesktop)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () =>
                                  _scaffoldKeyPlan.currentState?.openDrawer(),
                            ),
                          ),
                        DefaultTabController(
                          length: 5,
                          child: Column(
                            children: [
                              if (!isDesktop) const SizedBox(height: 40),
                              _buildPlanSelector(userType, context, width),
                              if (userType != "admin" &&
                                  userType != "superAdmin" &&
                                  selectedString == "Buy Plans")
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: BlinkingText(
                                    text: "Upgrade your Plan",
                                    style: AppTextStyles.body(
                                      context,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (isPosterActive &&
                                  planController.editUploadImage.isNotEmpty &&
                                  selectedString == "Buy Plans")
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: TextButton(
                                    onPressed: () =>
                                        Get.toNamed('/createPostImages'),
                                    style: TextButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Scrolling Ads Pick Image',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: GetBuilder<PlanController>(
                                  builder: (controller) {
                                    if (controller.isLoading) {
                                      return _buildPlanShimmer(width);
                                    }
                                    if (selectedString == "Active Plans") {
                                      return SingleChildScrollView(
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            maxWidth: 700,
                                          ),

                                          child: PlanDetailsWidget(
                                            planList: controller.checkPlanList,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return _buildBuyPlans(
                                        userType,
                                        context,
                                        width,
                                        controller,
                                        isMobile,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildPlanShimmer(double s) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Center(
        child: SizedBox(
          height: 500,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) => Container(
              width: 320,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSelector(String userType, BuildContext context, double s) {
    if (userType == "superAdmin" || userType == "admin")
      return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio<String>(
          value: "Active Plans",
          groupValue: selectedString,
          onChanged: (value) => setState(() => selectedString = value),
        ),
        Text("Active Plans", style: AppTextStyles.caption(context)),
        Radio<String>(
          value: "Buy Plans",
          groupValue: selectedString,
          onChanged: (value) => setState(() => selectedString = value),
        ),
        const Text("Buy Plan"),
      ],
    );
  }

  Widget _buildBuyPlans(
    String userType,
    BuildContext context,
    double s,
    PlanController controller,
    bool isMobile,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              if (userType == "superAdmin" || userType == "admin")
                isMobile
                    ? Column(
                        children: [
                          _modernFilterBox(
                            icon: Icons.person_outline,
                            label:
                                planController.selectedUserType ??
                                "Select User Type",
                            onTap: _showUserTypeDialog,
                          ),
                          const SizedBox(height: 10),
                          gradientButton(
                            text: 'Create Plan',
                            height: 45,
                            onTap: () {
                              resetPlanFields();
                              Get.toNamed(
                                '/createPlanPageWeb',
                                arguments: {'selectedString': "BasePlan"},
                              );
                            },
                            context: context,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Text(
                            'Select UserType',
                            style: AppTextStyles.caption(
                              context,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 250,
                            child: _modernFilterBox(
                              icon: Icons.person_outline,
                              label:
                                  planController.selectedUserType ??
                                  "Select User Type",
                              onTap: _showUserTypeDialog,
                            ),
                          ),
                          const Spacer(),
                          gradientButton(
                            text: 'Create Plan',
                            height: 40,
                            width: 120,
                            onTap: () {
                              resetPlanFields();
                              Get.toNamed(
                                '/createPlanPageWeb',
                                arguments: {'selectedString': "BasePlan"},
                              );
                            },
                            context: context,
                          ),
                        ],
                      ),
              const SizedBox(height: 20),
              TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Base Plan'),
                  Tab(text: 'AddOns'),
                  Tab(text: 'Job Plan'),
                  Tab(text: 'Webinar Plan'),
                  Tab(text: 'Scrolling Ads'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              _buildPlanList(controller.basePlanList, "BasePlan"),
              _buildPlanList(controller.addOnsPlanList, "AddOnsPlan"),
              _buildPlanList(controller.jobPlanList, "JobPlan"),
              _buildPlanList(controller.webinarPlanList, "WebinarPlan"),
              _buildPlanList(controller.postImagePlanList, "PostImagePlan"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanList(List plans, String planType) {
    if (plans.isEmpty) return const Center(child: Text("No plans available"));
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    final userId = Api.userInfo.read('userId')?.toString() ?? "";
    return Center(
      child: SizedBox(
        height: 500,
        child: AnimationLimiter(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              String name = "";
              String price = "";
              String? markPrice;
              String duration = "";
              List<String> features = [];
              String planIdStr = "";

              if (plan is PlanModel) {
                name = plan.planName ?? "";
                price = plan.price ?? "0";
                markPrice = plan.details?.markPrice;
                duration = plan.duration ?? "0";
                features = plan.features ?? [];
                planIdStr = plan.planId?.toString() ?? "";
              } else if (plan is AddOnsPlanModel) {
                name = plan.addOnsPlanName ?? "";
                price = plan.price ?? "0";
                markPrice = plan.details?.markPrice;
                duration = plan.duration ?? "0";
                features = plan.features ?? [];
                planIdStr = plan.addOnsPlanId?.toString() ?? "";
              } else if (plan is JobPlanModel) {
                name = plan.jobPlanName ?? "";
                price = plan.price ?? "0";
                markPrice = plan.details?.markPrice;
                duration = plan.duration ?? "0";
                features = plan.features ?? [];
                planIdStr = plan.jobPlansId?.toString() ?? "";
              } else if (plan is WebinarPlan) {
                name = plan.webinarPlanName;
                price = plan.price;
                markPrice = _readMarkPrice(plan.details);
                duration = plan.duration;
                features = [];
                planIdStr = plan.webinarPlanId.toString();
              } else if (plan is PostImagePlan) {
                name = plan.postPlanName ?? "";
                price = plan.price;
                markPrice = _readMarkPrice(plan.details);
                duration = plan.duration;
                features = plan.features ?? [];
                planIdStr = plan.postImagesPlanId?.toString() ?? "";
              }

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Container(
                      width: 320,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.body(
                              context,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              if (markPrice != null && markPrice.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    "₹$markPrice",
                                    style:
                                        AppTextStyles.caption(
                                          context,
                                          color: Colors.grey,
                                        ).copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                  ),
                                ),
                              Text(
                                "₹$price",
                                style: AppTextStyles.subtitle(context),
                              ),
                            ],
                          ),
                          Text(
                            "Duration: $duration days",
                            style: AppTextStyles.caption(
                              context,
                              color: Colors.grey,
                            ),
                          ),
                          const Divider(height: 30),
                          Expanded(
                            child: features.isNotEmpty
                                ? ListView(
                                    shrinkWrap: true,
                                    children: features
                                        .map<Widget>(
                                          (f) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  size: 16,
                                                  color: Colors.green,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    f,
                                                    style:
                                                        AppTextStyles.caption(
                                                          context,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  )
                                : Center(
                                    child: Text(
                                      "No features listed",
                                      style: AppTextStyles.caption(
                                        context,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              onPressed: () {
                                if (userType == "superAdmin") {
                                  _onEditPlan(plan, planType);
                                } else if (userType != "admin") {
                                  _onBuyPlan(
                                    plan,
                                    planType,
                                    userId,
                                    name,
                                    price,
                                    duration,
                                    planIdStr,
                                  );
                                }
                              },
                              child: Text(
                                userType == "superAdmin"
                                    ? "Edit Plan"
                                    : "Buy Now",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onEditPlan(dynamic plan, String planType) {
    Map<String, dynamic> args = {'selectedString': planType};

    if (plan is PlanModel) {
      args.addAll({
        'planName': plan.planName,
        'planId': plan.planId,
        'price': plan.price,
        'duration': plan.duration,
        'details': {
          'images': plan.details?.images,
          'location': plan.details?.location,
          'mobileNumber': plan.details?.mobileNumber,
          'services': plan.details?.services,
          'video': plan.details?.video,
          'imageCount': plan.details?.imageCount,
          'imageSize': plan.details?.imageSize,
          'videoCount': plan.details?.videoCount,
          'videoSize': plan.details?.videoSize,
        },
        'features': plan.features,
        'userType': plan.userType,
      });
    } else if (plan is AddOnsPlanModel) {
      args.addAll({
        'addOnsPlanName': plan.addOnsPlanName,
        'addOnsId': plan.addOnsPlanId,
        'price': plan.price,
        'duration': plan.duration,
        'details': {
          'state': plan.details?.state,
          'district': plan.details?.district,
          'city': plan.details?.city,
          'area': plan.details?.area,
        },
        'features': plan.features,
        'userType': plan.userType,
      });
    } else if (plan is JobPlanModel) {
      args.addAll({
        'jobPlanName': plan.jobPlanName,
        'jobPlansId': plan.jobPlansId,
        'price': plan.price,
        'duration': plan.duration,
        'details': {
          'state': plan.details?.state,
          'district': plan.details?.district,
          'city': plan.details?.city,
          'area': plan.details?.area,
        },
        'features': plan.features,
        'userType': plan.userType,
      });
    } else if (plan is WebinarPlan) {
      args.addAll({
        'webinarPlanName': plan.webinarPlanName,
        'webinarPlanId': plan.webinarPlanId,
        'price': plan.price,
        'duration': plan.duration,
        'userType': plan.userType,
      });
    } else if (plan is PostImagePlan) {
      args.addAll({
        'postPlanName': plan.postPlanName,
        'postImagesPlanId': plan.postImagesPlanId,
        'price': plan.price,
        'duration': plan.duration,
        'userType': plan.userType,
        'details': plan.details ?? {},
      });
    }

    Get.toNamed('/createPlanPageWeb', arguments: args);
  }

  void _onBuyPlan(
    dynamic plan,
    String planType,
    String userId,
    String planName,
    String price,
    String duration,
    String planId,
  ) {
    var dates = calculatePlanDates(duration);
    String startDate = dates["startDate"].toString();
    String endDate = dates["endDate"].toString();
    double amount = double.tryParse(price) ?? 0.0;

    bool isActive = false;
    String warningMsg =
        "Your plan is already activated. If you proceed, your plan will be upgraded and the old plan will be automatically deactivated.";
    String currentPlanKey = "";

    if (planType == "BasePlan") {
      currentPlanKey = "basePlan";
    } else if (planType == "AddOnsPlan")
      currentPlanKey = "addonsPlan";
    else if (planType == "JobPlan")
      currentPlanKey = "jobPlan";
    else if (planType == "WebinarPlan")
      currentPlanKey = "webinarPlan";
    else if (planType == "PostImagePlan")
      currentPlanKey = "posterPlan";

    if (planController.checkPlanList.isNotEmpty) {
      final details = planController.checkPlanList[0]["details"]?["plan"];
      if (details != null && details[currentPlanKey] != null) {
        isActive = details[currentPlanKey]["isActive"] ?? false;
      }
    }

    bool isBaseActive = false;
    if (planController.checkPlanList.isNotEmpty) {
      isBaseActive =
          planController
              .checkPlanList[0]["details"]?["plan"]?["basePlan"]?["isActive"] ??
          false;
    }

    if (currentPlanKey != "basePlan" && !isBaseActive) {
      showSuccessDialog(
        context,
        title: "Alert",
        message: "Oops! Base plan not Activated. please activate base plan..",
      );
      return;
    }

    if (isActive) {
      showSuccessDialog(
        context,
        title: "Alert",
        message: warningMsg,
        onOkPressed: () {
          _navigateToPayment(
            userId,
            planId,
            startDate,
            endDate,
            amount,
            currentPlanKey,
            planType,
            planName,
          );
        },
      );
    } else {
      _navigateToPayment(
        userId,
        planId,
        startDate,
        endDate,
        amount,
        currentPlanKey,
        planType,
        planName,
      );
    }
  }

  void _navigateToPayment(
    String userId,
    String planId,
    String startDate,
    String endDate,
    double amount,
    String planKey,
    String planType,
    String planName,
  ) {
    Get.toNamed(
      '/paymentPageWeb',
      arguments: {
        'userId': userId,
        'planId': planId,
        'startDate': startDate,
        'endDate': endDate,
        'amount': amount,
        'name': planKey,
        'planType': planType,
        'planName': planName,
        'mobileNumber': Api.userInfo.read('mobileNumber') ?? "",
        'email': Api.userInfo.read('email') ?? "",
      },
    );
  }
}

class PlanDetailsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> planList;
  const PlanDetailsWidget({super.key, required this.planList});
  @override
  Widget build(BuildContext context) {
    if (planList.isEmpty)
      return const Center(child: Text("No plan details found"));
    final plans = planList.first["details"]?["plan"];
    if (plans == null)
      return const Center(child: Text("No plan data available"));

    final planCards = [
      if (plans["basePlan"] != null)
        _planCard("Base Plan", plans["basePlan"], context),
      if (plans["jobPlan"] != null)
        _planCard("Job Plan", plans["jobPlan"], context),
      if (plans["webinarPlan"] != null)
        _planCard("Webinar Plan", plans["webinarPlan"], context),
      if (plans["posterPlan"] != null)
        _planCard("Poster Plan", plans["posterPlan"], context),
      if (plans["addonsPlan"] != null)
        _planCard("Add-ons Plan", plans["addonsPlan"], context),
    ];

    return AnimationLimiter(
      child: Column(
        children: List.generate(planCards.length, (index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 700),
            child: SlideAnimation(
              verticalOffset: 80.0,
              curve: Curves.easeOutCubic,
              child: FadeInAnimation(child: planCards[index]),
            ),
          );
        }),
      ),
    );
  }

  Widget _planCard(
    String title,
    Map<String, dynamic> plan,
    BuildContext context,
  ) {
    final bool isActive = plan["isActive"] == true;
    String formatDate(String date) {
      if (date.isEmpty) return '';
      try {
        final parts = date.split('-');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final dateTime = DateTime(year, month, day);
        return DateFormat('MMM d, yyyy').format(dateTime);
      } catch (e) {
        return date;
      }
    }

    return Card(
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          isActive ? "Active" : "Expired",
          style: TextStyle(
            color: isActive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          _row("Plan Name", plan["name"], context),
          _row("Start Date", formatDate(plan["startDate"] ?? ""), context),
          _row("End Date", formatDate(plan["endDate"] ?? ""), context),
          if (plan["details"] != null && plan["details"] is Map)
            _features(Map<String, dynamic>.from(plan["details"])),
        ],
      ),
    );
  }

  Widget _row(String label, dynamic value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: AppTextStyles.caption(context, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: AppTextStyles.caption(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _features(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.entries.map((e) {
        if (e.value is! bool) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Icon(
                e.value == true ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: e.value == true ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(e.key),
            ],
          ),
        );
      }).toList(),
    );
  }
}
