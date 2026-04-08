import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import '../../common_widgets/color_code.dart';

class ReportsDashboardPage extends StatefulWidget {
  const ReportsDashboardPage({super.key});

  @override
  State<ReportsDashboardPage> createState() => _ReportsDashboardPageState();
}
class _ReportsDashboardPageState extends State<ReportsDashboardPage> {
  final PlanController controller = Get.put(PlanController());
  String selectedYear = DateTime.now().year.toString();
  @override
  void initState() {
    super.initState();
    controller.getIncomeDetailsByPlan(context: context);
    controller.getExpense(month: "", year: selectedYear);
  }
  Future<void> _refresh() async {
    controller.getIncomeDetailsByPlan(context: context);
    controller.getExpense(month: "", year: selectedYear);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          'Report Details',
          style: AppTextStyles.subtitle(context, color: AppColors.black),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
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
      body: GetBuilder<PlanController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Total Income",
                          style: AppTextStyles.body(
                              context,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "\₹ ${controller.income?.total.toStringAsFixed(2) ?? 0}",
                          style: AppTextStyles.body(
                              context,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Total Expenses",
                          style: AppTextStyles.subtitle(
                              context,
                              color: AppColors.white,
                            ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "\₹ ${controller.total.toStringAsFixed(2)}",
                          style: AppTextStyles.caption(
                              context,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    children: [
                      _metricCard(
                        title: "Income",
                        value:
                        "\₹ ${controller.income?.total.toStringAsFixed(2)}",
                        color: Colors.green,
                        onTap: () => Get.toNamed('/viewIncomePage'),
                      ),
                      _metricCard(
                        title: "Expenses",
                        value: "\₹ ${controller.total.toStringAsFixed(2)}",
                        color: Colors.red,
                        onTap: () => Get.toNamed('/viewExpensePage'),
                      ),
                      _metricCard(
                        title: "New Users",
                        value: "30",
                         //controller.newUsers,
                        color: Colors.blue,
                        onTap: () => Get.toNamed('/usersPage'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }

  Widget _metricCard(
      {required String title,
        required String value,
        required Color color,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTextStyles.caption(
                  Get.context!, color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.caption(
                  Get.context!, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}