import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final PlanController controller = Get.put(PlanController());
  final LoginController loginController = Get.put(LoginController());

  String selectedMonthName = DateFormat.MMMM().format(DateTime.now());
  String selectedYear = DateTime.now().year.toString();
  String? selectedState = "Tamilnadu";
  String? monthNumber = DateTime.now().month.toString();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await loginController.fetchStates();
    await controller.getExpense(
      month: monthNumber,
      year: selectedYear,
      state: selectedState,
    );
  }
  Color _getCategoryColor(String? category) {
    switch (category) {
      case "Salary":
        return Colors.green.shade200;
      case "Transport":
        return Colors.orange.shade200;
      case "Recharge":
        return Colors.blue.shade200;
      case "Others":
      default:
        return Colors.grey.shade300;
    }
  }
  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case "Salary":
        return Icons.attach_money;
      case "Transport":
        return Icons.directions_car;
      case "Recharge":
        return Icons.phone_android;
      case "Others":
      default:
        return Icons.category;
    }
  }
  void _showStatePickerDialog() {
    final states = ["Tamilnadu", "Karnataka", "Andhra"];
    String? tempSelectedState = selectedState;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title:  Text(
            "Select State",
            style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 250, // adjust height as needed
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return ListView(
                  children: states.map((state) {
                    return RadioListTile<String>(
                      title: Text(
                        state,
                        style: TextStyle(
                          fontWeight: tempSelectedState == state
                              ? FontWeight.bold
                              : FontWeight.normal,
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
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedState = tempSelectedState;
                });

                controller.getExpense(
                  month: monthNumber,
                  year: selectedYear,
                  state: selectedState,
                );

                Navigator.pop(context); // Confirm
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        title:  Text("Expense Details",style: AppTextStyles.body(context,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              controller.titleController.clear();
              controller.amountController.clear();
              controller.categoryController.clear();
              Get.toNamed('/addExpensesPage');
            },
            icon:  Icon(Icons.add,color: AppColors.primary,size: size*0.09,),
          ),
        ],
      ),
      body: GetBuilder<PlanController>(
        builder: (_) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      height: size * 0.45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Total Expense",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹${controller.total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, 
                        children: [

                          // _modernFilterBox(
                          //   icon: Icons.location_on,
                          //   label: selectedState ?? "Select State",
                          //   onTap: _showStatePickerDialog,
                          // ),
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _modernFilterBox(
                                  icon: Icons.calendar_month,
                                  label: selectedMonthName,
                                  onTap: _showMonthPickerDialog,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _modernFilterBox(
                                  icon: Icons.date_range,
                                  label: selectedYear,
                                  onTap: _showYearPickerRadioDialog,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    controller.expenses.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No expenses found."),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      itemCount: controller.expenses.length,
                      itemBuilder: (context, index) {
                        final expense =
                        controller.expenses[index];
              
                        return Container(
                          margin:
                          const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade50,
                                Colors.grey.shade50,
                              ],
                            ),
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: _getCategoryColor(expense.category),
                                child: Icon(
                                  _getCategoryIcon(expense.category),
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.title,
                                      style: const TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.createdDate)}",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "₹${expense.amount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar:
      const CommonBottomNavigation(currentIndex: 0),
    );
  }
  Widget _modernFilterBox({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption(context,fontWeight: FontWeight.bold)
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  void _showMonthPickerDialog() {
    final months = List.generate(12, (index) => DateFormat.MMMM().format(DateTime(0, index + 1)));
    String? tempSelectedMonth = selectedMonthName; // temp selection
    String? tempMonthNumber = monthNumber;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title:  Text(
            "Select Month",
            style: AppTextStyles.caption(context,fontWeight: FontWeight.bold)
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return ListView(
                  children: months.asMap().entries.map((entry) {
                    int index = entry.key;
                    String monthName = entry.value;
                    return RadioListTile<String>(
                      title: Text(
                        monthName,
                        style: AppTextStyles.caption(
                          fontWeight: tempSelectedMonth == monthName
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: tempSelectedMonth == monthName
                              ? AppColors.primary
                              : Colors.black,context
                        ),
                      ),
                      value: monthName,
                      groupValue: tempSelectedMonth,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setStateDialog(() {
                          tempSelectedMonth = value;
                          tempMonthNumber = (index + 1).toString();
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedMonthName = tempSelectedMonth!;
                  monthNumber = tempMonthNumber;
                });

                controller.getExpense(
                  month: monthNumber,
                  year: selectedYear,
                  state: selectedState,
                );
                Navigator.pop(context); // Confirm
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
  void _showYearPickerRadioDialog() {
    final years = List.generate(10, (i) => DateTime.now().year - i); // last 10 years
    String? tempSelectedYear = selectedYear; // temporary selection

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title:  Text(
            "Select Year",
            style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.minPositive,
            height: 250,
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return ListView(
                  children: years.map((year) {
                    final yearStr = year.toString();
                    return RadioListTile<String>(
                      title: Text(
                        yearStr,
                        style: AppTextStyles.caption(
                          fontWeight: tempSelectedYear == yearStr
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: tempSelectedYear == yearStr
                              ? AppColors.primary
                              : Colors.black,context
                        ),
                      ),
                      value: yearStr,
                      groupValue: tempSelectedYear,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setStateDialog(() {
                          tempSelectedYear = value;
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedYear = tempSelectedYear!;
                });
                controller.getExpense(
                  month: monthNumber,
                  year: selectedYear,
                  state: selectedState,
                );
                Navigator.pop(context); // Confirm
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}