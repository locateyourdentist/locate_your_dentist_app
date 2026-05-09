import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
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
    final userId = Get.arguments?['selectedUserId'] ?? Api.userInfo.read('userId');
    
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

  void _showUserTypeDialog() {
    final states = [
      "Dental Clinic",
      "Dental Lab",
      "Dental Shop",
      "Dental Mechanic",
      "Dental Consultant",
      "Job Seekers"
    ];
    String? tempSelectedState = planController.selectedUserType;

    showDialog(
      context: context,
      builder: (context) {
        double s = MediaQuery.of(context).size.width;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Select UserType", style: AppTextStyles.caption(context, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: s * 0.2,
            height: s * 0.23,
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return ListView(
                  children: states.map((state) {
                    return RadioListTile<String>(
                      title: Text(state,
                          style: AppTextStyles.caption(context,
                              fontWeight: FontWeight.bold,
                              color: tempSelectedState == state ? AppColors.primary : Colors.black)),
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
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: AppTextStyles.caption(context))),
            TextButton(
                onPressed: () {
                  setState(() {
                    planController.selectedUserType = tempSelectedState;
                  });
                  Navigator.pop(context);
                },
                child: Text("OK", style: AppTextStyles.caption(context))),
          ],
        );
      },
    );
  }

  Widget _modernFilterBox({required IconData icon, required String label, required VoidCallback onTap}) {
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
            Icon(icon, color: AppColors.primary, size: s * 0.012),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: AppTextStyles.caption(context, fontWeight: FontWeight.bold))),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: s * 0.012),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    
    bool isPosterActive = false;
    if (planController.checkPlanList.isNotEmpty) {
      final firstPlanDetails = planController.checkPlanList[0]["details"]?["plan"];
      isPosterActive = firstPlanDetails?["posterPlan"]?["isActive"] ?? false;
    }

    return Scaffold(
      key: _scaffoldKeyPlan,
      backgroundColor: AppColors.scaffoldBg,
      drawer: !isDesktop ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: Row(
        children: [
          if (isDesktop) const AdminSideBar(),
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
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                    ),
                    child: Stack(
                      children: [
                        if (!isDesktop)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () => _scaffoldKeyPlan.currentState?.openDrawer(),
                            ),
                          ),
                        DefaultTabController(
                          length: 5,
                          child: Column(
                            children: [
                              if (!isDesktop) const SizedBox(height: 40),
                              _buildPlanSelector(userType, context, width),
                              if (userType != "admin" && userType != "superAdmin" && selectedString == "Buy Plans")
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: BlinkingText(
                                    text: "Upgrade your Plan", 
                                    style: AppTextStyles.body(context, color: Colors.red, fontWeight: FontWeight.bold)
                                  ),
                                ),
                              if (isPosterActive && planController.editUploadImage.isNotEmpty && selectedString == "Buy Plans")
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: TextButton(
                                    onPressed: () => Get.toNamed('/createPostImages'),
                                    style: TextButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Scrolling Ads Pick Image', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              Expanded(
                                child: GetBuilder<PlanController>(
                                  builder: (controller) {
                                    if (controller.isLoading) {
                                      return _buildPlanShimmer(width);
                                    }
                                    if (selectedString == "Active Plans") {
                                      return SingleChildScrollView(child: PlanDetailsWidget(planList: controller.checkPlanList));
                                    } else {
                                      return _buildBuyPlans(userType, context, width, controller, isMobile);
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
    if (userType == "superAdmin" || userType == "admin") return const SizedBox.shrink();
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

  Widget _buildBuyPlans(String userType, BuildContext context, double s, PlanController controller, bool isMobile) {
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
                        label: planController.selectedUserType ?? "Select User Type",
                        onTap: _showUserTypeDialog,
                      ),
                      const SizedBox(height: 10),
                      gradientButton(
                        text: 'Create Plan',
                        height: 45,
                        onTap: () => Get.toNamed('/createPlanPageWeb', arguments: {'selectedString': "BasePlan"}),
                        context: context,
                      ),
                    ],
                  )
                : Row(
                  children: [
                    Text('Select UserType', style: AppTextStyles.caption(context, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 250,
                      child: _modernFilterBox(
                        icon: Icons.person_outline,
                        label: planController.selectedUserType ?? "Select User Type",
                        onTap: _showUserTypeDialog,
                      ),
                    ),
                    const Spacer(),
                    gradientButton(
                      text: 'Create Plan',
                      height: 40,
                      width: 120,
                      onTap: () => Get.toNamed('/createPlanPageWeb', arguments: {'selectedString': "BasePlan"}),
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
              _buildPlanList(controller.basePlanList, s),
              _buildPlanList(controller.addOnsPlanList, s),
              _buildPlanList(controller.jobPlanList, s),
              _buildPlanList(controller.webinarPlanList, s),
              _buildPlanList(controller.postImagePlanList, s),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanList(List plans, double s) {
    if (plans.isEmpty) return const Center(child: Text("No plans available"));
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
              String duration = "";
              List<String> features = [];

              if (plan is PlanModel) {
                name = plan.planName ?? "";
                price = plan.price ?? "0";
                duration = plan.duration ?? "0";
                features = plan.features ?? [];
              } else if (plan is AddOnsPlanModel) {
                name = plan.addOnsPlanName ?? "";
                price = plan.price ?? "0";
                duration = plan.duration ?? "0";
                features = plan.features ?? [];
              } else if (plan is JobPlanModel) {
                name = plan.jobPlanName ?? "";
                price = plan.price ?? "0";
                duration = plan.duration ?? "0";
                features = plan.features ?? [];
              } else if (plan is WebinarPlan) {
                name = plan.webinarPlanName;
                price = plan.price;
                duration = plan.duration;
                features = []; 
              } else if (plan is PostImagePlan) {
                name = plan.postPlanName ?? "";
                price = plan.price;
                duration = plan.duration;
                features = plan.features ?? [];
              }

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Container(
                      width: 320,
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTextStyles.body(context, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(height: 10),
                          Text("₹$price", style: AppTextStyles.subtitle(context,)),
                          Text("Duration: $duration days", style: AppTextStyles.caption(context, color: Colors.grey)),
                          const Divider(height: 30),
                          Expanded(
                            child: features.isNotEmpty
                                ? ListView(
                                    shrinkWrap: true,
                                    children: features.map<Widget>((f) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(f, style: AppTextStyles.caption(context))),
                                            ],
                                          ),
                                        )).toList(),
                                  )
                                : Center(child: Text("No features listed", style: AppTextStyles.caption(context, color: Colors.grey))),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              onPressed: () {},
                              child: const Text("Buy Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
}

class PlanDetailsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> planList;
  const PlanDetailsWidget({super.key, required this.planList});
  @override
  Widget build(BuildContext context) {
    if (planList.isEmpty) return const Center(child: Text("No plan details found"));
    final plans = planList.first["details"]?["plan"];
    if (plans == null) return const Center(child: Text("No plan data available"));
    
    return Column(
      children: [
        if (plans["basePlan"] != null) _planCard("Base Plan", plans["basePlan"], context),
        if (plans["jobPlan"] != null) _planCard("Job Plan", plans["jobPlan"], context),
        if (plans["webinarPlan"] != null) _planCard("Webinar Plan", plans["webinarPlan"], context),
        if (plans["posterPlan"] != null) _planCard("Poster Plan", plans["posterPlan"], context),
        if (plans["addonsPlan"] != null) _planCard("Add-ons Plan", plans["addonsPlan"], context),
      ],
    );
  }

  Widget _planCard(String title, Map<String, dynamic> plan, BuildContext context) {
    final bool isActive = plan["isActive"] == true;
    return Card(
      margin: const EdgeInsets.all(10),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isActive ? "Active" : "Expired", style: TextStyle(color: isActive ? Colors.green : Colors.red)),
        children: [
          ListTile(title: Text("Plan: ${plan["name"]}")),
          ListTile(title: Text("Valid until: ${plan["endDate"]}")),
        ],
      ),
    );
  }
}
