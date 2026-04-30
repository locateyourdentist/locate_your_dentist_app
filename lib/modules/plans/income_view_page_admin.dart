import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class IncomeDashboardPage extends StatefulWidget {
  const IncomeDashboardPage({super.key});

  @override
  State<IncomeDashboardPage> createState() => _IncomeDashboardPageState();
}

class _IncomeDashboardPageState extends State<IncomeDashboardPage>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(PlanController());
  final loginController = Get.put(LoginController());
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  String? selectState;

  @override
  void initState() {
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
    await     controller.getIncomeDetailsByPlan( context: context);
    await loginController.fetchStates();
  }

  @override
  Widget build(BuildContext context) {
    double s=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text('Income Details',style: AppTextStyles.subtitle(context,color: AppColors.black),),
        automaticallyImplyLeading: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
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
      body: GetBuilder<PlanController>(
        builder: (_) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final income = controller.income;
          if (income == null) {
            return  Center(child: Text("No Data Found",style: AppTextStyles.caption(context),));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GetBuilder<LoginController>(
                  builder: (controller) {
                    final items=controller.states.map((d) => d.toString()).toList();
                    return CustomDropdown<String>.search(
                      hintText: "Select State",
                      decoration: CustomDropdownDecoration(
                        closedFillColor: Colors.grey[100],
                        expandedFillColor: Colors.white,
                        closedBorder: Border.all(
                          color: AppColors.white,
                          width: 1.5,
                        ),
                        expandedBorder: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        closedBorderRadius: BorderRadius.circular(10),
                        expandedBorderRadius: BorderRadius.circular(10),
                        hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                        headerStyle: AppTextStyles.caption(context, color: Colors.black),
                        listItemStyle: AppTextStyles.caption(context, color: Colors.black),),
                      items: controller.states.map((s) => s.toString()).toList(),
                      //initialItem: controller.selectedState,
                      initialItem: items.contains(controller.selectedState)
                          ? controller.selectedState
                          : null,
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedState = val;
                          controller.districts.clear();
                          controller.selectedDistrict = null;
                          controller.selectedTaluka = null;
                          controller.selectedVillage = null;
                          final state = controller.states.firstWhere((s) => s == val);
                          print('state  selected$state');
                          controller.fetchDistricts(state.toString());
                          controller.update();
                        }
                      },
                    );
                  },
                ),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                Expanded(
                  child: CustomTextField(
                    hint: "From Date",
                    controller: fromDateController,
                    fillColor: Colors.grey.shade100,
                    borderColor: AppColors.white,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2025),
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        fromDateController.text =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        toDateController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: CustomTextField(
                    hint: "To Date",
                    controller: toDateController,
                    fillColor:Colors.grey.shade100,
                    borderColor: AppColors.white,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2025),
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        toDateController.text =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        print('pick date${fromDateController.text}');
                        await  controller.getIncomeDetailsByPlan(fromDate: fromDateController.text,toDate: toDateController.text, context: context);

                      }
                    },
                  ),
                ),
              ]),
                const SizedBox(height: 10),

                _animatedTotalCard(income.total),
                const SizedBox(height: 20),

                // _incomeTile(
                //     "Poster Income", income.posterIncome, income.activeUsers.poster,context),
                // _incomeTile(
                //     "Base Plan Income", income.basePlanIncome, income.activeUsers.basePlan,context),
                // _incomeTile(
                //     "Add Ons Income", income.addOnsIncome, income.activeUsers.addOns,context),
                // _incomeTile(
                //     "Job Income", income.jobIncome, income.activeUsers.job,context),
                // _incomeTile(
                //     "Webinar Income", income.webinarIncome, income.activeUsers.webinar,context),
              _incomeTile(
                  "Poster Income",
                  income.posterIncome,
                  income.posterActiveUsers,
                  context
              ),

              _incomeTile(
              "Base Plan Income",
              income.basePlanIncome,
              income.basePlanActiveUsers,
              context
          ),

              _incomeTile(
              "Add Ons Income",
              income.addOnsIncome,
              income.addOnsActiveUsers,
              context
          ),

              _incomeTile(
              "Job Income",
              income.jobIncome,
              income.jobActiveUsers,
              context
          ),

            _incomeTile(
              "Webinar Income",
              income.webinarIncome,
              income.webinarActiveUsers,
              context
          )
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
Widget _animatedTotalCard(int total) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: total.toDouble()),
    duration: const Duration(seconds: 1),
    builder: (context, value, _) {
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
               Text("Total Income",
                style:  AppTextStyles.body(context,fontWeight: FontWeight.bold,color: AppColors.black),),
               const SizedBox(height: 10),
              Text(
                "₹ ${value.toInt()}",
                style:  AppTextStyles.body(context,fontWeight: FontWeight.bold,color: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    },
  );
}
Widget _incomeTile(String title, int amount, int users,dynamic context) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      boxShadow: [
        const BoxShadow(color: Colors.black12, blurRadius: 6),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:  AppTextStyles.subtitle(context,)),
            const SizedBox(height: 4),
            Text("Active Users: $users",
                style:  AppTextStyles.caption(context)),
          ],
        ),
        Text(
          "₹ $amount",
          style:  AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.primary),

        ),
      ],
    ),
  );
}
